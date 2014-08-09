//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "TRMWavetable.h"

#include <stdlib.h>
#include <math.h>

#import "TRMFIRFilter.h"

#ifdef GNUSTEP
#undef USE_VECLIB
#else
#define USE_VECLIB
#import <Accelerate/Accelerate.h>
#endif

//  Compile with oversampling or plain oscillator
#define OVERSAMPLING_OSCILLATOR   1

//  Glottal source oscillator table variables
#define TABLE_LENGTH              512
#define TABLE_MODULUS             (TABLE_LENGTH-1)

static double mod0(double value);

// Returns the modulus of 'value', keeping it in the range 0 -> TABLE_MODULUS.
static double mod0(double value)
{
    if (value > TABLE_MODULUS)
        value -= TABLE_LENGTH;

    return value;
}

@interface TRMWavetable ()
- (void)incrementPosition:(double)frequency;
@end

#pragma mark -

@implementation TRMWavetable
{
    TRMFIRFilter *m_FIRFilter;
    double *m_wavetable;
    
    int32_t m_tableDiv1;
    int32_t m_tableDiv2;
    double m_tnLength;
    double m_tnDelta;
    
    double m_basicIncrement;
    double m_currentPosition;
}

// Calculates the initial glottal pulse and stores it in the wavetable, for use in the oscillator.
- (id)initWithWaveform:(TRMWaveFormType)waveForm throttlePulse:(double)tp tnMin:(double)tnMin tnMax:(double)tnMax sampleRate:(double)sampleRate;
{
    if ((self = [super init])) {
        int32_t i, j;

        m_FIRFilter = [[TRMFIRFilter alloc] initWithBeta:FIR_BETA gamma:FIR_GAMMA cutoff:FIR_CUTOFF];
        
        //  Allocate memory for wavetable
        m_wavetable = (double *)calloc(TABLE_LENGTH, sizeof(double));
        if (m_wavetable == NULL) {
            fprintf(stderr, "Failed to allocate space for wavetable in TRMWavetableCreate.\n");
            [self release];
            return nil;
        }
        
        //  Calculate wave table parameters
        m_tableDiv1 = rint(TABLE_LENGTH * (tp / 100.0));
        m_tableDiv2 = rint(TABLE_LENGTH * ((tp + tnMax) / 100.0));
        m_tnLength = m_tableDiv2 - m_tableDiv1;
        m_tnDelta = rint(TABLE_LENGTH * ((tnMax - tnMin) / 100.0));
        m_basicIncrement = (double)TABLE_LENGTH / sampleRate;
        m_currentPosition = 0;
        
        //  Initialize the wavetable with either a glottal pulse or sine tone
        if (waveForm == TRMWaveFormType_Pulse) {
            //  Calculate rise portion of wave table
            for (i = 0; i < m_tableDiv1; i++) {
                double x = (double)i / (double)m_tableDiv1;
                double x2 = x * x;
                double x3 = x2 * x;
                m_wavetable[i] = (3.0 * x2) - (2.0 * x3);
            }
            
            //  Calculate fall portion of wave table
            for (i = m_tableDiv1, j = 0; i < m_tableDiv2; i++, j++) {
                double x = (double)j / m_tnLength;
                m_wavetable[i] = 1.0 - (x * x);
            }
            
            //  Set closed portion of wave table
            for (i = m_tableDiv2; i < TABLE_LENGTH; i++)
                m_wavetable[i] = 0.0;
        } else {
            //  Sine wave
            for (i = 0; i < TABLE_LENGTH; i++) {
                m_wavetable[i] = sin( ((double)i / (double)TABLE_LENGTH) * 2.0 * M_PI );
            }
        }
    }

    return self;
}

- (void)dealloc;
{
    [m_FIRFilter release];

    if (m_wavetable != NULL) {
        free(m_wavetable);
        m_wavetable = NULL;
    }

    [super dealloc];
}

// Rewrites the changeable part of the glottal pulse according to the amplitude.
- (void)update:(double)amplitude;
{
    int i;

    //  Calculate new closure point, based on amplitude
    double newDiv2 = m_tableDiv2 - rint(amplitude * m_tnDelta);
    double newTnLength = newDiv2 - m_tableDiv1;
    double j;

    //  Recalculate the falling portion of the glottal pulse
#ifdef USE_VECLIB
    {
        double aj[TABLE_LENGTH], ajj[TABLE_LENGTH], one[TABLE_LENGTH];
        double scale = 1.0 / (newTnLength * newTnLength);
        int32_t len;

        len = newTnLength;
        for (i = 0, j = 0.0; i < len; i++, j += 1.0) {
            aj[i] = j;
            one[i] = 1.0;
        }

        vDSP_vsqD(aj, 1, ajj, 1, len);
        vDSP_vsmulD(ajj, 1, &scale, aj, 1, len);
        vDSP_vsubD(aj, 1, one, 1, &(m_wavetable[m_tableDiv1]), 1, len); // The docs seem to be wrong about which one gets subtracted...
    }
#else
    {
        for (i = wavetable->tableDiv1, j = 0.0; i < newDiv2; i++, j++) {
            double x = j / newTnLength;
            wavetable->wavetable[i] = 1.0 - (x * x);
        }
    }

#endif

    //  Fill in with closed portion of glottal pulse
#if 1
    for (i = newDiv2; i < m_tableDiv2; i++)
        m_wavetable[i] = 0.0;
#else
    i = newDiv2;
    if (wavetable->tableDiv2 > i)
        memset(&(wavetable[i]), 0, (wavetable->tableDiv2 - i) * sizeof(double)); // This seems to be crashy... possibly with 0 sizes?
#endif
}

// Increments the position in the wavetable according to the desired frequency.
- (void)incrementPosition:(double)frequency;
{
    m_currentPosition = mod0(m_currentPosition + (frequency * m_basicIncrement));
}

// A 2X oversampling interpolating wavetable oscillator.

#if OVERSAMPLING_OSCILLATOR
//  2X oversampling oscillator
- (double)oscillator:(double)frequency;  
{
    double output;

    for (NSUInteger index = 0; index < 2; index++) {
        //  First increment the table position, depending on frequency
        [self incrementPosition:frequency / 2.0];

        //  Find surrounding integer table positions
        int32_t lowerPosition = m_currentPosition;
        int32_t upperPosition = mod0(lowerPosition + 1);

        //  Calculate interpolated table value
        double interpolatedValue = (m_wavetable[lowerPosition] + ((m_currentPosition - lowerPosition) * (m_wavetable[upperPosition] - m_wavetable[lowerPosition])));

        //  Put value through FIR filter
        output = [m_FIRFilter filterInput:interpolatedValue needOutput:(index == 1)];
    }

    //  Since we decimate, take only the second output value
    return output;
}
#else

static void TRMWavetableIncrementPosition(TRMWavetable *wavetable, double frequency);

//  Plain oscillator
- (double)oscillator:(double)frequency;
{
    //  First increment the table position, depending on frequency
    TRMWavetableIncrementPosition(wavetable, frequency);

    //  Find surrounding integer table positions
    int32_t lowerPosition = wavetable->currentPosition;
    int3@_t upperPosition = mod0(lowerPosition + 1);

    //  Return interpolated table value
    return (wavetable->wavetable[lowerPosition]
            + ((wavetable->currentPosition - lowerPosition) * (wavetable->wavetable[upperPosition] - wavetable->wavetable[lowerPosition])));
}
#endif

@end


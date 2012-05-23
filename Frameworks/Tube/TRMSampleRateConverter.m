//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "TRMSampleRateConverter.h"

#import "TRMRingBuffer.h"
#import "util.h"


// Sample Rate Conversion Constants
#define ZERO_CROSSINGS            13                           // Source cutoff frequency
#define LP_CUTOFF                 (11.0/13.0)                  // 0.846 of Nyquist

#define N_BITS                    16
#define L_BITS                    8
#define L_RANGE                   256                          // must be 2^L_BITS
#define M_BITS                    8
#define M_RANGE                   256                          // must be 2^M_BITS
#define FRACTION_BITS             (L_BITS + M_BITS)
#define FRACTION_RANGE            65536                        // must be 2^FRACTION_BITS
#define FILTER_LENGTH             (ZERO_CROSSINGS * L_RANGE)
#define FILTER_LIMIT              (FILTER_LENGTH - 1)

#define N_MASK                    0xFFFF0000
#define L_MASK                    0x0000FF00
#define M_MASK                    0x000000FF
#define FRACTION_MASK             0x0000FFFF

#define nValue(x)                 (((x) & N_MASK) >> FRACTION_BITS)
#define lValue(x)                 (((x) & L_MASK) >> M_BITS)
#define mValue(x)                 ((x) & M_MASK)
#define fractionValue(x)          ((x) & FRACTION_MASK)

#define OUTPUT_SRATE_LOW          22050.0
#define OUTPUT_SRATE_HIGH         44100.0

#define BETA                      5.658        // Kaiser window parameters

@interface TRMSampleRateConverter () <TRMRingBufferDelegate>
- (void)_initializeFilter;

@property (assign) double sampleRateRatio;
@property (assign) uint32_t timeRegisterIncrement;
@property (assign) uint32_t filterIncrement;
@property (assign) uint32_t phaseIncrement;
@property (assign) uint32_t timeRegister;

@end

#pragma mark -

@implementation TRMSampleRateConverter
{
    double m_sampleRateRatio;
    double m_h[FILTER_LENGTH];
    double m_deltaH[FILTER_LENGTH];
    uint32_t m_timeRegisterIncrement;
    uint32_t m_filterIncrement;
    uint32_t m_phaseIncrement;
    uint32_t m_timeRegister;
    
    // Temporary sample storage values
    double m_maximumSampleValue;
    int32_t m_numberSamples;
    FILE *m_tempFilePtr;

    TRMRingBuffer *m_ringBuffer;
}

- (id)initWithInputRate:(double)inputRate outputRate:(double)outputRate;
{
    if ((self = [super init])) {
        m_timeRegister = 0;
        m_maximumSampleValue = 0.0;
        m_numberSamples = 0;
        
        // Initialize filter impulse response
        [self _initializeFilter];
        
        // Calculate sample rate ratio
        m_sampleRateRatio = outputRate / inputRate;
        
        // Calculate time register increment
        m_timeRegisterIncrement = (int)rint(pow(2.0, FRACTION_BITS) / m_sampleRateRatio);
        
        // Calculate rounded sample rate ratio
        double roundedSampleRateRatio = pow(2.0, FRACTION_BITS) / (double)m_timeRegisterIncrement;
        
        // Calculate phase or filter increment
        if (m_sampleRateRatio >= 1.0) {
            m_filterIncrement = L_RANGE;
        } else {
            m_phaseIncrement = (uint32_t)rint(m_sampleRateRatio * (double)FRACTION_RANGE);
        }
        
        // Calculate pad size
        int32_t padSize = (m_sampleRateRatio >= 1.0) ? ZERO_CROSSINGS : (int32_t)((float)ZERO_CROSSINGS / roundedSampleRateRatio) + 1;
        
        m_ringBuffer = [[TRMRingBuffer alloc] initWithPadSize:padSize];
        m_ringBuffer.delegate = self;
        
        // Initialize the temporary output file
        m_tempFilePtr = tmpfile();
    }

    return self;
}

// Initializes filter impulse response and impulse delta values.

- (void)_initializeFilter;
{
    // Initialize the filter impulse response
    m_h[0] = LP_CUTOFF;
    double x = M_PI / (double)L_RANGE;
    for (NSUInteger index = 1; index < FILTER_LENGTH; index++) {
        double y = (double)index * x;
        m_h[index] = sin(y * LP_CUTOFF) / y;
    }
    
    // Apply a Kaiser window to the impulse response
    double IBeta = 1.0 / Izero(BETA);
    for (NSUInteger index = 0; index < FILTER_LENGTH; index++) {
        double temp = (double)index / FILTER_LENGTH;
        m_h[index] *= Izero(BETA * sqrt(1.0 - (temp * temp))) * IBeta;
    }
    
    // Initialize the filter impulse response delta values
    for (NSUInteger index = 0; index < FILTER_LIMIT; index++)
        m_deltaH[index] = m_h[index+1] - m_h[index];
    m_deltaH[FILTER_LIMIT] = 0.0 - m_h[FILTER_LIMIT];
}

- (void)dealloc;
{
    [m_ringBuffer release];
    fclose(m_tempFilePtr);

    [super dealloc];
}

#pragma mark -

@synthesize sampleRateRatio = m_sampleRateRatio;
@synthesize timeRegisterIncrement = m_timeRegisterIncrement;
@synthesize filterIncrement = m_filterIncrement;
@synthesize phaseIncrement = m_phaseIncrement;
@synthesize timeRegister = m_timeRegister;
@synthesize maximumSampleValue = m_maximumSampleValue;
@synthesize numberSamples = m_numberSamples;
@synthesize tempFilePtr = m_tempFilePtr;

- (double *)h;
{
    return m_h;
}

- (double *)deltaH;
{
    return m_deltaH;
}

#pragma mark - TRMRingBufferDelegate

// Converts available portion of the input signal to the new sampling
// rate, and outputs the samples to the sound struct.

- (void)processDataFromRingBuffer:(TRMRingBuffer *)ringBuffer;
{
    int32_t endPtr;
    
    // Calculate end pointer
    endPtr = ringBuffer.fillPtr - ringBuffer.padSize;
    
    // Adjust the end pointer, if less than zero
    if (endPtr < 0)
        endPtr += TRMRingBufferSize;
    
    // Adjust the endpoint, if less then the empty pointer
    if (endPtr < ringBuffer.emptyPtr)
        endPtr += TRMRingBufferSize;
    
    // Upsample loop (slightly more efficient than downsampling)
    if (m_sampleRateRatio >= 1.0) {
        //printf("Upsampling...\n");
        while (ringBuffer.emptyPtr < endPtr) {
            int32_t index;
            uint32_t filterIndex;
            double output, interpolation, absoluteSampleValue;
            
            // Reset accumulator to zero
            output = 0.0;
            
            // Calculate interpolation value (static when upsampling)
            interpolation = (double)mValue(m_timeRegister) / (double)M_RANGE;
            
            // Compute the left side of the filter convolution
            index = ringBuffer.emptyPtr;
            for (filterIndex = lValue(m_timeRegister);
                 filterIndex < FILTER_LENGTH;
                 [TRMRingBuffer decrementIndex:&index], filterIndex += m_filterIncrement) {
                output += ringBuffer.buffer[index] * (m_h[filterIndex] + m_deltaH[filterIndex] * interpolation);
            }
            
            // Adjust values for right side calculation
            m_timeRegister = ~m_timeRegister;
            interpolation = (double)mValue(m_timeRegister) / (double)M_RANGE;
            
            // Compute the right side of the filter convolution
            index = ringBuffer.emptyPtr;
            [TRMRingBuffer incrementIndex:&index];
            for (filterIndex = lValue(m_timeRegister);
                 filterIndex < FILTER_LENGTH;
                 [TRMRingBuffer incrementIndex:&index], filterIndex += m_filterIncrement) {
                output += ringBuffer.buffer[index] * (m_h[filterIndex] + m_deltaH[filterIndex] * interpolation);
            }
            
            // Record maximum sample value
            absoluteSampleValue = fabs(output);
            if (absoluteSampleValue > m_maximumSampleValue)
                m_maximumSampleValue = absoluteSampleValue;
            
            // Increment sample number
            m_numberSamples++;
            
            // Output the sample to the temporary file
            fwrite((char *)&output, sizeof(output), 1, m_tempFilePtr);
            
            // Change time register back to original form
            m_timeRegister = ~m_timeRegister;
            
            // Increment the time register
            m_timeRegister += m_timeRegisterIncrement;
            
            // Increment the empty pointer, adjusting it and end pointer
            ringBuffer.emptyPtr += nValue(m_timeRegister);
            
            if (ringBuffer.emptyPtr >= TRMRingBufferSize) {
                ringBuffer.emptyPtr -= TRMRingBufferSize;
                endPtr -= TRMRingBufferSize;
            }
            
            // Clear N part of time register
            m_timeRegister &= (~N_MASK);
        }
    } else {
        //printf("Downsampling...\n");
        // Downsampling conversion loop
        while (ringBuffer.emptyPtr < endPtr) {
            int32_t index;
            uint32_t phaseIndex, impulseIndex;
            double absoluteSampleValue, output, impulse;
            
            // Reset accumulator to zero
            output = 0.0;
            
            // Compute P prime
            phaseIndex = (uint32_t)rint( ((double)fractionValue(m_timeRegister)) * m_sampleRateRatio);
            
            // Compute the left side of the filter convolution
            index = ringBuffer.emptyPtr;
            while ((impulseIndex = (phaseIndex >> M_BITS)) < FILTER_LENGTH) {
                impulse = m_h[impulseIndex] + (m_deltaH[impulseIndex] *
                                                        (((double)mValue(phaseIndex)) / (double)M_RANGE));
                output += (ringBuffer.buffer[index] * impulse);
                [TRMRingBuffer decrementIndex:&index];
                phaseIndex += m_phaseIncrement;
            }
            
            // Compute P prime, adjusted for right side
            phaseIndex = (unsigned int)rint( ((double)fractionValue(~m_timeRegister)) * m_sampleRateRatio);
            
            // Compute the right side of the filter convolution
            index = ringBuffer.emptyPtr;
            [TRMRingBuffer incrementIndex:&index];
            while ((impulseIndex = (phaseIndex>>M_BITS)) < FILTER_LENGTH) {
                impulse = m_h[impulseIndex] + (m_deltaH[impulseIndex] *
                                                        (((double)mValue(phaseIndex)) / (double)M_RANGE));
                output += (ringBuffer.buffer[index] * impulse);
                [TRMRingBuffer incrementIndex:&index];
                phaseIndex += m_phaseIncrement;
            }
            
            // Record maximum sample value
            absoluteSampleValue = fabs(output);
            if (absoluteSampleValue > m_maximumSampleValue)
                m_maximumSampleValue = absoluteSampleValue;
            
            // Increment sample number
            m_numberSamples++;
            
            // Output the sample to the temporary file
            fwrite((char *)&output, sizeof(output), 1, m_tempFilePtr);
            
            // Increment the time register
            m_timeRegister += m_timeRegisterIncrement;
            
            // Increment the empty pointer, adjusting it and end pointer
            ringBuffer.emptyPtr += nValue(m_timeRegister);
            if (ringBuffer.emptyPtr >= TRMRingBufferSize) {
                ringBuffer.emptyPtr -= TRMRingBufferSize;
                endPtr -= TRMRingBufferSize;
            }
            
            // Clear N part of time register
            m_timeRegister &= (~N_MASK);
        }
    }
}

#pragma mark -

- (void)dataFill:(double)data;
{
    [m_ringBuffer dataFill:data];
}

- (void)flush;
{
    [m_ringBuffer flush];
}

@end

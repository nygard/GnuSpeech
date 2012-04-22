//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright (c) 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMDriftGenerator.h"

static const float kInitialSeed = 0.7892347;
static const float kFactor = 377.0;

@implementation MMDriftGenerator
{
    float m_pitchDeviation;
    float m_pitchOffset;
    float m_a0;
    float m_b1;

    float m_seed;
    float m_previousSample;
}

// deviation     - the amount of drift in semitones above and below the median.  A value around 1 or so should give good results.
//
// sampleRate    - the rate of the system in Hz--this should be the same as the control rate (250 Hz).
//
// lowpassCutoff - the cutoff in Hz of the lowpass filter applied to the noise generator.  This value must
//                 range from 0 Hz to Nyquist.  A low value around 1 - 4 Hz should give good results.

- (id)init;
{
    if ((self = [super init])) {
        m_pitchDeviation = 0;
        m_pitchOffset    = 0;
        m_a0             = 0;
        m_b1             = 0;
        m_seed           = kInitialSeed;
        m_previousSample = 0.0;
    }
    
    return self;
}

- (void)configureWithDeviation:(float)deviation sampleRate:(float)sampleRate lowpassCutoff:(float)lowpassCutoff;
{
    m_pitchDeviation = deviation * 2.0;
    m_pitchOffset = deviation;
    
    // Clamp the range of the lowpass cutoff to 0..sampleRate/2.0
    if (lowpassCutoff < 0.0)                     lowpassCutoff = 0.0;
    else if (lowpassCutoff > (sampleRate / 2.0)) lowpassCutoff = sampleRate / 2.0;
    
    // Set the filter coefficients
    m_a0 = (lowpassCutoff * 2.0) / sampleRate;
    m_b1 = 1.0 - m_a0;

    // And seed is not changed...
    m_previousSample = 0.0;
}

// Clear the previous sample memory.
- (void)resetMemory;
{
    m_previousSample = 0;
}

// Returns one sample of the drift signal.
- (float)generateDrift;
{
    // Create a random number between 0 and 1
    float temp = m_seed * kFactor;
    m_seed = temp - (int32_t)temp;  // Seed is saved for next invocation
    
    // Create random signal with range -deviation to +deviation
    temp = (m_seed * m_pitchDeviation) - m_pitchOffset;
    
    // Lowpass filter the random signal (output is saved for next time)
    m_previousSample = (m_a0 * temp) + (m_b1 * m_previousSample);
    
    return m_previousSample;
}

@end

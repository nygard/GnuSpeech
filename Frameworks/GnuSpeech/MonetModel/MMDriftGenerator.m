//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright (c) 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMDriftGenerator.h"

static const float kInitialSeed = 0.7892347;
static const float kFactor = 377.0;

@implementation MMDriftGenerator
{
    float _pitchDeviation;
    float _pitchOffset;
    float _a0;
    float _b1;

    float _seed;
    float _previousSample;
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
        _pitchDeviation = 0;
        _pitchOffset    = 0;
        _a0             = 0;
        _b1             = 0;
        _seed           = kInitialSeed;
        _previousSample = 0.0;
    }
    
    return self;
}

- (void)configureWithDeviation:(float)deviation sampleRate:(float)sampleRate lowpassCutoff:(float)lowpassCutoff;
{
    _pitchDeviation = deviation * 2.0;
    _pitchOffset = deviation;
    
    // Clamp the range of the lowpass cutoff to 0..sampleRate/2.0
    if (lowpassCutoff < 0.0)                     lowpassCutoff = 0.0;
    else if (lowpassCutoff > (sampleRate / 2.0)) lowpassCutoff = sampleRate / 2.0;
    
    // Set the filter coefficients
    _a0 = (lowpassCutoff * 2.0) / sampleRate;
    _b1 = 1.0 - _a0;

    // And seed is not changed...
    _previousSample = 0.0;
}

// Clear the previous sample memory.
- (void)resetMemory;
{
    _previousSample = 0;
}

// Returns one sample of the drift signal.
- (float)generateDrift;
{
    // Create a random number between 0 and 1
    float temp = _seed * kFactor;
    _seed = temp - (int32_t)temp;  // Seed is saved for next invocation
    
    // Create random signal with range -deviation to +deviation
    temp = (_seed * _pitchDeviation) - _pitchOffset;
    
    // Lowpass filter the random signal (output is saved for next time)
    _previousSample = (_a0 * temp) + (_b1 * _previousSample);
    
    return _previousSample;
}

@end

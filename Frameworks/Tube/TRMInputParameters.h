//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

@interface TRMInputParameters : NSObject

@property (assign) int32_t outputFileFormat;           // file format (0=AU, 1=AIFF, 2=WAVE)
@property (assign) float outputRate;                   // output sample rate (22.05, 44.1 KHz)
@property (assign) float controlRate;                  // 1.0-1000.0 input tables/second (Hz)

@property (assign) double volume;                      // master volume (0 - 60 dB)
@property (assign) int32_t channels;                   // # of sound output channels (1, 2)
@property (assign) double balance;                     // stereo balance (-1 to +1)

@property (assign) int32_t waveform;                   // GS waveform type (0=PULSE, 1=SINE)
@property (assign) double tp;                          // % glottal pulse rise time
@property (assign) double tnMin;                       // % glottal pulse fall time minimum
@property (assign) double tnMax;                       // % glottal pulse fall time maximum
@property (assign) double breathiness;                 // % glottal source breathiness

@property (assign) double length;                      // nominal tube length (10 - 20 cm)
@property (assign) double temperature;                 // tube temperature (25 - 40 C)
@property (assign) double lossFactor;                  // junction loss factor in (0 - 5 %)

@property (assign) double apScale;                     // aperture scl. radius (3.05 - 12 cm)
@property (assign) double mouthCoef;                   // mouth aperture coefficient
@property (assign) double noseCoef;                    // nose aperture coefficient

@property (nonatomic, readonly) double *noseRadius;                 // fixed nose radii (0 - 3 cm).  Pointer to array of TOTAL_NASAL_SECTIONS doubles.

@property (assign) double throatCutoff;                // throat lp cutoff (50 - nyquist Hz)
@property (assign) double throatVol;                   // throat volume (0 - 48 dB)

@property (assign) int32_t modulation;                 // pulse mod. of noise (0=OFF, 1=ON)
@property (assign) double mixOffset;                   // noise crossmix offset (30 - 60 dB)

@end

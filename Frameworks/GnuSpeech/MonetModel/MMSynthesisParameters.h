//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

typedef enum {
    MMGPShapePulse = 0,
    MMGPShapeSine = 1,
} MMGlottalPulseShape;

typedef enum {
    MMSamplingRate22050 = 0,
    MMSamplingRate44100 = 1,
} MMSamplingRate;

typedef enum {
    MMChannelsMono = 0,
    MMChannelsStereo = 1,
} MMChannels;

@interface MMSynthesisParameters : NSObject

+ (NSString *)stringForGlottalPulseShape:(MMGlottalPulseShape)aShape;
+ (MMGlottalPulseShape)glottalPulseShapeFromString:(NSString *)aString;

+ (NSString *)stringForSamplingRate:(MMSamplingRate)aRate;
+ (MMSamplingRate)samplingRateFromString:(NSString *)aString;
+ (double)samplingRate:(MMSamplingRate)aRate;

+ (NSString *)stringForChannels:(MMChannels)channels;
+ (MMChannels)channelsFromString:(NSString *)aString;

- (void)restoreDefaultValues;
- (void)saveAsDefaults;

@property (assign) double masterVolume;
@property (assign) double vocalTractLength;
@property (assign) double temperature;
@property (assign) double balance;
@property (assign) double breathiness;
@property (assign) double lossFactor;
@property (assign) double pitch;
@property (assign) double throatCutoff;
@property (assign) double throatVolume;
@property (assign) double apertureScaling;
@property (assign) double mouthCoef;
@property (assign) double noseCoef;
@property (assign) double mixOffset;
@property (assign) double n1;
@property (assign) double n2;
@property (assign) double n3;
@property (assign) double n4;
@property (assign) double n5;
@property (assign) double tp;
@property (assign) double tnMin;
@property (assign) double tnMax;
@property (assign) MMGlottalPulseShape glottalPulseShape;
@property (assign) BOOL shouldUseNoiseModulation;
@property (assign) MMSamplingRate samplingRate;
@property (assign) MMChannels outputChannels;

- (void)writeToFile:(NSString *)aFilename includeComments:(BOOL)shouldIncludeComments;

@end

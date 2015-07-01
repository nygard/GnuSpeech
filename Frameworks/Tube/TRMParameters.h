//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

// Control parameters?
@interface TRMParameters : NSObject

@property (assign) double glottalPitch;
@property (assign) double glottalVolume;
@property (assign) double aspirationVolume;
@property (assign) double fricationVolume;
@property (assign) double fricationPosition;
@property (assign) double fricationCenterFrequency;
@property (assign) double fricationBandwidth;
@property (nonatomic, readonly) double *radius;
@property (assign) double velum;

@property (nonatomic, readonly) NSString *valuesString;

@end

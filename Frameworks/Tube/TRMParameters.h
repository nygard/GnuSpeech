//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

// Control parameters?
@interface TRMParameters : NSObject

@property (assign) double glotPitch;
@property (assign) double glotVol;
@property (assign) double aspVol;
@property (assign) double fricVol;
@property (assign) double fricPos;
@property (assign) double fricCF;
@property (assign) double fricBW;
@property (nonatomic, readonly) double *radius;
@property (assign) double velum;

@end

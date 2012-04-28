//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

/*  GLOBAL DEFINES  **********************************************************/
#define PHARYNX_SECTIONS     3
#define VELUM_SECTIONS       1
#define ORAL_SECTIONS        5
#define NASAL_SECTIONS       5

@interface TRMData : NSObject

@property (nonatomic, assign) float glotPitch;
@property (nonatomic, assign) float glotVol;
@property (nonatomic, assign) float aspVol;
@property (nonatomic, assign) float fricVol;
@property (assign) float fricPos;
@property (nonatomic, assign) float fricCF;
@property (nonatomic, assign) float fricBW;
@property (nonatomic, assign) float r1;
@property (nonatomic, assign) float r2;
@property (nonatomic, assign) float r3;
@property (nonatomic, assign) float r4;
@property (nonatomic, assign) float r5;
@property (nonatomic, assign) float r6;
@property (nonatomic, assign) float r7;
@property (nonatomic, assign) float r8;
@property (nonatomic, assign) float velum;

@property (assign) int32_t controlRate;
@property (nonatomic, assign) float volume;
@property (assign) int32_t channels;
@property (assign) double balance;

@property (assign) int32_t waveform;
@property (assign) float tp;
@property (assign) float tnMin;
@property (assign) float tnMax;
@property (assign) float breathiness;

@property (assign) double length;
@property (assign) double temperature;
@property (nonatomic, assign) float lossFactor;

@property (nonatomic, assign) float apScale;
@property (assign) double mouthCoef;
@property (assign) double noseCoef;

@property (nonatomic, assign) float n1;
@property (nonatomic, assign) float n2;
@property (nonatomic, assign) float n3;
@property (nonatomic, assign) float n4;
@property (nonatomic, assign) float n5;

@property (nonatomic, assign) float throatCutoff;
@property (nonatomic, assign) float throatVol;

@property (assign) int32_t modulation;
@property (nonatomic, assign) float mixOffset;

@end

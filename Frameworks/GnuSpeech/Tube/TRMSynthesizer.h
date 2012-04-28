//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>
#import <Tube/TubeModel.h>

@class MMSynthesisParameters;

@interface TRMSynthesizer : NSObject

- (void)setupSynthesisParameters:(MMSynthesisParameters *)synthesisParameters;
- (void)removeAllParameters;
- (void)addParameters:(float *)values;

@property (assign) BOOL shouldSaveToSoundFile;
@property (strong) NSString *filename;
@property (nonatomic, assign) int fileType;

- (void)synthesize;

@end

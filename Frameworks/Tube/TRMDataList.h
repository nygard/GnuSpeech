//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

@class TRMInputParameters;

@interface TRMDataList : NSObject

- (id)initWithContentsOfFile:(NSString *)path error:(NSError **)error;

@property (readonly) TRMInputParameters *inputParameters;
@property (readonly) NSMutableArray *values;

- (void)printInputParameters;
- (void)printControlRateInputTable;

@end

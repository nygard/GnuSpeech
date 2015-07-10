//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

#import "NSObject-Extensions.h"

@interface MMTarget : NSObject

- (id)init;
- (id)initWithValue:(double)newValue isDefault:(BOOL)shouldBeDefault;
- (id)initWithXMLElement:(NSXMLElement *)element error:(NSError **)error;

@property (assign) double value;
@property (assign) BOOL isDefault;

- (void)setValue:(double)newValue isDefault:(BOOL)shouldBeDefault;
- (void)changeDefaultValueFrom:(double)oldDefault to:(double)newDefault;

@end

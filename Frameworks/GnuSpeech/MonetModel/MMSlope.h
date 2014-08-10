//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

@interface MMSlope : NSObject

- (id)initWithXMLElement:(NSXMLElement *)element error:(NSError **)error;

@property (assign) double slope;
@property (assign) double displayTime;

- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;

@end

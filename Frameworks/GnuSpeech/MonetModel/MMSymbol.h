//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMNamedObject.h"

#import "NSObject-Extensions.h"

@interface MMSymbol : MMNamedObject <GSXMLArchiving>

@property (assign) double minimumValue;
@property (assign) double maximumValue;
@property (nonatomic, assign) double defaultValue;

@end

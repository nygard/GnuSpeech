//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMObject.h"

@interface MMNamedObject : MMObject

@property (strong) NSString *name;
@property (strong) NSString *comment;
@property (nonatomic, readonly) BOOL hasComment;

@end

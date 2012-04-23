//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMObject.h"

@implementation MMObject
{
    __weak MModel *nonretained_model;
}

@synthesize model = nonretained_model;

- (NSUndoManager *)undoManager;
{
    return nil;
}

@end

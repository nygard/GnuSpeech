//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMGroupedObject.h"

#import "MMGroup.h"

@implementation MMGroupedObject
{
    __weak MMGroup *nonretained_group;
}

@synthesize group = nonretained_group;

@end

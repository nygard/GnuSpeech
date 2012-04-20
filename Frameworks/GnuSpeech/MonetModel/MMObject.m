//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMObject.h"

@implementation MMObject
{
    MModel *nonretained_model;
}

- (MModel *)model;
{
    return nonretained_model;
}

- (void)setModel:(MModel *)newModel;
{
    nonretained_model = newModel;
}

- (NSUndoManager *)undoManager;
{
    return nil;
}

@end

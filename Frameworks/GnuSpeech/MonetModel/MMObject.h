//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/NSObject.h>
#import <Foundation/NSUndoManager.h>

@class MModel;

@interface MMObject : NSObject
{
    MModel *nonretained_model;
}

- (MModel *)model;
- (void)setModel:(MModel *)newModel;

- (NSUndoManager *)undoManager;

@end

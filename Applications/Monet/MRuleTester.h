//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MWindowController.h"

@class MModel;

@interface MRuleTester : MWindowController

- (id)initWithModel:(MModel *)aModel;

- (MModel *)model;
- (void)setModel:(MModel *)newModel;

- (NSUndoManager *)undoManager;

- (void)clearOutput;

// Actions
- (IBAction)parseRule:(id)sender;
- (IBAction)shiftPosturesLeft:(id)sender;

@end

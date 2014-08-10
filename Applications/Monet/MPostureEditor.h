//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MWindowController.h"

@class MModel, MMPosture;

@interface MPostureEditor : MWindowController <NSTableViewDataSource, NSTableViewDelegate, NSTextViewDelegate>

- (id)initWithModel:(MModel *)model;

- (MModel *)model;
- (void)setModel:(MModel *)newModel;

- (NSUndoManager *)undoManager;

- (void)updateViews;
- (void)_updatePostureDetails;
- (void)_updateUseDefaultButtons;

- (MMPosture *)selectedPosture;

- (IBAction)addPosture:(id)sender;
- (IBAction)removePosture:(id)sender;

- (IBAction)useDefaultValueForParameter:(id)sender;
- (IBAction)useDefaultValueForMetaParameter:(id)sender;
- (IBAction)useDefaultValueForSymbol:(id)sender;

@end

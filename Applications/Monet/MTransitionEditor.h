//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MWindowController.h"

#import "TransitionView.h" // For TransitionViewDelegate
@class MModel, MMPoint, MMTransition;

@interface MTransitionEditor : MWindowController <NSOutlineViewDataSource, NSOutlineViewDelegate, TransitionViewDelegate>

@property (nonatomic, strong) MModel *model;

- (NSUndoManager *)undoManager;

- (void)updateViews;
- (void)expandEquations;

@property (nonatomic, strong) MMTransition *transition;

- (void)_updateSelectedPointDetails;
- (IBAction)setType:(id)sender;
- (IBAction)setPointValue:(id)sender;
- (IBAction)setPhantom:(id)sender;
- (IBAction)setTransitionType:(id)sender;

@end

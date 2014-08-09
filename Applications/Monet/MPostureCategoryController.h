//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MWindowController.h"

@class MModel;

@interface MPostureCategoryController : MWindowController <NSTableViewDataSource, NSTableViewDelegate>

- (id)initWithModel:(MModel *)aModel;

- (MModel *)model;
- (void)setModel:(MModel *)newModel;

- (NSUndoManager *)undoManager;

- (void)updateViews;
- (void)createCategoryColumns;
- (void)_selectFirstRow;

@end

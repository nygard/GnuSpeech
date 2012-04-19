//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock

#import <AppKit/NSTableView.h>
#import <Foundation/NSUndoManager.h>
#import "MWindowController.h"

@class MModel, NSControl;

@interface MPostureCategoryController : MWindowController
{
    IBOutlet NSTableView *postureCategoryTableView;

    MModel *model;
}

- (id)initWithModel:(MModel *)aModel;
- (void)dealloc;

- (MModel *)model;
- (void)setModel:(MModel *)newModel;

- (NSUndoManager *)undoManager;

- (void)windowDidLoad;

- (void)updateViews;
- (void)createCategoryColumns;
- (void)_selectFirstRow;

// NSTableView data source
- (int)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row;
- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(int)row;

// NSTableView delegate
- (BOOL)control:(NSControl *)aControl shouldProcessCharacters:(NSString *)characters;

@end

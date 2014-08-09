//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MWindowController.h"

@class MMCategory, MModel, MMParameter, MMPosture, MMSymbol;

@interface MPostureEditor : MWindowController

- (id)initWithModel:(MModel *)aModel;

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

// NSTableView data source
- (NSUInteger)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;

// NSTableView delegate
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;
- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;

- (BOOL)control:(NSControl *)aControl shouldProcessCharacters:(NSString *)characters;

// NSTextView delegate
- (void)textDidEndEditing:(NSNotification *)aNotification;

@end

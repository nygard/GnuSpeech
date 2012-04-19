//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock

#import "MWindowController.h"
#import <AppKit/AppKit.h>

@class MMCategory, MModel, MMParameter, MMPosture, MMSymbol;
@class NSButton, NSButtonCell, NSFont, NSControl;

@interface MPostureEditor : MWindowController
{
    IBOutlet NSTableView *postureTableView;
    IBOutlet NSTextField *postureTotalTextField;
    IBOutlet NSButtonCell *removePostureButtonCell;
    IBOutlet NSTextView *postureCommentTextView;

    IBOutlet NSTableView *categoryTableView;

    IBOutlet NSTableView *parameterTableView;
    IBOutlet NSButton *useDefaultParameterButton;

    IBOutlet NSTableView *metaParameterTableView;
    IBOutlet NSButton *useDefaultMetaParameterButton;

    IBOutlet NSTableView *symbolTableView;
    IBOutlet NSButton *useDefaultSymbolButton;

    MModel *model;

    NSFont *regularControlFont;
    NSFont *boldControlFont;
}

- (id)initWithModel:(MModel *)aModel;
- (void)dealloc;

- (MModel *)model;
- (void)setModel:(MModel *)newModel;

- (NSUndoManager *)undoManager;

- (void)windowDidLoad;

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
- (int)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row;
- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(int)row;

// NSTableView delegate
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;
- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int)row;

- (BOOL)control:(NSControl *)aControl shouldProcessCharacters:(NSString *)characters;

// NSTextView delegate
- (void)textDidEndEditing:(NSNotification *)aNotification;

@end

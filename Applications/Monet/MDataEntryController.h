//
// $Id: MDataEntryController.h,v 1.6 2004/03/24 20:25:58 nygard Exp $
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <AppKit/NSWindowController.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class MMCategory, MModel, MMParameter, MMSymbol;

@interface MDataEntryController : NSWindowController
{
    IBOutlet NSTableView *categoryTableView;
    IBOutlet NSTextField *categoryTotalTextField;
    IBOutlet NSTextView *categoryCommentTextView;
    IBOutlet NSButtonCell *removeCategoryButtonCell;

    IBOutlet NSTableView *parameterTableView;
    IBOutlet NSTextField *parameterTotalTextField;
    IBOutlet NSTextView *parameterCommentTextView;
    IBOutlet NSButtonCell *removeParameterButtonCell;

    IBOutlet NSTableView *metaParameterTableView;
    IBOutlet NSTextField *metaParameterTotalTextField;
    IBOutlet NSTextView *metaParameterCommentTextView;
    IBOutlet NSButtonCell *removeMetaParameterButtonCell;

    IBOutlet NSTableView *symbolTableView;
    IBOutlet NSTextField *symbolTotalTextField;
    IBOutlet NSTextView *symbolCommentTextView;
    IBOutlet NSButtonCell *removeSymbolButtonCell;

    MModel *model;
}

- (id)initWithModel:(MModel *)aModel;
- (void)dealloc;

- (MModel *)model;
- (void)setModel:(MModel *)newModel;

- (NSUndoManager *)undoManager;

- (void)windowDidLoad;

- (void)updateViews;
- (void)_selectFirstRows;
- (void)_updateCategoryComment;
- (void)_updateParameterComment;
- (void)_updateMetaParameterComment;
- (void)_updateSymbolComment;

// Actions
- (IBAction)addCategory:(id)sender;
- (IBAction)removeCategory:(id)sender;

- (IBAction)addParameter:(id)sender;
- (IBAction)removeParameter:(id)sender;

- (IBAction)addMetaParameter:(id)sender;
- (IBAction)removeMetaParameter:(id)sender;

- (IBAction)addSymbol:(id)sender;
- (IBAction)removeSymbol:(id)sender;

// NSTableView data source
- (int)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row;
- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(int)row;

// NSTableView delegate
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;

// NSTextView delegate
- (void)textDidEndEditing:(NSNotification *)aNotification;

- (MMCategory *)selectedCategory;
- (MMParameter *)selectedParameter;
- (MMParameter *)selectedMetaParameter;
- (MMSymbol *)selectedSymbol;

@end

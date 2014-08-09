//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MWindowController.h"

@class MMBooleanNode, MMBooleanParser, MModel, MMRule;

@interface MRuleManager : MWindowController <NSTableViewDataSource, NSTableViewDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate, NSBrowserDelegate>

- (id)initWithModel:(MModel *)aModel;

- (MModel *)model;
- (void)setModel:(MModel *)newModel;

- (NSUndoManager *)undoManager;
- (MMRule *)selectedRule;

- (void)updateViews;
- (void)expandOutlines;
- (void)_updateSelectedRuleDetails;
- (void)_updateRuleComment;
- (void)_updateSelectedSymbolDetails;
- (void)_updateSelectedParameterDetails;
- (void)_updateSelectedSpecialParameterDetails;
- (void)_updateSelectedMetaParameterDetails;

- (void)setExpression:(MMBooleanNode *)anExpression atIndex:(NSInteger)index;
- (void)evaluateMatchLists;
- (void)updateCombinations;

// MExtendedTableView delegate
- (BOOL)control:(NSControl *)aControl shouldProcessCharacters:(NSString *)characters;

// Actions
- (IBAction)setExpression:(id)sender;
- (IBAction)addRule:(id)sender;
- (IBAction)updateRule:(id)sender;
- (IBAction)removeRule:(id)sender;

@end

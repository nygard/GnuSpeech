//
// $Id: MRuleTester.h,v 1.1 2004/03/23 21:28:44 nygard Exp $
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <AppKit/NSWindowController.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class MModel;

@interface MRuleTester : NSWindowController
{
    IBOutlet NSForm *phone1Form;
    IBOutlet NSForm *phone2Form;
    IBOutlet NSForm *phone3Form;
    IBOutlet NSForm *phone4Form;

    IBOutlet NSTextField *ruleOutputTextField;
    IBOutlet NSTextField *consumedTokensTextField;
    IBOutlet NSForm *durationOutputForm;

    MModel *model;
}

- (id)initWithModel:(MModel *)aModel;
- (void)dealloc;

- (MModel *)model;
- (void)setModel:(MModel *)newModel;

- (NSUndoManager *)undoManager;

- (void)windowDidLoad;

- (void)updateViews;

// Actions
- (IBAction)parseRule:(id)sender;
- (IBAction)shiftPhonesLeft:(id)sender;

@end

//
// $Id: MRuleTester.h,v 1.2 2004/03/23 22:53:02 nygard Exp $
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MWindowController.h"
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class MModel;

@interface MRuleTester : MWindowController
{
    IBOutlet NSForm *posture1Form;
    IBOutlet NSForm *posture2Form;
    IBOutlet NSForm *posture3Form;
    IBOutlet NSForm *posture4Form;

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
- (void)clearOutput;

// Actions
- (IBAction)parseRule:(id)sender;
- (IBAction)shiftPosturesLeft:(id)sender;

@end

//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock

#import "MWindowController.h"
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet
#import <AppKit/NSForm.h>
#import <AppKit/NSTextField.h>

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

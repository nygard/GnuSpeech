//
// $Id: MSynthesisController.h,v 1.1 2004/03/30 22:49:05 nygard Exp $
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <AppKit/NSWindowController.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class MModel;
@class EventListView, IntonationView;

@interface MSynthesisController : NSWindowController
{
    // Synthesis window
    IBOutlet NSTextField *stringTextField;
    IBOutlet NSTableView *parameterTableView;
    IBOutlet EventListView *eventListView;
    IBOutlet NSTextField *filenameField;
    IBOutlet NSButton *parametersStore;

    // intonation parameter window
    IBOutlet NSWindow *intonationParameterWindow;

    IBOutlet NSTextField *tempoField;
    IBOutlet NSForm *intonParmsField;
    IBOutlet NSTextField *radiusMultiplyField;

    IBOutlet NSMatrix *intonationMatrix;
    IBOutlet NSTextField *driftDeviationField;
    IBOutlet NSTextField *driftCutoffField;
    IBOutlet NSButton *smoothIntonationSwitch;

    // Intonation window
    IBOutlet NSWindow *intonationWindow;
    IBOutlet IntonationView *intonationView;

    MModel *model;
}

- (id)initWithModel:(MModel *)aModel;
- (void)dealloc;

- (MModel *)model;
- (void)setModel:(MModel *)newModel;

- (NSUndoManager *)undoManager;

- (void)windowDidLoad;

- (void)updateViews;

- (IBAction)showIntonationWindow:(id)sender;
- (IBAction)showIntonationParameterWindow:(id)sender;

@end

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MWindowController.h"
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

#import "EventList.h" // for struct _intonationParameters

@class MModel, MMPostureRewriter;
@class EventListView, IntonationPoint, IntonationView;
@class TRMSynthesizer;

@interface MSynthesisController : MWindowController
{
    // Synthesis window
    IBOutlet NSComboBox *stringTextField;
    IBOutlet NSTableView *parameterTableView;
    IBOutlet EventListView *eventListView;
    IBOutlet NSTextField *filenameField;
    IBOutlet NSPopUpButton *fileTypePopUpButton;
    IBOutlet NSButton *parametersStore;

    // Intonation parameter window
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
    IBOutlet NSScrollView *intonationView;

    IBOutlet NSTextField *semitoneTextField;
    IBOutlet NSTextField *hertzTextField;
    IBOutlet NSTextField *slopeTextField;

    IBOutlet NSTableView *intonationRuleTableView;
    IBOutlet NSTextField *beatTextField;
    IBOutlet NSTextField *beatOffsetTextField;
    IBOutlet NSTextField *absTimeTextField;

    struct _intonationParameters intonationParameters;

    MModel *model;
    NSMutableArray *displayParameters;
    EventList *eventList;
    MMPostureRewriter *postureRewriter;

    TRMSynthesizer *synthesizer;
}

- (id)initWithModel:(MModel *)aModel;
- (void)dealloc;

- (MModel *)model;
- (void)setModel:(MModel *)newModel;

- (NSUndoManager *)undoManager;

- (void)windowDidLoad;

- (void)_updateDisplayParameters;
- (void)updateViews;
- (void)_updateDisplayedParameters;
- (void)_takeIntonationParametersFromUI;
- (void)_updateSelectedPointDetails;

- (IBAction)showIntonationWindow:(id)sender;
- (IBAction)showIntonationParameterWindow:(id)sender;

- (IBAction)parseStringButton:(id)sender;
- (IBAction)synthesizeWithSoftware:(id)sender;
- (IBAction)synthesizeToFile:(id)sender;
- (void)synthesizeToSoundFile:(BOOL)shouldSaveToSoundFile;

- (IBAction)generateContour:(id)sender;

- (IBAction)generateGraphImages:(id)sender;

- (void)parsePhoneString:(NSString *)str;

// Intonation Point details
- (IntonationPoint *)selectedIntonationPoint;
- (IBAction)setSemitone:(id)sender;
- (IBAction)setHertz:(id)sender;
- (IBAction)setSlope:(id)sender;
- (IBAction)setBeatOffset:(id)sender;

// NSTableView data source
- (int)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row;
- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(int)row;

// IntonationView delegate
- (void)intonationViewSelectionDidChange:(NSNotification *)aNotification;

@end

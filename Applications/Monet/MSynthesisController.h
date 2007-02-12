//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MWindowController.h"
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

#import <GnuSpeech/GnuSpeech.h> // for struct _intonationParameters

@class MMIntonationPoint, MModel;
@class EventListView, MAIntonationScrollView;
@class TRMSynthesizer;
@class NSComboBox, NSPopUpButton, NSMatrix, NSPrintInfo, NSOpenPanel, NSSavePanel;
@class NSTableView, NSButton, NSTextField, NSView, NSForm, NSUndoManager;
@class NSTableColumn, NSNotification, NSControl;

@interface MSynthesisController : MWindowController
{
    // Synthesis window
    IBOutlet NSComboBox *stringTextField;
    IBOutlet NSTableView *parameterTableView;
    IBOutlet EventListView *eventListView;
    IBOutlet NSButton *parametersStore;

    // Save panel accessory view
    IBOutlet NSView *savePanelAccessoryView;
    IBOutlet NSPopUpButton *fileTypePopUpButton;

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
    IBOutlet MAIntonationScrollView *intonationView;

    IBOutlet NSTextField *semitoneTextField;
    IBOutlet NSTextField *hertzTextField;
    IBOutlet NSTextField *slopeTextField;

    IBOutlet NSTableView *intonationRuleTableView;
    IBOutlet NSTextField *beatTextField;
    IBOutlet NSTextField *beatOffsetTextField;
    IBOutlet NSTextField *absTimeTextField;

    NSPrintInfo *intonationPrintInfo;

    struct _intonationParameters intonationParameters;

    MModel *model;
    NSMutableArray *displayParameters;
    EventList *eventList;

    TRMSynthesizer *synthesizer;

    // Event Table stuff
    IBOutlet NSTableView *eventTableView;
}

+ (void)initialize;

- (id)initWithModel:(MModel *)aModel;
- (void)dealloc;

- (MModel *)model;
- (void)setModel:(MModel *)newModel;

- (NSUndoManager *)undoManager;

- (void)windowDidLoad;

- (void)_updateDisplayParameters;
- (void)_updateEventColumns;
- (void)updateViews;
- (void)_updateDisplayedParameters;
- (void)_takeIntonationParametersFromUI;
- (void)_updateSelectedPointDetails;

- (IBAction)showIntonationWindow:(id)sender;
- (IBAction)showIntonationParameterWindow:(id)sender;

- (IBAction)synthesizeWithSoftware:(id)sender;
- (IBAction)synthesizeToFile:(id)sender;
- (IBAction)fileTypeDidChange:(id)sender;
- (void)synthesize;

- (IBAction)synthesizeWithContour:(id)sender;
- (void)prepareForSynthesis;
- (void)continueSynthesis;
- (IBAction)generateContour:(id)sender;

- (IBAction)generateGraphImages:(id)sender;
- (void)openPanelDidEnd:(NSOpenPanel *)openPanel returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void)savePanelDidEnd:(NSSavePanel *)savePanel returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void)saveGraphImagesToPath:(NSString *)basePath;

- (IBAction)addPhoneString:(id)sender;

// Intonation Point details
- (MMIntonationPoint *)selectedIntonationPoint;
- (IBAction)setSemitone:(id)sender;
- (IBAction)setHertz:(id)sender;
- (IBAction)setSlope:(id)sender;
- (IBAction)setBeatOffset:(id)sender;

- (IBAction)openIntonationContour:(id)sender;
- (IBAction)saveIntonationContour:(id)sender;

- (IBAction)runPageLayout:(id)sneder;
- (IBAction)printDocument:(id)sender;

- (void)intonationPointDidChange:(NSNotification *)aNotification;

// NSTableView data source
- (int)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row;
- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(int)row;

// NSTableView delegate
- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int)row;

// MExtendedTableView delegate
- (BOOL)control:(NSControl *)aControl shouldProcessCharacters:(NSString *)characters;

// MAIntonationView delegate
- (void)intonationViewSelectionDidChange:(NSNotification *)aNotification;

// Intonation Parameters
- (IBAction)updateSmoothIntonation:(id)sender;
- (IBAction)updateMacroIntonation:(id)sender;
- (IBAction)updateMicroIntonation:(id)sender;
- (IBAction)updateDrift:(id)sender;

@end

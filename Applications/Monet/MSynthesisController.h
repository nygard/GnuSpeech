//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MWindowController.h"

#import <GnuSpeech/GnuSpeech.h> // for struct _intonationParameters

@class MMIntonationPoint, MModel;
@class EventListView, MAIntonationScrollView;
@class TRMSynthesizer, MTextToPhone;

@interface MSynthesisController : MWindowController
{
    // Synthesis window
	IBOutlet NSComboBox *textStringTextField;
	IBOutlet NSTextView *phoneStringTextView;
    IBOutlet NSTableView *parameterTableView;
    IBOutlet EventListView *eventListView;
	IBOutlet NSScrollView *scrollView;  // db
    IBOutlet NSButton *parametersStore;
	
	IBOutlet NSTextField *mouseTimeField;  // db
    IBOutlet NSTextField *mouseValueField;  // db
	
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
	
	MMTextToPhone * textToPhone;
	
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
- (void)parseText:(id)sender;
- (NSString *)getAndSyncPhoneString;

- (IBAction)synthesizeWithContour:(id)sender;
- (void)prepareForSynthesis;
- (void)continueSynthesis;
- (IBAction)generateContour:(id)sender;

- (IBAction)generateGraphImages:(id)sender;
- (void)saveGraphImagesToPath:(NSString *)basePath;

- (IBAction) addTextString:(id)sender;

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
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;

// NSTableView delegate
- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;

// MExtendedTableView delegate
- (BOOL)control:(NSControl *)aControl shouldProcessCharacters:(NSString *)characters;

// MAIntonationView delegate
- (void)intonationViewSelectionDidChange:(NSNotification *)aNotification;

// NSComboBox delegate
- (void)controlTextDidChange:(NSNotification *)aNotification;
- (void)controlTextDidEndEditing:(NSNotification *)aNotification;

// NSTextView delegate
- (void)textDidChange:(NSNotification *)aNotification;

// Intonation Parameters
- (IBAction)updateSmoothIntonation:(id)sender;
- (IBAction)updateMacroIntonation:(id)sender;
- (IBAction)updateMicroIntonation:(id)sender;
- (IBAction)updateDrift:(id)sender;

@end

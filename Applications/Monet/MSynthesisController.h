//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MWindowController.h"

@class MMIntonationPoint, MModel;

@interface MSynthesisController : MWindowController

- (id)initWithModel:(MModel *)aModel;

@property (nonatomic, strong) MModel *model;

- (NSUndoManager *)undoManager;

- (IBAction)showIntonationWindow:(id)sender;
- (IBAction)showIntonationParameterWindow:(id)sender;

- (IBAction)synthesizeWithSoftware:(id)sender;
- (IBAction)synthesizeToFile:(id)sender;
- (IBAction)fileTypeDidChange:(id)sender;
- (IBAction)parseText:(id)sender;

- (IBAction)synthesizeWithContour:(id)sender;
- (IBAction)generateContour:(id)sender;

- (IBAction)generateGraphImages:(id)sender;

- (IBAction)addTextString:(id)sender;

// Intonation Point details
- (MMIntonationPoint *)selectedIntonationPoint;
- (IBAction)setSemitone:(id)sender;
- (IBAction)setHertz:(id)sender;
- (IBAction)setSlope:(id)sender;
- (IBAction)setBeatOffset:(id)sender;

- (IBAction)openIntonationContour:(id)sender;
- (IBAction)saveIntonationContour:(id)sender;

- (IBAction)runPageLayout:(id)sender;
- (IBAction)printDocument:(id)sender;

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

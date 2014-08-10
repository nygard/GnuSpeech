//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Cocoa/Cocoa.h>

@class MModel, MMTransition;
@class MDataEntryController, MPostureCategoryController, MPostureEditor, MPrototypeManager, MReleaseNotesController, MRuleManager, MRuleTester;
@class MSpecialTransitionEditor, MSynthesisController, MSynthesisParameterEditor, MTransitionEditor;

@interface AppController : NSObject

@property (strong) NSString *filename;

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
- (void)applicationWillTerminate:(NSNotification *)notification;

- (void)displayInfoPanel:(id)sender;

- (IBAction)openFile:(id)sender;
- (IBAction)importTRMData:(id)sender;

- (void)setModel:(MModel *)newModel;

- (IBAction)saveDocument:(id)sender;
- (IBAction)saveDocumentAs:(id)sender;
- (IBAction)revertDocumentToSaved:(id)sender;

- (IBAction)savePrototypes:(id)sender;
- (IBAction)loadPrototypes:(id)sender;

- (IBAction)showDataEntryWindow:(id)sender;
- (IBAction)showPostureCategoryWindow:(id)sender;
- (IBAction)showPostureEditor:(id)sender;
- (IBAction)showPrototypeManager:(id)sender;
- (IBAction)showTransitionEditor:(id)sender;
- (IBAction)showSpecialTransitionEditor:(id)sender;
- (IBAction)showRuleTester:(id)sender;
- (IBAction)showRuleManager:(id)sender;
- (IBAction)showSynthesisParameterEditor:(id)sender;
- (IBAction)showSynthesisController:(id)sender;
- (IBAction)showIntonationWindow:(id)sender;
- (IBAction)showIntonationParameterWindow:(id)sender;
- (IBAction)generateXML:(id)sender;

- (void)editTransition:(MMTransition *)transition;
- (void)editSpecialTransition:(MMTransition *)transition;

- (IBAction)showReleaseNotes:(id)sender;

@end

//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Cocoa/Cocoa.h>

@class MModel, MMTransition;
@class MDataEntryController, MPostureCategoryController, MPostureEditor, MPrototypeManager, MReleaseNotesController, MRuleManager, MRuleTester;
@class MSpecialTransitionEditor, MSynthesisController, MSynthesisParameterEditor, MTransitionEditor;

@interface AppController : NSObject

- (void)setFilename:(NSString *)newFilename;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
- (void)applicationWillTerminate:(NSNotification *)notification;

- (void)displayInfoPanel:(id)sender;

- (IBAction)openFile:(id)sender;
- (IBAction)importTRMData:(id)sender;
- (IBAction)printData:(id)sender;

- (void)setModel:(MModel *)newModel;

- (void)_loadFile:(NSString *)aFilename;
- (void)_loadDegasFile:(NSString *)aFilename;
- (void)_loadMonetXMLFile:(NSString *)aFilename;

- (IBAction)saveDocument:(id)sender;
- (IBAction)saveDocumentAs:(id)sender;
- (IBAction)revertDocumentToSaved:(id)sender;

- (IBAction)savePrototypes:(id)sender;
- (IBAction)loadPrototypes:(id)sender;

- (void)_disableUnconvertedClassLoading;

- (MDataEntryController *)dataEntryController;
- (IBAction)showDataEntryWindow:(id)sender;

- (MPostureCategoryController *)postureCategoryController;
- (IBAction)showPostureCategoryWindow:(id)sender;

- (MPostureEditor *)postureEditor;
- (IBAction)showPostureEditor:(id)sender;

- (MPrototypeManager *)prototypeManager;
- (IBAction)showPrototypeManager:(id)sender;

- (MTransitionEditor *)transitionEditor;
- (IBAction)showTransitionEditor:(id)sender;

- (MSpecialTransitionEditor *)specialTransitionEditor;
- (IBAction)showSpecialTransitionEditor:(id)sender;

- (MRuleTester *)ruleTester;
- (IBAction)showRuleTester:(id)sender;

- (MRuleManager *)ruleManager;
- (IBAction)showRuleManager:(id)sender;

- (MSynthesisParameterEditor *)synthesisParameterEditor;
- (IBAction)showSynthesisParameterEditor:(id)sender;

- (MSynthesisController *)synthesisController;
- (IBAction)showSynthesisController:(id)sender;

- (IBAction)showIntonationWindow:(id)sender;
- (IBAction)showIntonationParameterWindow:(id)sender;

- (IBAction)generateXML:(id)sender;

- (void)editTransition:(MMTransition *)aTransition;
- (void)editSpecialTransition:(MMTransition *)aTransition;

- (MReleaseNotesController *)releaseNotesController;
- (IBAction)showReleaseNotes:(id)sender;

@end

//
// $Id: AppController.h,v 1.43 2004/04/02 03:22:01 nygard Exp $
//

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================

	Object: AppController
	Purpose: Oversees the functioning of MONET

	Date: March 23, 1994

History:
	March 23, 1994
		Integrated into MONET.

===========================================================================*/

#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class CategoryList, ParameterList, PhoneList, SymbolList;
@class EventListView, IntonationScrollView, PrototypeManager;
@class MModel, MMTransition;
@class MDataEntryController, MPostureEditor, MPrototypeManager, MRuleManager, MRuleTester, MSpecialTransitionEditor;
@class MSynthesisController, MSynthesisParameterEditor, MTransitionEditor;

@interface AppController : NSObject
{
    IBOutlet NSPanel *infoPanel;

    MModel *model;

    IBOutlet PrototypeManager *prototypeManager;
    IBOutlet EventListView *eventListView;
    IBOutlet IntonationScrollView *intonationView;

    /* Window pointers */
    IBOutlet NSWindow *synthesisWindow;

    MDataEntryController *dataEntryController;
    MPostureEditor *postureEditor;
    MPrototypeManager *newPrototypeManager;
    MTransitionEditor *transitionEditor;
    MSpecialTransitionEditor *specialTransitionEditor;
    MRuleTester *ruleTester;
    MRuleManager *ruleManager;
    MSynthesisParameterEditor *synthesisParameterEditor;
    MSynthesisController *synthesisController;
}

- (id)init;
- (void)dealloc;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;

- (void)displayInfoPanel:(id)sender;

- (IBAction)openFile:(id)sender;
- (IBAction)importTRMData:(id)sender;
- (IBAction)printData:(id)sender;


- (IBAction)archiveToDisk:(id)sender;
- (IBAction)readFromDisk:(id)sender;

- (IBAction)savePrototypes:(id)sender;
- (IBAction)loadPrototypes:(id)sender;

- (void)_disableUnconvertedClassLoading;

- (IBAction)showNewDataEntryWindow:(id)sender;
- (IBAction)showPostureEditor:(id)sender;
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

@end

/* NeXT Streams */
#undef NXRead
#define NXRead(fp, buf, size) fread(buf, size, 1, fp)

////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
//  
//  Contributors: Steve Nygard
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
////////////////////////////////////////////////////////////////////////////////
//
//  AppController.h
//  Monet
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.9.5
//
////////////////////////////////////////////////////////////////////////////////

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

@class MModel, MMTransition;
@class MDataEntryController, MPostureCategoryController, MPostureEditor, MPrototypeManager, MReleaseNotesController, MRuleManager, MRuleTester;
@class MSpecialTransitionEditor, MSynthesisController, MSynthesisParameterEditor, MTransitionEditor;
@class NSPanel, NSNotification;

@interface AppController : NSObject
{
    IBOutlet NSPanel *infoPanel;

    NSString *filename;
    MModel *model;

    MDataEntryController *dataEntryController;
    MPostureCategoryController *postureCategoryController;
    MPostureEditor *postureEditor;
    MPrototypeManager *prototypeManager;
    MTransitionEditor *transitionEditor;
    MSpecialTransitionEditor *specialTransitionEditor;
    MRuleTester *ruleTester;
    MRuleManager *ruleManager;
    MSynthesisParameterEditor *synthesisParameterEditor;
    MSynthesisController *synthesisController;
    MReleaseNotesController *releaseNotesController;
}

- (id)init;
- (void)dealloc;

- (void)setFilename:(NSString *)newFilename;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
- (void)applicationWillTerminate:(NSNotification *)notification;

- (void)displayInfoPanel:(id)sender;

- (IBAction)openFile:(id)sender;
- (IBAction)importTRMData:(id)sender;
- (IBAction)printData:(id)sender;

- (void)setModel:(MModel *)newModel;

- (void)_loadFile:(NSString *)aFilename;
- (void)_loadMonetFile:(NSString *)aFilename;
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

#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class NSFont;
@class MonetList, MMEquation, MMTransition;
@class AppController, DelegateResponder;
@class MModel;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface PrototypeManager : NSObject
{
    IBOutlet AppController *controller;

    IBOutlet NSBrowser *protoBrowser;
    IBOutlet NSControl *browserSelector; // TODO (2004-03-03): Not sure what type of control this is.

    IBOutlet NSButtonCell *newButton;
    IBOutlet NSButtonCell *removeButton;
    IBOutlet NSTextField *inputTextField;

    IBOutlet NSBox *outputBox;
    IBOutlet NSTextField *selectedOutput; // TODO (2004-03-03): Not sure about this.

    MModel *model;

    NSFont *courierFont;
    NSFont *courierBoldFont;

    DelegateResponder *delegateResponder;
}

- (id)init;
- (void)dealloc;

- (void)applicationDidFinishLaunching:(NSNotification *)notification;

- (MModel *)model;
- (void)setModel:(MModel *)newModel;

/* Browser Delegate Methods */
- (void)browserHit:(id)sender;
- (void)browserDoubleHit:(id)sender;
- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;

- (IBAction)addCategory:(id)sender;
- (IBAction)add:(id)sender;
- (IBAction)rename:(id)sender;
- (IBAction)remove:(id)sender;

- (IBAction)setEquations:(id)sender;
- (IBAction)setTransitions:(id)sender;
- (IBAction)setSpecial:(id)sender;

- (MonetList *)equationList;
- (MonetList *)transitionList;
- (MonetList *)specialList;

- (MMEquation *)findEquationList:(NSString *)aListName named:(NSString *)anEquationName;
- (void)findList:(int *)listIndex andIndex:(int *)equationIndex ofEquation:(MMEquation *)anEquation;
- (MMEquation *)findEquation:(int)listIndex andIndex:(int)equationIndex;

- (MMEquation *)findTransitionList:(NSString *)aListName named:(NSString *)aTransitionName;
- (void)findList:(int *)listIndex andIndex:(int *)transitionIndex ofTransition:(MMEquation *)aTransition;
- (MMEquation *)findTransition:(int)listIndex andIndex:(int)transitionIndex;

- (MMTransition *)findSpecialList:(NSString *)aListName named:(NSString *)aSpecialName;
- (void)findList:(int *)listIndex andIndex:(int *)specialIndex ofSpecial:(MMTransition *)aTransition;
- (MMTransition *)findSpecial:(int)listIndex andIndex:(int)specialIndex;

- (BOOL)isEquationUsed:(MMEquation *)anEquation;

- (IBAction)cut:(id)sender;
- (IBAction)copy:(id)sender;
- (IBAction)paste:(id)sender;

/* Window Delegate Methods */
- (void)windowDidBecomeMain:(NSNotification *)notification;
- (BOOL)windowShouldClose:(id)sender;
- (void)windowDidResignMain:(NSNotification *)notification;

@end

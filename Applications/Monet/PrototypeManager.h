#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class NSFont;
@class MonetList;
@class DelegateResponder, MyController;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface PrototypeManager : NSObject
{
    IBOutlet MyController *controller;

    IBOutlet NSBrowser *protoBrowser;
    IBOutlet NSControl *browserSelector; // TODO (2004-03-03): Not sure what type of control this is.

    IBOutlet NSButton *newButton;
    IBOutlet NSButton *removeButton;
    IBOutlet NSTextField *inputTextField;

    IBOutlet NSBox *outputBox;
    IBOutlet NSTextField *selectedOutput; // TODO (2004-03-03): Not sure about this.

    MonetList *protoEquations;
    MonetList *protoTemplates;
    MonetList *protoSpecial;

    NSFont *courier;
    NSFont *courierBold;

    DelegateResponder *delegateResponder;
}

- (id)init;
- (void)dealloc;

- (void)applicationDidFinishLaunching:(NSNotification *)notification;

/* Browser Delegate Methods */
- (void)browserHit:(id)sender;
- (void)browserDoubleHit:(id)sender;
- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;

- (void)addCategory:(id)sender;
- (void)add:(id)sender;
- (void)rename:(id)sender;
- (void)remove:(id)sender;

- (void)setEquations:(id)sender;
- (void)setTransitions:(id)sender;
- (void)setSpecial:(id)sender;

- (MonetList *)equationList;
- (MonetList *)transitionList;
- (MonetList *)specialList;

- findEquationList:(NSString *)list named:(NSString *)name;
- (void)findList:(int *)listIndex andIndex:(int *)index ofEquation:equation;
- findEquation:(int)listIndex andIndex:(int)index;

- findTransitionList:(NSString *)list named:(NSString *)name;
- (void)findList:(int *)listIndex andIndex:(int *)index ofTransition:transition;
- findTransition:(int)listIndex andIndex:(int)index;

- findSpecialList:(NSString *)list named:(NSString *)name;
- (void)findList:(int *)listIndex andIndex:(int *)index ofSpecial:transition;
- findSpecial:(int)listIndex andIndex:(int)index;

- (BOOL)isEquationUsed:anEquation;

- (void)cut:(id)sender;
- (void)copy:(id)sender;
- (void)paste:(id)sender;

- (void)readPrototypesFrom:(NSArchiver *)stream;
- (void)writePrototypesTo:(NSArchiver *)stream;

/* Window Delegate Methods */
- (void)windowDidBecomeMain:(NSNotification *)notification;
- (BOOL)windowShouldClose:(id)sender;
- (void)windowDidResignMain:(NSNotification *)notification;

@end

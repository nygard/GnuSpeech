#import <Foundation/NSObject.h>

@class NSFont;
@class MonetList;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface PrototypeManager : NSObject
{
    id controller;

    id protoBrowser;
    id browserSelector;

    id newButton;
    id removeButton;
    id inputTextField;

    id outputBox;
    id selectedOutput;

    MonetList *protoEquations;
    MonetList *protoTemplates;
    MonetList *protoSpecial;

    NSFont *courier;
    NSFont *courierBold;

    id delegateResponder;
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

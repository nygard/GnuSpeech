#import <Foundation/NSObject.h>

#ifdef PORTING
#import <Foundation/NSArray.h>
#import <AppKit/NSBrowser.h>
#import <AppKit/NSBrowserCell.h>
#import <AppKit/NSForm.h>
#import "NamedList.h"
#import <AppKit/NSFont.h>
#endif

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

- init;
- (void)applicationDidFinishLaunching:(NSNotification *)notification;

/* Window Delegate Methods */
- (void)windowDidBecomeMain:(NSNotification *)notification;
- (BOOL)windowShouldClose:(id)sender;
- (void)windowDidResignMain:(NSNotification *)notification;

/* Browser Delegate Methods */
- (void)browserHit:sender;
- (void)browserDoubleHit:sender;
- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;

- (void)add:sender;
- (void)addCategory:sender;
- (void)rename:sender;
- (void)remove:sender;

- (void)setEquations:sender;
- (void)setTransitions:sender;
- (void)setSpecial:sender;

- findEquationList:(NSString *)list named:(NSString *)name;
- findList:(int *)listIndex andIndex:(int *)index ofEquation:equation;
- findEquation:(int)listIndex andIndex:(int)index;

- findTransitionList: (const char *) list named: (const char *) name;
- findList: (int *) listIndex andIndex: (int *) index ofTransition: transition;
- findTransition: (int) listIndex andIndex: (int) index;

- findSpecialList: (const char *) list named: (const char *) name;
- findList: (int *) listIndex andIndex: (int *) index ofSpecial: transition;
- findSpecial: (int) listIndex andIndex: (int) index;

- equationList;
- transitionList;
- specialList;

- (BOOL) isEquationUsed: anEquation;

- (void)cut:(id)sender;
- (void)copy:(id)sender;
- (void)paste:(id)sender;

- (void)readPrototypesFrom:(NSArchiver *)stream;
- (void)writePrototypesTo:(NSArchiver *)stream;

@end

#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class NSFont;
@class MonetList, ProtoEquation;
@class AppController, DelegateResponder;

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

    MonetList *protoEquations; // Of NamedLists of ProtoEquations
    MonetList *protoTemplates; // Of NamedLists of ProtoTemplates
    MonetList *protoSpecial; // Of NamedLists of ProtoTemplates

    NSFont *courierFont;
    NSFont *courierBoldFont;

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

- (ProtoEquation *)findEquationList:(NSString *)aListName named:(NSString *)anEquationName;
- (void)findList:(int *)listIndex andIndex:(int *)equationIndex ofEquation:(ProtoEquation *)anEquation;
- (ProtoEquation *)findEquation:(int)listIndex andIndex:(int)equationIndex;

- (ProtoEquation *)findTransitionList:(NSString *)aListName named:(NSString *)aTransitionName;
- (void)findList:(int *)listIndex andIndex:(int *)transitionIndex ofTransition:(ProtoEquation *)aTransition;
- (ProtoEquation *)findTransition:(int)listIndex andIndex:(int)transitionIndex;

- (ProtoEquation *)findSpecialList:(NSString *)aListName named:(NSString *)aSpecialName;
- (void)findList:(int *)listIndex andIndex:(int *)specialIndex ofSpecial:(ProtoEquation *)aTransition;
- (ProtoEquation *)findSpecial:(int)listIndex andIndex:(int)specialIndex;

- (BOOL)isEquationUsed:(ProtoEquation *)anEquation;

- (IBAction)cut:(id)sender;
- (IBAction)copy:(id)sender;
- (IBAction)paste:(id)sender;

- (void)readPrototypesFrom:(NSArchiver *)stream;
- (void)writePrototypesTo:(NSArchiver *)stream;

/* Window Delegate Methods */
- (void)windowDidBecomeMain:(NSNotification *)notification;
- (BOOL)windowShouldClose:(id)sender;
- (void)windowDidResignMain:(NSNotification *)notification;

- (void)_setProtoEquations:(MonetList *)newProtoEquations;
- (void)_setProtoTemplates:(MonetList *)newProtoTemplates;
- (void)_setProtoSpecial:(MonetList *)newProtoSpecial;

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
- (void)_appendXMLForProtoEquationsToString:(NSMutableString *)resultString level:(int)level;
- (void)_appendXMLForProtoTemplatesToString:(NSMutableString *)resultString level:(int)level;
- (void)_appendXMLForProtoSpecialsToString:(NSMutableString *)resultString level:(int)level;

@end

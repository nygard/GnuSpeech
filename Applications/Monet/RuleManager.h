#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class NSBrowser, NSForm, NSMatrix, NSScrollView, NSTextField, NSTextView;
@class BooleanExpression, BooleanParser, MMCategory, MonetList, MMEquation, MMTransition, RuleList;
@class AppController, DelegateResponder;
@class MModel;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface RuleManager : NSObject
{
    int cacheValue;

    IBOutlet AppController *controller;

    IBOutlet NSBrowser *ruleMatrix;
    IBOutlet NSScrollView *ruleScrollView; // not used

    IBOutlet NSBrowser *matchBrowser1;
    IBOutlet NSBrowser *matchBrowser2;
    IBOutlet NSBrowser *matchBrowser3;
    IBOutlet NSBrowser *matchBrowser4;

    IBOutlet NSForm *expressionFields;
    IBOutlet NSTextField *errorTextField;
    IBOutlet NSTextField *possibleCombinations;

    BooleanParser *boolParser;

    MonetList *matchLists; // Of PhoneLists?
    BooleanExpression *expressions[4];

    MModel *model;

    IBOutlet NSForm *phone1;
    IBOutlet NSForm *phone2;
    IBOutlet NSForm *phone3;
    IBOutlet NSForm *phone4;
    IBOutlet NSTextField *ruleOutput;
    IBOutlet NSTextField *consumedTokens;
    IBOutlet NSForm *durationOutput;

    DelegateResponder *delegateResponder;
}

- (id)init;
- (void)dealloc;
- (void)applicationDidFinishLaunching:(NSNotification *)notification;

- (MModel *)model;
- (void)setModel:(MModel *)newModel;

// Browser actions
- (IBAction)browserHit:(id)sender;
- (IBAction)browserDoubleHit:(id)sender;

// Browser delegate methods
- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;

- (void)setExpression:(BooleanExpression *)anExpression atIndex:(int)index;

- (IBAction)setExpression:(id)sender;

- (void)realignExpressions;
- (void)evaluateMatchLists;
- (void)updateCombinations;
- (void)updateRuleDisplay;

- (IBAction)add:(id)sender;
- (IBAction)rename:(id)sender;
- (IBAction)remove:(id)sender;

- (IBAction)parseRule:(id)sender;

- (RuleList *)ruleList;

#if 1
- (void)addParameter;
- (void)addMetaParameter;
- (void)removeParameter:(int)index;
- (void)removeMetaParameter:(int)index;

/* Finding Stuff */

- (BOOL)isCategoryUsed:(MMCategory *)aCategory;
#endif
- (BOOL)isEquationUsed:(MMEquation *)anEquation;
- (BOOL)isTransitionUsed:(MMTransition *)aTransition;

- (void)findEquation:(MMEquation *)anEquation andPutIn:(MonetList *)aList;
- (void)findTemplate:(MMTransition *)aTemplate andPutIn:(MonetList *)aList;

- (IBAction)cut:(id)sender;
- (IBAction)copy:(id)sender;
- (IBAction)paste:(id)sender;

// Archiving
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

// Archiving - Degas support
- (void)readDegasFileFormat:(FILE *)fp;

// Window delegate methods
- (void)windowDidBecomeMain:(NSNotification *)notification;
- (BOOL)windowShouldClose:(id)sender;
- (void)windowDidResignMain:(NSNotification *)notification;

// Other
- (IBAction)shiftPhonesLeft:(id)sender;

@end

#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class NSBrowser, NSForm, NSMatrix, NSScrollView, NSTextField, NSTextView;
@class BooleanParser, CategoryNode, MonetList, ProtoEquation, ProtoTemplate, RuleList;
@class AppController, DelegateResponder;

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
    IBOutlet NSScrollView *ruleScrollView;

    IBOutlet NSBrowser *matchBrowser1;
    IBOutlet NSBrowser *matchBrowser2;
    IBOutlet NSBrowser *matchBrowser3;
    IBOutlet NSBrowser *matchBrowser4;

    IBOutlet NSForm *expressionFields;
    IBOutlet NSTextField *errorTextField;
    IBOutlet NSTextField *possibleCombinations;

    BooleanParser *boolParser;

    MonetList *matchLists;
    MonetList *expressions;

    RuleList *ruleList;

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

// Browser actions
- (IBAction)browserHit:(id)sender;
- (IBAction)browserDoubleHit:(id)sender;

// Browser delegate methods
- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;

- (IBAction)setExpression1:(id)sender;
- (IBAction)setExpression2:(id)sender;
- (IBAction)setExpression3:(id)sender;
- (IBAction)setExpression4:(id)sender;

- (void)realignExpressions;
- (void)evaluateMatchLists;
- (void)updateCombinations;
- (void)updateRuleDisplay;

- (IBAction)add:(id)sender;
- (IBAction)rename:(id)sender;
- (IBAction)remove:(id)sender;

- (IBAction)parseRule:(id)sender;

- (RuleList *)ruleList;

- (void)addParameter;
- (void)addMetaParameter;
- (void)removeParameter:(int)index;
- (void)removeMetaParameter:(int)index;

/* Finding Stuff */

- (BOOL)isCategoryUsed:(CategoryNode *)aCategory;
- (BOOL)isEquationUsed:(ProtoEquation *)anEquation;
- (BOOL)isTransitionUsed:(ProtoTemplate *)aTransition;

- (void)findEquation:(ProtoEquation *)anEquation andPutIn:(MonetList *)aList;
- (void)findTemplate:(ProtoTemplate *)aTemplate andPutIn:(MonetList *)aList;

- (IBAction)cut:(id)sender;
- (IBAction)copy:(id)sender;
- (IBAction)paste:(id)sender;

// Archiving
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

// Archiving - NS Compatibility
- (void)readRulesFrom:(NSArchiver *)stream;
- (void)writeRulesTo:(NSArchiver *)stream;

// Archiving - Degas support
- (void)readDegasFileFormat:(FILE *)fp;

// Window delegate methods
- (void)windowDidBecomeMain:(NSNotification *)notification;
- (BOOL)windowShouldClose:(id)sender;
- (void)windowDidResignMain:(NSNotification *)notification;

// Other
- (IBAction)shiftPhonesLeft:(id)sender;

// Archiving - XML
- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;

@end

#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class NSBrowser, NSForm, NSMatrix, NSScrollView, NSTextField, NSTextView;
@class BooleanParser, DelegateResponder, MonetList, MyController, RuleList;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface RuleManager : NSObject
{
    int cacheValue;

    IBOutlet MyController *controller;

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

- (void)browserHit:sender;
- (void)browserDoubleHit:sender;
- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;

- (NSString *)expressionStringForRule:(int)index;

- (void)setExpression1:sender;
- (void)setExpression2:sender;
- (void)setExpression3:sender;
- (void)setExpression4:sender;

- (void)realignExpressions;
- (void)evaluateMatchLists;
- (void)updateCombinations;
- (void)updateRuleDisplay;

- (void)add:sender;
- (void)rename:sender;
- (void)remove:sender;

- (void)parseRule:sender;

- (RuleList *)ruleList;

- (void)addParameter;
- (void)addMetaParameter;
- (void)removeParameter:(int)index;
- (void)removeMetaParameter:(int)index;

/* Finding Stuff */

- (BOOL)isCategoryUsed:aCategory;
- (BOOL)isEquationUsed:anEquation;
- (BOOL)isTransitionUsed:aTransition;

- findEquation:anEquation andPutIn:(MonetList *)aList;
- findTemplate:aTemplate andPutIn:aList;

- (void)cut:(id)sender;
- (void)copy:(id)sender;
- (void)paste:(id)sender;

- (void)readDegasFileFormat:(FILE *)fp;

- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

- (void)readRulesFrom:(NSArchiver *)stream;
- (void)writeRulesTo:(NSArchiver *)stream;

/* Window Delegate Methods */
- (void)windowDidBecomeMain:(NSNotification *)notification;
- (BOOL)windowShouldClose:(id)sender;
- (void)windowDidResignMain:(NSNotification *)notification;

@end

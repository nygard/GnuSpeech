#import "ProtoEquationInspector.h"

#import <AppKit/AppKit.h>
#import "AppController.h"
#import "FormulaExpression.h"
#import "FormulaParser.h"
#import "Inspector.h"
#import "MonetList.h"
#import "NamedList.h"
#import "MMEquation.h"
#import "PrototypeManager.h"
#import "RuleList.h"
#import "RuleManager.h"

@implementation ProtoEquationInspector

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
    [commentView retain];
    [equationBox retain];
    [usageBox retain];
    [popUpListView retain];

    [usageBrowser setTarget:self];
    [usageBrowser setAction:@selector(browserHit:)];
    [usageBrowser setDoubleAction:@selector(browserDoubleHit:)];
}

- (id)init;
{
    if ([super init] == nil)
        return nil;

    formulaParser = [[FormulaParser alloc] init];
    equationList = [[MonetList alloc] initWithCapacity:20];

    return self;
}

- (void)dealloc;
{
    [commentView release];
    [equationBox release];
    [usageBox release];
    [popUpListView release];

    [formulaParser release];
    [equationList release];
    [currentMMEquation release];

    [super dealloc];
}

- (void)setCurrentMMEquation:(MMEquation *)anEquation;
{
    if (anEquation == currentMMEquation)
        return;

    [currentMMEquation release];
    currentMMEquation = [anEquation retain];
}

- (void)inspectMMEquation:(MMEquation *)anEquation;
{
    [self setCurrentMMEquation:anEquation];
    [mainInspector setPopUpListView:popUpListView];
    [self setUpWindow:popUpList];
}

- (void)setUpWindow:(NSPopUpButton *)sender;
{
    PrototypeManager *prototypeManager = NXGetNamedObject(@"prototypeManager", NSApp);
    RuleManager *tempRuleManager = NXGetNamedObject(@"ruleManager", NSApp);
    NSString *str;
    int index1, index2;
    int i, j;
    id tempList1, tempList2;

    str = [[sender selectedCell] title];
    if ([str hasPrefix:@"C"]) {
        /* Comment Window */
        [mainInspector setGeneralView:commentView];

        [setCommentButton setTarget:self];
        [setCommentButton setAction:@selector(setComment:)];

        [revertCommentButton setTarget:self];
        [revertCommentButton setAction:@selector(revertComment:)];

        if ([currentMMEquation comment] != nil)
            [commentText setString:[currentMMEquation comment]];
        else
            [commentText setString:@""];
    } else if ([str hasPrefix:@"E"]) {
        NSString *equation;

        [mainInspector setGeneralView:equationBox];

        [setEquationButton setTarget:self];
        [setEquationButton setAction:@selector(setEquation:)];

        [revertEquationButton setTarget:self];
        [revertEquationButton setAction:@selector(revertEquation:)];

        [equationText setString:[[currentMMEquation expression] expressionString]];

        [prototypeManager findList:&index1 andIndex:&index2 ofEquation:currentMMEquation];
        equation = [NSString stringWithFormat:@"%@:%@",
                             [(NamedList *)[[prototypeManager equationList] objectAtIndex:index1] name],
                             [(MMEquation *)[[[prototypeManager equationList] objectAtIndex:index1] objectAtIndex:index2] name]];

        [currentEquationField setStringValue:equation];
    } else if ([str hasPrefix:@"U"]) {
        [usageBrowser setDelegate:self];
        [usageBrowser setTarget:self];
        [usageBrowser setAction:@selector(browserHit:)];
        [usageBrowser setDoubleAction:@selector(browserDoubleHit:)];
        [mainInspector setGeneralView:usageBox];
        [usageBrowser setDelegate:self];
        [equationList removeAllObjects];
        [tempRuleManager findEquation:currentMMEquation andPutIn:equationList];

        tempList1 = [prototypeManager transitionList];
        for (i = 0; i < [tempList1 count]; i++) {
            tempList2 = [tempList1 objectAtIndex:i];
            for (j = 0; j < [tempList2 count]; j++)
                [[tempList2 objectAtIndex:j] findEquation:currentMMEquation andPutIn:equationList];
        }
        tempList1 = [prototypeManager specialList];
        for (i = 0; i < [tempList1 count]; i++) {
            tempList2 = [tempList1 objectAtIndex:i];
            for (j = 0; j < [tempList2 count]; j++)
                [[tempList2 objectAtIndex:j] findEquation:currentMMEquation andPutIn:equationList];
        }

        [usageBrowser loadColumnZero];
    }
}

- (void)beginEditting;
{
    NSString *str;

    str = [[popUpList selectedCell] title];
    if ([str hasPrefix:@"C"]) {
        /* Comment Window */
        [commentText selectAll:self];
    } else if ([str hasPrefix:@"E"]) {
    }
}

- (IBAction)setComment:(id)sender;
{
    NSString *newComment;

    // TODO (2004-03-13): Maybe just copy it in the -setComment: method, hopefully in a common base class.
    newComment = [[commentText string] copy]; // Need to copy, becuase it's mutable and owned by the NSTextView
    [currentMMEquation setComment:newComment];
    [newComment release];
}

- (IBAction)revertComment:(id)sender;
{
    if ([currentMMEquation comment] != nil)
        [commentText setString:[currentMMEquation comment]];
    else
        [commentText setString:@""];
}

- (IBAction)setEquation:(id)sender;
{
    FormulaExpression *result;
    NSString *str;

    [formulaParser setSymbolList:NXGetNamedObject(@"mainSymbolList", NSApp)];

    result = [formulaParser parseString:[equationText string]];
    NSLog(@"%s, result: %p", _cmd, result);
    str = [formulaParser errorMessage];
    NSLog(@"errorMessage: '%@'", str);
    if ([str length] == 0)
        str = @"Equation parsed.";
    [messagesText setString:str];
    if (result == nil) {
        NSRange errorRange;

        errorRange.location = [formulaParser errorLocation];
        errorRange.length = [[equationText string] length];
        NSLog(@"errorRange (1): %@", NSStringFromRange(errorRange));
        if (errorRange.location > errorRange.length)
            errorRange.length = 0;
        else
            errorRange.length -= errorRange.location;
        NSLog(@"errorRange (2): %@", NSStringFromRange(errorRange));

        [equationText setSelectedRange:errorRange];
    } else {
        [currentMMEquation setExpression:result];
    }
}

- (IBAction)revertEquation:(id)sender;
{
    [equationText setString:[[currentMMEquation expression] expressionString]];
    [messagesText setString:@""];
}

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
{
    [usageBrowser setTitle:[NSString stringWithFormat:@"Equation Usage: %d", [equationList count]] ofColumn:0];

    return [equationList count];
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
{
    RuleManager *tempRuleManager = NXGetNamedObject(@"ruleManager", NSApp);
    PrototypeManager *prototypeManager = NXGetNamedObject(@"prototypeManager", NSApp);
    id tempRuleList;
    NSString *str;
    int i, j;

    tempRuleList = [tempRuleManager ruleList];
    [cell setLeaf:YES];
    [cell setLoaded:YES];

    if ([[equationList objectAtIndex:row] isKindOfClass:[Rule class]]) {
        str = [NSString stringWithFormat:@"Rule: %d\n",
                        [tempRuleList indexOfObject:[equationList objectAtIndex:row]] + 1];
        [cell setStringValue:str];
    } else {
        [prototypeManager findList:&i andIndex:&j ofTransition:[equationList objectAtIndex:row]];
        if (i >= 0) {
            str = [NSString stringWithFormat:@"T:%@:%@",
                            [(NamedList *)[[prototypeManager transitionList] objectAtIndex:i] name],
                            [(MMEquation *)[[[prototypeManager transitionList] objectAtIndex:i] objectAtIndex:j] name]];
            [cell setStringValue:str];
        } else {
            [prototypeManager findList:&i andIndex:&j ofSpecial:[equationList objectAtIndex:row]];
            if (i >= 0) {
                str = [NSString stringWithFormat:@"S:%@:%@",
                                [(NamedList *)[[prototypeManager specialList] objectAtIndex:i] name],
                                [(MMEquation *)[[[prototypeManager specialList] objectAtIndex:i] objectAtIndex:j] name]];
                [cell setStringValue:str];
            }
        }
    }
}

- (IBAction)browserHit:(id)sender;
{
}

- (IBAction)browserDoubleHit:(id)sender;
{
}

@end

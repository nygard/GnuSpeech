#import "ProtoEquationInspector.h"

#import <AppKit/AppKit.h>
#import "AppController.h"
#import "FormulaExpression.h"
#import "FormulaParser.h"
#import "Inspector.h"
#import "MonetList.h"
#import "NamedList.h"
#import "ProtoEquation.h"
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

    formParser = [[FormulaParser alloc] init];
    equationList = [[MonetList alloc] initWithCapacity:20];

    return self;
}

- (void)dealloc;
{
    [commentView release];
    [equationBox release];
    [usageBox release];
    [popUpListView release];

    [formParser release];
    [equationList release];
    [currentProtoEquation release];

    [super dealloc];
}

- (void)setCurrentProtoEquation:(ProtoEquation *)anEquation;
{
    if (anEquation == currentProtoEquation)
        return;

    [currentProtoEquation release];
    currentProtoEquation = [anEquation retain];
}

- (void)inspectProtoEquation:(ProtoEquation *)anEquation;
{
    [self setCurrentProtoEquation:anEquation];
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

        if ([currentProtoEquation comment] != nil)
            [commentText setString:[currentProtoEquation comment]];
        else
            [commentText setString:@""];
    } else if ([str hasPrefix:@"E"]) {
        NSString *equation;

        [mainInspector setGeneralView:equationBox];

        [setEquationButton setTarget:self];
        [setEquationButton setAction:@selector(setEquation:)];

        [revertEquationButton setTarget:self];
        [revertEquationButton setAction:@selector(revertEquation:)];

        [equationText setString:[[currentProtoEquation expression] expressionString]];

        [prototypeManager findList:&index1 andIndex:&index2 ofEquation:currentProtoEquation];
        equation = [NSString stringWithFormat:@"%@:%@",
                             [(NamedList *)[[prototypeManager equationList] objectAtIndex:index1] name],
                             [(ProtoEquation *)[[[prototypeManager equationList] objectAtIndex:index1] objectAtIndex:index2] name]];

        [currentEquationField setStringValue:equation];
    } else if ([str hasPrefix:@"U"]) {
        [usageBrowser setDelegate:self];
        [usageBrowser setTarget:self];
        [usageBrowser setAction:@selector(browserHit:)];
        [usageBrowser setDoubleAction:@selector(browserDoubleHit:)];
        [mainInspector setGeneralView:usageBox];
        [usageBrowser setDelegate:self];
        [equationList removeAllObjects];
        [tempRuleManager findEquation:currentProtoEquation andPutIn:equationList];

        tempList1 = [prototypeManager transitionList];
        for (i = 0; i < [tempList1 count]; i++) {
            tempList2 = [tempList1 objectAtIndex:i];
            for (j = 0; j < [tempList2 count]; j++)
                [[tempList2 objectAtIndex:j] findEquation:currentProtoEquation andPutIn:equationList];
        }
        tempList1 = [prototypeManager specialList];
        for (i = 0; i < [tempList1 count]; i++) {
            tempList2 = [tempList1 objectAtIndex:i];
            for (j = 0; j < [tempList2 count]; j++)
                [[tempList2 objectAtIndex:j] findEquation:currentProtoEquation andPutIn:equationList];
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
    [currentProtoEquation setComment:[commentText string]];
}

- (IBAction)revertComment:(id)sender;
{
    if ([currentProtoEquation comment] != nil)
        [commentText setString:[currentProtoEquation comment]];
    else
        [commentText setString:@""];
}

- (IBAction)setEquation:(id)sender;
{
    id temp;

    [formParser setSymbolList:NXGetNamedObject(@"mainSymbolList", NSApp)];

    temp = [formParser parseString:[equationText string]];
    if (temp == nil) {
        [messagesText setString:[formParser errorMessage]];
    } else {
        [currentProtoEquation setExpression:temp];
    }
}

- (IBAction)revertEquation:(id)sender;
{
    [equationText setString:[[currentProtoEquation expression] expressionString]];
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
                        [tempRuleList indexOfObject:[equationList objectAtIndex:row]]+1];
        [cell setStringValue:str];
    } else {
        [prototypeManager findList:&i andIndex:&j ofTransition:[equationList objectAtIndex:row]];
        if (i >= 0) {
            str = [NSString stringWithFormat:@"T:%@:%@",
                            [(NamedList *)[[prototypeManager transitionList] objectAtIndex:i] name],
                            [(ProtoEquation *)[[[prototypeManager transitionList] objectAtIndex:i] objectAtIndex:j] name]];
            [cell setStringValue:str];
        } else {
            [prototypeManager findList:&i andIndex:&j ofSpecial:[equationList objectAtIndex:row]];
            if (i >= 0) {
                str = [NSString stringWithFormat:@"S:%@:%@",
                                [(NamedList *)[[prototypeManager specialList] objectAtIndex:i] name],
                                [(ProtoEquation *)[[[prototypeManager specialList] objectAtIndex:i] objectAtIndex:j] name]];
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

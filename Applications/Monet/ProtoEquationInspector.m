#import "ProtoEquationInspector.h"

#import <AppKit/AppKit.h>
#import "AppController.h"
#import "FormulaParser.h"
#import "Inspector.h"
#import "MonetList.h"
#import "ProtoEquation.h"
#import "PrototypeManager.h"
#import "RuleList.h"
#import "RuleManager.h"

@implementation ProtoEquationInspector

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
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
    [formParser release];
    [equationList release];

    [super dealloc];
}

- (void)inspectProtoEquation:equation;
{
    protoEquation = equation;
    [mainInspector setPopUpListView:popUpListView];
    [self setUpWindow:popUpList];
}

- (void)setUpWindow:(NSPopUpButton *)sender;
{
    PrototypeManager *tempProto = NXGetNamedObject(@"prototypeManager", NSApp);
    RuleManager *tempRuleManager = NXGetNamedObject(@"ruleManager", NSApp);
    PrototypeManager *tempProtoManager = NXGetNamedObject(@"prototypeManager", NSApp); // TODO (2004-03-03): We shouldn't need the dupe
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

        [commentText setString:[protoEquation comment]];
    } else if ([str hasPrefix:@"E"]) {
        NSString *equation;

        [mainInspector setGeneralView:equationBox];

        [setEquationButton setTarget:self];
        [setEquationButton setAction:@selector(setEquation:)];

        [revertEquationButton setTarget:self];
        [revertEquationButton setAction:@selector(revertEquation:)];

        [equationText setString:[[protoEquation expression] expressionString]];

        [tempProto findList:&index1 andIndex:&index2 ofEquation:protoEquation];
        equation = [NSString stringWithFormat:@"%@:%@",
                             [(ProtoEquation *)[[tempProto equationList] objectAtIndex:index1] name],
                             [(ProtoEquation *)[[[tempProto equationList] objectAtIndex:index1] objectAtIndex:index2] name]];

        [currentEquationField setStringValue:equation];
    } else if ([str hasPrefix:@"U"]) {
        [usageBrowser setDelegate:self];
        [usageBrowser setTarget:self];
        [usageBrowser setAction:@selector(browserHit:)];
        [usageBrowser setDoubleAction:@selector(browserDoubleHit:)];
        [mainInspector setGeneralView:usageBox];
        [usageBrowser setDelegate:self];
        [equationList removeAllObjects];
        [tempRuleManager findEquation:protoEquation andPutIn:equationList];

        tempList1 = [tempProtoManager transitionList];
        for (i = 0; i < [tempList1 count]; i++) {
            tempList2 = [tempList1 objectAtIndex:i];
            for (j = 0; j < [tempList2 count]; j++)
                [[tempList2 objectAtIndex:j] findEquation:protoEquation andPutIn:equationList];
        }
        tempList1 = [tempProtoManager specialList];
        for (i = 0; i < [tempList1 count]; i++) {
            tempList2 = [tempList1 objectAtIndex:i];
            for (j = 0; j < [tempList2 count]; j++)
                [[tempList2 objectAtIndex:j] findEquation:protoEquation andPutIn:equationList];
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

- (void)setComment:(id)sender;
{
    [protoEquation setComment:[commentText string]];
}

- (void)revertComment:(id)sender;
{
    [commentText setString:[protoEquation comment]];
}

- (void)setEquation:(id)sender;
{
    id temp;

    [formParser setSymbolList:NXGetNamedObject(@"mainSymbolList", NSApp)];

    temp = [formParser parseString:[equationText string]];
    if (temp == nil) {
        [messagesText setString:[formParser errorMessage]];
    } else {
        [protoEquation setExpression:temp];
    }
}

- (void)revertEquation:(id)sender;
{
    [equationText setString:[[protoEquation expression] expressionString]];
}

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
{
    [usageBrowser setTitle:[NSString stringWithFormat:@"Equation Usage: %d", [equationList count]] ofColumn:0];
    return [equationList count];
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
{
    RuleManager *tempRuleManager = NXGetNamedObject(@"ruleManager", NSApp);
    PrototypeManager *tempProtoManager = NXGetNamedObject(@"prototypeManager", NSApp);
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
        [tempProtoManager findList:&i andIndex:&j ofTransition:[equationList objectAtIndex:row]];
        if (i >= 0) {
            str = [NSString stringWithFormat:@"T:%@:%@",
                            [(ProtoEquation *)[[tempProtoManager transitionList] objectAtIndex:i] name],
                            [(ProtoEquation *)[[[tempProtoManager transitionList] objectAtIndex:i] objectAtIndex:j] name]];
            [cell setStringValue:str];
        } else {
            [tempProtoManager findList:&i andIndex:&j ofSpecial:[equationList objectAtIndex:row]];
            if (i >= 0) {
                str = [NSString stringWithFormat:@"S:%@:%@",
                                [(ProtoEquation *)[[tempProtoManager specialList] objectAtIndex:i] name],
                                [(ProtoEquation *)[[[tempProtoManager specialList] objectAtIndex:i] objectAtIndex:j] name]];
                [cell setStringValue:str];
            }
        }
    }
}

- (void)browserHit:(id)sender;
{
}

- (void)browserDoubleHit:(id)sender;
{
}

@end

#import "ProtoTemplateInspector.h"

#import <AppKit/AppKit.h>
#import "AppController.h"
#import "FormulaParser.h"
#import "Inspector.h"
#import "RuleManager.h"
#import "MonetList.h"
#import "ProtoTemplate.h"
#import "Rule.h"

@implementation ProtoTemplateInspector

- (id)init;
{
    if ([super init] == nil)
        return nil;

    formParser = [[FormulaParser alloc] init];
    templateList = [[MonetList alloc] initWithCapacity:20];

    return self;
}

- (void)dealloc;
{
    [formParser release];
    [templateList release];

    [super dealloc];
}

- (void)inspectProtoTemplate:template;
{
    protoTemplate = template;
    [mainInspector setPopUpListView:popUpListView];
    [self setUpWindow:popUpList];
}

- (void)setUpWindow:(NSPopUpButton *)sender;
{
    RuleManager *tempRuleManager = NXGetNamedObject(@"ruleManager", NSApp);
    NSString *str;

    str = [[sender selectedCell] title];
    if ([str hasPrefix:@"C"]) {
        /* Comment Window */
        [mainInspector setGeneralView:commentView];

        [setCommentButton setTarget:self];
        [setCommentButton setAction:@selector(setComment:)];

        [revertCommentButton setTarget:self];
        [revertCommentButton setAction:@selector(revertComment:)];

        [commentText setString:[protoTemplate comment]];
    } else if ([str hasPrefix:@"G"]) {
        [mainInspector setGeneralView:genInfoView];

        switch ([protoTemplate type]) {
          case DIPHONE:
              [typeMatrix selectCellAtRow:0 column:0];
              break;
          case TRIPHONE:
              [typeMatrix selectCellAtRow:1 column:0];
              break;
          case TETRAPHONE:
              [typeMatrix selectCellAtRow:2 column:0];
              break;
        }
        [typeMatrix display];
    } else if ([str hasPrefix:@"U"]) {
        [usageBrowser setDelegate:self];
        [usageBrowser setTarget:self];
        [usageBrowser setAction:@selector(browserHit:)];
        [usageBrowser setDoubleAction:@selector(browserDoubleHit:)];
        [mainInspector setGeneralView:usageBox];
        [templateList removeAllObjects];
        [tempRuleManager findTemplate:protoTemplate andPutIn:templateList];

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
    }
}

- (void)setComment:(id)sender;
{
    [protoTemplate setComment:[commentText string]];
}

- (void)revertComment:(id)sender;
{
    [commentText setString:[protoTemplate comment]];
}

- (void)setDiphone:(id)sender;
{
    [protoTemplate setType:DIPHONE];
    [NXGetNamedObject(@"transitionBuilder", NSApp) display];
    [NXGetNamedObject(@"specialTransitionBuilder", NSApp) display];
}

- (void)setTriphone:(id)sender;
{
    [protoTemplate setType:TRIPHONE];
    [NXGetNamedObject(@"transitionBuilder", NSApp) display];
    [NXGetNamedObject(@"specialTransitionBuilder", NSApp) display];
}

- (void)setTetraphone:(id)sender;
{
    [protoTemplate setType:TETRAPHONE];
    [NXGetNamedObject(@"transitionBuilder", NSApp) display];
    [NXGetNamedObject(@"specialTransitionBuilder", NSApp) display];
}

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
{
    NSString *str;

    str = [NSString stringWithFormat:@"Equation Usage: %d", [templateList count]];
    [usageBrowser setTitle:str ofColumn:0];

    return [templateList count];
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
{
    RuleManager *tempRuleManager = NXGetNamedObject(@"ruleManager", NSApp);
    id tempRuleList;

    tempRuleList = [tempRuleManager ruleList];
    [cell setLeaf:YES];
    [cell setLoaded:YES];

    if ([[templateList objectAtIndex: row] isKindOfClass:[Rule class]]) {
        NSString *str;

        str = [NSString stringWithFormat:@"Rule: %d", [tempRuleList indexOfObject:[templateList objectAtIndex:row]]+1];
        [cell setStringValue:str];
    }
}

- (void)browserHit:(id)sender;
{
}

- (void)browserDoubleHit:(id)sender;
{
}


@end

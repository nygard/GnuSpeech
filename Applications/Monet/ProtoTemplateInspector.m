#import "ProtoTemplateInspector.h"

#import <AppKit/AppKit.h>
#import "AppController.h"
#import "Inspector.h"
#import "RuleManager.h"
#import "MonetList.h"
#import "MMTransition.h"
#import "MMRule.h"

@implementation ProtoTemplateInspector

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
    // TODO (2004-03-14): We'll add an extra retain every time we load a file... That should be handled differently.
    [commentView retain];
    [genInfoView retain];
    [usageBox retain];
    [popUpListView retain];
}

- (id)init;
{
    if ([super init] == nil)
        return nil;

    templateList = [[MonetList alloc] initWithCapacity:20];

    return self;
}

- (void)dealloc;
{
    [commentView release];
    [genInfoView release];
    [usageBox release];
    [popUpListView release];

    [templateList release];
    [currentTransition release];

    [super dealloc];
}

- (void)setCurrentMMTransition:(MMTransition *)aTemplate;
{
    if (aTemplate == currentTransition)
        return;

    [currentTransition release];
    currentTransition = [aTemplate retain];
}

- (void)inspectMMTransition:(MMTransition *)aTemplate;
{
    [self setCurrentMMTransition:aTemplate];
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

        if ([currentTransition comment] != nil)
            [commentText setString:[currentTransition comment]];
        else
            [commentText setString:@""];
    } else if ([str hasPrefix:@"G"]) {
        [mainInspector setGeneralView:genInfoView];

        switch ([currentTransition type]) {
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
        [tempRuleManager findTemplate:currentTransition andPutIn:templateList];

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

- (IBAction)setComment:(id)sender;
{
    NSString *newComment;

    newComment = [[commentText string] copy]; // Need to copy, becuase it's mutable and owned by the NSTextView
    [currentTransition setComment:newComment];
    [newComment release];
}

- (IBAction)revertComment:(id)sender;
{
    if ([currentTransition comment] != nil)
        [commentText setString:[currentTransition comment]];
    else
        [commentText setString:@""];
}

- (IBAction)setDiphone:(id)sender;
{
    [currentTransition setType:DIPHONE];
    [NXGetNamedObject(@"transitionBuilder", NSApp) display];
    [NXGetNamedObject(@"specialTransitionBuilder", NSApp) display];
}

- (IBAction)setTriphone:(id)sender;
{
    [currentTransition setType:TRIPHONE];
    [NXGetNamedObject(@"transitionBuilder", NSApp) display];
    [NXGetNamedObject(@"specialTransitionBuilder", NSApp) display];
}

- (IBAction)setTetraphone:(id)sender;
{
    [currentTransition setType:TETRAPHONE];
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

    if ([[templateList objectAtIndex: row] isKindOfClass:[MMRule class]]) {
        NSString *str;

        str = [NSString stringWithFormat:@"Rule: %d", [tempRuleList indexOfObject:[templateList objectAtIndex:row]]+1];
        [cell setStringValue:str];
    }
}

- (IBAction)browserHit:(id)sender;
{
}

- (IBAction)browserDoubleHit:(id)sender;
{
}


@end

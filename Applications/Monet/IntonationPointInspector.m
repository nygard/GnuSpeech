#import "IntonationPointInspector.h"

#import <AppKit/AppKit.h>
#include <math.h>
#import "AppController.h"
#import "EventList.h"
#import "Inspector.h"
#import "IntonationPoint.h"
#import "IntonationView.h"
#import "Phone.h"

#define MIDDLEC	261.6255653

@implementation IntonationPointInspector

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
}

- (void)inspectIntonationPoint:point;
{
    currentPoint = point;
    [mainInspector setPopUpListView:popUpListView];
    [self setUpWindow:popUpList];
}

- (void)setUpWindow:(NSPopUpButton *)sender;
{
    NSString *str;

    str = [[sender selectedCell] title];
    if ([str hasPrefix:@"G"]) {
        [mainInspector setGeneralView:mainBox];
        [self updateInspector];

        [ruleBrowser loadColumnZero];

        [[ruleBrowser matrixInColumn:0] scrollCellToVisibleAtRow:[currentPoint ruleIndex] column:0];
        [[ruleBrowser matrixInColumn:0] selectCellAtRow:[currentPoint ruleIndex] column:0];

        [ruleBrowser setTarget:self];
        [ruleBrowser setAction:@selector(browserHit:)];
        [ruleBrowser setDoubleAction:@selector(browserDoubleHit:)];
    }
}

- (void)beginEditting;
{
    NSString *str;

    str = [[popUpList selectedCell] title];
    if ([str hasPrefix:@"C"]) {
        /* Comment Window */
        //[commentText selectAll:self];
    } else if ([str hasPrefix:@"D"]) {
    }
}

- (void)browserHit:(id)sender;
{
    IntonationView *tempView = NXGetNamedObject(@"intonationView", NSApp);
    int index;

    index = [[ruleBrowser matrixInColumn:0] selectedRow];
    [currentPoint setRuleIndex:index];
    [[tempView documentView] addIntonationPoint:currentPoint];
    [tempView display];
    [self updateInspector];
}

- (void)browserDoubleHit:(id)sender;
{
}

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
{
    return [[currentPoint eventList] numberOfRules];
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
{
    int i;
    struct _rule *rule;
    NSMutableString *str;

    [cell setLoaded:YES];
    [cell setLeaf:YES];

    rule = [[currentPoint eventList] getRuleAtIndex:row];

    str = [[NSMutableString alloc] init];
    for (i = rule->firstPhone; i <= rule->lastPhone; i++) {
        [str appendString:[[[currentPoint eventList] getPhoneAtIndex:i] symbol]];
        if (i == rule->lastPhone)
            break;
        [str appendString:@" > "];
    }

    [cell setStringValue:str];
    [str release];
}

- (void)setSemitone:(id)sender;
{
    IntonationView *tempView = NXGetNamedObject(@"intonationView", NSApp);

    [currentPoint setSemitone:[sender doubleValue]];
    [tempView display];
    [self updateInspector];
}

- (void)setHertz:(id)sender;
{
    IntonationView *tempView = NXGetNamedObject(@"intonationView", NSApp);
    double temp;

    temp = 12.0 * (log10([sender doubleValue]/MIDDLEC)/log10(2.0));
    [currentPoint setSemitone:temp];
    [tempView display];
    [self updateInspector];
}

- (void)setSlope:(id)sender;
{
    IntonationView *tempView = NXGetNamedObject(@"intonationView", NSApp);

    [currentPoint setSlope:[sender doubleValue]];
    [tempView display];
    [self updateInspector];
}

- (void)setBeatOffset:(id)sender;
{
    IntonationView *tempView = NXGetNamedObject(@"intonationView", NSApp);

    [currentPoint setOffsetTime:[sender doubleValue]];
    [[tempView documentView] addIntonationPoint:currentPoint];
    [tempView display];
    [self updateInspector];
}

- (void)updateInspector;
{
    double temp;

    temp = pow(2, [currentPoint semitone]/12.0)*MIDDLEC;
    [semitoneField setDoubleValue:[currentPoint semitone]];
    [hertzField setDoubleValue:temp];
    [slopeField setDoubleValue:[currentPoint slope]];
    [beatField setDoubleValue:[currentPoint beatTime]];
    [beatOffsetField setDoubleValue:[currentPoint offsetTime]];
    [absTimeField setDoubleValue:[currentPoint absoluteTime]];
}

@end

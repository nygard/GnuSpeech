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
    [mainBox retain];
    [popUpListView retain];
}

- (void)dealloc;
{
    [mainBox release];
    [popUpListView release];

    [currentIntonationPoint release];

    [super dealloc];
}

- (void)setCurrentIntonationPoint:(IntonationPoint *)anIntonationPoint;
{
    if (anIntonationPoint == currentIntonationPoint)
        return;

    [currentIntonationPoint release];
    currentIntonationPoint = [anIntonationPoint retain];
}

- (void)inspectIntonationPoint:(IntonationPoint *)anIntonationPoint;
{
    [self setCurrentIntonationPoint:anIntonationPoint];
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

        [[ruleBrowser matrixInColumn:0] scrollCellToVisibleAtRow:[currentIntonationPoint ruleIndex] column:0];
        [[ruleBrowser matrixInColumn:0] selectCellAtRow:[currentIntonationPoint ruleIndex] column:0];

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

- (IBAction)browserHit:(id)sender;
{
    IntonationView *tempView = NXGetNamedObject(@"intonationView", NSApp);
    int index;

    index = [[ruleBrowser matrixInColumn:0] selectedRow];
    [currentIntonationPoint setRuleIndex:index];
    [[tempView documentView] addIntonationPoint:currentIntonationPoint];
    [tempView display];
    [self updateInspector];
}

- (IBAction)browserDoubleHit:(id)sender;
{
}

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
{
    return [[currentIntonationPoint eventList] numberOfRules];
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
{
    int i;
    struct _rule *rule;
    NSMutableString *str;

    [cell setLoaded:YES];
    [cell setLeaf:YES];

    rule = [[currentIntonationPoint eventList] getRuleAtIndex:row];

    str = [[NSMutableString alloc] init];
    for (i = rule->firstPhone; i <= rule->lastPhone; i++) {
        [str appendString:[[[currentIntonationPoint eventList] getPhoneAtIndex:i] symbol]];
        if (i == rule->lastPhone)
            break;
        [str appendString:@" > "];
    }

    [cell setStringValue:str];
    [str release];
}

- (IBAction)setSemitone:(id)sender;
{
    IntonationView *tempView = NXGetNamedObject(@"intonationView", NSApp);

    [currentIntonationPoint setSemitone:[sender doubleValue]];
    [tempView display];
    [self updateInspector];
}

- (IBAction)setHertz:(id)sender;
{
    IntonationView *tempView = NXGetNamedObject(@"intonationView", NSApp);
    double temp;

    temp = 12.0 * (log10([sender doubleValue]/MIDDLEC)/log10(2.0));
    [currentIntonationPoint setSemitone:temp];
    [tempView display];
    [self updateInspector];
}

- (IBAction)setSlope:(id)sender;
{
    IntonationView *tempView = NXGetNamedObject(@"intonationView", NSApp);

    [currentIntonationPoint setSlope:[sender doubleValue]];
    [tempView display];
    [self updateInspector];
}

- (IBAction)setBeatOffset:(id)sender;
{
    IntonationView *tempView = NXGetNamedObject(@"intonationView", NSApp);

    [currentIntonationPoint setOffsetTime:[sender doubleValue]];
    [[tempView documentView] addIntonationPoint:currentIntonationPoint];
    [tempView display];
    [self updateInspector];
}

- (void)updateInspector;
{
    double temp;

    temp = pow(2, [currentIntonationPoint semitone]/12.0)*MIDDLEC;
    [semitoneField setDoubleValue:[currentIntonationPoint semitone]];
    [hertzField setDoubleValue:temp];
    [slopeField setDoubleValue:[currentIntonationPoint slope]];
    [beatField setDoubleValue:[currentIntonationPoint beatTime]];
    [beatOffsetField setDoubleValue:[currentIntonationPoint offsetTime]];
    [absTimeField setDoubleValue:[currentIntonationPoint absoluteTime]];
}

@end


#import "IntonationPointInspector.h"
#import "IntonationView.h"
#import "Inspector.h"
#import "EventList.h"
#import "MyController.h"
#import <AppKit/NSText.h>
#import <AppKit/NSApplication.h>
#import <string.h>
#import <math.h>

#define MIDDLEC	261.6255653

@implementation IntonationPointInspector

- init
{
	return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
}

- (void)inspectIntonationPoint:point
{
	currentPoint = point;
	[mainInspector setPopUpListView:popUpListView];
	[self setUpWindow:popUpList]; 
}

- (void)setUpWindow:sender
{
const char *temp;

	temp = [[[sender selectedCell] title] cString];
	switch(temp[0])
	{
		/* Comment Window */
		case 'G':
			[mainInspector setGeneralView:mainBox];
			[self updateInspector];

			[ruleBrowser loadColumnZero];

			[[ruleBrowser matrixInColumn:0] scrollCellToVisibleAtRow:[currentPoint ruleIndex] column:0];
			[[ruleBrowser matrixInColumn:0] selectCellAtRow:[currentPoint ruleIndex] column:0];

			[ruleBrowser setTarget:self];
			[ruleBrowser setAction:(SEL)(@selector(browserHit:))];
			[ruleBrowser setDoubleAction:(SEL)(@selector(browserDoubleHit:))];

			break;

	} 
}

- (void)beginEditting
{
const char *temp;

	temp = [[[popUpList selectedCell] title] cString];
	switch(temp[0])
	{
		/* Comment Window */
		case 'C':
//			[commentText selectAll:self];
			break;

		case 'D':

			break;
	} 
}

- (void)browserHit:sender
{
id tempView = NXGetNamedObject(@"intonationView", NSApp);
int index;

	index = [[ruleBrowser matrixInColumn:0] selectedRow];
	[currentPoint setRuleIndex:index];
	[[tempView documentView] addIntonationPoint:currentPoint];
	[tempView display];
	[self updateInspector]; 
}

- (void)browserDoubleHit:sender
{
	 
}

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column
{

	return [[currentPoint eventList] numberOfRules];
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column
{
int i;
struct _rule *rule;
char buffer[64];

	[cell setLoaded:YES];
	[cell setLeaf:YES];

	rule = [[currentPoint eventList] getRuleAtIndex:row];

	bzero(buffer, 64);
	for (i = rule->firstPhone; i<=rule->lastPhone; i++)
	{
		strcat(buffer, [[[currentPoint eventList] getPhoneAtIndex:i] symbol]);
		if (i==rule->lastPhone) break;
		strcat(buffer, " > ");
	}

	[cell setStringValue:[NSString stringWithCString:buffer]];
}

- (void)setSemitone:sender
{
id tempView = NXGetNamedObject(@"intonationView", NSApp);

	[currentPoint setSemitone:[sender doubleValue]];
	[tempView display];
	[self updateInspector]; 
}

- (void)setHertz:sender;
{
id tempView = NXGetNamedObject(@"intonationView", NSApp);
double temp;

	temp = 12.0 * (log10([sender doubleValue]/MIDDLEC)/log10(2.0));
	[currentPoint setSemitone:temp];
	[tempView display];
	[self updateInspector];
}

- (void)setSlope:sender;
{
id tempView = NXGetNamedObject(@"intonationView", NSApp);
	[currentPoint setSlope:[sender doubleValue]];
	[tempView display];
	[self updateInspector];
}

- (void)setBeatOffset:sender;
{
id tempView = NXGetNamedObject(@"intonationView", NSApp);

	[currentPoint setOffsetTime:[sender doubleValue]];
	[[tempView documentView] addIntonationPoint:currentPoint];
	[tempView display];
	[self updateInspector];
}

- (void)updateInspector
{
double temp;

	temp = pow(2,[currentPoint semitone]/12.0)*MIDDLEC;
	[semitoneField setDoubleValue:[currentPoint semitone]];
	[hertzField setDoubleValue:temp];
	[slopeField setDoubleValue:[currentPoint slope]];
	[beatField setDoubleValue:[currentPoint beatTime]];
	[beatOffsetField setDoubleValue:[currentPoint offsetTime]];
	[absTimeField setDoubleValue:[currentPoint absoluteTime]]; 
}

@end

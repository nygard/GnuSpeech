#import "EventListView.h"

#import <AppKit/AppKit.h>
#import "NSNumberFormatter-Extensions.h"

#import "AppController.h"
#import "Event.h"
#import "EventList.h"
#import "MonetList.h"
#import "MMDisplayParameter.h"
#import "MMParameter.h"
#import "ParameterList.h"
#import "MMPosture.h"

@implementation EventListView

/*===========================================================================

	Method: initFrame
	Purpose: To initialize the frame

===========================================================================*/

- (id)initWithFrame:(NSRect)frameRect;
{
    if ([super initWithFrame:frameRect] == nil)
        return nil;

    [self allocateGState];

    timesFont = [[NSFont fontWithName:@"Times-Roman" size:12] retain];
    timesFontSmall = [[NSFont fontWithName:@"Times-Roman" size:10] retain];

    startingIndex = 0;
    timeScale = 2.0;
    mouseBeingDragged = 0;

    eventList = nil;
    trackTag = 0;

    ruleCell = [[NSTextFieldCell alloc] initTextCell:@""];
    [ruleCell setControlSize:NSSmallControlSize];
    [ruleCell setAlignment:NSCenterTextAlignment];
    [ruleCell setBordered:YES];
    //[ruleCell setBezeled:YES];
    [ruleCell setEnabled:YES];

    minMaxCell = [[NSTextFieldCell alloc] initTextCell:@""];
    [minMaxCell setControlSize:NSSmallControlSize];
    [minMaxCell setAlignment:NSRightTextAlignment];
    [minMaxCell setBordered:NO];
    [minMaxCell setEnabled:YES];
    [minMaxCell setFont:timesFontSmall];
    [minMaxCell setFormatter:[NSNumberFormatter defaultNumberFormatter]];

    parameterNameCell = [[NSTextFieldCell alloc] initTextCell:@""];
    [parameterNameCell setControlSize:NSSmallControlSize];
    [parameterNameCell setAlignment:NSLeftTextAlignment];
    [parameterNameCell setBordered:NO];
    [parameterNameCell setEnabled:YES];
    [parameterNameCell setFont:timesFont];

    displayParameters = nil;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(frameDidChange:)
                                          name:NSViewFrameDidChangeNotification
                                          object:self];

    [self setNeedsDisplay:YES];

    return self;
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeTrackingRect:trackTag];

    [timesFont release];
    [timesFontSmall release];
    [eventList release];
    [ruleCell release];
    [minMaxCell release];
    [parameterNameCell release];
    [displayParameters release];

    [super dealloc];
}

- (void)awakeFromNib;
{
    trackTag = [self addTrackingRect:[self bounds] owner:self userData:NULL assumeInside:NO];
}

- (NSArray *)displayParameters;
{
    return displayParameters;
}

- (void)setDisplayParameters:(NSArray *)newDisplayParameters;
{
    if (newDisplayParameters == displayParameters)
        return;

    [displayParameters release];
    displayParameters = [newDisplayParameters retain];

    [self setNeedsDisplay:YES];
}

- (BOOL)acceptsFirstResponder;
{
    return YES;
}

- (void)setEventList:(EventList *)newEventList;
{
    if (newEventList == eventList)
        return;

    [eventList release];
    eventList = [newEventList retain];

    [self setNeedsDisplay:YES];
}

- (BOOL)isOpaque;
{
    return YES;
}

- (void)drawRect:(NSRect)rects;
{
    [self clearView];
    [self drawGrid];
    [self drawRules];
}

- (void)clearView;
{
    NSDrawGrayBezel([self bounds], [self bounds]);
}

#define TRACKHEIGHT	120.0
#define BORDERHEIGHT	20.0

- (void)drawGrid;
{
    NSMutableArray *displayList;
    int i, j, k, parameterIndex, phoneIndex;
    float currentX, currentY;
    float currentMin, currentMax;
    Event *currentEvent;
    MMPosture *currentPhone = nil;
    NSBezierPath *bezierPath;
    NSRect bounds;
    unsigned count, index;

    bounds = NSIntegralRect([self bounds]);

    phoneIndex = 0;
    displayList = [[NSMutableArray alloc] init];

    count = [displayParameters count];
    for (index = 0; index < count; index++) {
        MMDisplayParameter *currentDisplayParameter;

        currentDisplayParameter = [displayParameters objectAtIndex:index];
        [displayList addObject:currentDisplayParameter];
    }

    /* Figure out how many tracks are actually displayed */
    if ([displayList count ] > 4)
        j = 4;
    else
        j = [displayList count];

    /* Make an outlined white box for display */
    [[NSColor whiteColor] set];
    NSRectFill(NSMakeRect(80.0, 50.0, bounds.size.width - 100.0, bounds.size.height - 100.0));

    [[NSColor blackColor] set];
    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:2];
    [bezierPath appendBezierPathWithRect:NSMakeRect(79, 49, bounds.size.width - 80 - 20 + 2, bounds.size.height - 50 - 50 + 2)];
    [bezierPath stroke];
    [bezierPath release];

    /* Draw the space for each Track */
    [[NSColor darkGrayColor] set];
    for (i = 0; i < j; i++) {
        NSRectFill(NSMakeRect(80.0 + 1, bounds.size.height - (50.0 + (float)(i + 1) * TRACKHEIGHT), bounds.size.width - 100.0 - 2, BORDERHEIGHT));
    }

    // Draw parameter names
    [[NSColor blackColor] set];
    for (i = 0; i < j; i++) {
        MMDisplayParameter *displayParameter;
        NSRect cellFrame;

        displayParameter = [displayList objectAtIndex:i];
        [parameterNameCell setStringValue:[displayParameter label]];

        cellFrame.size.height = [parameterNameCell cellSize].height;

        cellFrame.origin.x = 15;
        cellFrame.origin.y = bounds.size.height - 50 - ((float)(i + 1) * TRACKHEIGHT) + BORDERHEIGHT + (TRACKHEIGHT - BORDERHEIGHT - cellFrame.size.height) / 2;
        cellFrame.size.width = 60;
        //cellFrame.size.height = TRACKHEIGHT - BORDERHEIGHT;
        [parameterNameCell drawWithFrame:cellFrame inView:self];
    }

    // Draw min/max parameter values
    for (i = 0; i < j; i++) {
        MMDisplayParameter *displayParameter;
        MMParameter *aParameter;
        NSRect cellFrame;

        displayParameter = [displayList objectAtIndex:i];
        aParameter = [displayParameter parameter];

        cellFrame.origin.x = 0;
        cellFrame.origin.y = bounds.size.height - 50 - (float)(i + 1) * TRACKHEIGHT + BORDERHEIGHT - 9;
        cellFrame.size.height = 18;
        cellFrame.size.width = 75;
        [minMaxCell setIntValue:[aParameter minimumValue]];
        [minMaxCell drawWithFrame:cellFrame inView:self];

        cellFrame.origin.y = bounds.size.height - 50 - (float)i * TRACKHEIGHT - 9;
        [minMaxCell setIntValue:[aParameter maximumValue]];
        [minMaxCell drawWithFrame:cellFrame inView:self];
    }

    // Draw phones/postures along top
    [timesFont set];
    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
    for (i = 0; i < [eventList count]; i++) {
        currentX = rint(80.0 + ((float)[[eventList objectAtIndex:i] time] / timeScale));
        if (currentX > bounds.size.width - 20.0)
            break;

        if ([[eventList objectAtIndex:i] flag]) {
            currentPhone = [eventList getPhoneAtIndex:phoneIndex++];
            if (currentPhone) {
                [[NSColor blackColor] set];
                [[currentPhone symbol] drawAtPoint:NSMakePoint(currentX - 5.0, bounds.size.height - 42.0) withAttributes:nil];
            }

            // TODO (2004-03-17): It still goes one pixel below where it should.
            [bezierPath moveToPoint:NSMakePoint(currentX + 0.5, bounds.size.height - (50.0 + 1 + (float)j * TRACKHEIGHT))];
            [bezierPath lineToPoint:NSMakePoint(currentX + 0.5, bounds.size.height - 50.0 - 1)];
        } else {
            if (!mouseBeingDragged) {
                [bezierPath moveToPoint:NSMakePoint(currentX + 0.5, bounds.size.height - (50.0 + 1 + (float)j * TRACKHEIGHT))];
                [bezierPath lineToPoint:NSMakePoint(currentX + 0.5, bounds.size.height - 50.0 - 1)];
            }
        }
    }
    [[NSColor lightGrayColor] set];
    [bezierPath stroke];
    [bezierPath release];

    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:2];
    [[NSColor blackColor] set];
    for (i = 0; i < [displayList count] && i < 4; i++) {
        MMDisplayParameter *displayParameter;

        displayParameter = [displayList objectAtIndex:i];
        parameterIndex = [displayParameter tag];
        currentMin = (float)[[displayParameter parameter] minimumValue];
        currentMax = (float)[[displayParameter parameter] maximumValue];

        k = 0;
        for (j = 0; j < [eventList count]; j++) {
            currentEvent = [eventList objectAtIndex:j];
            currentX = 80.0 + (float)([currentEvent time] / timeScale);
            if (currentX > bounds.size.width - 20.0)
                break;
            if ([currentEvent getValueAtIndex:parameterIndex] != NaN) {
                currentY = (bounds.size.height - (50.0 + (float)(i + 1) * TRACKHEIGHT)) + BORDERHEIGHT +
                    ((float)([currentEvent getValueAtIndex:parameterIndex] - currentMin) /
                     (currentMax - currentMin) * 100.0);
                //NSLog(@"cx:%f cy:%f min:%f max:%f", currentX, currentY, currentMin, currentMax);
                //currentX = rint(currentX);
                currentY = rint(currentY);
                if (k == 0) {
                    k = 1;
                    [bezierPath moveToPoint:NSMakePoint(currentX, currentY)];
                } else
                    [bezierPath lineToPoint:NSMakePoint(currentX, currentY)];
            }
        }
    }
    [bezierPath stroke];
    [bezierPath release];

    [displayList release];
}

- (void)drawRules;
{
    int count, index;
    float currentX;
    struct _rule *rule;
    NSRect bounds, cellFrame;

    bounds = [self bounds];

    [timesFontSmall set];
    currentX = 0;

    count = [eventList numberOfRules];
    for (index = 0; index < count; index++) {
        rule = [eventList getRuleAtIndex:index];
        cellFrame.origin.x = 80.0 + currentX;
        cellFrame.origin.y = bounds.size.height - 25.0;
        cellFrame.size.height = 18.0;
        cellFrame.size.width = floor((float)rule->duration / timeScale);

        [ruleCell setIntValue:rule->number];
        [ruleCell drawWithFrame:cellFrame inView:self];

        currentX += floor((float)rule->duration / timeScale);
    }
}

- (void)mouseDown:(NSEvent *)theEvent;
{
    float row, column;
    NSPoint mouseDownLocation = [theEvent locationInWindow];

    /* Get information about the original location of the mouse event */
    mouseDownLocation = [self convertPoint:mouseDownLocation fromView:nil];
    row = mouseDownLocation.y;
    column = mouseDownLocation.x;

    /* Single click mouse events */
    if ([theEvent clickCount] == 1) {
    }

    /* Double Click mouse events */
    if ([theEvent clickCount] == 2) {
        mouseBeingDragged = 1;
        [self lockFocus];
        [self updateScale:(float)column];
        [self unlockFocus];
        mouseBeingDragged = 0;
        [self setNeedsDisplay:YES];
    }
}

- (void)mouseEntered:(NSEvent *)theEvent;
{
    [[self window] setAcceptsMouseMovedEvents:YES];
}

- (void)mouseExited:(NSEvent *)theEvent;
{
    [[self window] setAcceptsMouseMovedEvents:NO];
}

- (void)mouseMoved:(NSEvent *)theEvent;
{
    NSPoint position;
    int time;

    position = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    time = (position.x - 80.0) * timeScale;
    if ((position.x < 80.0) || (position.x > [self bounds].size.width - 20.0))
        [mouseTimeField setStringValue:@"--"];
    else
        [mouseTimeField setIntValue:(position.x - 80.0) * timeScale];
}

- (void)updateScale:(float)column;
{
    NSPoint mouseDownLocation;
    NSEvent *newEvent;
    float delta, originalScale;

    originalScale = timeScale;

    [[self window] setAcceptsMouseMovedEvents:YES];
    while (1) {
        newEvent = [NSApp nextEventMatchingMask:NSAnyEventMask
                          untilDate:[NSDate distantFuture]
                          inMode:NSEventTrackingRunLoopMode
                          dequeue:YES];
        mouseDownLocation = [newEvent locationInWindow];
        mouseDownLocation = [self convertPoint:mouseDownLocation fromView:nil];
        delta = column - mouseDownLocation.x;
        timeScale = originalScale + delta / 20.0;

        if (timeScale > 10.0)
            timeScale = 10.0;

        if (timeScale < 0.1)
            timeScale = 0.1;

        [self clearView];
        [self drawGrid];
        [[self window] flushWindow];

        if ([newEvent type] == NSLeftMouseUp)
            break;
    }

    [[self window] setAcceptsMouseMovedEvents:NO];
}

- (void)frameDidChange:(NSNotification *)aNotification;
{
    [self resetTrackingRect];
}

- (void)resetTrackingRect;
{
    [self removeTrackingRect:trackTag];
    trackTag = [self addTrackingRect:[self bounds] owner:self userData:NULL assumeInside:NO];
}

@end

#import "EventListView.h"

#import <AppKit/AppKit.h>
#import "AppController.h"
#import "Event.h"
#import "EventList.h"
#import "MonetList.h"
#import "NiftyMatrix.h"
#import "NiftyMatrixCat.h"
#import "NiftyMatrixCell.h"
#import "Parameter.h"
#import "ParameterList.h"
#import "Phone.h"

#ifdef PORTING
#import "StringParser.h"
#import "PhoneList.h"
#endif

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
    timeScale = 1.0;
    mouseBeingDragged = 0;

    eventList = nil;

    [self setNeedsDisplay:YES];

    return self;
}

- (void)dealloc;
{
    [timesFont release];
    [timesFontSmall release];
    [eventList release];
    [niftyMatrix release];

    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
    NSRect scrollRect, matrixRect;
    NSSize interCellSpacing = NSZeroSize;
    NSSize cellSize;

    NSLog(@"<%@>[%p]  > %s", NSStringFromClass([self class]), self, _cmd);

    //trackRect.origin.x = 80.0;
    //trackRect.origin.y = 50.0;
    //trackRect.size.width = frame.size.width - 102.0;
    //trackRect.size.height = frame.size.height - 102.0;

    [[self window] setAcceptsMouseMovedEvents:YES];

    /* set the niftyMatrixScrollView's attributes */
    [niftyMatrixScrollView setBorderType:NSBezelBorder];
    [niftyMatrixScrollView setHasVerticalScroller:YES];
    [niftyMatrixScrollView setHasHorizontalScroller:NO];

    /* get the niftyMatrixScrollView's dimensions */
    scrollRect = [niftyMatrixScrollView frame];
    NSLog(@"scrollRect: %@", NSStringFromRect(scrollRect));

    /* determine the matrix bounds */
    matrixRect.origin = NSZeroPoint;
    matrixRect.size = [NSScrollView contentSizeForFrameSize:scrollRect.size hasHorizontalScroller:NO hasVerticalScroller:NO borderType:NSBezelBorder];

    NSLog(@"matrixRect: %@", NSStringFromRect(matrixRect));

    /* prepare a matrix to go inside our niftyMatrixScrollView */
    niftyMatrix = [[NiftyMatrix allocWithZone:[self zone]] initWithFrame:matrixRect mode:NSRadioModeMatrix cellClass:[NiftyMatrixCell class] numberOfRows:0 numberOfColumns:1];

    /* we don't want any space between the matrix's cells  */
    [niftyMatrix setIntercellSpacing:interCellSpacing];

    /* resize the matrix's cells and size the matrix to contain them */
    cellSize = [niftyMatrix cellSize];
    cellSize.width = NSWidth(matrixRect) + 0.1;
    [niftyMatrix setCellSize:cellSize];
    [niftyMatrix sizeToCells];
    [niftyMatrix setAutosizesCells:YES];

    /*
     * when the user clicks in the matrix and then drags the mouse out of niftyMatrixScrollView's contentView,
     * we want the matrix to scroll
     */

    [niftyMatrix setAutoscroll:YES];

    /* stick the matrix in our niftyMatrixScrollView */
    [niftyMatrixScrollView setDocumentView:niftyMatrix];

    /* set things up so that the matrix will resize properly */
    [[niftyMatrix superview] setAutoresizesSubviews:YES];
    [niftyMatrix setAutoresizingMask:NSViewWidthSizable];

    /* set the matrix's single-click actions */
    [niftyMatrix setTarget:self];
    [niftyMatrix setAction:@selector(itemsChanged:)];
    //[niftyMatrix allowEmptySel:YES];

    /* Generalize this LATER */
    [niftyMatrix insertCellWithStringValue:@"glotPitch" withTag:0];
    [niftyMatrix insertCellWithStringValue:@"glotVol" withTag:1];
    [niftyMatrix insertCellWithStringValue:@"aspVol" withTag:2];
    [niftyMatrix insertCellWithStringValue:@"fricVol" withTag:3];
    [niftyMatrix insertCellWithStringValue:@"fricPos" withTag:4];
    [niftyMatrix insertCellWithStringValue:@"fricCF" withTag:5];
    [niftyMatrix insertCellWithStringValue:@"fricBW" withTag:6];
    [niftyMatrix insertCellWithStringValue:@"r1" withTag:7];
    [niftyMatrix insertCellWithStringValue:@"r2" withTag:8];
    [niftyMatrix insertCellWithStringValue:@"r3" withTag:9];
    [niftyMatrix insertCellWithStringValue:@"r4" withTag:10];
    [niftyMatrix insertCellWithStringValue:@"r5" withTag:11];
    [niftyMatrix insertCellWithStringValue:@"r6" withTag:12];
    [niftyMatrix insertCellWithStringValue:@"r7" withTag:13];
    [niftyMatrix insertCellWithStringValue:@"r8" withTag:14];
    [niftyMatrix insertCellWithStringValue:@"velum" withTag:15];

    [niftyMatrix insertCellWithStringValue:@"glotPitch (special)" withTag:16];
    [niftyMatrix insertCellWithStringValue:@"glotVol (special)" withTag:17];
    [niftyMatrix insertCellWithStringValue:@"aspVol (special)" withTag:18];
    [niftyMatrix insertCellWithStringValue:@"fricVol (special)" withTag:19];
    [niftyMatrix insertCellWithStringValue:@"fricPos (special)" withTag:20];
    [niftyMatrix insertCellWithStringValue:@"fricCF (special)" withTag:21];
    [niftyMatrix insertCellWithStringValue:@"fricBW (special)" withTag:22];
    [niftyMatrix insertCellWithStringValue:@"r1 (special)" withTag:23];
    [niftyMatrix insertCellWithStringValue:@"r2 (special)n" withTag:24];
    [niftyMatrix insertCellWithStringValue:@"r3 (special)" withTag:25];
    [niftyMatrix insertCellWithStringValue:@"r4 (special)" withTag:26];
    [niftyMatrix insertCellWithStringValue:@"r5 (special)" withTag:27];
    [niftyMatrix insertCellWithStringValue:@"r6 (special)" withTag:28];
    [niftyMatrix insertCellWithStringValue:@"r7 (special)" withTag:29];
    [niftyMatrix insertCellWithStringValue:@"r8 (special)" withTag:30];
    [niftyMatrix insertCellWithStringValue:@"velum (special)" withTag:31];
    [niftyMatrix insertCellWithStringValue:@"Intonation" withTag:32];

    /* Display */
    [niftyMatrix grayAllCells];
    [niftyMatrix setNeedsDisplay:YES];

    NSLog(@"<%@>[%p] <  %s", NSStringFromClass([self class]), self, _cmd);
}

- (IBAction)itemsChanged:(id)sender;
{
    //NSLog(@" > %s", _cmd);
    [self setNeedsDisplay:YES];
    //NSLog(@"<  %s", _cmd);
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

- (void)drawRect:(NSRect)rects;
{
    NSRect trackRect;

    //NSLog(@" > %s", _cmd);

    trackRect = [self frame];
    [[self superview] convertRect:trackRect toView:nil];

    trackTag = [self addTrackingRect:trackRect owner:self userData:NULL assumeInside:NO];

    [self clearView];
    [self drawGrid];

    //NSLog(@"<  %s", _cmd);
}

- (void)clearView;
{
    NSDrawGrayBezel([self bounds], [self bounds]);
}

#define TRACKHEIGHT	120.0
#define BORDERHEIGHT	20.0

- (void)drawGrid;
{
    NSRect drawFrame;
    NSArray *cellList;
    MonetList *displayList;
    int i, j, k, parameterIndex, phoneIndex;
    NiftyMatrixCell *aCell;
    float currentX, currentY;
    float currentMin, currentMax;
    ParameterList *parameterList = NXGetNamedObject(@"mainParameterList", NSApp);
    Event *currentEvent;
    Phone *currentPhone = nil;
    struct _rule *rule;
    NSBezierPath *bezierPath;
    NSRect bounds;

    bounds = [self bounds];

    phoneIndex = 0;
    displayList = [[MonetList alloc] initWithCapacity:10];

    cellList = [niftyMatrix cells];
    for (i = 0; i < [cellList count]; i++) {
        aCell = [cellList objectAtIndex:i];
        if ([aCell toggleValue]) {
            [displayList addObject:aCell];
        }
    }

    /* Figure out how many tracks are actually displayed */
    if ([displayList count ] > 4)
        j = 4;
    else
        j = [displayList count];

    /* Make an outlined white box for display */
    [[NSColor whiteColor] set];
    NSRectFill(NSMakeRect(81.0, 51.0, bounds.size.width - 102.0, bounds.size.height - 102.0));

    [[NSColor blackColor] set];
    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:2];
    [bezierPath appendBezierPathWithRect:NSMakeRect(80, 50, bounds.size.width - 80 - 20, bounds.size.height - 50 - 50)];
    [bezierPath stroke];
    [bezierPath release];

    /* Draw the space for each Track */
    [[NSColor darkGrayColor] set];
    for (i = 0; i < j; i++) {
        NSRectFill(NSMakeRect(80.0 + 1, bounds.size.height - (50.0 + (float)(i + 1) * TRACKHEIGHT), bounds.size.width - 100.0 - 2, BORDERHEIGHT));
    }

    [[NSColor blackColor] set];
    [timesFont set];
    for (i = 0; i < j; i++) {
        Parameter *aParameter;

        aParameter = [parameterList objectAtIndex:[[displayList objectAtIndex:i] orderTag]];
        [[aParameter symbol] drawAtPoint:NSMakePoint(15.0, bounds.size.height - ((float)(i + 1) * TRACKHEIGHT) + 15.0) withAttributes:nil];
    }

    [timesFontSmall set];
    for (i = 0; i < j; i++) {
        NSString *str;

        str = [NSString stringWithFormat:@"%d", (int)[[parameterList objectAtIndex:[[displayList objectAtIndex:i] orderTag]] minimumValue]];
        [str drawAtPoint:NSMakePoint(55.0, bounds.size.height - (50.0 + (float)(i + 1) * TRACKHEIGHT) + BORDERHEIGHT) withAttributes:nil];

        str = [NSString stringWithFormat:@"%d", (int)[[parameterList objectAtIndex:[[displayList objectAtIndex:i] orderTag]] maximumValue]];
        [str drawAtPoint:NSMakePoint(55.0, bounds.size.height - (50.0 + (float)(i) * TRACKHEIGHT + 3.0)) withAttributes:nil];
    }

    [timesFont set];
    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
    for (i = 0; i < [eventList count]; i++) {
        currentX = 80.0 + ((float)[[eventList objectAtIndex:i] time] / timeScale);
        if (currentX > bounds.size.width - 20.0)
            break;

        if ([[eventList objectAtIndex:i] flag]) {
            currentPhone = [eventList getPhoneAtIndex:phoneIndex++];
            if (currentPhone) {
                [[NSColor blackColor] set];
                [[currentPhone symbol] drawAtPoint:NSMakePoint(currentX - 5.0, bounds.size.height - 42.0) withAttributes:nil];
            }

            [bezierPath moveToPoint:NSMakePoint(currentX, bounds.size.height - (50.0 + (float)(j) * TRACKHEIGHT))];
            [bezierPath lineToPoint:NSMakePoint(currentX, bounds.size.height - 50.0)];
        } else {
            if (!mouseBeingDragged) {
                [bezierPath moveToPoint:NSMakePoint(currentX, bounds.size.height - (50.0 + (float)(j) * TRACKHEIGHT))];
                [bezierPath lineToPoint:NSMakePoint(currentX, bounds.size.height - 50.0)];
            }
        }
    }
    [[NSColor lightGrayColor] set];
    [bezierPath stroke];
    [bezierPath release];

    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:2];
    [[NSColor blackColor] set];
    for (i = 0; i < [displayList count]; i++) {
        parameterIndex = [[displayList objectAtIndex:i] orderTag];
        if (parameterIndex == 32) {
            currentMin = -20;
            currentMax = 10;
        } else if (parameterIndex > 15) {
            currentMin = (float)[[parameterList objectAtIndex:parameterIndex-16] minimumValue];
            currentMax = (float)[[parameterList objectAtIndex:parameterIndex-16] maximumValue];
        } else {
            currentMin = (float)[[parameterList objectAtIndex:parameterIndex] minimumValue];
            currentMax = (float)[[parameterList objectAtIndex:parameterIndex] maximumValue];
        }

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
                if (k == 0) {
                    k = 1;
                    [bezierPath moveToPoint:NSMakePoint(currentX, currentY)];
                } else
                    [bezierPath lineToPoint:NSMakePoint(currentX, currentY)];
            }
        }
        if (i >= 4)
            break;
    }
    [bezierPath stroke];
    [bezierPath release];

    [timesFontSmall set];
    currentX = 0;
    for (i = 0; i < [eventList numberOfRules]; i++) {
        NSString *str;

        rule = [eventList getRuleAtIndex:i];
        drawFrame.origin.x = 80.0 + currentX;
        drawFrame.origin.y = bounds.size.height - 25.0;
        drawFrame.size.height = 15.0;
        drawFrame.size.width = (float)rule->duration / timeScale;
        NSDrawWhiteBezel(drawFrame, drawFrame);

        [[NSColor blackColor] set];
        str = [NSString stringWithFormat:@"%d", rule->number];
        [str drawAtPoint:NSMakePoint(80.0 + currentX + (float)rule->duration / (3 * timeScale), bounds.size.height - 21.0) withAttributes:nil];
        currentX += (float)rule->duration / timeScale;
    }


    [displayList release];
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
    NSEvent *nextEvent;
    NSPoint position;
    int time;

    [[self window] setAcceptsMouseMovedEvents: YES];
    while (1) {
        nextEvent = [[self window] nextEventMatchingMask:NSAnyEventMask];
        if (([nextEvent type] != NSMouseMoved) && ([nextEvent type] != NSMouseExited))
            [NSApp sendEvent:nextEvent];

        if ([nextEvent type] == NSMouseExited)
            break;

        if (([nextEvent type] == NSMouseMoved) && [[self window] isKeyWindow]) {
            position.x = [nextEvent locationInWindow].x;
            position.y = [nextEvent locationInWindow].y;
            position = [self convertPoint:position fromView:nil];
            time = (int)((position.x-80.0)*timeScale);
            if ((position.x < 80.0) || (position.x > [self frame].size.width-20.0))
                [mouseTimeField setStringValue:@"--"];
            else
                [mouseTimeField setIntValue:(int)((position.x-80.0)*timeScale)];
        }

    }

    [[self window] setAcceptsMouseMovedEvents: NO];
}

- (void)mouseExited:(NSEvent *)theEvent;
{
}

- (void)mouseMoved:(NSEvent *)theEvent;
{
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

@end

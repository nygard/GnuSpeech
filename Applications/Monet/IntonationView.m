#import "IntonationView.h"

#import <AppKit/AppKit.h>
#import "NSBezierPath-Extensions.h"
#import "NSNumberFormatter-extensions.h"
#import "NSString-Extensions.h"

#import "Event.h"
#import "EventList.h"
#import "GSXMLFunctions.h"
#import "MMIntonationPoint.h"
#import "MMPosture.h"
#import "MonetList.h"

#define TOP_MARGIN 65
#define BOTTOM_MARGIN 5
#define LEFT_MARGIN 1
#define RIGHT_MARGIN 20.0

#define SECTION_COUNT 30

#define RULE_Y_OFFSET 40
#define RULE_HEIGHT 30
#define POSTURE_Y_OFFSET 62

#define ZERO_SECTION 20

NSString *IntonationViewSelectionDidChangeNotification = @"IntonationViewSelectionDidChangeNotification";

@implementation IntonationView

- (id)initWithFrame:(NSRect)frameRect;
{
    NSNumberFormatter *durationFormatter;

    if ([super initWithFrame:frameRect] == nil)
        return nil;

    postureTextFieldCell = [[NSTextFieldCell alloc] initTextCell:@""];
    ruleIndexTextFieldCell = [[NSTextFieldCell alloc] initTextCell:@""];
    [ruleIndexTextFieldCell setFont:[NSFont labelFontOfSize:10.0]];
    [ruleIndexTextFieldCell setAlignment:NSCenterTextAlignment];

    durationFormatter = [[NSNumberFormatter alloc] init];
    [durationFormatter setFormat:@"0.##"];

    ruleDurationTextFieldCell = [[NSTextFieldCell alloc] initTextCell:@""];
    [ruleDurationTextFieldCell setAlignment:NSCenterTextAlignment];
    [ruleDurationTextFieldCell setFont:[NSFont labelFontOfSize:8.0]];
    [ruleDurationTextFieldCell setFormatter:durationFormatter];

    [durationFormatter release];

    timesFont = [[NSFont fontWithName:@"Times-Roman" size:12] retain];
    timesFontSmall = [[NSFont fontWithName:@"Times-Roman" size:10] retain];

    [postureTextFieldCell setFont:timesFont];

    timeScale = 1.0;
    flags.mouseBeingDragged = NO;

    eventList = nil;

    selectedPoints = [[NSMutableArray alloc] init];

    [self setNeedsDisplay:YES];

    return self;
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [postureTextFieldCell release];
    [ruleIndexTextFieldCell release];
    [ruleDurationTextFieldCell release];

    [timesFont release];
    [timesFontSmall release];
    [eventList release];
    [selectedPoints release];

    [super dealloc];
}

- (BOOL)acceptsFirstResponder;
{
    return YES;
}

- (void)setEventList:(EventList *)newEventList;
{
    if (newEventList == eventList)
        return;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:EventListDidChangeIntonationPoints object:nil];

    [eventList release];
    eventList = [newEventList retain];

    if (eventList != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(intonationPointDidChange:)
                                              name:EventListDidChangeIntonationPoints
                                              object:eventList];
    }

    [self setNeedsDisplay:YES];
}

- (BOOL)shouldDrawSelection;
{
    return flags.shouldDrawSelection;
}

- (void)setShouldDrawSelection:(BOOL)newFlag;
{
    if (newFlag == flags.shouldDrawSelection)
        return;

    flags.shouldDrawSelection = newFlag;
    [self setNeedsDisplay:YES];
}

- (BOOL)shouldDrawSmoothPoints;
{
    return flags.shouldDrawSmoothPoints;
}

- (void)setShouldDrawSmoothPoints:(BOOL)newFlag;
{
    if (newFlag == flags.shouldDrawSmoothPoints)
        return;

    flags.shouldDrawSmoothPoints = newFlag;
    [self setNeedsDisplay:YES];
}

- (id)delegate;
{
    return nonretained_delegate;
}

- (void)setDelegate:(id)newDelegate;
{
    nonretained_delegate = newDelegate;
}

- (void)drawRect:(NSRect)rect;
{
    NSRect clipRect;
    Event *lastEvent;
    float width;

    // TODO (2004-03-15): Changing the view frame in drawRect: can cause problems.  Should do before drawRect:
    clipRect = [[self superview] frame];
    lastEvent = [[eventList events] lastObject];

    width = [self scaleWidth:[lastEvent time]] + RIGHT_MARGIN;
    if (clipRect.size.width < width)
        clipRect.size.width = width;
    [self setFrame:clipRect];

    [[NSColor whiteColor] set];
    NSRectFill(rect);

    [self drawGrid];
    [self drawPostureLabels];
    [self drawRules];
    [self drawIntonationPoints];

    if (flags.shouldDrawSmoothPoints == YES && flags.mouseBeingDragged == NO)
        [self drawSmoothPoints];

    if (flags.shouldDrawSelection == YES) {
        NSRect selectionRect;

        selectionRect = [self rectFormedByPoint:selectionPoint1 andPoint:selectionPoint2];
        selectionRect.origin.x += 0.5;
        selectionRect.origin.y += 0.5;

        [[NSColor purpleColor] set];
        [NSBezierPath strokeRect:selectionRect];
    }

    [[self enclosingScrollView] reflectScrolledClipView:(NSClipView *)[self superview]];
}

- (void)drawGrid;
{
    NSBezierPath *bezierPath;
    NSRect bounds;
    NSPoint graphOrigin;
    int sectionHeight;
    int index;

    bounds = NSIntegralRect([self bounds]);
    graphOrigin = [self graphOrigin];
    sectionHeight = [self sectionHeight];

    // Draw border around graph
    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:2];
    [bezierPath appendBezierPathWithRect:NSMakeRect(graphOrigin.x, graphOrigin.y, bounds.size.width - 2, SECTION_COUNT * sectionHeight)];

    [[NSColor blackColor] set];
    [bezierPath stroke];
    [bezierPath release];

    // Draw semitone grid markers
    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
    for (index = 0; index < SECTION_COUNT; index++) {
        NSPoint aPoint;

        aPoint.x = 2;
        aPoint.y = rint(graphOrigin.y + index * sectionHeight) + 0.5;
        [bezierPath moveToPoint:aPoint];

        aPoint.x = bounds.size.width - 2;
        [bezierPath lineToPoint:aPoint];
    }

    [[NSColor lightGrayColor] set];
    [bezierPath stroke];
    [bezierPath release];

    // Draw the zero semitone line in black.
    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
    {
        NSPoint aPoint;

        aPoint.x = 2;
        aPoint.y = rint(graphOrigin.y + ZERO_SECTION * sectionHeight) + 0.5;
        [bezierPath moveToPoint:aPoint];

        aPoint.x = bounds.size.width - 2;
        [bezierPath lineToPoint:aPoint];
    }

    [[NSColor blackColor] set];
    [bezierPath stroke];
    [bezierPath release];
}

// Put posture label on the top
// TODO (2004-08-16): Need right margin so that the last posture is visible.
- (void)drawPostureLabels;
{
    int count, index;
    MMPosture *currentPosture;
    NSRect bounds;
    float currentX;
    int postureIndex = 0;
    NSArray *events;

    bounds = NSIntegralRect([self bounds]);

    [[NSColor blackColor] set];
    [timesFont set];

    events = [eventList events];
    count = [events count];
    for (index = 0; index < count; index++) {
        currentX = ((float)[[events objectAtIndex:index] time] / timeScale);

        if ([[events objectAtIndex:index] flag]) {
            currentPosture = [eventList getPhoneAtIndex:postureIndex++];
            if (currentPosture != nil) {
                //NSLog(@"[currentPosture name]: %@", [currentPosture name]);
#if 0
                [[NSColor blueColor] set];
                NSRectFill(NSMakeRect(currentX, bounds.size.height - POSTURE_Y_OFFSET, 10, 20));
#endif
                [[NSColor blackColor] set];
                [[currentPosture name] drawAtPoint:NSMakePoint(currentX, bounds.size.height - POSTURE_Y_OFFSET) withAttributes:nil];
                //[postureTextFieldCell setStringValue:[currentPosture name]];
            }
        }
    }
}

// Put Rules on top
- (void)drawRules;
{
    NSBezierPath *bezierPath;
    float currentX, extraWidth;
    int count, index;
    NSRect bounds;
    NSPoint graphOrigin;
    int sectionHeight;
    struct _rule *rule;

    bounds = NSIntegralRect([self bounds]);
    graphOrigin = [self graphOrigin];
    sectionHeight = [self sectionHeight];

    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
    currentX = 0.0;
    extraWidth = 0.0;

    count = [eventList numberOfRules];
    for (index = 0; index < count; index++) {
        NSPoint aPoint;
        NSRect ruleFrame;

        rule = [eventList getRuleAtIndex:index];

        ruleFrame.origin.x = currentX;
        ruleFrame.origin.y = bounds.size.height - RULE_Y_OFFSET;
        ruleFrame.size.height = RULE_HEIGHT;
        ruleFrame.size.width = [self scaleWidth:rule->duration] + extraWidth;
        NSFrameRect(ruleFrame);

        ruleFrame.size.height = 15.0;
        [ruleDurationTextFieldCell setDoubleValue:rule->duration];
        [ruleDurationTextFieldCell drawWithFrame:ruleFrame inView:self];

        ruleFrame.size.height += 12.0;
        [ruleIndexTextFieldCell setIntValue:rule->number];
        [ruleIndexTextFieldCell drawWithFrame:ruleFrame inView:self];

        aPoint.x = [self scaleXPosition:rule->beat] + 0.5;
        aPoint.y = graphOrigin.y + SECTION_COUNT * sectionHeight - 1.0;
        [bezierPath moveToPoint:aPoint];

        aPoint.y = graphOrigin.y;
        [bezierPath lineToPoint:aPoint];

        extraWidth = 1.0;
        currentX += ruleFrame.size.width - extraWidth;
    }

    [[NSColor darkGrayColor] set];
    [[NSColor blackColor] set];
    [[NSColor greenColor] set];
    [bezierPath stroke];
    [bezierPath release];
}

- (void)drawIntonationPoints;
{
    NSBezierPath *bezierPath;
    int count, index;
    NSPoint currentPoint;
    NSRect bounds;
    NSPoint graphOrigin;
    NSArray *intonationPoints = [eventList intonationPoints];
    MMIntonationPoint *currentIntonationPoint;

    bounds = [self bounds];
    graphOrigin = [self graphOrigin];

    [[NSColor blackColor] set];
    [[NSColor redColor] set];

    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
    [bezierPath moveToPoint:graphOrigin];

    count = [intonationPoints count];
    for (index = 0; index < count; index++) {
        currentIntonationPoint = [intonationPoints objectAtIndex:index];
        currentPoint.x = [self scaleXPosition:[currentIntonationPoint absoluteTime]];
        currentPoint.y = rint(graphOrigin.y + ([currentIntonationPoint semitone] + ZERO_SECTION) * [self sectionHeight]) + 0.5;
        [bezierPath lineToPoint:currentPoint];

        [NSBezierPath drawCircleMarkerAtPoint:currentPoint];
    }
    [bezierPath stroke];
    [bezierPath release];

    count = [selectedPoints count];
    for (index = 0; index < count; index++) {
        currentIntonationPoint = [selectedPoints objectAtIndex:index];
        currentPoint.x = [self scaleXPosition:[currentIntonationPoint absoluteTime]];
        currentPoint.y = rint(graphOrigin.y + ([currentIntonationPoint semitone] + ZERO_SECTION) * [self sectionHeight]) + 0.5;
        [NSBezierPath highlightMarkerAtPoint:currentPoint];
    }
}

// TODO (2004-03-15): See if we can just use the code from -applyIntonationSmooth instead.
- (void)drawSmoothPoints;
{
    double a, b, c, d;
    double x1, y1, m1, x12, x13;
    double x2, y2, m2, x22, x23;
    double denominator;
    double x, y;
    int i, j;
    id point1, point2;
    NSBezierPath *bezierPath;
    NSArray *intonationPoints = [eventList intonationPoints];
    NSPoint graphOrigin;
    NSPoint aPoint;

    if ([intonationPoints count] < 2)
        return;

    graphOrigin = [self graphOrigin];

    for (j = 0; j < [intonationPoints count] - 1; j++) {
        point1 = [intonationPoints objectAtIndex:j];
        point2 = [intonationPoints objectAtIndex:j + 1];

        x1 = [point1 absoluteTime];
        y1 = [point1 semitone] + ZERO_SECTION;
        m1 = [point1 slope];

        x2 = [point2 absoluteTime];
        y2 = [point2 semitone] + ZERO_SECTION;
        m2 = [point2 slope];

        x12 = x1*x1;
        x13 = x12*x1;

        x22 = x2*x2;
        x23 = x22*x2;

        denominator = (x2 - x1);
        denominator = denominator * denominator * denominator;

        d = ( -(y2*x13) + 3*y2*x12*x2 + m2*x13*x2 + m1*x12*x22 - m2*x12*x22 - 3*x1*y1*x22 - m1*x1*x23 + y1*x23) / denominator;
        c = ( -(m2*x13) - 6*y2*x1*x2 - 2*m1*x12*x2 - m2*x12*x2 + 6*x1*y1*x2 + m1*x1*x22 + 2*m2*x1*x22 + m1*x23) / denominator;
        b = ( 3*y2*x1 + m1*x12 + 2*m2*x12 - 3*x1*y1 + 3*x2*y2 + m1*x1*x2 - m2*x1*x2 - 3*y1*x2 - 2*m1*x22 - m2*x22) / denominator;
        a = ( -2*y2 - m1*x1 - m2*x1 + 2*y1 + m1*x2 + m2*x2) / denominator;

        //NSLog(@"\n===\n x1 = %f y1 = %f m1 = %f", x1, y1, m1);
        //NSLog(@"x2 = %f y2 = %f m2 = %f", x2, y2, m2);
        //NSLog(@"a = %f b = %f c = %f d = %f", a, b, c, d);

        // The curve looks better (darker) without adding the extra 0.5 to the y positions.
        aPoint.x = [self scaleXPosition:x1];
        aPoint.y = rint(graphOrigin.y + y1 * [self sectionHeight]);

        bezierPath = [[NSBezierPath alloc] init];
        [bezierPath moveToPoint:aPoint];
        for (i = (int)x1; i <= (int)x2; i++) {
            x = (double)i;
            y = x*x*x*a + x*x*b + x*c + d;

            aPoint.x = [self scaleXPosition:i];
            aPoint.y = rint(graphOrigin.y + y * [self sectionHeight]);
            [bezierPath lineToPoint:aPoint];
        }

        [[NSColor blackColor] set];
        [bezierPath stroke];
        [bezierPath release];
    }
}

//
// Event handling
//

- (void)mouseEntered:(NSEvent *)theEvent;
{
#ifdef PORTING
    NSEvent *nextEvent;
    NSPoint position;
    int time;

    [[self window] setAcceptsMouseMovedEvents:YES];
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
            time = (int)((position.x - 80.0) * timeScale);
//            if ((position.x<80.0) || (position.x>frame.size.width-20.0))
//                [mouseTimeField setStringValue:"--"];
//            else
//                [mouseTimeField setIntValue: (int)((position.x-80.0)*timeScale)];
        }

    }
    [[self window] setAcceptsMouseMovedEvents:NO];
#endif
}

- (void)keyDown:(NSEvent *)keyEvent;
{
    NSString *characters;
    int index, length;
    unichar ch;

    unsigned int ruleCount;
    MMIntonationPoint *tempPoint;

    NSLog(@" > %s", _cmd);

    ruleCount = [eventList numberOfRules];

    characters = [keyEvent characters];
    length = [characters length];
    for (index = 0; index < length; index++) {
        unsigned int pointCount, pointIndex;

        pointCount = [selectedPoints count];

        ch = [characters characterAtIndex:index];
        NSLog(@"index: %d, character: %@", index, [characters substringWithRange:NSMakeRange(index, 1)]);

        switch (ch) {
          case NSDeleteFunctionKey:
              NSLog(@"delete");
              [self deletePoints];
              break;

          case NSLeftArrowFunctionKey:
              NSLog(@"left arrow");
              for (pointIndex = 0; pointIndex < pointCount; pointIndex++) {
                  if ([[selectedPoints objectAtIndex:pointIndex] ruleIndex] - 1 < 0) {
                      NSBeep();
                      return;
                  }
              }

              for (pointIndex = 0; pointIndex < pointCount; pointIndex++) {
                  tempPoint = [selectedPoints objectAtIndex:pointIndex];
                  [tempPoint setRuleIndex:[tempPoint ruleIndex] - 1];
                  [eventList addIntonationPoint:tempPoint];
              }
              break;

          case NSRightArrowFunctionKey:
              NSLog(@"right arrow");
              for (pointIndex = 0; pointIndex < pointCount; pointIndex++) {
                  if ([[selectedPoints objectAtIndex:pointIndex] ruleIndex] + 1 >= ruleCount) {
                      NSBeep();
                      return;
                  }
              }

              for (pointIndex = 0; pointIndex < pointCount; pointIndex++) {
                  tempPoint = [selectedPoints objectAtIndex:pointIndex];
                  [tempPoint setRuleIndex:[tempPoint ruleIndex] + 1];
                  [eventList addIntonationPoint:tempPoint];
              }
              break;

          case NSUpArrowFunctionKey:
              NSLog(@"up arrow");
              for (pointIndex = 0; pointIndex < pointCount; pointIndex++) {
                  if ([[selectedPoints objectAtIndex:pointIndex] semitone] + 1.0 > 10.0) {
                      NSBeep();
                      return;
                  }
              }

              for (pointIndex = 0; pointIndex < pointCount; pointIndex++)
                  [[selectedPoints objectAtIndex:pointIndex] incrementSemitone];
              break;

          case NSDownArrowFunctionKey:
              NSLog(@"down arrow");
              for (pointIndex = 0; pointIndex < pointCount; pointIndex++) {
                  if ([[selectedPoints objectAtIndex:pointIndex] semitone] - 1.0 < -20.0) {
                      NSBeep();
                      return;
                  }
              }

              for (pointIndex = 0; pointIndex < pointCount; pointIndex++)
                  [[selectedPoints objectAtIndex:pointIndex] decrementSemitone];
              break;
        }
    }

    //[self setNeedsDisplay:YES];

    NSLog(@"<  %s", _cmd);
}

- (void)mouseDown:(NSEvent *)mouseEvent;
{
    NSPoint hitPoint;
#if 0
    if ([self isEnabled] == NO) {
        [super mouseDown:mouseEvent];
        return;
    }
#endif
    // Force this to be first responder, since nothing else seems to work!
    [[self window] makeFirstResponder:self];

    hitPoint = [self convertPoint:[mouseEvent locationInWindow] fromView:nil];
    NSLog(@"hitPoint: %@", NSStringFromPoint(hitPoint));

    [self setShouldDrawSelection:NO];
    [selectedPoints removeAllObjects];
    [self _selectionDidChange];
    [self setNeedsDisplay:YES];

    if ([mouseEvent clickCount] == 1) {
        //NSLog(@"[mouseEvent modifierFlags]: %x", [mouseEvent modifierFlags]);
#if 0
        if ([mouseEvent modifierFlags] & NSAlternateKeyMask) {
            MMPoint *newPoint;
            NSPoint graphOrigin = [self graphOrigin];
            int yScale = [self sectionHeight];
            float newValue;

            NSLog(@"Alt-clicked!");
            newPoint = [[MMPoint alloc] init];
            [newPoint setFreeTime:(hitPoint.x - graphOrigin.x) / [self timeScale]];
            //NSLog(@"hitPoint: %@, graphOrigin: %@, yScale: %d", NSStringFromPoint(hitPoint), NSStringFromPoint(graphOrigin), yScale);
            newValue = (hitPoint.y - graphOrigin.y - (zeroIndex * yScale)) * sectionAmount / yScale;

            //NSLog(@"NewPoint Time: %f  value: %f", [tempPoint freeTime], [tempPoint value]);
            [newPoint setValue:newValue];
            if ([[self delegate] respondsToSelector:@selector(transitionView:shouldAddPoint:)] == NO
                || [[self delegate] transitionView:self shouldAddPoint:newPoint] == YES) {
                [transition insertPoint:newPoint];
                [selectedPoints removeAllObjects];
                [selectedPoints addObject:newPoint];
            }

            [newPoint release];

            [self _selectionDidChange];
            [self setNeedsDisplay:YES];
            return;
        }
#endif
    }


    selectionPoint1 = hitPoint;
    selectionPoint2 = hitPoint; // TODO (2004-03-11): Should only do this one they start dragging
    [self setShouldDrawSelection:YES];
}

- (void)mouseDragged:(NSEvent *)mouseEvent;
{
    NSPoint hitPoint;

    //NSLog(@" > %s", _cmd);

//    if ([self isEnabled] == NO)
//        return;

    if (flags.shouldDrawSelection == YES) {
        hitPoint = [self convertPoint:[mouseEvent locationInWindow] fromView:nil];
        //NSLog(@"hitPoint: %@", NSStringFromPoint(hitPoint));
        selectionPoint2 = hitPoint;
        [self setNeedsDisplay:YES];

        [self selectGraphPointsBetweenPoint:selectionPoint1 andPoint:selectionPoint2];
    }

    //NSLog(@"<  %s", _cmd);
}

- (void)mouseUp:(NSEvent *)mouseEvent;
{
    [self setShouldDrawSelection:NO];
}

- (void)selectGraphPointsBetweenPoint:(NSPoint)point1 andPoint:(NSPoint)point2;
{
    NSPoint graphOrigin;
    NSRect selectionRect;
    int count, index;
    //float timeScale;
    int yScale;
    NSArray *intonationPoints;
    NSRect bounds;

    bounds = NSIntegralRect([self bounds]);

    [selectedPoints removeAllObjects];

    //NSLog(@"%s, cacheTag: %d", _cmd, cacheTag);
    graphOrigin = [self graphOrigin];
    //timeScale = [self timeScale];
    yScale = [self sectionHeight];

    selectionRect = [self rectFormedByPoint:point1 andPoint:point2];
    selectionRect.origin.x -= graphOrigin.x;
    selectionRect.origin.y -= graphOrigin.y;

    //NSLog(@"%s, selectionRect: %@", _cmd, NSStringFromRect(selectionRect));

    intonationPoints = [eventList intonationPoints];
    count = [intonationPoints count];
    //NSLog(@"%d display points", count);
    for (index = 0; index < count; index++) {
        MMIntonationPoint *currentIntonationPoint;
        NSPoint currentPoint;

        currentIntonationPoint = [intonationPoints objectAtIndex:index];
        currentPoint.x = [self scaleXPosition:[currentIntonationPoint absoluteTime]];
        currentPoint.y = rint(([currentIntonationPoint semitone] + ZERO_SECTION) * [self sectionHeight]) + 0.5;

        //NSLog(@"%2d: currentPoint: %@", index, NSStringFromPoint(currentPoint));
        if (NSPointInRect(currentPoint, selectionRect) == YES) {
            [selectedPoints addObject:currentIntonationPoint];
        }
    }

    [self _selectionDidChange];
    [self setNeedsDisplay:YES];
}

#ifdef PORTING
// Single click selects an intonation point
// Control clicking and then dragging adjusts the scale
// Rubberband selection of multiple points
// Double-clicking adds intonation point?
- (void)mouseDown:(NSEvent *)theEvent;
{
    float row, column;
    float row1, column1;
    float row2, column2;
    float temp, distance, distance1, tally = 0.0, tally1 = 0.0;
    float semitone;
    NSPoint mouseDownLocation = [theEvent locationInWindow];
    NSEvent *newEvent;
    int i, ruleIndex = 0;
    struct _rule *rule;
    MMIntonationPoint *iPoint;
    id tempPoint;

    [[self window] setAcceptsMouseMovedEvents:YES];

    /* Get information about the original location of the mouse event */
    mouseDownLocation = [self convertPoint:mouseDownLocation fromView:nil];
    row = mouseDownLocation.y;
    column = mouseDownLocation.x;

    /* Single click mouse events */
    if ([theEvent clickCount] == 1) {
        for (i = 0; i < [intonationPoints count]; i++) {
            tempPoint = [intonationPoints objectAtIndex:i];
            row1 = (([tempPoint semitone]+20.0) * ([self frame].size.height-70.0) / 30.0)+5.0;
            column1 = [tempPoint absoluteTime] / timeScale;

            if ( ((row1-row)*(row1-row) + (column1-column)*(column1-column)) < 100.0) {
                [selectedPoints removeAllObjects];
                [selectedPoints addObject:tempPoint];
                [self _selectionDidChange];
                [self setNeedsDisplay:YES];

                return;
            }
        }

        if (([theEvent modifierFlags] && NSControlKeyMask) || ([theEvent modifierFlags] && NSControlKeyMask)) {
            flags.mouseBeingDragged = YES;
            [self lockFocus];
            [self updateScale:(float)column];
            [self unlockFocus];
            flags.mouseBeingDragged = NO;
            [self setNeedsDisplay:YES];
        } else {
            NSPoint loc;

            [self lockFocus];
            //PSsetinstance(TRUE);
            while (1) {
                NSBezierPath *bezierPath;

                newEvent = [NSApp nextEventMatchingMask:NSAnyEventMask
                                  untilDate:[NSDate distantFuture]
                                  inMode:NSEventTrackingRunLoopMode
                                  dequeue:YES];
                //PSnewinstance();
                if ([newEvent type] == NSLeftMouseUp)
                    break;

                loc = [self convertPoint:[newEvent locationInWindow] fromView:nil];

                [[NSColor darkGrayColor] set];
                bezierPath = [[NSBezierPath alloc] init];
                [bezierPath moveToPoint:NSMakePoint(column, row)];
                [bezierPath lineToPoint:NSMakePoint(column, loc.y)];
                [bezierPath lineToPoint:NSMakePoint(loc.x, loc.y)];
                [bezierPath lineToPoint:NSMakePoint(loc.x, row)];
                [bezierPath lineToPoint:NSMakePoint(column, row)];
                [bezierPath stroke];
                [bezierPath release];

                [[self window] flushWindow];

            }
            //PSsetinstance(FALSE);
            loc = [self convertPoint:[newEvent locationInWindow] fromView:nil];

            if (row < [newEvent locationInWindow].y)
                row1 = loc.y;
            else {
                row1 = row;
                row = loc.y;
            }

            if (column < loc.x)
                column1 = loc.x;
            else {
                column1 = column;
                column = loc.x;
            }

            [selectedPoints removeAllObjects];
            for (i = 0; i < [intonationPoints count]; i++) {
                tempPoint = [intonationPoints objectAtIndex:i];
                column2 = [tempPoint absoluteTime] / timeScale;

                row2 = (([tempPoint semitone]+20.0) * ([self frame].size.height-70.0) / 30.0)+5.0;

                if ((row2 < row1) && (row2 > row))
                    if ((column2 < column1) && (column2 > column))
                        [selectedPoints addObject:tempPoint];
            }

            [self unlockFocus];
            [self _selectionDidChange];
            [self setNeedsDisplay:YES];
        }
    }

    /* Double Click mouse events */
    if ([theEvent clickCount] == 2) {
        if (![eventList numberOfRules])
            return;

        temp = column * timeScale;
        semitone = (double) (((row-5.0)/([self frame].size.height-70.0))*30.0)-20.0;

        distance = 1000000.0;

        tally = tally1 = 0.0;

        for (i = 0; i < [eventList numberOfRules]; i++) {
            rule = [eventList getRuleAtIndex:i];
            distance1 = (float) fabs(temp - rule->beat);
            //NSLog(@"temp: %f  beat: %f  dist: %f  distance1: %f", temp, rule->beat, distance, distance1);
            if (distance1 <= distance) {
                distance = distance1;
                ruleIndex = i;
            } else {
                rule = [eventList getRuleAtIndex:ruleIndex];
                //NSLog(@"Selecting Rule: %d posture index %d", ruleIndex, rule->lastPhone);

                // TODO (2004-08-09): Should just use -[EventList addIntonationPoint:offsetTime:slope:ruleIndex:]
                iPoint = [[MMIntonationPoint alloc] initWithEventList:eventList];
                [iPoint setRuleIndex:ruleIndex];
                [iPoint setOffsetTime:(double)temp - rule->beat];
                [iPoint setSemitone:semitone];
                [self addIntonationPoint:iPoint];
                [iPoint release];

                [self setNeedsDisplay:YES];
                // TODO (2004-03-31): Select new point.
                return;
            }
        }
    }
}
#endif

- (void)updateScale:(float)column;
{
#ifdef PORTING
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
        delta = column-mouseDownLocation.x;
        timeScale = originalScale + delta / 20.0;
        if (timeScale > 10.0)
            timeScale = 10.0;
        if (timeScale < 0.1)
            timeScale = 0.1;
        //[self clearView];
        [self drawGrid];
        [[self window] flushWindow];

        if ([newEvent type] == NSLeftMouseUp)
            break;
    }

    [[self window] setAcceptsMouseMovedEvents:NO];
#endif
}

- (void)deselectAllPoints;
{
    [selectedPoints removeAllObjects];
    [self setNeedsDisplay:YES];
    [self _selectionDidChange];
}

- (void)deletePoints;
{
    int i;
    id tempPoint;

    if ([selectedPoints count]) {
        for (i = 0; i < [selectedPoints count]; i++) {
            tempPoint = [selectedPoints objectAtIndex:i];
            [eventList removeIntonationPoint:tempPoint];
            [tempPoint release];
        }

        [selectedPoints removeAllObjects];
        [self setNeedsDisplay:YES];
        [self _selectionDidChange];
    } else {
        NSBeep();
    }
}

- (MMIntonationPoint *)selectedIntonationPoint;
{
    if ([selectedPoints count] == 0)
        return nil;

    return [selectedPoints objectAtIndex:0];
}

- (void)selectIntonationPoint:(MMIntonationPoint *)anIntonationPoint;
{
    [selectedPoints removeAllObjects];
    if (anIntonationPoint != nil)
        [selectedPoints addObject:anIntonationPoint];
    [self setNeedsDisplay:YES];
    [self _selectionDidChange];
}

- (void)_selectionDidChange;
{
    NSNotification *aNotification;

    aNotification = [NSNotification notificationWithName:IntonationViewSelectionDidChangeNotification object:self];
    [[NSNotificationCenter defaultCenter] postNotification:aNotification];

    if ([[self delegate] respondsToSelector:@selector(intonationViewSelectionDidChange:)] == YES)
        [[self delegate] intonationViewSelectionDidChange:aNotification];
}

//
// View geometry
//

- (int)sectionHeight;
{
    NSRect bounds;
    int sectionHeight;

    bounds = [self bounds];
    sectionHeight = (bounds.size.height - TOP_MARGIN - BOTTOM_MARGIN) / SECTION_COUNT;

    return sectionHeight;
}

- (NSPoint)graphOrigin;
{
    NSPoint graphOrigin;

    graphOrigin.x = LEFT_MARGIN;
    graphOrigin.y = [self bounds].size.height - TOP_MARGIN - SECTION_COUNT * [self sectionHeight];

    return graphOrigin;
}

- (void)updateEvents;
{
    [self deselectAllPoints];
    // TODO (2004-08-09): And select the first point again?
    [self setNeedsDisplay:YES];
}

- (float)scaleXPosition:(float)xPosition;
{
    return floor(xPosition / timeScale);
}

- (float)scaleWidth:(float)width;
{
    return floor(width / timeScale);
}

- (NSRect)rectFormedByPoint:(NSPoint)point1 andPoint:(NSPoint)point2;
{
    float minx, miny, maxx, maxy;
    NSRect rect;

    if (point1.x < point2.x) {
        minx = point1.x;
        maxx = point2.x;
    } else {
        minx = point2.x;
        maxx = point1.x;
    }

    if (point1.y < point2.y) {
        miny = point1.y;
        maxy = point2.y;
    } else {
        miny = point2.y;
        maxy = point1.y;
    }

    rect.origin.x = minx;
    rect.origin.y = miny;
    rect.size.width = maxx - minx;
    rect.size.height = maxy - miny;

    return rect;
}

- (void)intonationPointDidChange:(NSNotification *)aNotification;
{
    [self setNeedsDisplay:YES];
}

@end

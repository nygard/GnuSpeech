#import "IntonationView.h"

#import <AppKit/AppKit.h>
#import "AppController.h"
#import "Event.h"
#import "EventList.h"
#import "IntonationPoint.h"
#import "IntonationPointInspector.h"
#import "MonetList.h"
#import "Phone.h"
#import "StringParser.h"

@implementation IntonationView

/*===========================================================================

	Method: initFrame
	Purpose: To initialize the frame

===========================================================================*/

- (id)initWithFrame:(NSRect)frameRect;
{
    if ([super initWithFrame:frameRect] == nil)
        return nil;

    [self allocateGState];

    dotMarker = [NSImage imageNamed:@"dotMarker.tiff"];
    squareMarker = [NSImage imageNamed:@"squareMarker.tiff"];
    triangleMarker = [NSImage imageNamed:@"triangleMarker.tiff"];
    selectionBox = [NSImage imageNamed:@"selectionBox.tiff"];

    timesFont = [NSFont fontWithName:@"Times-Roman" size:12];
    timesFontSmall = [NSFont fontWithName:@"Times-Roman" size:10];

    timeScale = 1.0;
    mouseBeingDragged = 0;

    eventList = nil;

    intonationPoints = [[MonetList alloc] initWithCapacity:50];
    selectedPoints = [[MonetList alloc] initWithCapacity:20];

    [self display];

    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
    NSLog(@"<%@>[%p]  > %s", NSStringFromClass([self class]), self, _cmd);
    NSLog(@"<%@>[%p] <  %s", NSStringFromClass([self class]), self, _cmd);
}

- (BOOL)acceptsFirstResponder;
{
    ///NSLog(@"Accepts first responder");
    return YES;
}

- (void)setEventList:aList;
{
    eventList = aList;
    [self display];
}

- (void)setNewController:aController;
{
    controller = aController;
}

- controller;
{
    return controller;
}

- (void)setUtterance:newUtterance;
{
    utterance = newUtterance;
}

- (void)setSmoothing:smoothingSwitch;
{
    smoothing = smoothingSwitch;
}

- (void)addIntonationPoint:iPoint;
{
    double time;
    int i;

//    NSLog(@"Point  Semitone: %f  timeOffset:%f slope:%f phoneIndex:%d", [iPoint semitone], [iPoint offsetTime],
//           [iPoint slope], [iPoint ruleIndex]);

    if ([iPoint ruleIndex] > [eventList numberOfRules])
        return;

    [intonationPoints removeObject:iPoint];
    time = [iPoint absoluteTime];
    for (i = 0; i < [intonationPoints count]; i++) {
        if (time < [[intonationPoints objectAtIndex:i] absoluteTime]) {
            [intonationPoints insertObject:iPoint atIndex:i];
            return;
        }
    }

    [intonationPoints addObject:iPoint];
}

- (void)drawRect:(NSRect)rect;
{
    //[self clearView];
    [self drawGrid];
    [[self enclosingScrollView] reflectScrolledClipView:[self superview]];
}

- (void)clearView;
{
    NSDrawGrayBezel([self frame], [self frame]);
}

- (void)mouseEntered:(NSEvent *)theEvent;
{
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
    [[self window] setAcceptsMouseMovedEvents: NO];
}

// TODO (2004-03-02): Use NSLeftArrowFunctionKey and friends.
#define DELETEKEY	27
#define LEFTARROW	9
#define RIGHTARROW	16
#define UPARROW		22
#define DOWNARROW	15

- (void)keyDown:(NSEvent *)theEvent;
{
    int i, numRules, pointCount;
    id tempPoint;
    //NSLog(@"KeyDown %d", theEvent->data.key.keyCode);

    numRules = [eventList numberOfRules];
    pointCount = [selectedPoints count];

    switch ((int)[theEvent keyCode]) {
      case DELETEKEY:
          [self deletePoints];
          break;

      case LEFTARROW:
          for (i = 0; i < pointCount; i++) {
              if ([[selectedPoints objectAtIndex:i] ruleIndex] - 1 < 0) {
                  NSBeep();
                  return;
              }
          }

          for (i = 0; i < pointCount; i++) {
              tempPoint = [selectedPoints objectAtIndex:i];
              [tempPoint setRuleIndex:[tempPoint ruleIndex] - 1];
              [self addIntonationPoint:tempPoint];
          }
          break;

      case RIGHTARROW:
          for (i = 0; i < pointCount; i++) {
              if ([[selectedPoints objectAtIndex:i] ruleIndex] + 1 >= numRules) {
                  NSBeep();
                  return;
              }
          }

          for (i = 0; i < pointCount; i++) {
              tempPoint = [selectedPoints objectAtIndex:i];
              [tempPoint setRuleIndex:[tempPoint ruleIndex] + 1];
              [self addIntonationPoint:tempPoint];
          }
          break;

      case UPARROW:
          for (i = 0; i < pointCount; i++) {
              if ([[selectedPoints objectAtIndex:i] semitone] +1.0 > 10.0) {
                  NSBeep();
                  return;
              }
          }

          for (i = 0; i < pointCount; i++) {
              tempPoint = [selectedPoints objectAtIndex:i];
              [tempPoint setSemitone:[tempPoint semitone] + 1.0];
          }
          break;

      case DOWNARROW:
          for (i = 0; i < pointCount; i++) {
              if ([[selectedPoints objectAtIndex:i] semitone] - 1.0 < -20.0) {
                  NSBeep();
                  return;
              }
          }

          for (i = 0; i < pointCount; i++) {
              tempPoint = [selectedPoints objectAtIndex:i];
              [tempPoint setSemitone:[tempPoint semitone] - 1.0];
          }
          break;
    }

    [self display];
}

- (void)mouseExited:(NSEvent *)theEvent;
{
}

- (void)mouseMoved:(NSEvent *)theEvent;
{
}

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
    IntonationPoint *iPoint;
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
                [[controller inspector] inspectIntonationPoint:tempPoint];
                [selectedPoints removeAllObjects];
                [selectedPoints addObject:tempPoint];
                [self display];

                return;
            }
        }

        if (([theEvent modifierFlags] && NSControlKeyMask) || ([theEvent modifierFlags] && NSControlKeyMask)) {
            mouseBeingDragged = 1;
            [self lockFocus];
            [self updateScale:(float)column];
            [self unlockFocus];
            mouseBeingDragged = 0;
            [self display];
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
            [self display];
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
                //NSLog(@"Selecting Rule: %d phone index %d", ruleIndex, rule->lastPhone);

                iPoint = [[IntonationPoint alloc] initWithEventList:eventList];
                [iPoint setRuleIndex:ruleIndex];
                [iPoint setOffsetTime:(double)temp - rule->beat];
                [iPoint setSemitone:semitone];
                [self addIntonationPoint:iPoint];
                [iPoint release];

                [self display];
                //[[[[superview superview] controller] inspector] inspectIntonationPoint:iPoint];
                [[controller inspector] inspectIntonationPoint:iPoint];
                return;
            }
        }
    }
}

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent;
{
    NSLog(@"%s, %d", _cmd, [theEvent keyCode]);
    return YES;
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
}

- (void)drawGrid;
{
    NSRect drawFrame;
    NSRect rect = {{0.0, 0.0}, {10.0, 10.0}};
    NSPoint myPoint;
    int i, j, phoneIndex = 0;
    float currentX, currentY;
    float timeValue;
    float drawHeight;
    float increment[7] = {0.1, 0.2, 0.5, 1.0, 2.0, 5.0, 10.0};
    Event  *lastEvent;
    Phone *currentPhone = nil;
    struct _rule *rule;
    NSBezierPath *bezierPath;

    lastEvent = [eventList lastEvent];
    drawFrame = [[self superview] frame];
    timeValue = (float)[lastEvent time] / timeScale;
    if (drawFrame.size.width < timeValue)
        drawFrame.size.width = timeValue;
    [self setFrame:drawFrame];

    /* Make an outlined white box for display */
    [[NSColor whiteColor] set];
    NSRectFill([self bounds]);

    [[NSColor blackColor] set];
    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:2];
    [bezierPath moveToPoint:NSMakePoint(0.0, 5.0)];
    [bezierPath lineToPoint:NSMakePoint(0.0, [self frame].size.height-65.0)];
    [bezierPath lineToPoint:NSMakePoint([self frame].size.width, [self frame].size.height-65.0)];
    [bezierPath lineToPoint:NSMakePoint([self frame].size.width, 5.0)];
    [bezierPath lineToPoint:NSMakePoint(0.0, 5.0)];
    [bezierPath stroke];
    [bezierPath release];

    /* Put phone label on the top */
    [timesFont set];
    for (i = 0; i < [eventList count]; i++) {
        currentX = ((float)[[eventList objectAtIndex:i] time] / timeScale);
        if (currentX > [self frame].size.width-20.0)
            break;

        if ([[eventList objectAtIndex:i] flag]) {
            [[NSColor blackColor] set];
            currentPhone = [eventList getPhoneAtIndex:phoneIndex++];
            if (currentPhone)
                [[currentPhone symbol] drawAtPoint:NSMakePoint(currentX-5.0, [self frame].size.height-62.0) withAttributes:nil];
        }
#ifdef PORTING
        if (!mouseBeingDragged)
            PSstroke();
#endif
    }

    /* Put Rules on top */
    [timesFontSmall set];
    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
    currentX = 0;
    for (i = 0; i < [eventList numberOfRules]; i++) {
        NSString *str;
        rule = [eventList getRuleAtIndex:i];
        drawFrame.origin.x = currentX;
        drawFrame.origin.y = [self frame].size.height-40.0;
        drawFrame.size.height = 30.0;
        drawFrame.size.width = (float)rule->duration / timeScale;
        NSDrawWhiteBezel(drawFrame , drawFrame);
        [[NSColor blackColor] set];

        str = [NSString stringWithFormat:@"%d", rule->number];
        [str drawAtPoint:NSMakePoint(currentX+(float)rule->duration/(3*timeScale), [self frame].size.height-21.0) withAttributes:nil];

        str = [NSString stringWithFormat:@"%.2f", rule->duration];
        [str drawAtPoint:NSMakePoint(currentX+(float)rule->duration/(3*timeScale), [self frame].size.height-35.0) withAttributes:nil];

        [bezierPath moveToPoint:NSMakePoint((float)rule->beat/timeScale, [self frame].size.height-62.0)];
        [bezierPath lineToPoint:NSMakePoint((float)rule->beat/timeScale, 5.0)];

        currentX += (float)rule->duration / timeScale;
    }
    [[NSColor darkGrayColor] set];
    [bezierPath stroke];
    [bezierPath release];

    /* Draw in best fit grid markers */
    j = 0;
    drawHeight = [self frame].size.height-70.0;	/* Subtract [65(top) + 5(bottom)] */
    while ((drawHeight*increment[j]) / 30.0 < 15.0) {
        j++;
        if (j==6)
            break;
    }

    [[NSColor lightGrayColor] set];
    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
    for (i = 0; i< (int)(30.0/increment[j]); i++) {
        [bezierPath moveToPoint:NSMakePoint(0.0, ((float)i*increment[j]*([self frame].size.height-70.0))/30.0 + 5.0)];
        [bezierPath lineToPoint:NSMakePoint([self frame].size.width-2.0, ((float)i*increment[j]*([self frame].size.height-70.0))/30.0 + 5.0)];
    }
    [bezierPath stroke];
    [bezierPath release];

    [[NSColor blackColor] set];
    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
    [bezierPath moveToPoint:NSMakePoint(0.0, 5.0)];
    for (i = 0; i < [intonationPoints count]; i++) {
        currentX = (float) [[intonationPoints objectAtIndex:i] absoluteTime]/timeScale;
        currentY = (float) (([[intonationPoints objectAtIndex:i] semitone] + 20.0) * ([self frame].size.height-70.0))/30.0 + 5.0;
        [bezierPath lineToPoint:NSMakePoint(currentX, currentY)];

        myPoint.x = currentX-3.0;
        myPoint.y = currentY-3.0;
        [dotMarker compositeToPoint:myPoint fromRect:rect operation:NSCompositeSourceOver];
    }
    [bezierPath stroke];
    [bezierPath release];

    for (i = 0; i < [selectedPoints count]; i++) {
        currentX = (float) [[selectedPoints objectAtIndex:i] absoluteTime]/timeScale;
        currentY = (float) (([[selectedPoints objectAtIndex:i] semitone] + 20.0) * ([self frame].size.height-70.0))/30.0 + 5.0;
        //slopeX = 0.0;
        //slopeY = 0.0;

        //PSmoveto(currentX, currentY);
        //PSlineto(slopeX, slopeY);
        //PSstroke();

        myPoint.x = currentX - 5.0;
        myPoint.y = currentY - 5.0;
        [selectionBox compositeToPoint:myPoint fromRect:rect operation:NSCompositeSourceOver];
    }

    if ((!mouseBeingDragged) && ([smoothing state]))
        [self smoothPoints];
}

- (void)applyIntonation;
{
    int i;
    id temp;

    [eventList setFullTimeScale];
    [eventList insertEvent:32 atTime:0.0 withValue:-20.0];
    NSLog(@"Applying intonation");
    for (i = 0; i < [intonationPoints count]; i++) {
        temp = [intonationPoints objectAtIndex:i];
        NSLog(@"Added Event at Time: %f withValue: %f", [temp absoluteTime], [temp semitone]);
        [eventList insertEvent:32 atTime:[temp absoluteTime] withValue:[temp semitone]];
        [eventList insertEvent:33 atTime:[temp absoluteTime] withValue:0.0];
        [eventList insertEvent:34 atTime:[temp absoluteTime] withValue:0.0];
        [eventList insertEvent:35 atTime:[temp absoluteTime] withValue:0.0];
    }

    [eventList finalEvent:32 withValue:-20.0];
}

- (void)applyIntonationSmooth;
{
    int j;
    id point1, point2;
    id tempPoint;
    double a, b, c, d;
    double x1, y1, m1, x12, x13;
    double x2, y2, m2, x22, x23;
    double denominator;
    double yTemp;

    [eventList setFullTimeScale];
    tempPoint = [[IntonationPoint alloc] initWithEventList:eventList];
    [tempPoint setSemitone:[[intonationPoints objectAtIndex:0] semitone]];
    [tempPoint setSlope:0.0];
    [tempPoint setRuleIndex:0];
    [tempPoint setOffsetTime:0];

    [intonationPoints insertObject:tempPoint atIndex:0];

    //[eventList insertEvent:32 atTime: 0.0 withValue: -20.0];
    for (j = 0; j < [intonationPoints count]-1; j++) {
        point1 = [intonationPoints objectAtIndex:j];
        point2 = [intonationPoints objectAtIndex:j+1];

        x1 = [point1 absoluteTime] / 4.0;
        y1 = [point1 semitone] + 20.0;
        m1 = [point1 slope];

        x2 = [point2 absoluteTime] / 4.0;
        y2 = [point2 semitone] + 20.0;
        m2 = [point2 slope];

        x12 = x1*x1;
        x13 = x12*x1;

        x22 = x2*x2;
        x23 = x22*x2;

        denominator = (x2 - x1);
        denominator = denominator * denominator * denominator;

        d = ( -(y2*x13) + 3*y2*x12*x2 + m2*x13*x2 + m1*x12*x22 - m2*x12*x22 - 3*x1*y1*x22 - m1*x1*x23 + y1*x23)
            / denominator;
        c = ( -(m2*x13) - 6*y2*x1*x2 - 2*m1*x12*x2 - m2*x12*x2 + 6*x1*y1*x2 + m1*x1*x22 + 2*m2*x1*x22 + m1*x23 )
            / denominator;
        b = ( 3*y2*x1 + m1*x12 + 2*m2*x12 - 3*x1*y1 + 3*x2*y2 + m1*x1*x2 - m2*x1*x2 - 3*y1*x2 - 2*m1*x22 - m2*x22 )
            / denominator;
        a = ( -2*y2 - m1*x1 - m2*x1 + 2*y1 + m1*x2 + m2*x2)/ denominator;

        [eventList insertEvent:32 atTime:[point1 absoluteTime] withValue:[point1 semitone]];
        yTemp = ((3.0*a*x12) + (2.0*b*x1) + c) ;
        [eventList insertEvent:33 atTime:[point1 absoluteTime] withValue:yTemp];
        yTemp = ((6.0*a*x1) + (2.0*b)) ;
        [eventList insertEvent:34 atTime:[point1 absoluteTime] withValue:yTemp];
        yTemp = (6.0*a);
        [eventList insertEvent:35 atTime:[point1 absoluteTime] withValue:yTemp];

    }

    [intonationPoints removeObjectAtIndex:0];
}

- (void)deletePoints;
{
    int i;
    id tempPoint;

    if ([selectedPoints count]) {
        for (i = 0; i < [selectedPoints count]; i++) {
            tempPoint = [selectedPoints objectAtIndex:i];
            [intonationPoints removeObject:tempPoint];
            [tempPoint release];
        }

        [selectedPoints removeAllObjects];
    } else {
        NSBeep();
    }
}

- (void)saveIntonationContour:sender;
{
    NSString *str;
    NSString *filename;
    NSMutableData *mdata;
    NSArchiver *stream = nil;
    NSSavePanel *myPanel;

    str = [utterance stringValue];

    myPanel = [NSSavePanel savePanel];
    if ([myPanel runModal]) {
        filename = [myPanel filename];
        mdata = [NSMutableData dataWithCapacity:16];
        stream = [[NSArchiver alloc] initForWritingWithMutableData:mdata];
        if (stream) {
            [stream encodeValueOfObjCType:"*" at:&str]; // TODO (2004-03-02): Not the correct type.
            [stream encodeObject:intonationPoints];
            [mdata writeToFile:[myPanel filename] atomically:NO];
            [stream release];
        }
    }
}

- (void)loadContour:sender;
{
    char *temp;
    NSArchiver *stream = nil;
    NSArray *types, *fnames;
    NSString *filename;

    [selectedPoints removeAllObjects];
    [[NSOpenPanel openPanel] setAllowsMultipleSelection:NO];
    types = [NSArray arrayWithObjects: @"contour", @"", nil];

    if ([[NSOpenPanel openPanel] runModalForTypes:types]) {
        fnames = [[NSOpenPanel openPanel] filenames];
        filename =  [[NSOpenPanel openPanel] directory];
        filename = [filename stringByAppendingPathComponent:[fnames objectAtIndex:0]];

        NSLog(@"Filename = |%@|\n", filename);
        stream = [[NSUnarchiver alloc] initForReadingWithData:[NSData dataWithContentsOfFile:filename]];
        if (stream) {
            [stream decodeValueOfObjCType:"*" at:&temp];
            free(temp);
            [intonationPoints release];
            intonationPoints = [[stream decodeObject] retain];
            [stream release];
        }
    }
}

- (void)loadContourAndUtterance:sender;
{
    int i;
    char *temp;
    NSArray *types, *fnames;
    NSString *filename;
    NSArchiver *stream = nil;
    id tempList, stringParser;

    [selectedPoints removeAllObjects];
    types = [NSArray arrayWithObjects: @"contour", @"", nil];
    [[NSOpenPanel openPanel] setAllowsMultipleSelection:NO];

    if ([[NSOpenPanel openPanel] runModalForTypes:types]) {
        fnames = [[NSOpenPanel openPanel] filenames];
        filename =  [[NSOpenPanel openPanel] directory];
        filename = [filename stringByAppendingPathComponent:[fnames objectAtIndex:0]];

        NSLog(@"Filename = |%@|\n", filename);

        stream = [[NSUnarchiver alloc] initForReadingWithData:[NSData dataWithContentsOfFile:filename]];
        if (stream) {
            [stream decodeValueOfObjCType:"*" at:&temp];
            [utterance setStringValue:[NSString stringWithCString:temp]];
            free(temp);
            stringParser = NXGetNamedObject(@"stringParser", NSApp);
            [stringParser setUpDataStructures];

            [intonationPoints removeAllObjects];
            //[intonationPoints free];

            tempList = [[stream decodeObject] retain];
            for (i = 0; i < [tempList count]; i++) {
                [self addIntonationPoint:[tempList objectAtIndex:i]];
            }

            [tempList release];
            [stream release];
        }
    }
}

- (void)smoothPoints;
{
    double a, b, c, d;
    double x1, y1, m1, x12, x13;
    double x2, y2, m2, x22, x23;
    double denominator;
    double x, y, xx,yy;
    int i, j;
    id point1, point2;
    NSBezierPath *bezierPath;

    if ([intonationPoints count] < 2)
        return;

    for (j = 0; j < [intonationPoints count]-1; j++) {
        point1 = [intonationPoints objectAtIndex:j];
        point2 = [intonationPoints objectAtIndex:j+1];

        x1 = [point1 absoluteTime];
        y1 = [point1 semitone]+20.0;
        m1 = [point1 slope];

        x2 = [point2 absoluteTime];
        y2 = [point2 semitone]+20.0;
        m2 = [point2 slope];

        x12 = x1*x1;
        x13 = x12*x1;

        x22 = x2*x2;
        x23 = x22*x2;

        denominator = (x2 - x1);
        denominator = denominator * denominator * denominator;

        d = ( -(y2*x13) + 3*y2*x12*x2 + m2*x13*x2 + m1*x12*x22 - m2*x12*x22 - 3*x1*y1*x22 - m1*x1*x23 + y1*x23)
            / denominator;
        c = ( -(m2*x13) - 6*y2*x1*x2 - 2*m1*x12*x2 - m2*x12*x2 + 6*x1*y1*x2 + m1*x1*x22 + 2*m2*x1*x22 + m1*x23 )
            / denominator;
        b = ( 3*y2*x1 + m1*x12 + 2*m2*x12 - 3*x1*y1 + 3*x2*y2 + m1*x1*x2 - m2*x1*x2 - 3*y1*x2 - 2*m1*x22 - m2*x22 )
            / denominator;
        a = ( -2*y2 - m1*x1 - m2*x1 + 2*y1 + m1*x2 + m2*x2)/ denominator;

        NSLog(@"\n===\n x1 = %f y1 = %f m1 = %f", x1, y1, m1);
        NSLog(@"x2 = %f y2 = %f m2 = %f", x2, y2, m2);
        NSLog(@"a = %f b = %f c = %f d = %f", a, b, c, d);

        xx = (float)x1 / timeScale;
        yy = ((float)y1 * ([self frame].size.height-70.0))/30.0 +5.0;

        [[NSColor blackColor] set];

        bezierPath = [[NSBezierPath alloc] init];
        [bezierPath moveToPoint:NSMakePoint(xx,yy)];
        for (i = (int) x1; i <= (int)x2; i++) {
            x = (double) i;
            y = x*x*x*a + x*x*b + x*c + d;

            xx = (float)i/timeScale;
            yy = (float) ((float)y * ([self frame].size.height-70.0))/30.0 + 5.0;
            //NSLog(@"x = %f y = %f  yy = %f", (float)i, y, yy);
            [bezierPath lineToPoint:NSMakePoint(xx,yy)];
        }
        [bezierPath stroke];
        [bezierPath release];
    }
}

- (void)clearIntonationPoints;
{
    [selectedPoints removeAllObjects];
    [intonationPoints removeAllObjects];
}

- (void)addPoint:(double)semitone offsetTime:(double)offsetTime slope:(double)slope ruleIndex:(int)ruleIndex eventList:anEventList;
{
    IntonationPoint *iPoint;

    iPoint = [[IntonationPoint alloc] initWithEventList:anEventList];
    [iPoint setRuleIndex:ruleIndex];
    [iPoint setOffsetTime:offsetTime];
    [iPoint setSemitone:semitone];
    [iPoint setSlope:slope];
    [self addIntonationPoint:iPoint];
    [iPoint release];
}

@end

#import "SpecialView.h"

#import <AppKit/AppKit.h>
#import "Inspector.h"
#import "MonetList.h"
#import "MyController.h"
#import "Phone.h"
#import "Point.h"
#import "PointInspector.h"
#import "PrototypeManager.h"
#import "ProtoEquation.h"
#import "ProtoTemplate.h"
#import "TargetList.h"

@implementation SpecialView

/*===========================================================================

	Method: initFrame
	Purpose: To initialize the frame

===========================================================================*/

- (id)initWithFrame:(NSRect)frameRect;
{
    if ([super initWithFrame:frameRect] == nil)
        return nil;

    cache = -100000;

    self = [super initWithFrame:frameRect];
    [self allocateGState];

    totalFrame = NSMakeRect(0.0, 0.0, 700.0, 380.0);
    dotMarker = [NSImage imageNamed:@"dotMarker.tiff"];
    squareMarker = [NSImage imageNamed:@"squareMarker.tiff"];
    triangleMarker = [NSImage imageNamed:@"triangleMarker.tiff"];
    selectionBox = [NSImage imageNamed:@"selectionBox.tiff"];

    timesFont = [NSFont fontWithName:@"Times-Roman" size:12];

    currentTemplate = nil;

    selectedPoint = nil;

    [self setNeedsDisplay:YES];

    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
    Phone *dummy;
    id symbols, parms, metaParms;

    dummyPhoneList = [[MonetList alloc] initWithCapacity:4];
    displayPoints = [[MonetList alloc] initWithCapacity:12];

    symbols = NXGetNamedObject(@"mainSymbolList", NSApp);
    parms = NXGetNamedObject(@"mainParameterList", NSApp);
    metaParms = NXGetNamedObject(@"mainMetaParameterList", NSApp);

    dummy = [[Phone alloc] initWithSymbol:@"dummy" parmeters:parms metaParameters:metaParms symbols:symbols];
    [[[dummy symbolList] objectAtIndex:0] setValue:100.0];
    [[[dummy symbolList] objectAtIndex:1] setValue:33.3333];
    [[[dummy symbolList] objectAtIndex:2] setValue:33.3333];
    [[[dummy symbolList] objectAtIndex:3] setValue:33.3333];
    [dummyPhoneList addObject:dummy];
    [dummyPhoneList addObject:dummy];
    [dummyPhoneList addObject:dummy];
    [dummyPhoneList addObject:dummy];
}

- (BOOL)acceptsFirstResponder;
{
    //NSLog(@"Accepts first responder");
    return YES;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent;
{
    return YES;
}

- (void)drawRect:(NSRect)rect;
{
    //NSLog(@"Displaying Special Event");
    [self clearView];
    [self drawGrid];
    [self drawEquations];
    [self drawPhones];
    [self drawTransition];
}

- (void)clearView;
{
    NSDrawWhiteBezel([self frame], [self frame]);
}

- (void)drawGrid;
{
    int i;
    char tempLabel[25];
    float temp = ([self frame].size.height - 100.0)/14.0;

    PSsetgray(NSLightGray);
    PSrectfill(51.0, 51.0, [self frame].size.width - 102.0, (temp*2) - 2.0);
    PSrectfill(51.0, [self frame].size.height - 50.0 - (temp*2), [self frame].size.width - 102.0, (temp*2) - 1.0);
    PSstroke();

    /* Grayed out (unused) data spaces should be placed here */

    PSsetgray(NSBlack);
    PSsetlinewidth(2.0);
    PSmoveto(50.0, 50.0);
    PSlineto(50.0, [self frame].size.height - 50.0);
    PSlineto([self frame].size.width - 50.0, [self frame].size.height - 50.0);
    PSlineto([self frame].size.width - 50.0, 50.0);
    PSlineto(50.0, 50.0);
    PSstroke();

    [timesFont set];
    PSsetgray(NSBlack);
    PSsetlinewidth(1.0);

    for (i = 1; i < 14; i++)
    {
        PSmoveto(50.0, (float)i*temp + 50.0);
        PSlineto([self frame].size.width - 50.0,  (float)i*temp + 50.0);

        sprintf(tempLabel, "%4d%%", (i-7)*20);
        PSmoveto(16.0, (float)i*temp + 45.0);
        PSshow(tempLabel);
        PSmoveto([self frame].size.width - 47.0, (float)i*temp + 45.0);
        PSshow(tempLabel);
    }

    PSstroke();
}

- (void)drawEquations;
{
    int i, j;
    double symbols[5], time;
    id equationList = [NXGetNamedObject(@"prototypeManager", NSApp) equationList];
    id namedList, equation;
    float timeScale = ([self frame].size.width - 100.0) / [[displayParameters cellAtIndex:0] floatValue];
    int type;

    cache++;

    if (currentTemplate)
        type = [currentTemplate type];
    else
        type = DIPHONE;

    for (i = 0; i < 5; i++)
        symbols[i] = [[displayParameters cellAtIndex:i] doubleValue];

    PSsetgray(NSDarkGray);
    for (i = 0; i < [equationList count]; i++)
    {
        namedList = [equationList objectAtIndex:i];
        //NSLog(@"%@", [namedList name]);
        for (j = 0; j < [namedList count]; j++) {
            equation = [namedList objectAtIndex:j];
            if ([[equation expression] maxPhone] <= type) {
                time = [equation evaluate: symbols phones: dummyPhoneList andCacheWith: cache];
                //NSLog(@"\t%@", [equation name]);
                //NSLog(@"\t\ttime = %f", time);
                PSmoveto(50.0 + (timeScale*(float)time), 49.0);
                PSlineto(50.0 + (timeScale*(float)time), 40.0);
            }
        }
    }
    PSstroke();
}

- (void)drawPhones;
{
    NSRect rect = {{0.0, 0.0}, {8.0, 8.0}};
    NSPoint myPoint;
    float timeScale;
    float currentTimePoint;
    int type;

    if (currentTemplate)
        type = [currentTemplate type];
    else
        type = DIPHONE;

    PSsetlinewidth(2.0);
    PSsetgray(NSBlack);

    timeScale = ([self frame].size.width - 100.0) / [[displayParameters cellAtIndex:0] floatValue];
    myPoint.y = [self frame].size.height-47.0;

    switch (type) {
      case TETRAPHONE:
          currentTimePoint = (timeScale * [[displayParameters cellAtIndex:4] floatValue]);
          PSmoveto(50.0 + currentTimePoint, 50.0);
          PSlineto(50.0 + currentTimePoint, [self frame].size.height - 50.0);
          PSstroke();
          myPoint.x = currentTimePoint+47.0;
          [squareMarker compositeToPoint:myPoint fromRect:rect operation:NSCompositeSourceOver];

      case TRIPHONE:
          currentTimePoint = (timeScale * [[displayParameters cellAtIndex:3] floatValue]);
          PSmoveto(50.0 + currentTimePoint, 50.0);
          PSlineto(50.0 + currentTimePoint, [self frame].size.height - 50.0);
          PSstroke();
          myPoint.x = currentTimePoint+47.0;
          [triangleMarker compositeToPoint:myPoint fromRect:rect operation:NSCompositeSourceOver];

      case DIPHONE:
          currentTimePoint = (timeScale * [[displayParameters cellAtIndex:2] floatValue]);
          PSmoveto(50.0 + currentTimePoint, 50.0);
          PSlineto(50.0 + currentTimePoint, [self frame].size.height - 50.0);
          PSstroke();
          myPoint.x = currentTimePoint+47.0;
          [dotMarker compositeToPoint:myPoint fromRect:rect operation:NSCompositeSourceOver];
    }
}

- (void)drawTransition;
{
    int i, j;
    GSMPoint  *currentPoint;
    double symbols[5];
    float timeScale, yScale;
    float time, eventTime;
    NSRect rect = NSMakeRect(0, 0, 10, 10);

    if (currentTemplate == nil)
        return;

    [displayPoints removeAllObjects];

    for (i = 0; i < 5; i++)
        symbols[i] = [[displayParameters cellAtIndex:i] doubleValue];

    timeScale = ([self frame].size.width - 100.0) / [[displayParameters cellAtIndex:0] floatValue];
    yScale = ([self frame].size.height - 100.0)/14.0;

    cache++;

    for (i = 0; i < [[currentTemplate points] count]; i++) {
        currentPoint = [[currentTemplate points] objectAtIndex:i];
        if ([currentPoint expression] == nil)
            time = (float)[currentPoint freeTime];
        else
            time = (float)[[currentPoint expression] evaluate:symbols phones:dummyPhoneList andCacheWith:cache];

        //NSLog(@"%x Time = %f", [currentPoint expression], time);

        if (i == 0)
            [displayPoints addObject:currentPoint];
        else {
            j = [displayPoints count]-1;
            while (j > 0) {
                if ([[displayPoints objectAtIndex:j] expression] == nil)
                    eventTime = (float)[[displayPoints objectAtIndex:j] freeTime];
                else
                    eventTime = (float)[[[displayPoints objectAtIndex:j] expression] cacheValue];

                if (time > eventTime)
                    break;
                j--;
            }
            [displayPoints insertObject:currentPoint atIndex:j+1];
        }
    }

    PSsetlinewidth(2.0);
    PSmoveto(50.0, 50.0 + (yScale*2.0));

    for (i = 0; i < [displayPoints count]; i++) {
        float y;
        NSPoint myPoint;
        currentPoint = [displayPoints objectAtIndex:i];
        y = (float)[currentPoint value];
        //NSLog(@"y = %f", y);
        if ([currentPoint expression] == nil)
            eventTime = [currentPoint freeTime];
        else
            eventTime = [[currentPoint expression] evaluate:symbols phones:dummyPhoneList andCacheWith:cache];

        myPoint.x = timeScale * eventTime + 47.0;
        myPoint.y = (47.0 + (yScale*7.0))+ (y*yScale/20.0);
        PSlineto(myPoint.x+3.0, myPoint.y+3.0);
        PSstroke();
        switch ([currentPoint type]) {
          case TETRAPHONE:
              [squareMarker compositeToPoint:myPoint fromRect:rect operation:NSCompositeSourceOver];
              break;
          case TRIPHONE:
              [triangleMarker compositeToPoint:myPoint fromRect:rect operation:NSCompositeSourceOver];
              break;
          case DIPHONE:
              [dotMarker compositeToPoint:myPoint fromRect:rect operation:NSCompositeSourceOver];
              break;
        }

        if (i != [displayPoints count]-1) {
            if ([currentPoint type] == [(GSMPoint *)[displayPoints objectAtIndex:i+1] type])
                PSmoveto(myPoint.x+3.0, myPoint.y+3.0);
            else
                PSmoveto(myPoint.x+3.0, 50.0+(yScale*7.0));
        }
        else
            PSmoveto(myPoint.x+3.0, myPoint.y+3.0);
    }

    PSlineto([self frame].size.width-50.0, [self frame].size.height - 50.0 - (7.0*yScale));
    PSstroke();

    if (selectedPoint) {
        float y;
        NSPoint myPoint;
        y = (float)[(GSMPoint *)selectedPoint value];
        if ([selectedPoint expression] == nil)
            eventTime = [selectedPoint freeTime];
        else
            eventTime = [[selectedPoint expression] evaluate:symbols phones:dummyPhoneList andCacheWith:cache];

        myPoint.x = timeScale * eventTime + 45.0;
        myPoint.y = (45.0 + (yScale*7.0))+ (y*yScale/20.0);

        NSLog(@"Selectoion; x: %f y:%f", myPoint.x, myPoint.y);

        [selectionBox compositeToPoint:myPoint fromRect:rect operation:NSCompositeSourceOver];
    }
}

- (void)setTransition:newTransition;
{
    selectedPoint = nil;
    currentTemplate = newTransition;
    switch ([currentTemplate type]) {
      case DIPHONE:
          [[displayParameters cellAtIndex:0] setDoubleValue:100];
          [[displayParameters cellAtIndex:1] setDoubleValue:33];
          [[displayParameters cellAtIndex:2] setDoubleValue:100];
          [[displayParameters cellAtIndex:3] setStringValue:@"--"];
          [[displayParameters cellAtIndex:4] setStringValue:@"--"];
          break;
      case TRIPHONE:
          [[displayParameters cellAtIndex:0] setDoubleValue:200];
          [[displayParameters cellAtIndex:1] setDoubleValue:33];
          [[displayParameters cellAtIndex:2] setDoubleValue:100];
          [[displayParameters cellAtIndex:3] setDoubleValue:200];
          [[displayParameters cellAtIndex:4] setStringValue:@"--"];
          break;
      case TETRAPHONE:
          [[displayParameters cellAtIndex:0] setDoubleValue:300];
          [[displayParameters cellAtIndex:1] setDoubleValue:33];
          [[displayParameters cellAtIndex:2] setDoubleValue:100];
          [[displayParameters cellAtIndex:3] setDoubleValue:200];
          [[displayParameters cellAtIndex:4] setDoubleValue:300];
          break;
    }

    [self display];
}

- (void)mouseDown:(NSEvent *)theEvent;
{
    float row, column;
    float temp, distance, distance1;
    NSPoint mouseDownLocation = [theEvent locationInWindow];
    float timeScale = ([self frame].size.width - 100.0) / [[displayParameters cellAtIndex:0] floatValue];
    float yScale, tempValue;
    GSMPoint *tempPoint;
    int i;

    /* Get information about the original location of the mouse event */
    mouseDownLocation = [self convertPoint:mouseDownLocation fromView:nil];
    row = mouseDownLocation.y - 50.0;
    column = mouseDownLocation.x - 50.0;

    /* Single click mouse events */
    if ([theEvent clickCount] == 1) {
        selectedPoint = [displayPoints objectAtIndex:0];

        if ([[displayPoints objectAtIndex:0] expression] == nil)
            temp = [[displayPoints objectAtIndex:0] freeTime] * timeScale;
        else
            temp = [[[displayPoints objectAtIndex:0] expression] cacheValue] * timeScale;
        distance = (float)fabs((double)column - temp);

        for (i = 1; i < [displayPoints count]; i++) {
            if ([[displayPoints objectAtIndex:i] expression] == nil)
                temp = [[displayPoints objectAtIndex:i] freeTime] * timeScale;
            else
                temp = [[[displayPoints objectAtIndex:i] expression] cacheValue] * timeScale;
            distance1 = (float)fabs((double)column - temp);
            if (distance1 < distance) {
                distance = distance1;
                selectedPoint = [displayPoints objectAtIndex:i];
            }
        }
        [[controller inspector] inspectPoint:selectedPoint];
        [self display];
    }

    /* Double Click mouse events */
    if ([theEvent clickCount] == 2) {
        tempPoint = [[GSMPoint alloc] init];
        [tempPoint setFreeTime:column/timeScale];
        yScale = ([self frame].size.height - 100.0)/14.0;
        tempValue = (row - (7.0*yScale))/(5.0*yScale) * 100.0;

        printf("NewPoint Time: %f  value: %f\n", [tempPoint freeTime], [tempPoint value]);
        [tempPoint setValue:tempValue];
        [[currentTemplate points] addObject:tempPoint];
        [tempPoint release];
        selectedPoint = tempPoint;
        [[controller inspector] inspectPoint:selectedPoint];
        [self display];
    }
}

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent;
{
    NSLog(@"%d", [theEvent keyCode]);
    return YES;
}

- (void)showWindow:(int)otherWindow;
{
    [[self window] orderWindow:NSWindowBelow relativeTo:otherWindow];
}


- (void)delete:(id)sender;
{
    if ((currentTemplate == nil) || (selectedPoint == nil)) {
        NSBeep();
        return;
    }

    if ([[currentTemplate points] indexOfObject:selectedPoint] == 0) {
        NSBeep();
        return;
    }

    [[currentTemplate points] removeObject:selectedPoint];
    selectedPoint = nil;
    [[controller inspector] cleanInspectorWindow];
    [self display];
}

@end

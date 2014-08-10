//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "EventListView.h"

#import <GnuSpeech/GnuSpeech.h>

#import "NSNumberFormatter-Extensions.h"

#import "MMDisplayParameter.h"

#import <math.h>

#define RIGHT_MARGIN 20.0

@implementation EventListView
{
    NSFont *_timesFont;
    NSFont *_timesFontSmall;

    EventList *_eventList;

	NSTextField *_mouseTimeField;
	NSTextField *_mouseValueField;

    NSUInteger _startingIndex;
    CGFloat _timeScale;
    BOOL _mouseBeingDragged;
    NSTrackingRectTag _trackTag;

    NSTextFieldCell *_ruleCell;
    NSTextFieldCell *_minMaxCell;
    NSTextFieldCell *_parameterNameCell;

    NSArray *_displayParameters;
}

- (id)initWithFrame:(NSRect)frameRect;
{
    if ((self = [super initWithFrame:frameRect])) {
        [self allocateGState];
        
        _timesFont = [NSFont fontWithName:@"Times-Roman" size:12];
        _timesFontSmall = [NSFont fontWithName:@"Times-Roman" size:10];
        
        _startingIndex = 0;
        _timeScale = 2.0;
        _mouseBeingDragged = NO;
        
        _eventList = nil;
        _trackTag = 0;
        
        _ruleCell = [[NSTextFieldCell alloc] initTextCell:@""];
        [_ruleCell setFont:[NSFont labelFontOfSize:10.0]];
        [_ruleCell setAlignment:NSCenterTextAlignment];
        [_ruleCell setBordered:YES];
        [_ruleCell setEnabled:YES];
        
        _minMaxCell = [[NSTextFieldCell alloc] initTextCell:@""];
        [_minMaxCell setControlSize:NSSmallControlSize];
        [_minMaxCell setAlignment:NSRightTextAlignment];
        [_minMaxCell setBordered:NO];
        [_minMaxCell setEnabled:YES];
        [_minMaxCell setFont:_timesFontSmall];
        [_minMaxCell setFormatter:[NSNumberFormatter defaultNumberFormatter]];
        
        _parameterNameCell = [[NSTextFieldCell alloc] initTextCell:@""];
        [_parameterNameCell setControlSize:NSSmallControlSize];
        [_parameterNameCell setAlignment:NSLeftTextAlignment];
        [_parameterNameCell setBordered:NO];
        [_parameterNameCell setEnabled:YES];
        [_parameterNameCell setFont:_timesFont];
        
        _displayParameters = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(frameDidChange:)
                                                     name:NSViewFrameDidChangeNotification
                                                   object:self];	
        
        [self setNeedsDisplay:YES];
    }

    return self;
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeTrackingRect:_trackTag];  // track
}

#pragma mark -

- (void)awakeFromNib;
{
    _trackTag = [self addTrackingRect:[self bounds] owner:self userData:NULL assumeInside:NO];  // track
}

#pragma mark -

- (NSArray *)displayParameters;
{
    return _displayParameters;
}

- (void)setDisplayParameters:(NSArray *)newDisplayParameters;
{
    if (newDisplayParameters == _displayParameters)
        return;

    _displayParameters = newDisplayParameters;

    [self setNeedsDisplay:YES];
}

- (BOOL)acceptsFirstResponder;
{
    return YES;
}

- (void)setEventList:(EventList *)newEventList;
{
    if (newEventList == _eventList)
        return;

    _eventList = newEventList;

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
	NSRect bounds;
	
	// Added by dalmazio, April 11, 2009.
	bounds.size.width = [self minimumWidth];
	bounds.size.height = [self minimumHeight];
    // This is call during drawing, and it's a bad idea to change the frame during drawing.  On 10.7.3 it slows down the app tremendously.
	//[self setFrame:bounds];
	
	NSDrawGrayBezel([self bounds], [self bounds]);
}

#define TRACKHEIGHT		120.0
#define BORDERHEIGHT	20.0

- (void)drawGrid;
{
    NSUInteger j, k, parameterIndex;
    CGFloat currentX, currentY;
    CGFloat currentMin, currentMax;
    MMPosture *currentPhone = nil;
    NSRect bounds;
	
	// Set the proper bounds according to the event data.
	bounds.size.width = [self minimumWidth];
	bounds.size.height = [self minimumHeight];
	
	NSUInteger phoneIndex = 0;
	NSMutableArray *displayList = [[NSMutableArray alloc] init];
	
    NSUInteger count = [_displayParameters count];
    for (NSUInteger index = 0; index < count; index++) {
        MMDisplayParameter *currentDisplayParameter = [_displayParameters objectAtIndex:index];
        [displayList addObject:currentDisplayParameter];
    }

    // Figure out how many tracks are actually displayed.
	j = [displayList count];

    /* Make an outlined white box for display */
    [[NSColor whiteColor] set];
    NSRectFill(NSMakeRect(80.0, 50.0, bounds.size.width - 100.0 - 30.0, bounds.size.height - 100.0));	// reduced 30.0 from x dimension for aesthetics -- db.

    [[NSColor blackColor] set];
    NSBezierPath *bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:2];
    [bezierPath appendBezierPathWithRect:NSMakeRect(79.0, 49.0, bounds.size.width - 80.0 - 20.0 - 30.0 + 2.0, bounds.size.height - 50.0 - 50.0 + 2.0)];  // reduced 30.0 from x dimension for aesthetics -- db.
    [bezierPath stroke];

    /* Draw the space for each Track */
    [[NSColor darkGrayColor] set];
    for (NSUInteger i = 0; i < j; i++) {
        NSRectFill(NSMakeRect(80.0 + 1.0, bounds.size.height - (50.0 + (float)(i + 1) * TRACKHEIGHT), bounds.size.width - 100.0 - 30.0 - 2.0, BORDERHEIGHT));  // reduced 30.0 from x dimension for aesthetics -- db.
    }

    // Draw parameter names
    [[NSColor blackColor] set];
    for (NSUInteger i = 0; i < j; i++) {
        MMDisplayParameter *displayParameter = [displayList objectAtIndex:i];
        [_parameterNameCell setStringValue:[displayParameter label]];

        NSRect cellFrame;
        cellFrame.size.height = [_parameterNameCell cellSize].height;

        cellFrame.origin.x = 15.0;
        cellFrame.origin.y = bounds.size.height - 50.0 - ((float)(i + 1) * TRACKHEIGHT) + BORDERHEIGHT + (TRACKHEIGHT - BORDERHEIGHT - cellFrame.size.height) / 2;
        cellFrame.size.width = 60.0;
        //cellFrame.size.height = TRACKHEIGHT - BORDERHEIGHT;
        [_parameterNameCell drawWithFrame:cellFrame inView:self];
    }

    // Draw min/max parameter values
    for (NSUInteger i = 0; i < j; i++) {
        MMDisplayParameter *displayParameter = [displayList objectAtIndex:i];
        MMParameter *aParameter = [displayParameter parameter];

        NSRect cellFrame;
        cellFrame.origin.x = 0;
        cellFrame.origin.y = bounds.size.height - 50.0 - (float)(i + 1) * TRACKHEIGHT + BORDERHEIGHT - 9.0;
        cellFrame.size.height = 18.0;
        cellFrame.size.width = 75.0;
        [_minMaxCell setIntValue:[aParameter minimumValue]];
        [_minMaxCell drawWithFrame:cellFrame inView:self];

        cellFrame.origin.y = bounds.size.height - 50.0 - (float)i * TRACKHEIGHT - 9.0;
        [_minMaxCell setIntValue:[aParameter maximumValue]];
        [_minMaxCell drawWithFrame:cellFrame inView:self];
    }

    // Draw phones/postures along top
    [_timesFont set];
    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];

    NSArray *events = [_eventList events];
    for (NSUInteger i = 0; i < [events count]; i++) {
        currentX = [self scaledX:[[events objectAtIndex:i] time]];

        if ([[events objectAtIndex:i] flag]) {
            currentPhone = [_eventList getPhoneAtIndex:phoneIndex++];
            if (currentPhone) {
                [[NSColor blackColor] set];
                [[currentPhone name] drawAtPoint:NSMakePoint(currentX - 5.0, bounds.size.height - 42.0) withAttributes:nil];
            }
        }

        if (_mouseBeingDragged == NO) {
            // TODO (2004-03-17): It still goes one pixel below where it should.
            [bezierPath moveToPoint:NSMakePoint(currentX + 0.5, bounds.size.height - (50.0 + 1.0 + (float)j * TRACKHEIGHT))];
            [bezierPath lineToPoint:NSMakePoint(currentX + 0.5, bounds.size.height - 50.0 - 1.0)];
        }
    }
    [[NSColor lightGrayColor] set];
    [bezierPath stroke];

	// Draw bezier curves for each parameter
    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:2];
    [[NSColor blackColor] set];
    for (NSUInteger i = 0; i < [displayList count] && i < 4; i++) {
        MMDisplayParameter *displayParameter = [displayList objectAtIndex:i];
        parameterIndex = [displayParameter tag];
        currentMin = (float)[[displayParameter parameter] minimumValue];
        currentMax = (float)[[displayParameter parameter] maximumValue];

        k = 0;
        for (j = 0; j < [events count]; j++) {
            Event *currentEvent = [events objectAtIndex:j];
            currentX = [self scaledX:[currentEvent time]];
            if (currentX > bounds.size.width - 20.0 - 30.0)  // reduced 30.0 from x dimension for aesthetics -- db.
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

}

- (void)drawRules;
{
    NSRect bounds = NSIntegralRect([self bounds]);

    [_timesFontSmall set];
    CGFloat currentX = 0;
    CGFloat extraWidth = 0.0;

    NSUInteger count = [_eventList ruleCount];
    for (NSUInteger index = 0; index < count; index++) {
        struct _rule *rule = [_eventList getRuleAtIndex:index];

        NSRect cellFrame;
        cellFrame.origin.x = 80.0 + currentX;
        cellFrame.origin.y = bounds.size.height - 25.0;
        cellFrame.size.height = 18.0;
        cellFrame.size.width = [self scaledWidth:rule->duration] + extraWidth;

        [_ruleCell setIntegerValue:rule->number];
        [_ruleCell drawWithFrame:cellFrame inView:self];

        extraWidth = 1.0;
        currentX += cellFrame.size.width - extraWidth;
    }
}

- (void)mouseDown:(NSEvent *)event;
{
    /* Get information about the original location of the mouse event */
    NSPoint mouseDownLocation = [self convertPoint:[event locationInWindow] fromView:nil];
    CGFloat column = mouseDownLocation.x;

    /* Single click mouse events */
    if ([event clickCount] == 1) {
    }

    /* Double Click mouse events */
    if ([event clickCount] == 2) {
        _mouseBeingDragged = YES;
        [self lockFocus];
        [self updateScale:(float)column];
        [self unlockFocus];
        _mouseBeingDragged = NO;
        [self setNeedsDisplay:YES];
    }
}

- (void)mouseEntered:(NSEvent *)event;
{
    [[self window] setAcceptsMouseMovedEvents:YES];
}

- (void)mouseExited:(NSEvent *)event;
{
    [[self window] setAcceptsMouseMovedEvents:NO];
}

- (void)mouseMoved:(NSEvent *)event;
{
    NSPoint position = [self convertPoint:[event locationInWindow] fromView:nil];
    CGFloat time = (position.x - 80.0) * _timeScale;
	CGFloat value = [self parameterValueForYCoord:position.y];
	
    if ((position.x < 80.0) || (position.x > [self bounds].size.width - 20.0 - 30.0)) {  // reduced 30.0 from x dimension for aesthetics -- db.
        [_mouseTimeField setStringValue:@"--"];
	} else {
        [_mouseTimeField setIntValue:time];
	}
	
	if ((value == FLT_MAX) || (position.y > [self bounds].size.height - 50.0) || (position.y < 50.0)) {  // inverse y coordinates
		[_mouseValueField setStringValue:@"--"];
	} else {
		[_mouseValueField setFloatValue:value];
	}

}

- (void)updateScale:(CGFloat)column;
{
    CGFloat originalScale = _timeScale;

    [[self window] setAcceptsMouseMovedEvents:YES];
    while (1) {
        NSEvent *newEvent = [NSApp nextEventMatchingMask:NSLeftMouseDraggedMask|NSLeftMouseUpMask
                                               untilDate:[NSDate distantFuture]
                                                  inMode:NSEventTrackingRunLoopMode
                                                 dequeue:YES];

        if ([newEvent type] == NSLeftMouseUp)
            break;

        NSPoint mouseDownLocation = [self convertPoint:[newEvent locationInWindow] fromView:nil];
        CGFloat delta = column - mouseDownLocation.x;
        _timeScale = originalScale + delta / 20.0;

        if (_timeScale > 10.0)
            _timeScale = 10.0;

        if (_timeScale < 0.1)
            _timeScale = 0.1;

        [self clearView];
        [self drawGrid];
        [self drawRules];
        [[self window] flushWindow];
    }

    [[self window] setAcceptsMouseMovedEvents:NO];
}

- (void)frameDidChange:(NSNotification *)aNotification;
{
	[self setNeedsDisplay:YES];
    [self resetTrackingRect];  // track
}

- (void)resetTrackingRect;
{
    [self removeTrackingRect:_trackTag];  // track
    _trackTag = [self addTrackingRect:[self bounds] owner:self userData:NULL assumeInside:NO];
}

- (CGFloat)scaledX:(CGFloat)x;
{
    return rint(80.0 + x / _timeScale);
}

- (CGFloat)scaledWidth:(CGFloat)width;
{
    return floor(width / _timeScale);
}

// Obtain the parameter value for the y coordinate. Added by dalmazio, April 11, 2009.
- (CGFloat)parameterValueForYCoord:(CGFloat)y;
{
    NSRect bounds = [self bounds];
	CGFloat value = FLT_MAX;
	NSInteger parameterIndex = (int)floor((bounds.size.height - y - 50.0) / TRACKHEIGHT);
	
	if (parameterIndex >= 0 && parameterIndex < [_displayParameters count]) {		
		MMParameter * parameter = [[_displayParameters objectAtIndex:parameterIndex] parameter];
		CGFloat minValue = [parameter minimumValue];
		CGFloat maxValue = [parameter maximumValue];
		
		// Now to get the value we need to get the % of the range this y coord represents and scale by min and max.
		float percentage = 1.0 - (bounds.size.height - y - 50.0 - parameterIndex * TRACKHEIGHT) / (TRACKHEIGHT - BORDERHEIGHT);
		if (percentage >= 0.0)
			value = minValue + percentage * (maxValue - minValue);
		else
			value = FLT_MAX;		
	}
	return value;
}

#pragma mark - Methods to handle sizing and resizing of the main view.

// Added by dalmazio, April 11, 2009.
- (void)resize;
{
    NSScrollView *enclosingScrollView = [self enclosingScrollView];
    if (enclosingScrollView != nil) {
        NSRect documentVisibleRect = [enclosingScrollView documentVisibleRect];
        NSRect bounds = [self bounds];
		
        bounds.size.width = [self minimumWidth];
		if (bounds.size.width < documentVisibleRect.size.width)
            bounds.size.width = documentVisibleRect.size.width;
		
        bounds.size.height = [self minimumHeight];
        if (bounds.size.height < documentVisibleRect.size.height)
			bounds.size.height = documentVisibleRect.size.height;

        [self setFrameSize:bounds.size];
        [self setNeedsDisplay:YES];
        [[self superview] setNeedsDisplay:YES];
    }
}

// Added by dalmazio, April 11, 2009.
- (CGFloat)minimumWidth;
{
    CGFloat minimumWidth;
	
    if ([[_eventList events] count] == 0) {
        minimumWidth = 0.0;
    } else {
        Event *lastEvent;
        lastEvent = [[_eventList events] lastObject];		
        minimumWidth = 80.0 + 30.0 + 1.0 + [self scaleWidth:[lastEvent time]] + RIGHT_MARGIN;  // added 30.0 to x dimension for aesthetics -- db.
    }
	
    // Make sure that we at least show something.
	NSRect bounds = [[self enclosingScrollView] documentVisibleRect];
	if (minimumWidth < bounds.size.width)
		minimumWidth = bounds.size.width;
	
    return minimumWidth;
}

// Added by dalmazio, April 11, 2009.
- (CGFloat)minimumHeight;
{
	NSUInteger displayCount = [_displayParameters count];
	
	CGFloat minimumHeight = 50.0 + 30.0 + 1.0 + (displayCount * TRACKHEIGHT) + BORDERHEIGHT;

	NSRect bounds = [[self enclosingScrollView] documentVisibleRect];
	if (minimumHeight < bounds.size.height)
		minimumHeight = bounds.size.height;
	
	return minimumHeight;
}

// Added by dalmazio, April 11, 2009.
- (CGFloat)scaleWidth:(CGFloat)width;
{
    return floor(width / _timeScale);
}

// Added by dalmazio, April 11, 2009.
- (void)resizeWithOldSuperviewSize:(NSSize)oldSize;
{
    [super resizeWithOldSuperviewSize:oldSize];
    [self resize];
}

// Allow access to mouse tracking fields.
- (void)setMouseTimeField:(NSTextField *)mtField
{
	_mouseTimeField = mtField;
}

- (void)setMouseValueField:(NSTextField *)mvField
{
	_mouseValueField = mvField;
}

@end

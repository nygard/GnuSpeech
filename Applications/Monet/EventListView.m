#import <AppKit/NSApplication.h>
#import <AppKit/NSSlider.h>
#import <AppKit/NSEvent.h>
#import <string.h>
#import <AppKit/NSGraphics.h>
#ifdef NeXT
#import <AppKit/psops.h>
#else
#import <AppKit/PSOperators.h>
#endif
#import <math.h>
#import <AppKit/NSCursor.h>
#import <AppKit/NSForm.h>
#import <AppKit/NSScrollView.h>

#import "EventListView.h"
#import "NiftyMatrix.h"
#import "NiftyMatrixCat.h"
#import "NiftyMatrixCell.h"
#import "ParameterList.h"
#import "StringParser.h"
#import "PhoneList.h"

@implementation EventListView

/*===========================================================================

	Method: initFrame
	Purpose: To initialize the frame

===========================================================================*/
- initWithFrame:(NSRect)frameRect
{

	self = [super initWithFrame:frameRect];
	[self allocateGState];

	totalFrame = NSMakeRect(0.0, 0.0, 700.0, 380.0);
	dotMarker = [NSImage imageNamed:@"dotMarker.tiff"];
	squareMarker = [NSImage imageNamed:@"squareMarker.tiff"];
	triangleMarker = [NSImage imageNamed:@"triangleMarker.tiff"];
	selectionBox = [NSImage imageNamed:@"selectionBox.tiff"];

	timesFont = [NSFont fontWithName:@"Times-Roman" size:12];
	timesFontSmall = [NSFont fontWithName:@"Times-Roman" size:10];

	startingIndex = 0;
	timeScale = 1.0;
	mouseBeingDragged = 0;

	eventList = nil;

	[self display];

	return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    NSRect scrollRect, matrixRect;
NSSize interCellSpacing = {0.0, 0.0};
NSSize cellSize;

//	trackRect.origin.x = 80.0;
//	trackRect.origin.y = 50.0;
//	trackRect.size.width = frame.size.width - 102.0;
//	trackRect.size.height = frame.size.height - 102.0;

	[[self window] setAcceptsMouseMovedEvents: YES];


	/* set the niftyMatrixScrollView's attributes */
	[niftyMatrixScrollView setBorderType:NSBezelBorder];
	[niftyMatrixScrollView setHasVerticalScroller:YES];
	[niftyMatrixScrollView setHasHorizontalScroller:NO];

	/* get the niftyMatrixScrollView's dimensions */
	scrollRect = [niftyMatrixScrollView frame];

	/* determine the matrix bounds */
	(matrixRect.size) = [NSScrollView contentSizeForFrameSize:(scrollRect.size) hasHorizontalScroller:NO hasVerticalScroller:NO borderType:NSBezelBorder];

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
	[niftyMatrix insertCellWithStringValue:"glotPitch" withTag:0];
	[niftyMatrix insertCellWithStringValue:"glotVol" withTag:1];
	[niftyMatrix insertCellWithStringValue:"aspVol" withTag:2];
	[niftyMatrix insertCellWithStringValue:"fricVol" withTag:3];
	[niftyMatrix insertCellWithStringValue:"fricPos" withTag:4];
	[niftyMatrix insertCellWithStringValue:"fricCF" withTag:5];
	[niftyMatrix insertCellWithStringValue:"fricBW" withTag:6];
	[niftyMatrix insertCellWithStringValue:"r1" withTag:7];
	[niftyMatrix insertCellWithStringValue:"r2" withTag:8];
	[niftyMatrix insertCellWithStringValue:"r3" withTag:9];
	[niftyMatrix insertCellWithStringValue:"r4" withTag:10];
	[niftyMatrix insertCellWithStringValue:"r5" withTag:11];
	[niftyMatrix insertCellWithStringValue:"r6" withTag:12];
	[niftyMatrix insertCellWithStringValue:"r7" withTag:13];
	[niftyMatrix insertCellWithStringValue:"r8" withTag:14];
	[niftyMatrix insertCellWithStringValue:"velum" withTag:15];

	[niftyMatrix insertCellWithStringValue:"glotPitch (special)" withTag:16];
	[niftyMatrix insertCellWithStringValue:"glotVol (special)" withTag:17];
	[niftyMatrix insertCellWithStringValue:"aspVol (special)" withTag:18];
	[niftyMatrix insertCellWithStringValue:"fricVol (special)" withTag:19];
	[niftyMatrix insertCellWithStringValue:"fricPos (special)" withTag:20];
	[niftyMatrix insertCellWithStringValue:"fricCF (special)" withTag:21];
	[niftyMatrix insertCellWithStringValue:"fricBW (special)" withTag:22];
	[niftyMatrix insertCellWithStringValue:"r1 (special)" withTag:23];
	[niftyMatrix insertCellWithStringValue:"r2 (special)n" withTag:24];
	[niftyMatrix insertCellWithStringValue:"r3 (special)" withTag:25];
	[niftyMatrix insertCellWithStringValue:"r4 (special)" withTag:26];
	[niftyMatrix insertCellWithStringValue:"r5 (special)" withTag:27];
	[niftyMatrix insertCellWithStringValue:"r6 (special)" withTag:28];
	[niftyMatrix insertCellWithStringValue:"r7 (special)" withTag:29];
	[niftyMatrix insertCellWithStringValue:"r8 (special)" withTag:30];
	[niftyMatrix insertCellWithStringValue:"velum (special)" withTag:31];
	[niftyMatrix insertCellWithStringValue:"Intonation" withTag:32];

	/* Display */
	[niftyMatrix grayAllCells];
	[niftyMatrix display];
}

- (void)itemsChanged:sender
{
	[self display]; 
}

- (BOOL) acceptsFirstResponder
{
//	printf("Accepts first responder\n");
	return YES;
}

- (void)setEventList:aList
{
	eventList = aList;
	[self display]; 
}

- (void)drawRect:(NSRect)rects
{
NSRect trackRect;

	trackRect = [self frame];
	[[self superview] convertRect:trackRect toView:nil];


	trackTag = [self addTrackingRect:trackRect owner:self userData: NULL assumeInside:NO];


	[self clearView];
	[self drawGrid];
}

- (void)clearView
{
NSRect drawFrame = {{0.0, 0.0}, {[self frame].size.width, [self frame].size.height}};

	NSDrawGrayBezel(drawFrame , drawFrame); 
}

#define TRACKHEIGHT	120.0
#define BORDERHEIGHT	20.0
- (void)drawGrid
{
NSRect drawFrame;
NSArray *list;
MonetList *displayList;
int i, j, k, parameterIndex, phoneIndex;
id tempCell;
float currentX, currentY;
float currentMin, currentMax;
ParameterList *parameterList = NXGetNamedObject("mainParameterList", NSApp);
Event *currentEvent;
char string[256];
Phone *currentPhone = nil;
struct _rule *rule;

	phoneIndex = 0;
	displayList = [[MonetList alloc] initWithCapacity:10];

	list = [niftyMatrix cells];
	for(i = 0 ; i<[list count]; i++)
	{
		tempCell = [list objectAtIndex:i];
		if ([tempCell toggleValue])
		{
			[displayList addObject:tempCell];
		}
	}

	/* Figure out how many tracks are actually displayed */
	if ([displayList count ]>4)
		j = 4;
	else
		j = [displayList count];

	/* Make an outlined white box for display */
	PSsetgray(NSWhite);
	PSrectfill(81.0, 51.0, [self frame].size.width - 102.0, [self frame].size.height-102.0);
	PSstroke();

	PSsetgray(NSBlack);
	PSsetlinewidth(2.0);
	PSmoveto(80.0, 50.0);
	PSlineto(80.0, [self frame].size.height - 50.0);
	PSlineto([self frame].size.width - 20.0, [self frame].size.height - 50.0);
	PSlineto([self frame].size.width - 20.0, 50.0);
	PSlineto(80.0, 50.0);
	PSstroke();

	/* Draw the space for each Track */
	PSsetgray(NSDarkGray);
	for(i = 0; i<j; i++)
	{
		PSrectfill(80.0, [self frame].size.height-(50.0+(float)(i+1)*TRACKHEIGHT), [self frame].size.width - 100.0, BORDERHEIGHT);
	}
	PSstroke();

	PSsetgray(NSBlack);
	[timesFont set];
	for(i = 0; i<j; i++)
	{
		PSmoveto(15.0, [self frame].size.height-((float)(i+1)*TRACKHEIGHT)+15.0);
		sprintf(string,"%s", [[parameterList objectAtIndex:[[displayList objectAtIndex:i] orderTag]] symbol]);
		PSshow(string);
	}
	PSstroke();

	[timesFontSmall set];
	for(i = 0; i<j; i++)
	{
		PSmoveto(55.0, [self frame].size.height-(50.0+(float)(i+1)*TRACKHEIGHT) + BORDERHEIGHT);
		sprintf(string,"%d", (int)[[parameterList objectAtIndex:[[displayList objectAtIndex:i] orderTag]] minimumValue]);
		PSshow(string);
		PSmoveto(55.0, [self frame].size.height-(50.0+(float)(i)*TRACKHEIGHT+3.0));
		sprintf(string,"%d", (int)[[parameterList objectAtIndex:[[displayList objectAtIndex:i] orderTag]] maximumValue]);
		PSshow(string);
	}
	PSstroke();

	[timesFont set];
	PSsetlinewidth(1.0);
	PSsetgray(NSLightGray);
	for(i = 0; i<[eventList count]; i++)
	{

		currentX = 80.0+((float)[[eventList objectAtIndex:i] time]/timeScale);
		if (currentX>[self frame].size.width-20.0)
			break;

		if([[eventList objectAtIndex:i] flag])
		{
			PSsetgray(NSBlack);
			PSmoveto(currentX-5.0, [self frame].size.height-42.0);
			currentPhone = [eventList getPhoneAtIndex:phoneIndex++];
			if (currentPhone)
				PSshow([currentPhone symbol]);
			PSmoveto(currentX, [self frame].size.height-(50.0+(float)(j)*TRACKHEIGHT));
			PSlineto(currentX, [self frame].size.height-50.0);
		}
		else
		{
			if (!mouseBeingDragged)
			{
				PSsetgray(NSLightGray);
				PSmoveto(currentX, [self frame].size.height-(50.0+(float)(j)*TRACKHEIGHT));
				PSlineto(currentX, [self frame].size.height-50.0);
			}
		}
		if (!mouseBeingDragged)
			PSstroke();
	}
	PSstroke();

	PSsetlinewidth(2.0);
	PSsetgray(NSBlack);
	for(i = 0; i<[displayList count]; i++)
	{
		parameterIndex = [[displayList objectAtIndex:i] orderTag];
		if (parameterIndex == 32)
		{
			currentMin = -20;
			currentMax = 10;
		}
		else
		if (parameterIndex>15)
		{
			currentMin = (float) [[parameterList objectAtIndex:parameterIndex-16] minimumValue];
			currentMax = (float) [[parameterList objectAtIndex:parameterIndex-16] maximumValue];
		}
		else
		{
			currentMin = (float) [[parameterList objectAtIndex:parameterIndex] minimumValue];
			currentMax = (float) [[parameterList objectAtIndex:parameterIndex] maximumValue];
		}

		k = 0;
		for(j = 0; j<[eventList count]; j++)
		{
			currentEvent = [eventList objectAtIndex:j];
			currentX = 80.0+(float)([currentEvent time]/timeScale);
			if (currentX>[self frame].size.width-20.0)
				break;
			if ([currentEvent getValueAtIndex:parameterIndex]!=NaN)
			{
				currentY = ([self frame].size.height-(50.0+(float)(i+1)*TRACKHEIGHT)) + BORDERHEIGHT +
					((float)([currentEvent getValueAtIndex:parameterIndex]-currentMin)/
					 (currentMax - currentMin) *100.0);
//				printf("cx:%f cy:%f min:%f max:%f\n", currentX, currentY, currentMin, currentMax);
				if (k == 0)
				{
					k = 1;
					PSmoveto(currentX, currentY);
				}
				else
					PSlineto(currentX, currentY);
			}
		}
		PSstroke();
		if (i>=4) break;
	}

	[timesFontSmall set];
	currentX = 0;
	for(i = 0; i< [eventList numberOfRules]; i++)
	{
		rule = [eventList getRuleAtIndex:i];
		drawFrame.origin.x = 80.0+currentX;
		drawFrame.origin.y = [self frame].size.height-25.0;
		drawFrame.size.height = 15.0;
		drawFrame.size.width = (float)rule->duration/timeScale;
		NSDrawWhiteBezel(drawFrame , drawFrame);
		PSmoveto(80.0+currentX+(float)rule->duration/(3*timeScale), [self frame].size.height-21.0); ;
		sprintf(string, "%d", rule->number);
		PSsetgray(NSBlack);
		PSshow(string);
		PSstroke();
		currentX += (float)rule->duration/timeScale;
	}


	[displayList release]; 
}

- (void)mouseDown:(NSEvent *)theEvent 
{
float row, column;
NSPoint mouseDownLocation = [theEvent locationInWindow];

	/* Get information about the original location of the mouse event */
	mouseDownLocation = [self convertPoint:mouseDownLocation fromView:nil];
	row = mouseDownLocation.y;
	column = mouseDownLocation.x;

	/* Single click mouse events */
	if ([theEvent clickCount] == 1)
	{}

	/* Double Click mouse events */
	if ([theEvent clickCount] == 2)
	{
		mouseBeingDragged = 1;
		[self lockFocus];
		[self updateScale:(float) column];
		[self unlockFocus];
		mouseBeingDragged = 0;
		[self display];
	}
}

- (void)mouseEntered:(NSEvent *)theEvent 
{
NSEvent *nextEvent;
NSPoint position;
int time;

	[[self window] setAcceptsMouseMovedEvents: YES];
	while(1)
	{
		nextEvent = [[self window] nextEventMatchingMask:NSAnyEventMask];
		if (([nextEvent type] != NSMouseMoved) && ([nextEvent type] != NSMouseExited))
			[NSApp sendEvent:nextEvent];

		if ([nextEvent type] == NSMouseExited)
			break;

		if (([nextEvent type] == NSMouseMoved) && [[self window] isKeyWindow])
		{
			position.x = [nextEvent locationInWindow].x;
			position.y = [nextEvent locationInWindow].y;
			position = [self convertPoint:position fromView:nil];
			time = (int)((position.x-80.0)*timeScale);
			if ((position.x<80.0) || (position.x>[self frame].size.width-20.0))
				[mouseTimeField setStringValue:@"--"];
			else
				[mouseTimeField setIntValue:(int)((position.x-80.0)*timeScale)];
		}

	}
	[[self window] setAcceptsMouseMovedEvents: NO];
}

- (void)mouseExited:(NSEvent *)theEvent 
{
	
}

- (void)mouseMoved:(NSEvent *)theEvent 
{
	
}


- (BOOL)performKeyEquivalent:(NSEvent *)theEvent 
{
	printf("%d\n", [theEvent keyCode]);
	return YES;
}

- (void)updateScale:(float)column
{
NSPoint mouseDownLocation;
NSEvent *newEvent;
float delta, originalScale;

	originalScale = timeScale;

	[[self window] setAcceptsMouseMovedEvents: YES];
	while(1)
	{
                newEvent = [NSApp nextEventMatchingMask: NSAnyEventMask
                     untilDate: [NSDate distantFuture]
                     inMode: NSEventTrackingRunLoopMode
                     dequeue: YES];
		mouseDownLocation = [newEvent locationInWindow];
		mouseDownLocation = [self convertPoint:mouseDownLocation fromView:nil];
		delta = column-mouseDownLocation.x;
		timeScale = originalScale + delta/20.0;
		if (timeScale > 10.0) timeScale = 10.0;
		if (timeScale < 0.1) timeScale = 0.1;
		[self clearView];
		[self drawGrid];
		[[self window] flushWindow];

		if ([newEvent type] == NSLeftMouseUp) break;
	}
	[[self window] setAcceptsMouseMovedEvents: NO];
}



@end


#import "IntonationScrollView.h"

@implementation IntonationScrollView

/*===========================================================================

	Method: initFrame:
	Purpose: To initialize the View and subViews

===========================================================================*/
- initWithFrame:(NSRect)frameRect
{
NSRect scaleRect, clipRect;

	[super initWithFrame:frameRect];

	/* Set display attributes */
	[self setBorderType:NSLineBorder];
	[self setHasHorizontalScroller:YES];

	/* alloc and init a scale view instance.  Add to subView List */
	scaleRect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
//	scaleView = [[FFTScaleView alloc] initFrame:&scaleRect];
//	[self addSubview:scaleView];

	/* alloc and init a intonation view instance.  Make Doc View */
	clipRect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
	[self setDocumentView:
		[[IntonationView alloc] initWithFrame:frameRect]];
	[[self documentView] setNewController:controller];

	[self setBackgroundColor:[NSColor whiteColor]];
//	[self tile];	/* hack? */

	return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    printf("AddDidInit\n");
	[[self documentView] setNewController:controller];
	[[self documentView] setUtterance:utterance];
	[[self documentView] setSmoothing:smoothing];
}


/*===========================================================================

	Method: drawSelf::
	Purpose: Automatically called.  This function clears the view for 
		subsequent drawing.

===========================================================================*/
- (void)drawRect:(NSRect)rects
{
	PSsetgray(NSWhite);
	PSrectfill(NSMinX([self bounds]),NSMinY([self bounds]),NSWidth([self bounds]),NSHeight([self bounds]));

	[super drawRect:rects];
}

/*===========================================================================

	Method: tile
	Purpose: Hack to avoid a bug(?) or feature(?). 

===========================================================================*/
- (void)tile
{
NSRect scaleRect, clipRect;

	[super tile];

	clipRect = [[self contentView] frame];
	NSDivideRect(clipRect , &scaleRect , &clipRect , 50.0, NSMinXEdge);
	[[self contentView] setFrame:clipRect];
}

/*===========================================================================

	Method: printPSCode
	Purpose: Set up and print post script code of the FFT.

===========================================================================*/
- (void)print:(id)sender
{
	/* Turn off some things to make output look better */
	[self setBorderType:NSNoCellMask];
	[self setHasHorizontalScroller:NO];

	/* Send code */
	[super print:sender];

	/* Reinstate original settings */
	[self setBorderType:NSLineBorder];
	[self setHasHorizontalScroller:YES];
}

/*===========================================================================

	Method: scaleView
	Purpose: return the id of the ScaleView
	Returns:
		(id) scaleView instance variable.

===========================================================================*/
- scaleView
{
	return scaleView;
}

- (void)saveIntonationContour:sender
{
	[[self documentView] saveIntonationContour:sender]; 
}

- (void)loadContour:sender;
{
	[[self documentView] loadContour:sender];
}

- (void)loadContourAndUtterance:sender;
{
	[[self documentView] loadContourAndUtterance:sender];
}

@end

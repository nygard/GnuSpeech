#import "IntonationScrollView.h"

#import <AppKit/AppKit.h>
#import "IntonationView.h"

@implementation IntonationScrollView

/*===========================================================================

	Method: initFrame:
	Purpose: To initialize the View and subViews

===========================================================================*/

- (id)initWithFrame:(NSRect)frameRect;
{
    NSRect scaleRect, clipRect;
    IntonationView *aView;

    if ([super initWithFrame:frameRect] == nil)
        return nil;

    /* Set display attributes */
    [self setBorderType:NSLineBorder];
    [self setHasHorizontalScroller:YES];

    /* alloc and init a scale view instance.  Add to subView List */
    scaleRect = NSZeroRect;
    //scaleView = [[FFTScaleView alloc] initFrame:&scaleRect];
    //[self addSubview:scaleView];

    /* alloc and init a intonation view instance.  Make Doc View */
    clipRect = NSZeroRect;
    aView = [[IntonationView alloc] initWithFrame:frameRect];
    [self setDocumentView:aView];
    [aView release];
    [[self documentView] setNewController:controller];

    [self setBackgroundColor:[NSColor whiteColor]];
    //[self tile];	/* hack? */

    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
    NSLog(@"AddDidInit");
    [[self documentView] setNewController:controller];
    [[self documentView] setUtterance:utterance];
    [[self documentView] setSmoothing:smoothing];
}


/*===========================================================================

	Method: drawSelf::
	Purpose: Automatically called.  This function clears the view for
		subsequent drawing.

===========================================================================*/
- (void)drawRect:(NSRect)rect;
{
    [[NSColor whiteColor] set];
    NSRectFill([self bounds]);

    [super drawRect:rect];
}

/*===========================================================================

	Method: tile
	Purpose: Hack to avoid a bug(?) or feature(?).

===========================================================================*/
- (void)tile;
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
- (void)print:(id)sender;
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
- scaleView;
{
    return scaleView;
}

- (void)saveIntonationContour:sender;
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

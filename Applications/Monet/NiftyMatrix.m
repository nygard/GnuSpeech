/*
 *    Filename:	NiftyMatrix.m 
 *    Created :	Tue Jan 14 21:48:34 1992 
 *    Author  :	Vince DeMarco
 *		<vince@whatnxt.cuc.ab.ca>
 *
 * LastEditDate "Sat Jun  6 11:28:30 1992"
 *
 * _Log: NiftyMatrix.m,v $
 * Revision 1.3  2003/01/22 05:17:42  fedor
 * Re-add NXStream reading on NeXT. Minor changes to compile
 * correctly on OPENSTEP 4.2
 *
 * Revision 1.2  2002/12/15 05:05:09  fedor
 * Port to Openstep and GNUstep
 *
 * Revision 1.1  2002/03/21 16:49:47  rao
 * Initial import.
 *
# Revision 2.1  1992/06/10  14:26:58  vince
# initFrame method has been removed. and the cache Windows
# are now global static variables this has been done
# inorder to have all instances of the NiftyMatrix class share
# the same two cache windows. This saves a few bytes of memory.
#
# Revision 2.0  1992/04/08  03:43:23  vince
# Initial-Release
#
 *
 */


// NiftyMatrix.m
// By Jayson Adams, NeXT Developer Support Team
// You may freely copy, distribute and reuse the code in this example.
// NeXT disclaims any warranty of any kind, expressed or implied, as to its
// fitness for any
// particular use.

#ifdef NeXT
#import <AppKit/psops.h>
#else
#import <AppKit/PSOperators.h>
#endif
#import <AppKit/NSWindow.h>
#import <AppKit/NSApplication.h>

#import "NiftyMatrix.h"
#import "NiftyMatrixCell.h"

/* These are global to ensure that the application uses the least amount of memory possible
 * Since the code below resizes the offscreen caches each time it uses them, this is possible.
 */
static id nifty_matrixCache;
static id nifty_cellCache;

@implementation NiftyMatrix


#define startTimer() [NSEvent startPeriodicEventsAfterDelay:0.1 withPeriod:0.01];

#define stopTimer() [NSEvent stopPeriodicEvents]

#define MOVE_MASK NSLeftMouseUpMask|NSLeftMouseDraggedMask


/* instance methods */

- (void)dealloc
{
	[nifty_matrixCache release];
	[nifty_cellCache release];

	nifty_matrixCache = nil;
	nifty_cellCache = nil;

	{ [super dealloc]; return; };
}


- (void)mouseDown:(NSEvent *)theEvent 
{
NSPoint mouseDownLocation, mouseUpLocation, mouseLocation;
int row, column, newRow;
NSRect visibleRect, cellCacheBounds, cellFrame;
id matrixCacheContentView, cellCacheContentView;
float dy;
NSEvent *event, *peek;
BOOL scrolled = NO;
NSPoint loc;

	/*
	 * if the current window is not the key window, and the user simply clicked on the matrix inorder to activate the window.
	 * In this case simply return and do nothing 
	 */
	if ([theEvent clickCount] == -1)
	{
		return;
	}

	/* if the user double clicked on the cell then toggle the cell */
	if ([theEvent clickCount] == 2)
	{
		mouseDownLocation = [theEvent locationInWindow];
		mouseDownLocation = [self convertPoint:mouseDownLocation fromView:nil];
		[self getRow:&row column:&column forPoint:mouseDownLocation];
		[[self cellAtRow:row column:column] toggle];
		[self display];
		[self sendAction];
		return;
	}

	/* prepare the cell and matrix cache windows */
	[self setupCacheWindows];

	/* we're now interested in mouse dragged events */
	[[self window] setAcceptsMouseMovedEvents: YES];

	/* find the cell that got clicked on and select it */
	mouseDownLocation = [theEvent locationInWindow];
	mouseDownLocation = [self convertPoint:mouseDownLocation fromView:nil];
	[self getRow:&row column:&column forPoint:mouseDownLocation];
	activeCell = [self cellAtRow:row column:column];
	[self selectCell:activeCell];
	cellFrame = [self cellFrameAtRow:row column:column];

	/* draw a "well" in place of the selected cell (see drawSelf::) */
	[self lockFocus];
	[self drawRect:cellFrame];
	[self unlockFocus];

	/* copy what's currently visible into the matrix cache */
	matrixCacheContentView = [nifty_matrixCache contentView];
	[matrixCacheContentView lockFocus];
	visibleRect = [self visibleRect];
	[self convertRect:visibleRect toView:nil];
	PScomposite(NSMinX(visibleRect), NSMinY(visibleRect),
		    NSWidth(visibleRect), NSHeight(visibleRect),
		    [[self window] gState], 0.0, NSHeight(visibleRect), NSCompositeCopy);
	[matrixCacheContentView unlockFocus];

	/* image the cell into its cache */
	cellCacheContentView = [nifty_cellCache contentView];
	[cellCacheContentView lockFocus];
	cellCacheBounds = [cellCacheContentView bounds];
	[activeCell drawWithFrame:cellCacheBounds inView:cellCacheContentView];
	[cellCacheContentView unlockFocus];

	/* save the mouse's location relative to the cell's origin */
	dy = mouseDownLocation.y - cellFrame.origin.y;

	/* from now on we'll be drawing into ourself */
	[self lockFocus];

	event = theEvent;
	loc = [event locationInWindow];
	while ([event type] != NSLeftMouseUp)
	{

		/* erase the active cell using the image in the matrix cache */
		visibleRect = [self visibleRect];
		PScomposite(NSMinX(cellFrame), NSHeight(visibleRect) -
			    NSMinY(cellFrame) + NSMinY(visibleRect) -
			    NSHeight(cellFrame), NSWidth(cellFrame),
			    NSHeight(cellFrame),[nifty_matrixCache gState],
			    NSMinX(cellFrame), NSMinY(cellFrame) + NSHeight(cellFrame),
			    NSCompositeCopy);

		/* move the active cell */
		mouseLocation = loc;
		mouseLocation = [self convertPoint:mouseLocation fromView:nil];
		cellFrame.origin.y = mouseLocation.y - dy;

		/* constrain the cell's location to our bounds */
		if (NSMinY(cellFrame) < NSMinX([self bounds]))
		{
			cellFrame.origin.y = NSMinX([self bounds]);
		}
		else
		if (NSMaxY(cellFrame) > NSMaxY([self bounds]))
		{
			cellFrame.origin.y = NSHeight([self bounds]) - NSHeight(cellFrame);
		}

		/*
		 * make sure the cell will be entirely visible in its new location (if we're in a scrollView, it may not be) 
		 */
		if (!NSContainsRect(visibleRect , cellFrame) && [self isAutoscroll])
		{
			/*
			 * the cell won't be entirely visible, so scroll, dood, scroll, but don't display on-screen yet 
			 */
			[[self window] disableFlushWindow];
			[self scrollRectToVisible:cellFrame];
			[[self window] enableFlushWindow];

			/* copy the new image to the matrix cache */
			[matrixCacheContentView lockFocus];
			visibleRect = [self visibleRect];
			[self convertRect:visibleRect fromView:[self superview]];
			[self convertRect:visibleRect toView:nil];
			PScomposite(NSMinX(visibleRect), NSMinY(visibleRect),
				    NSWidth(visibleRect), NSHeight(visibleRect),
				    [[self window] gState], 0.0, NSHeight(visibleRect),
				    NSCompositeCopy);
			[matrixCacheContentView unlockFocus];

			/*
			 * note that we scrolled and start generating timer events for autoscrolling 
			 */
			scrolled = YES;
			startTimer();
		}
		else
		{
			/* no scrolling, so stop any timer */
			stopTimer();
		}

		/* composite the active cell's image on top of ourself */
		PScomposite(0.0, 0.0, NSWidth(cellFrame), NSHeight(cellFrame),
			    [nifty_cellCache gState], NSMinX(cellFrame),
			    NSMinY(cellFrame) + NSHeight(cellFrame), NSCompositeCopy);

		/* now show what we've done */
		[[self window] flushWindow];

		/*
		 * if we autoscrolled, flush any lingering window server events to make the scrolling smooth 
		 */
		if (scrolled)
		{
		  //PSWait();
			scrolled = NO;
		}

		/* save the current mouse location, just in case we need it again */
		mouseLocation = loc;

		if (!(peek = [NSApp nextEventMatchingMask: MOVE_MASK 
				    untilDate: [NSData date]
				    inMode: NSEventTrackingRunLoopMode
				    dequeue: NO]))
		{
			/*
			 * no mouseMoved or mouseUp event immediately avaiable, so take mouseMoved, mouseUp, or timer 
			 */
			event = [[self window] nextEventMatchingMask:MOVE_MASK | NSPeriodicMask];
		}
		else
		{
			/* get the mouseMoved or mouseUp event in the queue */
			event = [[self window] nextEventMatchingMask:MOVE_MASK];
		}

		/* if a timer event, mouse location isn't valid, so we'll set it */
		if ([event type] == NSPeriodic)
		{
			loc = mouseLocation;
		}
	}

	/* mouseUp, so stop any timer and unlock focus */
	stopTimer();
	[self unlockFocus];

	/* find the cell under the mouse's location */
	mouseUpLocation = loc;
	mouseUpLocation = [self convertPoint:mouseUpLocation fromView:nil];
	if (![self getRow:&newRow column:&column forPoint:mouseUpLocation])
	{
		/* mouse is out of bounds, so find the cell the active cell covers */
		[self getRow:&newRow column:&column forPoint:(cellFrame.origin)];
	}

	/* we need to shuffle cells if the active cell's going to a new location */
	if (newRow != row)
	{
		/* no autodisplay while we move cells around */
		[[self window] disableFlushWindow];
		if (newRow > row)
		{
			/* adjust selected row if before new active cell location */
			if ([self selectedRow] <= newRow)
			{
				[self selectCellAtRow: [self selectedRow]-1
				      column: [self selectedColumn]];
			}

			/*
			 * push all cells above the active cell's new location up one row so that we fill the vacant spot 
			 */
			while (row++ < newRow)
			{
				id cell = [self cellAtRow:row column:0];
				[self putCell: cell atRow:(row - 1) column:0];
			}
			/* now place the active cell in its new home */
			[self putCell:activeCell atRow:newRow column:0];
		}
		else
		if (newRow < row)
		{
			/* adjust selected row if after new active cell location */
			if ([self selectedRow] >= newRow)
			{
				[self selectCellAtRow: [self selectedRow]+1
				      column: [self selectedColumn]];
			}

			/*
			 * push all cells below the active cell's new location down one row so that we fill the vacant spot 
			 */
			while (row-- > newRow)
			{
				id cell = [self cellAtRow:row column:0];
				[self putCell: cell atRow:(row + 1) column:0];
			}
			/* now place the active cell in its new home */
			[self putCell:activeCell atRow:newRow column:0];
		}

		/* if the active cell is selected, note its new row */
		if ([activeCell state])
		{
		  [self selectCellAtRow: newRow
			column: [self selectedColumn]];
		}

		/* make sure the active cell's visible if we're autoscrolling */
		if ([self isAutoscroll])
		{
			[self scrollCellToVisibleAtRow:newRow column:0];
		}

		/* no longer dragging the cell */
		activeCell = 0;

		/* size to cells after all this shuffling and turn autodisplay back on */
		[self sizeToCells];

		/* size to cells after all this shuffling and turn autodisplay back on */
		[[self window] enableFlushWindow];
	}
	else
	{
		/* no longer dragging the cell */
		activeCell = 0;
	}

	/* now redraw ourself */
	[self deselectAllCells];
	[self drawCellInside:activeCell];
	[self display];

	/* set the event mask to normal */
	[[self window] setAcceptsMouseMovedEvents: NO];
}

- (void)drawRect:(NSRect)rects
{
int row, col;
NSRect cellBorder;
int sides[] = {NSMinXEdge, NSMinYEdge, NSMaxXEdge, NSMaxYEdge, NSMinXEdge,
	       NSMinYEdge};
float grays[] = {NSDarkGray, NSDarkGray, NSWhite, NSWhite, NSBlack,
		 NSBlack};

	/* do the regular drawing */
	[super drawRect:rects];

	/* draw a "well" if the user's dragging a cell */
	if (activeCell)
	{
		/* get the cell's frame */
		[self getRow:&row column:&col ofCell:activeCell];
		cellBorder = [self cellFrameAtRow:row column:col];

		/* draw the well */
		if (!NSIsEmptyRect(NSIntersectionRect(cellBorder , rects)))
		{
			cellBorder  = NSDrawTiledRects(cellBorder , NSZeroRect , sides, grays, 6);
			PSsetgray(0.17);
			NSRectFill(cellBorder);
		}
	}
}

- (void)setupCacheWindows
{
NSRect visibleRect;

	/* create the matrix cache window */
	visibleRect = [self visibleRect];
	nifty_matrixCache = [self sizeCacheWindow:nifty_matrixCache to:(visibleRect.size)];

	/* create the cell cache window */
	nifty_cellCache = [self sizeCacheWindow:nifty_cellCache to:[self cellSize]]; 
}

- sizeCacheWindow:cacheWindow to:(NSSize)windowSize
{
NSRect cacheFrame;

	if (!cacheWindow)
	{
		/* create the cache window if it doesn't exist */
		cacheFrame.origin.x = cacheFrame.origin.y = 0.0;
		cacheFrame.size = windowSize;
		cacheWindow = [[NSWindow allocWithZone:[self zone]] 
			initWithContentRect:cacheFrame 
			styleMask:NSBorderlessWindowMask 
			backing:NSBackingStoreRetained defer:NO];
		/* flip the contentView since we are flipped */
		/* FIXME: Need a custom view for this? */
		//[[cacheWindow contentView] setFlipped:YES];
	}
	else
	{
		/* make sure the cache window's the right size */
		cacheFrame = [cacheWindow frame];
		if (cacheFrame.size.width != windowSize.width ||
		    cacheFrame.size.height != windowSize.height)
		{
			[cacheWindow setContentSize:windowSize];
		}
	}

	return cacheWindow;
}

@end

#import "NiftyMatrix.h"

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "NiftyMatrixCell.h"

#define startTimer() [NSEvent startPeriodicEventsAfterDelay:0.1 withPeriod:0.01]
#define stopTimer() [NSEvent stopPeriodicEvents]
#define MOVE_MASK NSLeftMouseUpMask|NSLeftMouseDraggedMask

@implementation NiftyMatrix

- (void)dealloc;
{
    [niftyMatrixCache release];
    [niftyCellCache release];

    [super dealloc];
}


- (void)mouseDown:(NSEvent *)mouseEvent;
{
    NSPoint mouseDownLocation, mouseUpLocation, mouseLocation;
    int row, column, newRow;
    NSRect visibleRect, cellFrame;
    id matrixCacheContentView;
    float dy;
    NSEvent *event, *peek;
    BOOL scrolled = NO;
    NSPoint loc;

    NSImage *cellCache;

    /*
     * if the current window is not the key window, and the user simply clicked on the matrix inorder to activate the window.
     * In this case simply return and do nothing
     */
    if ([mouseEvent clickCount] == -1) {
        NSLog(@"%s, clickCount == -1", _cmd);
        return;
    }

    /* if the user double clicked on the cell then toggle the cell */
    if ([mouseEvent clickCount] == 2) {
        NSLog(@"Double click.");
        mouseDownLocation = [self convertPoint:[mouseEvent locationInWindow] fromView:nil];
        [self getRow:&row column:&column forPoint:mouseDownLocation];
        [[self cellAtRow:row column:column] toggle];
        [self setNeedsDisplay:YES];
        [self sendAction];
        return;
    }

    /* prepare the cell and matrix cache windows */
    [self setupCacheWindows];

    /* we are now interested in mouse dragged events */
    [[self window] setAcceptsMouseMovedEvents:YES];

    /* find the cell that got clicked on and select it */
    mouseDownLocation = [self convertPoint:[mouseEvent locationInWindow] fromView:nil];
    [self getRow:&row column:&column forPoint:mouseDownLocation];
    activeCell = [self cellAtRow:row column:column];
    [self selectCell:activeCell];
    cellFrame = [self cellFrameAtRow:row column:column];

    /* draw a "well" in place of the selected cell (see drawRect:) */
    [self lockFocus];
    [self drawRect:cellFrame];
    [self unlockFocus];

#if 0
    /* copy what is currently visible into the matrix cache */
    matrixCacheContentView = [niftyMatrixCache contentView];
    [matrixCacheContentView lockFocus];
    visibleRect = [self visibleRect];
    [self convertRect:visibleRect toView:nil];
#warning this will not work...
    PScomposite(NSMinX(visibleRect), NSMinY(visibleRect),
                NSWidth(visibleRect), NSHeight(visibleRect),
                [[self window] gState], 0.0, NSHeight(visibleRect), NSCompositeCopy);
    [matrixCacheContentView unlockFocus];

    /* image the cell into its cache */
    cellCache = [[NSImage alloc] initWithSize:cellFrame.size];
    NSLog(@"cellCache size: %@", NSStringFromSize(cellFrame.size));
    [cellCacheImage lockFocus];
    [activeCell drawWithFrame:cellFrame.size inView:self]; // TODO (2004-03-08): Is it okay to use self for the view?
    [cellCacheImage unlockFocus];

    /* save the mouse's location relative to the cell's origin */
    dy = mouseDownLocation.y - cellFrame.origin.y;

    /* from now on we will be drawing into ourself */
    [self lockFocus];

    event = mouseEvent;
    loc = [event locationInWindow];
    while ([event type] != NSLeftMouseUp) {
        /* erase the active cell using the image in the matrix cache */
        visibleRect = [self visibleRect];
        PScomposite(NSMinX(cellFrame), NSHeight(visibleRect) - NSMinY(cellFrame) + NSMinY(visibleRect) - NSHeight(cellFrame),
                    NSWidth(cellFrame), NSHeight(cellFrame),
                    [niftyMatrixCache gState],
                    NSMinX(cellFrame), NSMinY(cellFrame) + NSHeight(cellFrame),
                    NSCompositeCopy);

        /* move the active cell */
        mouseLocation = loc;
        mouseLocation = [self convertPoint:mouseLocation fromView:nil];
        cellFrame.origin.y = mouseLocation.y - dy;

        /* constrain the cell's location to our bounds */
        if (NSMinY(cellFrame) < NSMinX([self bounds])) {
            cellFrame.origin.y = NSMinX([self bounds]);
        } else if (NSMaxY(cellFrame) > NSMaxY([self bounds])) {
                cellFrame.origin.y = NSHeight([self bounds]) - NSHeight(cellFrame);
        }

        /*
         * make sure the cell will be entirely visible in its new location (if we are in a scrollView, it may not be)
         */
        if (!NSContainsRect(visibleRect , cellFrame) && [self isAutoscroll]) {
            /*
             * the cell will not be entirely visible, so scroll, dood, scroll, but do not display on-screen yet
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
        } else {
            /* no scrolling, so stop any timer */
            stopTimer();
        }

        /* composite the active cell's image on top of ourself */
        PScomposite(0.0, 0.0, NSWidth(cellFrame), NSHeight(cellFrame),
                    [niftyCellCache gState], NSMinX(cellFrame),
                    NSMinY(cellFrame) + NSHeight(cellFrame), NSCompositeCopy);

        /* now show what we have done */
        [[self window] flushWindow];

        /*
         * if we autoscrolled, flush any lingering window server events to make the scrolling smooth
         */
        if (scrolled) {
            //PSWait();
            scrolled = NO;
        }

        /* save the current mouse location, just in case we need it again */
        mouseLocation = loc;

        if (!(peek = [NSApp nextEventMatchingMask: MOVE_MASK
                            untilDate: [NSData date]
                            inMode: NSEventTrackingRunLoopMode
                            dequeue: NO])) {
            /*
             * no mouseMoved or mouseUp event immediately avaiable, so take mouseMoved, mouseUp, or timer
             */
            event = [[self window] nextEventMatchingMask:MOVE_MASK | NSPeriodicMask];
        } else {
            /* get the mouseMoved or mouseUp event in the queue */
            event = [[self window] nextEventMatchingMask:MOVE_MASK];
        }

        /* if a timer event, mouse location is not valid, so we will set it */
        if ([event type] == NSPeriodic) {
            loc = mouseLocation;
        }
    }

    /* mouseUp, so stop any timer and unlock focus */
    stopTimer();
    [self unlockFocus];

    /* find the cell under the mouse's location */
    mouseUpLocation = loc;
    mouseUpLocation = [self convertPoint:mouseUpLocation fromView:nil];
    if (![self getRow:&newRow column:&column forPoint:mouseUpLocation]) {
        /* mouse is out of bounds, so find the cell the active cell covers */
        [self getRow:&newRow column:&column forPoint:(cellFrame.origin)];
    }

    /* we need to shuffle cells if the active cell's going to a new location */
    if (newRow != row) {
        /* no autodisplay while we move cells around */
        [[self window] disableFlushWindow];
        if (newRow > row) {
            /* adjust selected row if before new active cell location */
            if ([self selectedRow] <= newRow) {
                [self selectCellAtRow:[self selectedRow]-1
                      column: [self selectedColumn]];
            }

            /*
             * push all cells above the active cell's new location up one row so that we fill the vacant spot
             */
            while (row++ < newRow) {
                id cell = [self cellAtRow:row column:0];
                [self putCell: cell atRow:(row - 1) column:0];
            }
            /* now place the active cell in its new home */
            [self putCell:activeCell atRow:newRow column:0];
        } else if (newRow < row) {
            /* adjust selected row if after new active cell location */
            if ([self selectedRow] >= newRow) {
                [self selectCellAtRow:[self selectedRow]+1
                      column: [self selectedColumn]];
            }

            /*
             * push all cells below the active cell's new location down one row so that we fill the vacant spot
             */
            while (row-- > newRow) {
                id cell = [self cellAtRow:row column:0];
                [self putCell: cell atRow:(row + 1) column:0];
            }
            /* now place the active cell in its new home */
            [self putCell:activeCell atRow:newRow column:0];
        }

        /* if the active cell is selected, note its new row */
        if ([activeCell state]) {
            [self selectCellAtRow:newRow column:[self selectedColumn]];
        }

        /* make sure the active cell's visible if we are autoscrolling */
        if ([self isAutoscroll]) {
            [self scrollCellToVisibleAtRow:newRow column:0];
        }

        /* no longer dragging the cell */
        activeCell = 0;

        /* size to cells after all this shuffling and turn autodisplay back on */
        [self sizeToCells];

        /* size to cells after all this shuffling and turn autodisplay back on */
        [[self window] enableFlushWindow];
    } else {
        /* no longer dragging the cell */
        activeCell = 0;
    }

    /* now redraw ourself */
    [self deselectAllCells];
    [self drawCellInside:activeCell];
    [self display];

    /* set the event mask to normal */
    [[self window] setAcceptsMouseMovedEvents: NO];
#else
    [super mouseDown:mouseEvent];
#endif
}

- (void)drawRect:(NSRect)rect;
{
    int row, col;
    NSRect cellBorder;
    NSRectEdge sides[] = {NSMinXEdge, NSMinYEdge, NSMaxXEdge, NSMaxYEdge, NSMinXEdge, NSMinYEdge};
    float grays[] = {NSDarkGray, NSDarkGray, NSWhite, NSWhite, NSBlack, NSBlack};

    NSLog(@"->%s", _cmd);
    // do the regular drawing
    [super drawRect:rect];

    // draw a "well" if the user's dragging a cell
    if (activeCell != nil) {
        [self getRow:&row column:&col ofCell:activeCell];
        cellBorder = [self cellFrameAtRow:row column:col];

        // draw the well
        if (NSIsEmptyRect(NSIntersectionRect(cellBorder, rect)) == NO) {
            //NSDrawGroove(cellBorder, rect);
            NSDrawGrayBezel(cellBorder, rect);
        }
    }
}

- (void)createCacheWindowsIfNecessary;
{
    if (niftyMatrixCache == nil)
        niftyMatrixCache = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 30, 30)
                                             styleMask:NSBorderlessWindowMask
                                             backing:NSBackingStoreRetained
                                             defer:NO];

    if (niftyCellCache == nil)
        niftyCellCache = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 30, 30)
                                           styleMask:NSBorderlessWindowMask
                                           backing:NSBackingStoreRetained
                                           defer:NO];
}

- (void)setupCacheWindows;
{
    [self sizeCacheWindow:niftyMatrixCache to:[self visibleRect].size];
    [self sizeCacheWindow:niftyCellCache to:[self cellSize]];
}

- (void)sizeCacheWindow:(NSWindow *)aCacheWindow to:(NSSize)windowSize;
{
    NSSize cacheSize;

    [self createCacheWindowsIfNecessary];

    /* make sure the cache window is the right size */
    cacheSize = [aCacheWindow frame].size;
    if (NSEqualSizes(cacheSize, windowSize) == NO)
        [aCacheWindow setContentSize:windowSize];
}

@end

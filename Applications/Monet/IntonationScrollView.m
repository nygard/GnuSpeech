#import "IntonationScrollView.h"

#import <AppKit/AppKit.h>
#import "MAIntonationView.h"

@implementation IntonationScrollView

#define SCALE_WIDTH 50

// TODO (2004-03-15): This doesn't get called when loaded from a nib.
- (id)initWithFrame:(NSRect)frameRect;
{
    //NSRect scaleRect, clipRect;
    MAIntonationView *aView;

    NSLog(@"<%@>[%p]  > %s", NSStringFromClass([self class]), self, _cmd);

    if ([super initWithFrame:frameRect] == nil)
        return nil;

    /* Set display attributes */
    [self setBorderType:NSLineBorder];
    [self setHasHorizontalScroller:YES];

    /* alloc and init a scale view instance.  Add to subView List */
    //scaleRect = NSZeroRect;
    //scaleView = [[FFTScaleView alloc] initFrame:&scaleRect];
    //[self addSubview:scaleView];

    /* alloc and init a intonation view instance.  Make Doc View */
    //clipRect = NSZeroRect;
    // TODO (2004-03-31): See if we can remove this code:
    aView = [[MAIntonationView alloc] initWithFrame:frameRect];
    [self setDocumentView:aView];
    [aView release];

    [self setBackgroundColor:[NSColor whiteColor]];

    NSLog(@"<%@>[%p] <  %s", NSStringFromClass([self class]), self, _cmd);

    return self;
}

/*===========================================================================

	Method: tile
	Purpose: Hack to avoid a bug(?) or feature(?).

===========================================================================*/
- (void)tile;
{
    NSRect scaleFrame, contentFrame;

    [super tile];

    contentFrame = [[self contentView] frame];
    NSDivideRect(contentFrame, &scaleFrame, &contentFrame, SCALE_WIDTH, NSMinXEdge);
    [[self contentView] setFrame:contentFrame];
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

- (NSView *)scaleView;
{
    return scaleView;
}

@end

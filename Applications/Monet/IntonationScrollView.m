#import "IntonationScrollView.h"

#import <AppKit/AppKit.h>
#import "IntonationView.h"

@implementation IntonationScrollView

#define SCALE_WIDTH 50

// TODO (2004-03-15): This doesn't get called when loaded from a nib.
- (id)initWithFrame:(NSRect)frameRect;
{
    //NSRect scaleRect, clipRect;
    IntonationView *aView;

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
    aView = [[IntonationView alloc] initWithFrame:frameRect];
    [self setDocumentView:aView];
    [aView release];
    [[self documentView] setNewController:controller];

    [self setBackgroundColor:[NSColor whiteColor]];

    NSLog(@"<%@>[%p] <  %s", NSStringFromClass([self class]), self, _cmd);

    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
    NSLog(@"<%@>[%p]  > %s", NSStringFromClass([self class]), self, _cmd);

    [[self documentView] applicationDidFinishLaunching:notification];

    [[self documentView] setNewController:controller];
    [[self documentView] setUtterance:utterance];
    [[self documentView] setSmoothing:smoothing];

    NSLog(@"<%@>[%p] <  %s", NSStringFromClass([self class]), self, _cmd);
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

- (IBAction)saveIntonationContour:(id)sender;
{
    [[self documentView] saveIntonationContour:sender];
}

- (IBAction)loadContour:(id)sender;
{
    [[self documentView] loadContour:sender];
}

- (IBAction)loadContourAndUtterance:(id)sender;
{
    [[self documentView] loadContourAndUtterance:sender];
}

@end

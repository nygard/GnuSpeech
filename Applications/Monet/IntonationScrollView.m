#import "IntonationScrollView.h"

#import <AppKit/AppKit.h>
#import "MAIntonationView.h"
#import "MAIntonationScaleView.h"

@implementation IntonationScrollView

#define SCALE_WIDTH 50

// TODO (2004-03-15): This doesn't get called when loaded from a nib.
- (id)initWithFrame:(NSRect)frameRect;
{
    NSRect contentFrame;
    MAIntonationView *intonationView;

    NSLog(@"<%@>[%p]  > %s", NSStringFromClass([self class]), self, _cmd);

    NSLog(@"ISV %s, frame: %@", _cmd, NSStringFromRect(frameRect));
    if ([super initWithFrame:frameRect] == nil)
        return nil;

    //[self setBorderType:NSLineBorder];
    //[self setHasHorizontalScroller:YES];
    //[self setBackgroundColor:[NSColor whiteColor]];

    // TODO (2004-03-31): See if we can remove this code:
    contentFrame.origin = NSZeroPoint;
    contentFrame.size = [self contentSize];
    intonationView = [[MAIntonationView alloc] initWithFrame:contentFrame];
    [self setDocumentView:intonationView];
    [intonationView release];

    [self addScaleView];

    NSLog(@"<%@>[%p] <  %s", NSStringFromClass([self class]), self, _cmd);

    return self;
}

- (void)dealloc;
{
    [scaleView release];

    [super dealloc];
}

- (void)awakeFromNib;
{
    [self addScaleView];
}

- (void)addScaleView;
{
    NSSize contentSize;
    NSRect frameRect, scaleFrame;
    NSRect documentVisibleRect;

    NSLog(@" > %s", _cmd);

    contentSize = [self contentSize];
    frameRect = [self frame];
    NSLog(@"contentSize: %@, frameRect: %@", NSStringFromSize(contentSize), NSStringFromRect(frameRect));

    scaleFrame = NSMakeRect(0, 0, SCALE_WIDTH, contentSize.height);
    scaleView = [[MAIntonationScaleView alloc] initWithFrame:scaleFrame];
    [self addSubview:scaleView];

    [[self documentView] setScaleView:scaleView];

    [self tile];

    documentVisibleRect = [self documentVisibleRect];

    [[self documentView] setFrame:documentVisibleRect];
    [[self documentView] setNeedsDisplay:YES];

    NSLog(@"<  %s", _cmd);
}

- (void)tile;
{
    NSRect scaleFrame, contentFrame;

    [super tile];

    contentFrame.origin = NSZeroPoint;
    contentFrame.size = [self contentSize];
    NSDivideRect(contentFrame, &scaleFrame, &contentFrame, SCALE_WIDTH, NSMinXEdge);
    [scaleView setFrame:scaleFrame];
    [scaleView setNeedsDisplay:YES];
    [[self contentView] setFrame:contentFrame];
    [[self contentView] setNeedsDisplay:YES];
}

- (NSView *)scaleView;
{
    return scaleView;
}

- (NSSize)printableSize;
{
    NSSize scaleViewSize, printableSize;

    scaleViewSize = [scaleView frame].size;
    printableSize = [[self documentView] frame].size;
    NSLog(@"%s, scaleViewSize: %@, printableSize: %@", _cmd, NSStringFromSize(scaleViewSize), NSStringFromSize(printableSize));

    return printableSize;
}

@end

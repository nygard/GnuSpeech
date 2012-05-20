//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MAIntonationScrollView.h"

#import "MAIntonationView.h"
#import "MAIntonationScaleView.h"

@implementation MAIntonationScrollView
{
    IBOutlet MAIntonationScaleView *scaleView;
}

#define SCALE_WIDTH 50

- (id)initWithFrame:(NSRect)frameRect;
{
    if ((self = [super initWithFrame:frameRect])) {
        NSRect contentFrame;
        contentFrame.origin = NSZeroPoint;
        contentFrame.size = [self contentSize];

        MAIntonationView *intonationView = [[MAIntonationView alloc] initWithFrame:contentFrame];
        [self setDocumentView:intonationView];
        [intonationView release];
        
        [self addScaleView];
    }

    return self;
}

- (void)dealloc;
{
    [scaleView release];

    [super dealloc];
}

#pragma mark -

// -initWithFrame: isn't used when loaded from a nib.
- (void)awakeFromNib;
{
    [self addScaleView];
}

- (void)addScaleView;
{
    NSSize contentSize;
    NSRect scaleFrame;
    NSRect documentVisibleRect;

    contentSize = [self contentSize];

    scaleFrame = NSMakeRect(0, 0, SCALE_WIDTH, contentSize.height);
    scaleView = [[MAIntonationScaleView alloc] initWithFrame:scaleFrame];
    [self addSubview:scaleView];

    [[self documentView] setScaleView:scaleView];

    [self tile];

    documentVisibleRect = [self documentVisibleRect];

    [[self documentView] setFrame:documentVisibleRect];
    [[self documentView] setNeedsDisplay:YES];
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
    printableSize.width += scaleViewSize.width;

    return printableSize;
}

@end

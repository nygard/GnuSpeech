//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MWaveShapeView.h"

@implementation MWaveShapeView

- (id)initWithFrame:(NSRect)frameRect;
{
    if ([super initWithFrame:frameRect] == nil)
        return nil;

    wavetable = TRMWavetableCreate(TRMWaveformTypePulse, 40.0, 12.0, 32.0, 11025.0);
    [self setMinYValue:-1.0];
    [self setMaxYValue:1.0];

    return self;
}

- (void)dealloc;
{
    if (wavetable != NULL)
        TRMWavetableFree(wavetable);

    [super dealloc];
}

- (void)drawRect:(NSRect)rect;
{
    [super drawRect:rect];

    [[NSColor blackColor] set];
    [self drawValues:wavetable->wavetable count:TRMWavetableLength(wavetable)];
}

@end

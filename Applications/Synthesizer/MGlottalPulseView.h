//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MGraphView.h"

#include "wavetable.h"

@interface MGlottalPulseView : MGraphView
{
    double riseTime;
    double minimumFallTime;
    double maximumFallTime;

    TRMWavetable *minimumWavetable;
    TRMWavetable *maximumWavetable;
}

- (id)initWithFrame:(NSRect)frameRect;
- (void)dealloc;

- (double)riseTime;
- (void)setRiseTime:(double)newRiseTime;

- (double)minimumFallTime;
- (void)setMinimumFallTime:(double)newMinimumFallTime;

- (double)maximumFallTime;
- (void)setMaximumFallTime:(double)newMaximumFallTime;

- (void)drawRect:(NSRect)rect;

@end

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MGraphView.h"

#include "wavetable.h"

@interface MWaveShapeView : MGraphView
{
    TRMWavetable *wavetable;
}

- (id)initWithFrame:(NSRect)frameRect;
- (void)dealloc;

- (void)drawRect:(NSRect)rect;

@end

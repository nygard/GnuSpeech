//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MGlottalSourceController.h"

#import "MGlottalPulseView.h"
#import "MWaveShapeView.h"

@implementation MGlottalSourceController

- (id)init;
{
    if ([super initWithWindowNibName:@"GlottalSource"] == nil)
        return nil;

    [self setWindowFrameAutosaveName:@"GlottalSource"];

    return self;
}

- (void)windowDidLoad;
{
    [riseTimeTextField setDoubleValue:[glottalPulseView riseTime]];
    [minimumFallTimeTextField setDoubleValue:[glottalPulseView minimumFallTime]];
    [maximumFallTimeTextField setDoubleValue:[glottalPulseView maximumFallTime]];
}

- (IBAction)changeRiseTime:(id)sender;
{
    [glottalPulseView setRiseTime:[riseTimeTextField doubleValue]];
}

- (IBAction)changeMinimumFallTime:(id)sender;
{
    [glottalPulseView setMinimumFallTime:[minimumFallTimeTextField doubleValue]];
}

- (IBAction)changeMaximumFallTime:(id)sender;
{
    [glottalPulseView setMaximumFallTime:[maximumFallTimeTextField doubleValue]];
}

@end

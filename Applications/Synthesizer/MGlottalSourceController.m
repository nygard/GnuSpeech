//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MGlottalSourceController.h"

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
    [riseTimeTextField setDoubleValue:[waveShapeView riseTime]];
    [minimumFallTimeTextField setDoubleValue:[waveShapeView minimumFallTime]];
    [maximumFallTimeTextField setDoubleValue:[waveShapeView maximumFallTime]];
}

- (IBAction)changeRiseTime:(id)sender;
{
    [waveShapeView setRiseTime:[riseTimeTextField doubleValue]];
}

- (IBAction)changeMinimumFallTime:(id)sender;
{
    [waveShapeView setMinimumFallTime:[minimumFallTimeTextField doubleValue]];
}

- (IBAction)changeMaximumFallTime:(id)sender;
{
    [waveShapeView setMaximumFallTime:[maximumFallTimeTextField doubleValue]];
}

@end

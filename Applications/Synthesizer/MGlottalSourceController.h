//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MWindowController.h"

@class MGlottalPulseView, MWaveShapeView;

@interface MGlottalSourceController : MWindowController
{
    IBOutlet MWaveShapeView *waveShapeView;
    IBOutlet MGlottalPulseView *glottalPulseView;

    IBOutlet NSTextField *riseTimeTextField;
    IBOutlet NSTextField *minimumFallTimeTextField;
    IBOutlet NSTextField *maximumFallTimeTextField;
}

- (id)init;

- (void)windowDidLoad;

- (IBAction)changeRiseTime:(id)sender;
- (IBAction)changeMinimumFallTime:(id)sender;
- (IBAction)changeMaximumFallTime:(id)sender;

@end

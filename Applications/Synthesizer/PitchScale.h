//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Cocoa/Cocoa.h>
#import "ChartView.h"

#define PSLEFT_MARGIN 10
#define PSRIGHT_MARGIN 10
#define PSTOP_BOTTOM_MARGIN 10

#define PSY_SCALE_DIVS 14
#define PSX_SCALE_DIVS 1

@interface PitchScale : ChartView

- (IBAction)drawPitch:(int)pitch Cents:(int)cents Volume:(float)volume;

@end

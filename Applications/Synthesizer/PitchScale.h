//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Cocoa/Cocoa.h>
#import "ChartView.h"
#import"structs.h"
//#import "tube.c"

@interface PitchScale : ChartView

#define PSLEFT_MARGIN 10
#define PSRIGHT_MARGIN 10
#define PSTOP_BOTTOM_MARGIN 10

#define PSY_SCALE_DIVS 14
#define PSX_SCALE_DIVS 1

{
	float horizontalCenter;
    float verticalCenter;
    float sharpCenter;
    float arrowCenter;
	
    id background;
    id foreground;
	float notePosition;
	BOOL sharpNeeded;
	BOOL arrowNeeded;
	int upDown;
	
	
}

- (void)dealloc;
- (void)awakeFromNib;
- (IBAction)drawPitch:(int)pitch Cents:(int)cents Volume:(float)volume;


@end

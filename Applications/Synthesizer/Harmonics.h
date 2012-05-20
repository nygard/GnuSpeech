//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Cocoa/Cocoa.h>
#import "ChartView.h"
#import "syn_structs.h"
#import "fft.h"

#define HLABEL_MARGIN 3 
#define HLEFT_MARGIN 20
#define HRIGHT_MARGIN 5
#define HTOP_MARGIN 5
#define HBOTTOM_MARGIN 5


#define HX_SCALE_DIVS 1
#define HX_SCALE_ORIGIN 0
#define HX_SCALE_STEPS 1
#define HX_LABEL_INTERVAL 1
#define HY_SCALE_DIVS 7
#define HY_SCALE_ORIGIN -70
#define HY_SCALE_STEPS 10
#define HY_LABEL_INTERVAL 1

#define BAR_WIDTH 3
#define BAR_MARGIN 3


@interface Harmonics : ChartView
{
}

- (void)drawSineScale:(float)amplitude;
- (void)drawHarmonics;
@end

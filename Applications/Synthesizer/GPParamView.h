//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Cocoa/Cocoa.h>
#import "ChartView.h"
#import "structs.h"


#define GPTOP_MARGIN 5

#define GPLEFT_MARGIN 5
#define GPRIGHT_MARGIN 5
#define GPTOP_MARGIN 5
#define GPBOTTOM_MARGIN 5
#define GPX_SCALE_FACTOR 80


#define WX_SCALE_DIVS 1
#define WX_SCALE_ORIGIN 0
#define WX_SCALE_STEPS 0
#define WX_LABEL_INTERVAL 0
#define WY_SCALE_DIVS 2
#define WY_SCALE_ORIGIN 0
#define WY_SCALE_STEPS 0
#define WY_LABEL_INTERVAL 1





@interface GPParamView : ChartView

{
}

- (void)drawGlottalPulseAmplitude;


@end

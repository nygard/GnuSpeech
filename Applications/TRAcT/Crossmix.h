//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

/******************************************
$Author: Leonard Manzara, David R. Hill$
$Revision: 1.2$
$Source: /svnroot/Synthesizer/Crossmix.m.h$
$State: Exp $
 *****************************************/

#import "ChartView.h"
#import "Crossmix.h"
#import "GlottalSource.h"
#import "conversion.h"


#define CMX_SCALE_DIVS 6
#define CMX_SCALE_ORIGIN 0
#define CMX_SCALE_STEPS 10
#define CMX_LABEL_INTERVAL 1
#define CMY_SCALE_DIVS 4
#define CMY_SCALE_ORIGIN 0
#define CMY_SCALE_STEPS 0.25
#define CMY_LABEL_INTERVAL 1
#define CMY_VOLUME_MAX 48




@interface Crossmix : ChartView


{
    NSRect bounds;
    id  background;
    id  foreground;
    id  volumeImage;
    
    double numberPoints;
    double width;
    double height;
    int numberCoords;
    int numberOps;
    float *coord;
    char *ops;
    float bbox[4];
}

- (void)drawGraph;
- (void)mixOffsetChanged:(NSNotification *)note;

/*
- initFrame:(const NSRect *)frameRect;
- initializeUserPath;
- free;

- drawLinearScale;
- drawCrossmix:(int)crossmix;

- drawNoCrossmix;
- drawVolume:(int)volume;

- drawSelf:(const NSRect *)rects :(int)rectCount;

extern float pulsedGain(float volume, float crossmixOffset);
 */

@end

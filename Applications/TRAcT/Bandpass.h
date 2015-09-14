//  This file is part of Gnuspeech, an extensible, text-to-speech package,
// based on real-time, articulatory, speech-synthesis-by-rules.
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
#import "tube.h"


#define NYQUIST_MAX 15000
#define PI   3.14159265358979
#define PI2  6.28318530717959


@interface Bandpass : ChartView


{
    NSRect bounds;
    id  background;
    id  foreground;
    id  volumeImage;
    
    double numberPoints;
    double width;
    double height;
    float frequencyScale;
    float nyquistScale;

}

- (void)drawGraph;
//- (void)mixOffsetChanged:(NSNotification *)note;
- (void)fricParamChanged;


@end

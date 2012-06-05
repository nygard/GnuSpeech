//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Cocoa/Cocoa.h>
#import "ChartView.h"
#import "Analysis.h"


#define SGLABEL_MARGIN 3 
#define SGLEFT_MARGIN 45
#define SGRIGHT_MARGIN 20
#define SGTOP_MARGIN 15
#define SGBOTTOM_MARGIN 18
#define SGGRAPH_MARGIN 10

#define SGX_SCALE_DIVS 1
#define SGX_SCALE_ORIGIN 0
#define SGX_SCALE_STEPS 1
#define SGX_LABEL_INTERVAL 3
#define SGY_SCALE_DIVS 11
#define SGY_SCALE_ORIGIN 0
#define SGY_SCALE_STEPS 1000
#define SGY_LABEL_INTERVAL 1

#define SG_YSCALE_FUDGE 1.03

// DEFAULT FOR SPECTROGRAPH GIRD IS OFF (0)
#define SGGRID_DISPLAY_DEF 0

@interface Spectrograph : ChartView

- (void)setSpectrographGrid:(BOOL)spectrographGridState;
- (void)drawSpectrograph:(float *)data size:(int)size okFlag:(int)flag;
- (void)readUpperThreshold;
- (void)readLowerThreshold;
- (void)setMagnitudeScale:(int)value;

@end

//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

/*  HEADER FILES  ************************************************************/
#import <AppKit/AppKit.h>
#import "Spectrum.h"


/*  GLOBAL DEFINES  **********************************************************/
#define RECTANGULAR           0
#define TRIANGULAR            1
#define HANNING               2
#define HAMMING               3
#define BLACKMAN              4
#define KAISER                5
#define Izero2EPSILON		1E-21

extern double Izero2(double x);

@interface AnalysisWindow:NSObject
{

    float *window;
    int   windowSize;
	id spectrum;
}

- init;
- (void)dealloc;
- (void)freeWindow;

- (void)setWindowType:(int)type alpha:(float)alpha beta:(float)beta size:(int)size;
- (const float *)windowBuffer;
- (int)windowSize;
- (BOOL)haveWindow;

@end

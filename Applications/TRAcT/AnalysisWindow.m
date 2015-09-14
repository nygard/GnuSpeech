//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

/*  HEADER FILES  ************************************************************/
#import "AnalysisWindow.h"
// #import "sr_conversion.h"
#include <math.h>
#import "tube.h"

/*  GLOBAL FUNCTIONS (LOCAL TO THIS FILE)  ***********************************/
static void rectangularWindow(float *window, int windowSize);
static void triangularWindow(float *window, int windowSize);
static void hanningWindow(float *window, int windowSize);
static void hammingWindow(float *window, int windowSize, float alpha);
static void blackmanWindow(float *window, int windowSize);
static void kaiserWindow(float *window, int windowSize, float beta);

@implementation AnalysisWindow
{
    float *window;
    int   windowSize;
	id spectrum;
}

- (id)init;
{
    if ((self = [super init])) {
        /*  INITIALIZE DATA TO EMPTY  */
        window = NULL;
        windowSize = 0;
    }

    return self;
}

- (void)dealloc;
{
    /*  FREE BUFFER, IF NECESSARY  */
    [self freeWindow];

    /*  DO REGULAR FREE  */
    [super dealloc];
}

- (void)awakeFromNib;
{
	//[self setWindowType:4 alpha:0 beta:0 size:512];
}

- (void)freeWindow;
{
    /*  FREE BUFFER, IF NECESSARY  */
    if (window) {
        free((char *)window);
        windowSize = 0;
    } 
}

- (void)setWindowType:(int)type alpha:(float)alpha beta:(float)beta size:(int)size;
{
    /*  FREE OLD BUFFER, IF NECESSARY  */
    [self freeWindow];
	NSLog(@"AnalysisWindow.m:81 size is %d, type is %d", size, type);
    
    /*  RETURN IMMEDIATELY IF SIZE ZERO OR LESS  */
    if (size <= 0)
        return;
	NSLog(@"AnalysisWindow.m:86 Past immediate return");
    /*  SET WINDOW SIZE  */
    windowSize = size;
    
    /*  ALLOCATE THE WINDOW BUFFER  */
    window = (float *)calloc(windowSize, sizeof(float));
    
    /*  CREATE THE WINDOW  */
    switch (type) {
        case TRIANGULAR:
            triangularWindow(window, windowSize);
            break;
        case HANNING:
            hanningWindow(window, windowSize);
            break;
        case HAMMING:
            hammingWindow(window, windowSize, alpha);
            break;
        case BLACKMAN:
            blackmanWindow(window, windowSize);
            break;
        case KAISER:
            kaiserWindow(window, windowSize, beta);
            break;
        case RECTANGULAR:
        default:
            rectangularWindow(window, windowSize);
            break;
    } 
	NSNotificationCenter *nc;
	nc = [NSNotificationCenter defaultCenter];
	NSLog(@"AnalysisWindow.m:116 Sending notification windowTypeDidChange");
	[nc postNotificationName:@"windowTypeDidChange" object: self];
    /*	int i;
     for (i = 0; i <= windowSize; i++)
     NSLog(@"AnalysisWindow.m:121 window[%d] is %f", i, window[i]); */
	[spectrum setAnalysisWindowShape:(float *) window];
	[spectrum setNeedsDisplay:YES];
}

- (const float *)windowBuffer;
{
    return (const float *)window;
}

- (int)windowSize;
{
    return windowSize;
}

- (BOOL)haveWindow;
{
    if (window)
        return YES;
    else
        return NO;
}



/******************************************************************************
*
*	function:	rectangularWindow
*
*	purpose:	Creates a rectangular window.
*			
*       arguments:      window - memory buffer to write into.
*                       windowSize - size of the window.
*
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

void rectangularWindow(float *window, int windowSize)
{
    for (NSUInteger index = 0; index < windowSize; index++)
        window[index] = 1.0;
}



/******************************************************************************
*
*	function:	triangularWindow
*
*	purpose:	Creates a triangular window
*			
*       arguments:      window - memory buffer to write into.
*                       windowSize - size of the window.
*
******************************************************************************/

void triangularWindow(float *window, int windowSize)
{
    int i;
    float m = (float)(windowSize - 1);
    float midPoint = m / 2.0;
    float delta = 2.0 / m;
    
    /*  CREATE RISING PORTION  */
    for (i = 0; i < midPoint; i++)
        window[i] = delta * (float)i;
    
    /*  CREATE FALLING PORTION  */
    for ( ; i < windowSize; i++)
        window[i] = 2.0 - (delta * (float)i);
}



/******************************************************************************
*
*	purpose:	Creates a Hanning window.
*			
*       arguments:      window - memory buffer to write into.
*                       windowSize - size of the window.
*
******************************************************************************/

void hanningWindow(float *window, int windowSize)
{
    int i;
    float m = (float)(windowSize - 1);
    float pi2divM = TWO_PI / m;
    
    for (i = 0; i < windowSize; i++)
        window[i] = 0.5 - (0.5 * cos(pi2divM * (float)i));
}



/******************************************************************************
*
*	purpose:	Creates a Hamming window
*                       
*			
*       arguments:      window - memory buffer to write into.
*                       windowSize - size of the window.
*                       alpha - window shape parameter.
*
******************************************************************************/

void hammingWindow(float *window, int windowSize, float alpha)
{
    int i;
    float m = (float)(windowSize - 1);
    float pi2divM = TWO_PI / m;
    float alphaComplement = 1.0 - alpha;
    
    for (i = 0; i < windowSize; i++)
        window[i] = alpha - (alphaComplement * cos(pi2divM * (float)i));
}



/******************************************************************************
*
*	purpose:	Creates a Blackman window
*			
*       arguments:      window - memory buffer to write into.
*                       windowSize - size of the window.
*
******************************************************************************/

void blackmanWindow(float *window, int windowSize)
{
    int i;
    float m = (float)(windowSize - 1);
    float pi2divM = TWO_PI / m;
    float pi4divM = pi2divM * 2.0;
    
    for (i = 0; i < windowSize; i++)
        window[i] = 0.42 - (0.5 * cos(pi2divM * (float)i)) +
	    (0.08 * cos(pi4divM * (float)i));
}

/******************************************************************************
*
*	purpose:	Creates a Kaiser window.
*
*       arguments:      window - memory buffer to write into.
*                       windowSize - size of the window.
*                       beta - window shape parameter.
*
******************************************************************************/

void kaiserWindow(float *window, int windowSize, float beta)
{
    int i;
    float m = (float)(windowSize - 1);
    float midPoint = m / 2.0;
    float IBeta = 1.0 / Izero2(beta);
    
    for (i = 0; i < windowSize; i++) {
        float temp = ((float)i - midPoint) / midPoint;
        window[i] = Izero2(beta * sqrt(1.0 - (temp*temp))) * IBeta;
    }
}

@end

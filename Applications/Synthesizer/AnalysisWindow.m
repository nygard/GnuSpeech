////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
//  
//  Contributors: Adam Fedor, David Hill
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
////////////////////////////////////////////////////////////////////////////////
//
//  AnalysisWindow.m
//  Synthesizer
//
//  Created by Adam Fedor on 1/18/2003.
//
//  Version: 0.7.3
//
////////////////////////////////////////////////////////////////////////////////


/*  REVISION INFORMATION  *****************************************************

$Author: fedor $
$Date: 2003/01/18 05:04:50 $
$Revision: 1.2 $
$Source: /cvsroot/gnuspeech/gnuspeech/trillium/src/Synthesizer/AnalysisWindow.m,v $
$State: Exp $


$Log: AnalysisWindow.m,v $
Revision 1.2  2003/01/18 05:04:50  fedor
Port to OpenStep/GNUstep

Revision 1.1  2002/03/21 16:49:54  rao
Initial import.

# Revision 1.1.1.1  1994/05/20  00:22:04  len
# Initial archive of TRM interactive Synthesizer.
#

******************************************************************************/

/*  HEADER FILES  ************************************************************/
#import "AnalysisWindow.h"
// #import "sr_conversion.h"
#include <math.h>

/*  GLOBAL FUNCTIONS (LOCAL TO THIS FILE)  ***********************************/
static void rectangularWindow(float *window, int windowSize);
static void triangularWindow(float *window, int windowSize);
static void hanningWindow(float *window, int windowSize);
static void hammingWindow(float *window, int windowSize, float alpha);
static void blackmanWindow(float *window, int windowSize);
static void kaiserWindow(float *window, int windowSize, float beta);
extern float PI2;



@implementation AnalysisWindow

- init
{
    /*  DO REGULAR INITIALIZATION  */
    [super init];

    /*  INITIALIZE DATA TO EMPTY  */
    window = NULL;
    windowSize = 0;

    return self;
}

- (void) awakeFromNib
{
	//[self setWindowType:4 alpha:0 beta:0 size:512];
}


- (void)dealloc
{
    /*  FREE BUFFER, IF NECESSARY  */
    [self freeWindow];

    /*  DO REGULAR FREE  */
    [super dealloc];
}



- (void)freeWindow
{
    /*  FREE BUFFER, IF NECESSARY  */
    if (window) {
	free((char *)window);
	windowSize = 0;
    } 
}



- (void)setWindowType:(int)type alpha:(float)alpha beta:(float)beta size:(int)size
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



- (const float *)windowBuffer
{
    return (const float *)window;
}



- (int)windowSize
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
    int i;

    for (i = 0; i < windowSize; i++)
	window[i] = 1.0;
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
*	internal
*	functions:	none
*
*	library
*	functions:	none
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
*	function:	hanningWindow
*
*	purpose:	Creates a Hanning window.
*			
*       arguments:      window - memory buffer to write into.
*                       windowSize - size of the window.
*                       
*	internal
*	functions:	none
*
*	library
*	functions:	cos
*
******************************************************************************/

void hanningWindow(float *window, int windowSize)
{
    int i;
    float m = (float)(windowSize - 1);
    float pi2divM = PI2 / m;

    for (i = 0; i < windowSize; i++)
	window[i] = 0.5 - (0.5 * cos(pi2divM * (float)i));
}



/******************************************************************************
*
*	function:	hammingWindow
*
*	purpose:	Creates a Hamming window
*                       
*			
*       arguments:      window - memory buffer to write into.
*                       windowSize - size of the window.
*                       alpha - window shape parameter.
*                       
*	internal
*	functions:	none
*
*	library
*	functions:	cos
*
******************************************************************************/

void hammingWindow(float *window, int windowSize, float alpha)
{
    int i;
    float m = (float)(windowSize - 1);
    float pi2divM = PI2 / m;
    float alphaComplement = 1.0 - alpha;

    for (i = 0; i < windowSize; i++)
	window[i] = alpha - (alphaComplement * cos(pi2divM * (float)i));
}



/******************************************************************************
*
*	function:	blackmanWindow
*
*	purpose:	Creates a Blackman window
*			
*       arguments:      window - memory buffer to write into.
*                       windowSize - size of the window.
*                       
*	internal
*	functions:	none
*
*	library
*	functions:	cos
*
******************************************************************************/

void blackmanWindow(float *window, int windowSize)
{
    int i;
    float m = (float)(windowSize - 1);
    float pi2divM = PI2 / m;
    float pi4divM = pi2divM * 2.0;

    for (i = 0; i < windowSize; i++)
	window[i] = 0.42 - (0.5 * cos(pi2divM * (float)i)) +
	    (0.08 * cos(pi4divM * (float)i));
}



//******************************************************************************
//*
//*	function:	kaiserWindow
//*
//*	purpose:	Creates a Kaiser window.
//*
//*       arguments:      window - memory buffer to write into.
//*                       windowSize - size of the window.
//*                       beta - window shape parameter.
//*                       
//*	internal
//*	functions:	Izero2
//*
//*	library
//*	functions:	sqrt
//*
//******************************************************************************

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

//*****************************************************************************
//*
//*	function:	Izero
//*
//*	purpose:	Returns the value for the modified Bessel function of
//*                       the first kind, order 0, as a double.
//*			
//*       arguments:      x - input argument
//*                       
//*	internal
//*	functions:	none
//*
//*	library
//*	functions:	none
//*
//******************************************************************************
/* ****
double Izero2(double x)
{
	double sum, u, halfx, temp;
	int n;
	
	sum = u = n = 1;
	halfx = x / 2.0;
	
	do {
		temp = halfx / (double)n;
		n += 1;
		temp *= temp;
		u *= temp;
		sum += u;
	} while (u >= (Izero2EPSILON * sum));
	
	return(sum);
} // ****
*/

@end

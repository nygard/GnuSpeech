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
//  AnalysisWindow.h
//  Synthesizer
//
//  Created by Adam Fedor on 1/18/2003.
//
//  Version: 0.7.4
//
////////////////////////////////////////////////////////////////////////////////


/*  REVISION INFORMATION  *****************************************************

$Author: fedor $
$Date: 2003/01/18 05:04:50 $
$Revision: 1.2 $
$Source: /cvsroot/gnuspeech/gnuspeech/trillium/src/Synthesizer/AnalysisWindow.h,v $
$State: Exp $


$Log: AnalysisWindow.h,v $
Revision 1.2  2003/01/18 05:04:50  fedor
Port to OpenStep/GNUstep

Revision 1.1  2002/03/21 16:49:54  rao
Initial import.

 * Revision 1.1.1.1  1994/05/20  00:22:03  len
 * Initial archive of TRM interactive Synthesizer.
 *

******************************************************************************/

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

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
//  Analysis.h
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
$Source: /cvsroot/gnuspeech/gnuspeech/trillium/src/Synthesizer/Analysis.h,v $
$State: Exp $


$Log: Analysis.h,v $
Revision 1.2  2003/01/18 05:04:50  fedor
Port to OpenStep/GNUstep

Revision 1.1  2002/03/21 16:49:54  rao
Initial import.

 * Revision 1.1.1.1  1994/05/20  00:21:52  len
 * Initial archive of TRM interactive Synthesizer.
 *

******************************************************************************/

#import <AppKit/AppKit.h>

@interface Analysis:NSObject
{
    id  analysisWindow;
    id	magnitudeForm;
    id	magnitudePopUp;
    id  magnitudeLabel;
    id	binSizeFrequency;
    id	binSizePopUp;
    id	doAnalysisButton;
    id	grayLevelPopUp;
    id  normalizeSwitch;
    id	rateForm;
    id	rateSecond;
    id	spectrograph;
    id	spectrographGridButton;
    id	spectrum;
    id	spectrumGridButton;
    id	updateMatrix;
    id	windowForm;
    id	windowPopUp;
    id  synthesizer;
	id  runButton;
	id	testSwitch;

    //id  soundDataObject;
    id  analysisDataObject;
	id controller;
	
    BOOL normalizeInput;
    int binSize;
    int windowType;
    float alpha;
    float beta;
    int grayLevel;
    int magnitudeScale;
    float linearUpperThreshold;
    float linearLowerThreshold;
    int logUpperThreshold;
    int logLowerThreshold;
    BOOL spectrographGrid;
    BOOL spectrumGrid;

    int updateMode;
    float updateRate;
    BOOL analysisEnabled;
    BOOL running;
	

    NSTimer *timedEntry;
}

- (void)defaultInstanceVariables;
- (void)awakeFromNib;
- (void)displayAndSynthesizeIvars;

- (void)saveToStream:(NSArchiver *)typedStream;
- (void)openFromStream:(NSArchiver *)typedStream;

- (void)windowWillMiniaturize:sender;

- (void)setAnalysisEnabled:(BOOL)flag;
- (IBAction)setRunning;

- (void)normalizeSwitchPushed:sender;
- (void)magnitudeFormEntered:sender;
- (void)magnitudeScaleSelected:sender;
- (void)binSizeSelected:sender;
- (void)doAnalysisButtonPushed:sender;
- (void)grayLevelSelected:sender;
- (void)rateFormEntered:sender;
- (void)spectrographGridPushed:sender;
- (void)spectrumGridPushed:sender;
- (void)updateMatrixPushed:sender;
- (void)windowFormEntered:sender;
- (void)windowSelected:sender;
- (void)updateWindow;

//- (void)displayAnalysis;

- (int)runState;


@end

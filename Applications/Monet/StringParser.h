#import <Foundation/NSObject.h>

@class EventList, MonetList;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface StringParser : NSObject
{
    int stringIndex;
    int cache;
    const char *parseString;
    EventList *eventList;
    MonetList *categoryList;
    MonetList *phoneList;

    id intonationSystem;

    /* Min and Max for each parameter */
    double min[16];
    double max[16];

    id stringTextField;
    id eventListView;
    id intonationView;

    /* Synthesizer Control Panel Outlets */

    /* General*/
    id masterVolume;
    id length;
    id temperature;
    id balance;
    id breathiness;
    id lossFactor;
    id pitchMean;

    /* Nasal Cavity */
    id n1;
    id n2;
    id n3;
    id n4;
    id n5;

    id tp;
    id tnMin;
    id tnMax;
    id waveform;

    id throatCutoff;
    id throatVolume;
    id apScale;
    id mouthCoef;
    id noseCoef;
    id mixOffset;
    id modulation;

    id tempoField;

    id fileFlag;
    id filenameField;
    id parametersStore;
    id intonationMatrix;
    id intonParmsField;
    id driftDeviationField;
    id driftCutoffField;

    id smoothIntonationSwitch;

    id stereoMono;
    id samplingRate;

    id radiusMultiplyField;
}

- (id)init;
- (void)applicationDidFinishLaunching:(NSNotification *)notification;
- (void)saveDefaults:(id)sender;
- (void)parseStringButton:(id)sender;
- (void)synthesizeWithSoftware:(id)sender;

- (void)setUpDataStructures;

- (void)automaticIntonation:(id)sender;

@end

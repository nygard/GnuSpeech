#import <Foundation/NSObject.h>

@class EventList, MonetList, PhoneList;
@class EventListView, IntonationView;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface StringParser : NSObject
{
    //int stringIndex;
    int cache;
    //NSString *parseString;
    EventList *eventList;
    MonetList *categoryList;
    PhoneList *phoneList;

    id intonationSystem;

    /* Min and Max for each parameter */
    double min[16];
    double max[16];

    IBOutlet NSTextField *stringTextField;
    IBOutlet EventListView *eventListView;
    IBOutlet NSScrollView *intonationView;

    /* Synthesizer Control Panel Outlets */

    /* General*/
    IBOutlet NSTextField *masterVolume;
    IBOutlet NSTextField *length;
    IBOutlet NSTextField *temperature;
    IBOutlet NSTextField *balance;
    IBOutlet NSTextField *breathiness;
    IBOutlet NSTextField *lossFactor;
    IBOutlet NSTextField *pitchMean;

    /* Nasal Cavity */
    IBOutlet NSTextField *n1;
    IBOutlet NSTextField *n2;
    IBOutlet NSTextField *n3;
    IBOutlet NSTextField *n4;
    IBOutlet NSTextField *n5;

    IBOutlet NSTextField *tp;
    IBOutlet NSTextField *tnMin;
    IBOutlet NSTextField *tnMax;
    IBOutlet NSMatrix *waveform;

    IBOutlet NSTextField *throatCutoff;
    IBOutlet NSTextField *throatVolume;
    IBOutlet NSTextField *apScale;
    IBOutlet NSTextField *mouthCoef;
    IBOutlet NSTextField *noseCoef;
    IBOutlet NSTextField *mixOffset;
    IBOutlet NSMatrix *modulation;

    IBOutlet NSTextField *tempoField;

    IBOutlet NSTextField *fileFlag;
    IBOutlet NSTextField *filenameField;
    IBOutlet NSButton *parametersStore;
    IBOutlet NSMatrix *intonationMatrix;
    IBOutlet NSForm *intonParmsField;
    IBOutlet NSTextField *driftDeviationField;
    IBOutlet NSTextField *driftCutoffField;

    IBOutlet NSButton *smoothIntonationSwitch;

    IBOutlet NSMatrix *stereoMono;
    IBOutlet NSMatrix *samplingRate;

    IBOutlet NSTextField *radiusMultiplyField;
}

- (id)init;
- (void)applicationDidFinishLaunching:(NSNotification *)notification;
- (void)saveDefaults:(id)sender;
- (void)parseStringButton:(id)sender;
- (void)synthesizeWithSoftware:(id)sender;

- (void)setUpDataStructures;

- (void)automaticIntonation:(id)sender;

@end

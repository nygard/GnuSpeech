#import <Foundation/NSObject.h>

@class EventList, MModel, MonetList, PhoneList;
@class EventListView, IntonationScrollView, IntonationView;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface StringParser : NSObject
{
    EventList *eventList;

    IBOutlet IntonationScrollView *intonationSystem;

    /* Min and Max for each parameter */
    double min[16];
    double max[16];

    IBOutlet NSTextField *stringTextField;
    IBOutlet EventListView *eventListView;
    IBOutlet NSScrollView *intonationView;

    IBOutlet NSTextField *tempoField;

    IBOutlet NSTextField *filenameField;
    IBOutlet NSButton *parametersStore;
    IBOutlet NSMatrix *intonationMatrix;
    IBOutlet NSForm *intonParmsField;
    IBOutlet NSTextField *driftDeviationField;
    IBOutlet NSTextField *driftCutoffField;

    IBOutlet NSButton *smoothIntonationSwitch;

    IBOutlet NSTextField *radiusMultiplyField;

    MModel *model;
}

+ (NSCharacterSet *)gsStringParserWhitespaceCharacterSet;
+ (NSCharacterSet *)gsStringParserDefaultCharacterSet;

- (id)init;
- (void)dealloc;

- (MModel *)model;
- (void)setModel:(MModel *)newModel;

- (void)parseStringButton:(id)sender;
- (void)synthesizeWithSoftware:(id)sender;

- (void)setUpDataStructures;

- (void)automaticIntonation:(id)sender;

- (void)parsePhoneString:(NSString *)str;

@end

#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class GSMPoint, MonetList;
@class Inspector;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================

	Object: PointInspector
	Purpose: Oversees the functioning of the PhoneInspector Panel

	Date: June 5, 1994

History:
	June 5, 1994
		Integrated into MONET.

===========================================================================*/


@interface PointInspector:NSObject
{
    IBOutlet Inspector *mainInspector;
    IBOutlet NSBox *popUpListView;
    IBOutlet NSPopUpButton *popUpList;

    id multipleListView;

    id valueBox;
    id valueField;
    id phantomSwitch;

    id type1Button;
    id type2Button;
    id type3Button;

    id expressionBrowser;
    id currentTimingField;

    GSMPoint *currentPoint;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;

- (void)inspectPoint:(GSMPoint *)point;
- (void)inspectPoints:(MonetList *)points;

- (void)setUpWindow:(NSPopUpButton *)sender;
- (void)beginEditting;

- (IBAction)browserHit:(id)sender;
- (IBAction)browserDoubleHit:(id)sender;

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;

- (IBAction)setValue:(id)sender;
- (IBAction)setType1:(id)sender;
- (IBAction)setType2:(id)sender;
- (IBAction)setType3:(id)sender;

- (IBAction)setPhantom:(id)sender;

@end

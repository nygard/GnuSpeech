#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class GSMPoint;

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
    id mainInspector;
    id popUpListView;
    id popUpList;

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

- (void)inspectPoint:point;
- (void)setUpWindow:(id)sender;
- (void)beginEditting;

- (void)browserHit:(id)sender;
- (void)browserDoubleHit:(id)sender;

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;

- (void)setValue:(id)sender;
- (void)setType1:(id)sender;
- (void)setType2:(id)sender;
- (void)setType3:(id)sender;

- (void)setPhantom:(id)sender;

@end

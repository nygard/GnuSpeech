#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

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
	id	mainInspector;
	id	popUpListView;
	id	popUpList;

	id	multipleListView;

	id	valueBox;
	id	valueField;
	id	phantomSwitch;

	id	type1Button;
	id	type2Button;
	id	type3Button;

	id	expressionBrowser;
	id	currentTimingField;

	Point	*currentPoint;

}

- init;
- (void)applicationDidFinishLaunching:(NSNotification *)notification;

- (void)inspectPoint:point;
- (void)setUpWindow:sender;
- (void)beginEditting;

- (void)browserHit:sender;
- (void)browserDoubleHit:sender;

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;

- (void)setValue:sender;
- (void)setType1:sender;
- (void)setType2:sender;
- (void)setType3:sender;

- (void)setPhantom:sender;

@end

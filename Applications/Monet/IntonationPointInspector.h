
#import <AppKit/AppKit.h>
#import "IntonationPoint.h"

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================

	Object: Intonation PointInspector
	Purpose: Oversees the functioning of the PhoneInspector Panel

	Date: June 5, 1994

History:
	June 5, 1994
		Integrated into MONET.

===========================================================================*/


@interface IntonationPointInspector:NSObject
{
	id	mainInspector;
	id	popUpListView;
	id	popUpList;

	id	mainBox;

	id	semitoneField;
	id	hertzField;
	id	slopeField;

	id	ruleBrowser;
	id	beatField;
	id	beatOffsetField;
	id	absTimeField;

	IntonationPoint	*currentPoint;

}

- init;
- (void)applicationDidFinishLaunching:(NSNotification *)notification;

- (void)inspectIntonationPoint:point;
- (void)setUpWindow:sender;
- (void)beginEditting;

- (void)browserHit:sender;
- (void)browserDoubleHit:sender;

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;

- (void)setSemitone:sender;
- (void)setHertz:sender;
- (void)setSlope:sender;
- (void)setBeatOffset:sender;

- (void)updateInspector;

@end

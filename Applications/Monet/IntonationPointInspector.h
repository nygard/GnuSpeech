#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class IntonationPoint;

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

@interface IntonationPointInspector : NSObject
{
    id mainInspector;
    id popUpListView;
    id popUpList;

    id mainBox;

    id semitoneField;
    id hertzField;
    id slopeField;

    id ruleBrowser;
    id beatField;
    id beatOffsetField;
    id absTimeField;

    IntonationPoint *currentPoint;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;

- (void)inspectIntonationPoint:point;
- (void)setUpWindow:(id)sender;
- (void)beginEditting;

- (void)browserHit:(id)sender;
- (void)browserDoubleHit:(id)sender;

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;

- (void)setSemitone:(id)sender; // TODO (2004-03-02): Renamed to "changeSemitone:", so it doens't conflict with setSemitone:(double)newValue;
- (void)setHertz:(id)sender;
- (void)setSlope:(id)sender;
- (void)setBeatOffset:(id)sender;

- (void)updateInspector;

@end

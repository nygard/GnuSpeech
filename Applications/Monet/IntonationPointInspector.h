#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class IntonationPoint;
@class Inspector;

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
    IBOutlet Inspector *mainInspector;
    IBOutlet NSBox *popUpListView;
    IBOutlet NSPopUpButton *popUpList;

    IBOutlet NSBox *mainBox;

    IBOutlet NSTextField *semitoneField;
    IBOutlet NSTextField *hertzField;
    IBOutlet NSTextField *slopeField;

    IBOutlet NSBrowser *ruleBrowser;
    IBOutlet NSTextField *beatField;
    IBOutlet NSTextField *beatOffsetField;
    IBOutlet NSTextField *absTimeField;

    IntonationPoint *currentIntonationPoint;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;

- (void)dealloc;

- (void)setCurrentIntonationPoint:(IntonationPoint *)anIntonationPoint;
- (void)inspectIntonationPoint:(IntonationPoint *)anIntonationPoint;
- (void)setUpWindow:(NSPopUpButton *)sender;
- (void)beginEditing;

- (IBAction)browserHit:(id)sender;
- (IBAction)browserDoubleHit:(id)sender;

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;

- (IBAction)setSemitone:(id)sender; // TODO (2004-03-02): Renamed to "changeSemitone:", so it doens't conflict with setSemitone:(double)newValue;
- (IBAction)setHertz:(id)sender;
- (IBAction)setSlope:(id)sender;
- (IBAction)setBeatOffset:(id)sender;

- (void)updateInspector;

@end

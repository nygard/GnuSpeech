#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class MMPoint, MonetList;
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

    IBOutlet NSBox *multipleListView;

    IBOutlet NSBox *valueBox;
    IBOutlet NSTextField *valueField;
    IBOutlet NSButton *phantomSwitch;

    IBOutlet NSButton *type1Button;
    IBOutlet NSButton *type2Button;
    IBOutlet NSButton *type3Button;

    IBOutlet NSBrowser *expressionBrowser;
    IBOutlet NSTextField *currentTimingField;

    MMPoint *currentPoint;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;

- (void)dealloc;

- (void)setCurrentPoint:(MMPoint *)aPoint;
- (void)inspectPoint:(MMPoint *)aPoint;
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

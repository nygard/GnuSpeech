#import <AppKit/NSScrollView.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

/*===========================================================================

	Object: IntonationView
	Purpose: Highest View in the ScrollView Hierarchy.  This view has
		two sub views.  They are intonationView and
		intonationScaleView
		NOTE: IntonationView is the "docView" of this scrollview, so its
		instance variable is in the superclass.

	Author: Craig-Richard Taube-Schock
	Date: Nov. 1, 1993

History:
	Nov. 23, 1993.  Documentation Completed.

===========================================================================*/

@class AppController;

@interface IntonationScrollView : NSScrollView
{
    IBOutlet AppController *controller;
    IBOutlet NSView *scaleView; // TODO (2004-03-15): Find specific subclass that is used.
    IBOutlet NSTextField *utterance;
    IBOutlet NSButton *smoothing;
}

- (id)initWithFrame:(NSRect)frameRect;
- (void)applicationDidFinishLaunching:(NSNotification *)notification;

- (void)drawRect:(NSRect)rect;
- (void)tile;
- (IBAction)print:(id)sender;

- (NSView *)scaleView;

- (IBAction)saveIntonationContour:(id)sender;
- (IBAction)loadContour:(id)sender;
- (IBAction)loadContourAndUtterance:(id)sender;

@end

#import <AppKit/NSScrollView.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

/*===========================================================================

	Author: Craig-Richard Taube-Schock
	Date: Nov. 1, 1993

===========================================================================*/

@class MAIntonationScaleView;

@interface IntonationScrollView : NSScrollView
{
    IBOutlet MAIntonationScaleView *scaleView;
}

- (id)initWithFrame:(NSRect)frameRect;
- (void)dealloc;

- (void)awakeFromNib;
- (void)addScaleView;

- (void)tile;

- (NSView *)scaleView;

- (NSSize)printableSize;

@end

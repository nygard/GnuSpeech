//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Cocoa/Cocoa.h>
#import "Controller.h"

#define MAX_SECT_DIAM 4.0
#define MIN_SECT_DIAM 0.1


@interface TubeSection : NSView {
	
	IBOutlet NSTextField *radius;
	IBOutlet NSTextField *diameter;
	IBOutlet NSTextField *area;

	// I probably need a notification in here so I can get the observer
	// to use the newSlider method to get the slider value and id + ID
	//IBOutlet Controller *myController;
	NSRect slide;
	NSPoint temp;
	BOOL status; // State = 0 for setting value; state = 1 for field change input
	@public float slideHeight;

	
}


- (void)mouseDragged:(NSEvent *)event;
- (void)controlTextDidEndEditing:(NSNotification *) aNotification;
- (void)setValue:(float)value;
- (float)getValue;
- (void)setSection:(double)value:(int)tag:(BOOL)state;
- (void)sectionChanged:(float)value;




@end

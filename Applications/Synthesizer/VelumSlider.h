//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Cocoa/Cocoa.h>
#import "Controller.h"

#define VMAX_SECT_DIAM 3
#define VMIN_SECT_DIAM 0

@interface VelumSlider : NSView
{
	IBOutlet NSTextField *radius;
	IBOutlet NSTextField *diameter;
	IBOutlet NSTextField *area;
	NSRect slide;
	NSPoint temp;
	@public float slideWidth;
	
}

- (void)mouseDragged:(NSEvent *)event;
- (void)setSection:(float)value:(int)tag;
- (void)sectionChanged:(float)value;
- (void)setValue:(float)value;

@end

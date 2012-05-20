//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "VelarNasalConnector.h"

@implementation VelarNasalConnector

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		// Add initialization code here
	}
	return self;
}

- (void)drawRect:(NSRect)rect
{
	NSBezierPath *line = [NSBezierPath bezierPath];
	NSRect bounds = [self bounds];
	[[[NSColor lightGrayColor] colorWithAlphaComponent:0.0] set];
	[NSBezierPath fillRect:bounds];
	[[NSColor blackColor] set];
	// Draw connector round edge of view
	NSPoint start = NSMakePoint(bounds.origin.x, bounds.origin.y);
	NSPoint middle = NSMakePoint(bounds.origin.x, bounds.size.height);
	NSPoint end = NSMakePoint(bounds.size.width, bounds.size.height);
	[line setLineWidth:5];
	[line moveToPoint:start];
	[line lineToPoint:middle];
	[line lineToPoint:end];
	[line stroke];
	
}

@end

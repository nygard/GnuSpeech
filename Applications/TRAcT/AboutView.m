//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "AboutView.h"

@implementation AboutView
{
}

- (void)drawRect:(NSRect)rect;
{
	NSImage *aboutImage = [NSImage imageNamed:@"AboutSynthesizer.png"];
	
	NSRect imageRect;
	imageRect.origin = NSZeroPoint;
	imageRect.size = [aboutImage size];

	NSRect drawingRect = imageRect;
	[aboutImage drawInRect:drawingRect
				 fromRect:imageRect
				operation:NSCompositeSourceOver
				 fraction:1];
	
}


@end

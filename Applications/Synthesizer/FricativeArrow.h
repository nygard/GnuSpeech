//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Cocoa/Cocoa.h>
//#import "NoiseSource.h"


@interface FricativeArrow : NSView
{

	NSRect fricationView;
	float fricationPosition;
	float fricationValue;
	float velumConnection;
	NSBezierPath *downArrow;
	float scale;

}

- (void)awakeFromNib;
- (void)setFricationPosition:(float)aValue;
- (float)floatValue;

@end

//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Cocoa/Cocoa.h>

@interface VelumSlider : NSView

- (void)mouseDragged:(NSEvent *)event;
- (void)setSection:(float)value:(int)tag;
- (void)sectionChanged:(float)value;
- (void)setValue:(float)value;

@end

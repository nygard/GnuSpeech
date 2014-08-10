//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Cocoa/Cocoa.h>

@class MAIntonationScaleView;

@interface MAIntonationScrollView : NSScrollView

- (id)initWithFrame:(NSRect)frameRect;

- (void)awakeFromNib;
- (void)addScaleView;

- (void)tile;

- (NSView *)scaleView;

- (NSSize)printableSize;

@end

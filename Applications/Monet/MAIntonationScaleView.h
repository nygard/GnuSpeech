//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Cocoa/Cocoa.h>

@interface MAIntonationScaleView : NSView

- (id)initWithFrame:(NSRect)frameRect;

- (NSUInteger)sectionCount;
- (void)setSectionCount:(NSUInteger)newSectionCount;

- (CGFloat)sectionHeight;
- (void)setSectionHeight:(CGFloat)newSectionHeight;

- (NSUInteger)zeroSection;
- (void)setZeroSection:(NSUInteger)newZeroSection;

- (CGFloat)yOrigin;
- (void)setYOrigin:(CGFloat)newYOrigin;

- (void)drawRect:(NSRect)rect;

@end

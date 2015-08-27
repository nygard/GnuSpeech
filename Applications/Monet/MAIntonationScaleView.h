//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Cocoa/Cocoa.h>

@interface MAIntonationScaleView : NSView

@property (nonatomic, assign) NSUInteger sectionCount;
@property (nonatomic, assign) CGFloat sectionHeight;
@property (nonatomic, assign) NSUInteger zeroSection;
@property (nonatomic, assign) CGFloat yOrigin;

@end

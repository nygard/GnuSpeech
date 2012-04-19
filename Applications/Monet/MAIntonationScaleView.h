//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface MAIntonationScaleView : NSView
{
    NSTextFieldCell *labelTextFieldCell;

    NSTextStorage *textStorage;
    NSLayoutManager *layoutManager;
    NSTextContainer *textContainer;
    NSFont *labelFont;
    NSFont *axisLabelFont;

    int sectionCount;
    int sectionHeight;
    int zeroSection;
    int yOrigin;
}

- (id)initWithFrame:(NSRect)frameRect;
- (void)dealloc;

- (int)sectionCount;
- (void)setSectionCount:(int)newSectionCount;

- (int)sectionHeight;
- (void)setSectionHeight:(int)newSectionHeight;

- (int)zeroSection;
- (void)setZeroSection:(int)newZeroSection;

- (int)yOrigin;
- (void)setYOrigin:(int)newYOrigin;

- (void)drawRect:(NSRect)rect;

@end

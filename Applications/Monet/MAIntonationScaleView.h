//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <AppKit/NSView.h>

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

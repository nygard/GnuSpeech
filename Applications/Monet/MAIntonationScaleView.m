//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MAIntonationScaleView.h"

#import <AppKit/AppKit.h>

@implementation MAIntonationScaleView

- (id)initWithFrame:(NSRect)frameRect;
{
    NSDictionary *attributes;

    if ([super initWithFrame:frameRect] == nil)
        return nil;

    labelTextFieldCell = [[NSTextFieldCell alloc] initTextCell:@""];
    labelFont = [[[NSFontManager sharedFontManager] fontWithFamily:@"Times" traits:0 weight:0 size:10.0] retain];
    [labelTextFieldCell setFont:labelFont];
    [labelTextFieldCell setAlignment:NSRightTextAlignment];

    axisLabelFont = [[[NSFontManager sharedFontManager] fontWithFamily:@"Times" traits:0 weight:0 size:14.0] retain];
    attributes = [[NSDictionary alloc] initWithObjectsAndKeys:axisLabelFont, NSFontAttributeName,
                                       [NSColor blackColor], NSForegroundColorAttributeName,
                                       nil];


    textStorage = [[NSTextStorage alloc] initWithString:@"Semitone" attributes:attributes];
    layoutManager = [[NSLayoutManager alloc] init];
    textContainer = [[NSTextContainer alloc] init];
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    [layoutManager setUsesScreenFonts:NO];

    [attributes release];

    sectionCount = 20;
    sectionHeight = 10;
    zeroSection = 10;
    yOrigin = 0;

    return self;
}

- (void)dealloc;
{
    [labelTextFieldCell release];

    [textStorage release];
    [layoutManager release];
    [textContainer release];
    [labelFont release];
    [axisLabelFont release];

    [super dealloc];
}

- (int)sectionCount;
{
    return sectionCount;
}

- (void)setSectionCount:(int)newSectionCount;
{
    if (newSectionCount == sectionCount)
        return;

    sectionCount = newSectionCount;
    [self setNeedsDisplay:YES];
}

- (int)sectionHeight;
{
    return sectionHeight;
}

- (void)setSectionHeight:(int)newSectionHeight;
{
    if (newSectionHeight == sectionHeight)
        return;

    sectionHeight = newSectionHeight;
    [self setNeedsDisplay:YES];
}

- (int)zeroSection;
{
    return zeroSection;
}

- (void)setZeroSection:(int)newZeroSection;
{
    if (newZeroSection == zeroSection)
        return;

    zeroSection = newZeroSection;
    [self setNeedsDisplay:YES];
}

- (int)yOrigin;
{
    return yOrigin;
}

- (void)setYOrigin:(int)newYOrigin;
{
    if (newYOrigin == yOrigin)
        return;

    yOrigin = newYOrigin;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect;
{
    NSBezierPath *bezierPath;
    NSRect bounds, cellFrame;
    NSPoint point;
    unsigned int index;

    float labelHeight;
    float labelDescender;

    [[NSColor whiteColor] set];
    NSRectFill(rect);

    labelHeight = ceil([labelFont boundingRectForFont].size.height);
    labelDescender = ceil([labelFont descender]);

    bounds = [self bounds];

    cellFrame.origin.x = 0;
    cellFrame.origin.y = 0;
    cellFrame.size.width = bounds.size.width - 10.0;
    cellFrame.size.height = labelHeight;

    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:2.0];
    [bezierPath setLineCapStyle:NSSquareLineCapStyle];

    point.x = NSMaxX(bounds) - 1.0;
    point.y = yOrigin;
    //NSLog(@"point1: %@", NSStringFromPoint(point));
    [bezierPath moveToPoint:point];

    point.y += sectionCount * sectionHeight;
    //NSLog(@"point2: %@", NSStringFromPoint(point));
    [bezierPath lineToPoint:point];

    [[NSColor blackColor] set];
    [bezierPath stroke];
    [bezierPath release];

    bezierPath = [[NSBezierPath alloc] init];
    for (index = 0; index <= sectionCount; index++) {
        point.x = NSMaxX(bounds);
        point.y = yOrigin + index * sectionHeight + 0.5;
        [bezierPath moveToPoint:point];

        point.x -= 5.0;
        [bezierPath lineToPoint:point];

        cellFrame.origin.y = point.y - (labelHeight / 2.0) - labelDescender;
        [labelTextFieldCell setIntValue:index - zeroSection];
        [labelTextFieldCell drawWithFrame:cellFrame inView:self];
    }

    [bezierPath stroke];
    [bezierPath release];

    {
        NSGraphicsContext *context;
        NSAffineTransform *transform;
        NSPoint labelPoint;
        NSRange glyphRange;
        NSRect boundingRect;
        float axisLabelHeight;

        axisLabelHeight = ceil([axisLabelFont boundingRectForFont].size.height);

        context = [NSGraphicsContext currentContext];
        transform = [NSAffineTransform transform];
        [transform translateXBy:axisLabelHeight + 10.0 yBy:0.0];
        [transform rotateByDegrees:90.0];

        glyphRange = [layoutManager glyphRangeForTextContainer:textContainer];
        boundingRect = [layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:textContainer];
        //NSLog(@"boundingRect: %@", NSStringFromRect(boundingRect));

        //labelPoint = NSMakePoint((bounds.size.height - boundingRect.size.width) / 2.0, -boundingRect.size.height);
        labelPoint = NSMakePoint((bounds.size.height - boundingRect.size.width) / 2.0, 0);

        [context saveGraphicsState];
        [transform concat];
        [layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:labelPoint];
        [context restoreGraphicsState];
    }
}

@end

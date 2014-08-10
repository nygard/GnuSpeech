//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MAIntonationScaleView.h"

@implementation MAIntonationScaleView
{
    NSTextFieldCell *labelTextFieldCell;
    
    NSTextStorage *textStorage;
    NSLayoutManager *layoutManager;
    NSTextContainer *textContainer;
    NSFont *labelFont;
    NSFont *axisLabelFont;
    
    NSUInteger sectionCount;
    CGFloat sectionHeight;
    NSUInteger zeroSection;
    CGFloat yOrigin;
}

- (id)initWithFrame:(NSRect)frameRect;
{
    if ((self = [super initWithFrame:frameRect])) {
        labelTextFieldCell = [[NSTextFieldCell alloc] initTextCell:@""];
        labelFont = [[NSFontManager sharedFontManager] fontWithFamily:@"Times" traits:0 weight:0 size:10.0];
        [labelTextFieldCell setFont:labelFont];
        [labelTextFieldCell setAlignment:NSRightTextAlignment];
        
        axisLabelFont = [[NSFontManager sharedFontManager] fontWithFamily:@"Times" traits:0 weight:0 size:14.0];
        NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:axisLabelFont, NSFontAttributeName,
                                    [NSColor blackColor], NSForegroundColorAttributeName,
                                    nil];
        
        
        textStorage = [[NSTextStorage alloc] initWithString:@"Semitone" attributes:attributes];
        layoutManager = [[NSLayoutManager alloc] init];
        textContainer = [[NSTextContainer alloc] init];
        [layoutManager addTextContainer:textContainer];
        [textStorage addLayoutManager:layoutManager];
        [layoutManager setUsesScreenFonts:NO];

        sectionCount = 20;
        sectionHeight = 10;
        zeroSection = 10;
        yOrigin = 0;
    }

    return self;
}

#pragma mark -

- (NSUInteger)sectionCount;
{
    return sectionCount;
}

- (void)setSectionCount:(NSUInteger)newSectionCount;
{
    if (newSectionCount == sectionCount)
        return;

    sectionCount = newSectionCount;
    [self setNeedsDisplay:YES];
}

- (CGFloat)sectionHeight;
{
    return sectionHeight;
}

- (void)setSectionHeight:(CGFloat)newSectionHeight;
{
    if (newSectionHeight == sectionHeight)
        return;

    sectionHeight = newSectionHeight;
    [self setNeedsDisplay:YES];
}

- (NSUInteger)zeroSection;
{
    return zeroSection;
}

- (void)setZeroSection:(NSUInteger)newZeroSection;
{
    if (newZeroSection == zeroSection)
        return;

    zeroSection = newZeroSection;
    [self setNeedsDisplay:YES];
}

- (CGFloat)yOrigin;
{
    return yOrigin;
}

- (void)setYOrigin:(CGFloat)newYOrigin;
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
    NSUInteger index;

    CGFloat labelHeight;
    CGFloat labelDescender;
    NSUInteger labelSkip = 1;

    [[NSColor whiteColor] set];
    NSRectFill(rect);

    labelHeight = ceil([labelFont boundingRectForFont].size.height);
    labelDescender = ceil([labelFont descender]);

    while (sectionHeight * labelSkip < labelHeight && labelSkip < sectionCount) {
        labelSkip *= 2;
    }

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

    bezierPath = [[NSBezierPath alloc] init];
    for (index = 0; index <= sectionCount; index++) {
        point.x = NSMaxX(bounds);
        point.y = yOrigin + index * sectionHeight + 0.5;
        [bezierPath moveToPoint:point];

        point.x -= 5.0;
        [bezierPath lineToPoint:point];

        if (((index - zeroSection) % labelSkip) == 0) {
            cellFrame.origin.y = point.y - (labelHeight / 2.0) - labelDescender;
            [labelTextFieldCell setIntegerValue:index - zeroSection];
            [labelTextFieldCell drawWithFrame:cellFrame inView:self];
        }
    }

    [bezierPath stroke];

    {
        NSGraphicsContext *context;
        NSAffineTransform *transform;
        NSPoint labelPoint;
        NSRange glyphRange;
        NSRect boundingRect;
        CGFloat axisLabelHeight;

        axisLabelHeight = ceil([axisLabelFont boundingRectForFont].size.height);

        context = [NSGraphicsContext currentContext];
        transform = [NSAffineTransform transform];
        [transform translateXBy:axisLabelHeight + 10.0 yBy:0.0];
        [transform rotateByDegrees:90.0];

        glyphRange = [layoutManager glyphRangeForTextContainer:textContainer];
        boundingRect = [layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:textContainer];

        labelPoint.x = yOrigin + (sectionCount * sectionHeight - boundingRect.size.width) / 2.0;
        labelPoint.y = 0.0;

        [context saveGraphicsState];
        [transform concat];
        [layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:labelPoint];
        [context restoreGraphicsState];
    }
}

@end

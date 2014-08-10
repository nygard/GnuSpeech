//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MAIntonationScaleView.h"

@implementation MAIntonationScaleView
{
    NSTextFieldCell *_labelTextFieldCell;

    NSTextStorage *_textStorage;
    NSLayoutManager *_layoutManager;
    NSTextContainer *_textContainer;
    NSFont *_labelFont;
    NSFont *_axisLabelFont;

    NSUInteger _sectionCount;
    CGFloat _sectionHeight;
    NSUInteger _zeroSection;
    CGFloat _yOrigin;
}

- (id)initWithFrame:(NSRect)frameRect;
{
    if ((self = [super initWithFrame:frameRect])) {
        _labelTextFieldCell = [[NSTextFieldCell alloc] initTextCell:@""];
        _labelFont = [[NSFontManager sharedFontManager] fontWithFamily:@"Times" traits:0 weight:0 size:10.0];
        [_labelTextFieldCell setFont:_labelFont];
        [_labelTextFieldCell setAlignment:NSRightTextAlignment];
        
        _axisLabelFont = [[NSFontManager sharedFontManager] fontWithFamily:@"Times" traits:0 weight:0 size:14.0];
        NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:_axisLabelFont, NSFontAttributeName,
                                    [NSColor blackColor], NSForegroundColorAttributeName,
                                    nil];
        
        
        _textStorage = [[NSTextStorage alloc] initWithString:@"Semitone" attributes:attributes];
        _layoutManager = [[NSLayoutManager alloc] init];
        _textContainer = [[NSTextContainer alloc] init];
        [_layoutManager addTextContainer:_textContainer];
        [_textStorage addLayoutManager:_layoutManager];
        [_layoutManager setUsesScreenFonts:NO];

        _sectionCount = 20;
        _sectionHeight = 10;
        _zeroSection = 10;
        _yOrigin = 0;
    }

    return self;
}

#pragma mark -

- (NSUInteger)sectionCount;
{
    return _sectionCount;
}

- (void)setSectionCount:(NSUInteger)newSectionCount;
{
    if (newSectionCount == _sectionCount)
        return;

    _sectionCount = newSectionCount;
    [self setNeedsDisplay:YES];
}

- (CGFloat)sectionHeight;
{
    return _sectionHeight;
}

- (void)setSectionHeight:(CGFloat)newSectionHeight;
{
    if (newSectionHeight == _sectionHeight)
        return;

    _sectionHeight = newSectionHeight;
    [self setNeedsDisplay:YES];
}

- (NSUInteger)zeroSection;
{
    return _zeroSection;
}

- (void)setZeroSection:(NSUInteger)newZeroSection;
{
    if (newZeroSection == _zeroSection)
        return;

    _zeroSection = newZeroSection;
    [self setNeedsDisplay:YES];
}

- (CGFloat)yOrigin;
{
    return _yOrigin;
}

- (void)setYOrigin:(CGFloat)newYOrigin;
{
    if (newYOrigin == _yOrigin)
        return;

    _yOrigin = newYOrigin;
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

    labelHeight = ceil([_labelFont boundingRectForFont].size.height);
    labelDescender = ceil([_labelFont descender]);

    while (_sectionHeight * labelSkip < labelHeight && labelSkip < _sectionCount) {
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
    point.y = _yOrigin;
    //NSLog(@"point1: %@", NSStringFromPoint(point));
    [bezierPath moveToPoint:point];

    point.y += _sectionCount * _sectionHeight;
    //NSLog(@"point2: %@", NSStringFromPoint(point));
    [bezierPath lineToPoint:point];

    [[NSColor blackColor] set];
    [bezierPath stroke];

    bezierPath = [[NSBezierPath alloc] init];
    for (index = 0; index <= _sectionCount; index++) {
        point.x = NSMaxX(bounds);
        point.y = _yOrigin + index * _sectionHeight + 0.5;
        [bezierPath moveToPoint:point];

        point.x -= 5.0;
        [bezierPath lineToPoint:point];

        if (((index - _zeroSection) % labelSkip) == 0) {
            cellFrame.origin.y = point.y - (labelHeight / 2.0) - labelDescender;
            [_labelTextFieldCell setIntegerValue:index - _zeroSection];
            [_labelTextFieldCell drawWithFrame:cellFrame inView:self];
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

        axisLabelHeight = ceil([_axisLabelFont boundingRectForFont].size.height);

        context = [NSGraphicsContext currentContext];
        transform = [NSAffineTransform transform];
        [transform translateXBy:axisLabelHeight + 10.0 yBy:0.0];
        [transform rotateByDegrees:90.0];

        glyphRange = [_layoutManager glyphRangeForTextContainer:_textContainer];
        boundingRect = [_layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:_textContainer];

        labelPoint.x = _yOrigin + (_sectionCount * _sectionHeight - boundingRect.size.width) / 2.0;
        labelPoint.y = 0.0;

        [context saveGraphicsState];
        [transform concat];
        [_layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:labelPoint];
        [context restoreGraphicsState];
    }
}

@end

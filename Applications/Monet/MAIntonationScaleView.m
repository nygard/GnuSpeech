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
        NSDictionary *attributes = @{
                                     NSFontAttributeName            : _axisLabelFont,
                                     NSForegroundColorAttributeName : [NSColor blackColor],
                                     };

        
        _textStorage = [[NSTextStorage alloc] initWithString:@"Semitone" attributes:attributes];
        _layoutManager = [[NSLayoutManager alloc] init];
        _textContainer = [[NSTextContainer alloc] init];
        [_layoutManager addTextContainer:_textContainer];
        [_textStorage addLayoutManager:_layoutManager];
        [_layoutManager setUsesScreenFonts:NO];

        _sectionCount  = 20;
        _sectionHeight = 10;
        _zeroSection   = 10;
        _yOrigin       = 0;
    }

    return self;
}

#pragma mark -

- (void)setSectionCount:(NSUInteger)newSectionCount;
{
    if (newSectionCount == _sectionCount)
        return;

    _sectionCount = newSectionCount;
    [self setNeedsDisplay:YES];
}

- (void)setSectionHeight:(CGFloat)newSectionHeight;
{
    if (newSectionHeight == _sectionHeight)
        return;

    _sectionHeight = newSectionHeight;
    [self setNeedsDisplay:YES];
}

- (void)setZeroSection:(NSUInteger)newZeroSection;
{
    if (newZeroSection == _zeroSection)
        return;

    _zeroSection = newZeroSection;
    [self setNeedsDisplay:YES];
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
    NSUInteger labelSkip = 1;

    [[NSColor whiteColor] set];
    NSRectFill(rect);

    CGFloat labelHeight = ceil([_labelFont boundingRectForFont].size.height);
    CGFloat labelDescender = ceil([_labelFont descender]);

    while (_sectionHeight * labelSkip < labelHeight && labelSkip < _sectionCount) {
        labelSkip *= 2;
    }

    NSRect bounds = [self bounds];

    NSRect cellFrame;
    cellFrame.origin.x = 0;
    cellFrame.origin.y = 0;
    cellFrame.size.width = bounds.size.width - 10.0;
    cellFrame.size.height = labelHeight;

    NSBezierPath *bezierPath = [[NSBezierPath alloc] init];
    bezierPath.lineWidth = 2.0;
    bezierPath.lineCapStyle = NSSquareLineCapStyle;

    NSPoint point;
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
    for (NSUInteger index = 0; index <= _sectionCount; index++) {
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
        CGFloat axisLabelHeight = ceil([_axisLabelFont boundingRectForFont].size.height);

        NSGraphicsContext *context = [NSGraphicsContext currentContext];
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform translateXBy:axisLabelHeight + 10.0 yBy:0.0];
        [transform rotateByDegrees:90.0];

        NSRange glyphRange  = [_layoutManager glyphRangeForTextContainer:_textContainer];
        NSRect boundingRect = [_layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:_textContainer];

        NSPoint labelPoint;
        labelPoint.x = _yOrigin + (_sectionCount * _sectionHeight - boundingRect.size.width) / 2.0;
        labelPoint.y = 0.0;

        [context saveGraphicsState];
        [transform concat];
        [_layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:labelPoint];
        [context restoreGraphicsState];
    }
}

@end

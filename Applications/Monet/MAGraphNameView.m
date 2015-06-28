//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MAGraphNameView.h"

#import <GnuSpeech/GnuSpeech.h>
#import "MMDisplayParameter.h"

@interface MAGraphNameView ()
@property (strong) NSTextField *nameLabel;
@property (strong) NSTextField *topLabel;
@property (strong) NSTextField *bottomLabel;
@property (strong) NSView *rightLine;
@end

@implementation MAGraphNameView

- (id)initWithFrame:(NSRect)frameRect;
{
    if ((self = [super initWithFrame:frameRect])) {
        [self _commonInit_MAGraphNameView];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)coder;
{
    if ((self = [super initWithCoder:coder])) {
        [self _commonInit_MAGraphNameView];
    }

    return self;
}

- (void)_commonInit_MAGraphNameView;
{
    self.wantsLayer = YES;
    //self.layer.backgroundColor = [[NSColor greenColor] colorWithAlphaComponent:0.2].CGColor;
    //self.layer.borderWidth = 1;

    _nameLabel = [[NSTextField alloc] initWithFrame:CGRectZero];
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _nameLabel.alignment = NSCenterTextAlignment;
    _nameLabel.stringValue = @"fricBW\n(special)";
//    _nameLabel.usesSingleLineMode = NO;
    [_nameLabel setEditable:NO];
    _nameLabel.selectable = YES;
    [_nameLabel setBezeled:NO];
    _nameLabel.drawsBackground = NO;
    [self addSubview:_nameLabel];

    _topLabel = [[NSTextField alloc] initWithFrame:CGRectZero];
    _topLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _topLabel.alignment = NSRightTextAlignment;
    _topLabel.stringValue = @"13";
    _topLabel.font = [NSFont labelFontOfSize:[NSFont smallSystemFontSize]];
//    _topLabel.isEditable = NO;
    [_topLabel setEditable:NO];
    _topLabel.selectable = YES;
    [_topLabel setBezeled:NO];
    _topLabel.drawsBackground = NO;
    [self addSubview:_topLabel];

    _bottomLabel = [[NSTextField alloc] initWithFrame:CGRectZero];
    _bottomLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _bottomLabel.alignment = NSRightTextAlignment;
    _bottomLabel.stringValue = @"0";
    _bottomLabel.font = [NSFont labelFontOfSize:[NSFont smallSystemFontSize]];
    [_bottomLabel setEditable:NO];
    _bottomLabel.selectable = YES;
    [_bottomLabel setBezeled:NO];
    _bottomLabel.drawsBackground = NO;
    [self addSubview:_bottomLabel];

    _rightLine = [[NSView alloc] initWithFrame:CGRectZero];
    _rightLine.translatesAutoresizingMaskIntoConstraints = NO;
    _rightLine.wantsLayer = YES;
    _rightLine.layer.backgroundColor = [NSColor blackColor].CGColor;
    [self addSubview:_rightLine];


    NSDictionary *views = @{
                            @"name"        : _nameLabel,
                            @"topLabel"    : _topLabel,
                            @"bottomLabel" : _bottomLabel,
                            @"rightLine"   : _rightLine,
                            };

    [self addConstraint:[NSLayoutConstraint constraintWithItem:_nameLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0.0]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[name]-|" options:0 metrics:nil views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[topLabel(30)]-(4)-[rightLine(1)]|"    options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topLabel]"     options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[bottomLabel(30)]-(4)-[rightLine]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomLabel]|"  options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[rightLine]|"  options:0 metrics:nil views:views]];
}

#pragma mark -

- (CGSize)intrinsicContentSize;
{
    return CGSizeMake(100, 100);
}

#pragma mark -

- (void)setDisplayParameter:(MMDisplayParameter *)displayParameter;
{
    _displayParameter = displayParameter;
    self.nameLabel.stringValue   = self.displayParameter.label;
    self.topLabel.stringValue    = [NSString stringWithFormat:@"%.0f", self.displayParameter.parameter.maximumValue];
    self.bottomLabel.stringValue = [NSString stringWithFormat:@"%.0f", self.displayParameter.parameter.minimumValue];
}

@end

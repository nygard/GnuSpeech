//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MAGraphNameView.h"

#import <GnuSpeech/GnuSpeech.h>
#import "MMDisplayParameter.h"

@interface MAGraphNameView ()
@property (strong) NSTextField *nameLabel;
@property (strong) NSTextField *topLabel;
@property (strong) NSTextField *bottomLabel;
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
    self.layer.backgroundColor = [[NSColor greenColor] colorWithAlphaComponent:0.2].CGColor;
    self.layer.borderWidth = 1;

    _nameLabel = [[NSTextField alloc] initWithFrame:CGRectZero];
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _nameLabel.stringValue = @"fricBW\n(special)";
//    _nameLabel.usesSingleLineMode = NO;
    [self addSubview:_nameLabel];

    _topLabel = [[NSTextField alloc] initWithFrame:CGRectZero];
    _topLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _topLabel.alignment = NSRightTextAlignment;
    _topLabel.stringValue = @"13";
    [self addSubview:_topLabel];

    _bottomLabel = [[NSTextField alloc] initWithFrame:CGRectZero];
    _bottomLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _bottomLabel.alignment = NSRightTextAlignment;
    _bottomLabel.stringValue = @"0";
    [self addSubview:_bottomLabel];


    NSDictionary *views = @{
                            @"name"        : _nameLabel,
                            @"topLabel"    : _topLabel,
                            @"bottomLabel" : _bottomLabel,
                            };

    [self addConstraint:[NSLayoutConstraint constraintWithItem:_nameLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0.0]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[name]-|" options:0 metrics:nil views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[topLabel(30)]-(8)-|"    options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topLabel]"     options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[bottomLabel(30)]-(8)-|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomLabel]|"  options:0 metrics:nil views:views]];
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

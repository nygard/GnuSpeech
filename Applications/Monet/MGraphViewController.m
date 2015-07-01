//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MGraphViewController.h"

#import <GnuSpeech/GnuSpeech.h>
#import "MMDisplayParameter.h"
#import "MARulePhoneView.h"
#import "MAGraphNameView.h"
#import "MAGraphView.h"

@interface MGraphViewController ()

@property (weak) IBOutlet NSStackView *nameStackView;
@property (weak) IBOutlet NSStackView *graphStackView;
@property (weak) IBOutlet MARulePhoneView *rulePhoneView;

@end

@implementation MGraphViewController

- (id)init;
{
    if ((self = [super initWithWindowNibName:@"GraphView"])) {
        _displayParameters = nil;
        _eventList = nil;
        _scale = 0.5;
    }

    return self;
}

- (void)windowDidLoad;
{
    [super windowDidLoad];

    // I'm going to be lazy, and say you need to set up displayParameters, eventList, and scale before the view is loaded.
    // Although we might just want to reuse this view controller.
    // This'll be a quick'n'dirty bit o' code.

    self.rulePhoneView.scale = self.scale;
    self.rulePhoneView.eventList = self.eventList;

    for (MMDisplayParameter *displayParameter in self.displayParameters) {
        MAGraphNameView *graphNameView = [[MAGraphNameView alloc] initWithFrame:CGRectZero];
        graphNameView.translatesAutoresizingMaskIntoConstraints = NO;
        graphNameView.displayParameter = displayParameter;
        [self.nameStackView addView:graphNameView inGravity:NSStackViewGravityTop];


        MAGraphView *gv1 = [[MAGraphView alloc] initWithFrame:CGRectMake(0, 0, 300, 100)];
        gv1.translatesAutoresizingMaskIntoConstraints = NO;
        gv1.displayParameter = displayParameter;
        gv1.eventList = self.eventList;
        gv1.scale = self.scale;
        [self.graphStackView addView:gv1 inGravity:NSStackViewGravityTop];
    }

    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = [[NSColor greenColor] colorWithAlphaComponent:0.2].CGColor;
}

@end

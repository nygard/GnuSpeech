//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MIntonationController.h"

#import "MAIntonationView.h"

@interface MIntonationController ()
@property (weak) IBOutlet MAIntonationView *intonationView;
@property (weak) IBOutlet NSTextField *semitoneTextField;
@property (weak) IBOutlet NSTextField *hertzTextField;
@property (weak) IBOutlet NSTextField *slopeTextField;
@property (weak) IBOutlet NSTableView *intonationRuleTableView;
@property (weak) IBOutlet NSTextField *beatTextField;
@property (weak) IBOutlet NSTextField *beatOffsetTextField;
@property (weak) IBOutlet NSTextField *absoluteTimeTextField;

@end

@implementation MIntonationController
{
//    NSPrintInfo *_intonationPrintInfo;
}

- (id)init;
{
    if ((self = [super initWithWindowNibName:@"Intonation"])) {
    }

    return self;
}

@end

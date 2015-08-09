//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MIntonationSettingsEditor.h"

// This stores all of the values in user defaults.  It might be better suited as part of a preference panel.
// This currently uses bindings to the shared user defaults controller to load nd save the values.

@implementation MIntonationSettingsEditor

- (id)init;
{
    if ((self = [super initWithWindowNibName:@"IntonationSettings"])) {
    }

    return self;
}

- (IBAction)toneGroupOrManual:(id)sender;
{
    // The value updates are controlled by the user defaults controller.  This method is just used to associate the radio buttons in the same radio group.
}

@end

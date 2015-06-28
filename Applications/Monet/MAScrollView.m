//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MAScrollView.h"

NSString *MAScrollViewNotification_DidChangeScrollerVisibility = @"MAScrollViewNotification_DidChangeScrollerVisibility";

@implementation MAScrollView

- (void)tile;
{
    BOOL horizontalHiddenBefore = self.horizontalScroller.hidden;
    BOOL verticalHiddenBefore   = self.verticalScroller.hidden;

    [super tile];

    BOOL horizontalChanged = horizontalHiddenBefore != self.horizontalScroller.hidden;
    BOOL verticalChanged   = verticalHiddenBefore   != self.verticalScroller.hidden;
    if (horizontalChanged || verticalChanged) {
        // This method gets called a lot, so only post the notification when the scroller visibility has changed.
        //NSLog(@"%s, scroller visibility changed", __PRETTY_FUNCTION__);
        [[NSNotificationCenter defaultCenter] postNotificationName:MAScrollViewNotification_DidChangeScrollerVisibility object:self];
    }
}

@end

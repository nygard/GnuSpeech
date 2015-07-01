//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Cocoa/Cocoa.h>

@class EventList;

@interface MARulePhoneView : NSView

@property (nonatomic, strong) EventList *eventList;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGFloat rightEdgeInset;

@end

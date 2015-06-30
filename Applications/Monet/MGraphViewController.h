//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Cocoa/Cocoa.h>

@class EventList;
@class MMDisplayParameter;

/// This is the view used to generate an image of several graphs.  This name is perhaps misleading.
@interface MGraphViewController : NSViewController

@property (nonatomic, strong) NSArray *displayParameters;
@property (nonatomic, strong) EventList *eventList;
@property (nonatomic, assign) CGFloat scale;

@end

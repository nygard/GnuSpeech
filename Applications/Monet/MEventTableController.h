//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MWindowController.h"

@class EventList;

@interface MEventTableController : MWindowController

@property (nonatomic, strong) EventList *eventList;
@property (nonatomic, strong) NSArray *displayParameters;

@end

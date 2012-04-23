//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

@class EventList, MModel, MMPosture;

@interface MMPostureRewriter : NSObject

- (id)initWithModel:(MModel *)model;

- (void)_setupCategoryNames;
- (void)_setup;

@property (nonatomic, retain) MModel *model;

@property (retain) MMPosture *lastPosture;

- (void)resetState;
- (void)rewriteEventList:(EventList *)eventList withNextPosture:(MMPosture *)nextPosture wordMarker:(BOOL)followsWordMarker;

@end

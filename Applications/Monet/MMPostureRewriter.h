//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>

@class EventList, MModel, MMPosture;

@interface MMPostureRewriter : NSObject
{
    MModel *model;

    NSString *categoryNames[15];
    MMPosture *returnPostures[7];

    int currentState;
    MMPosture *lastPosture;
}

- (id)initWithModel:(MModel *)aModel;
- (void)dealloc;

- (void)_setupCategoryNames;
- (void)_setup;

- (MModel *)model;
- (void)setModel:(MModel *)newModel;

- (MMPosture *)lastPosture;
- (void)setLastPosture:(MMPosture *)newPosture;

- (void)resetState;
- (void)rewriteEventList:(EventList *)eventList withNextPosture:(MMPosture *)nextPosture wordMarker:(BOOL)followsWordMarker;

@end

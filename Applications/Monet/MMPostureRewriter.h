//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>

@class EventList, MModel, MMPosture;

@interface MMPostureRewriter : NSObject
{
    MModel *model;

    NSString *category[15]; // Just the names.  Use -[MMPosture isMemberOfCategoryNamed:]
    MMPosture *returnPostures[7];
    int currentState;
    MMPosture *lastPosture;
}

- (id)initWithModel:(MModel *)aModel;
- (void)dealloc;

- (void)_setup;

- (MModel *)model;
- (void)setModel:(MModel *)newModel;

- (MMPosture *)lastPosture;
- (void)setLastPosture:(MMPosture *)newPosture;

- (void)rewriteEventList:(EventList *)eventList withNextPosture:(MMPosture *)nextPosture wordMarker:(BOOL)followsWordMarker;

@end

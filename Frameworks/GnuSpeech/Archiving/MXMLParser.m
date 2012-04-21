//  This file is part of SNFoundation, a personal collection of Foundation extensions.
//  Copyright (C) 2004-2012 Steve Nygard.  All rights reserved.

#import "MXMLParser.h"

#import "MXMLIgnoreTreeDelegate.h"

@implementation MXMLParser
{
    NSMutableArray *delegateStack;
    id context;
}

- (id)initWithData:(NSData *)data;
{
    if ((self = [super initWithData:data])) {
        delegateStack = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void)dealloc;
{
    [delegateStack release];
    [context release];

    [super dealloc];
}

@synthesize context;

- (void)pushDelegate:(id)newDelegate;
{
    [delegateStack addObject:newDelegate];
    [self setDelegate:newDelegate];
}

- (void)popDelegate;
{
    // TODO (2004-04-21): I'm a little worried about this object retaining the delegate...
    if ([delegateStack count] > 0)
        [delegateStack removeLastObject];

    if ([delegateStack count] > 0)
        [self setDelegate:[delegateStack lastObject]];
    else
        [self setDelegate:nil];
}

- (void)skipTree;
{
    MXMLIgnoreTreeDelegate *ignoreTreeDelegate;

    ignoreTreeDelegate = [[MXMLIgnoreTreeDelegate alloc] init];
    [self pushDelegate:ignoreTreeDelegate];
    [ignoreTreeDelegate release];
}

@end

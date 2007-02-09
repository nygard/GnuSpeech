//  This file is part of SNFoundation, a personal collection of Foundation extensions.
//  Copyright (C) 2004 Steve Nygard.  All rights reserved.

#import "MXMLParser.h"

#import <Foundation/Foundation.h>
#import "MXMLIgnoreTreeDelegate.h"

@implementation MXMLParser

- (id)initWithData:(NSData *)data;
{
    if ([super initWithData:data] == nil)
        return nil;

    delegateStack = [[NSMutableArray alloc] init];

    return self;
}

- (void)dealloc;
{
    [delegateStack release];
    [context release];

    [super dealloc];
}

- (id)context;
{
    return context;
}

- (void)setContext:(id)newContext;
{
    if (newContext == context)
        return;

    [context release];
    context = [newContext retain];
}

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

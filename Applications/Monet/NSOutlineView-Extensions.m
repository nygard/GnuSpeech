//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "NSOutlineView-Extensions.h"

#import <AppKit/AppKit.h>

@implementation NSOutlineView (Extensions)

- (id)selectedItem;
{
    if ([self numberOfSelectedRows] == 1)
        return [self itemAtRow:[self selectedRow]];

    return nil;
}

// TODO (2004-03-21): Move into category of NSOutlineView
- (id)selectedItemOfClass:(Class)aClass;
{
    id selectedItem;

    selectedItem = [self selectedItem];
    if ([selectedItem isKindOfClass:aClass] == YES)
        return selectedItem;

    return nil;
}

@end

//  This file is part of SNFoundation, a personal collection of Foundation extensions.
//  Copyright (C) 2004 Steve Nygard.  All rights reserved.

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

- (void)selectItem:(id)anItem;
{
    if (anItem == nil)
        [self deselectAll:nil];
    else {
        int row;

        row = [self rowForItem:anItem];
        [self selectRow:row byExtendingSelection:NO];
        [self scrollRowToVisible:row];
    }
}

- (void)scrollRowForItemToVisible:(id)anItem;
{
    int row;

    if (anItem == nil)
        return;

    row = [self rowForItem:anItem];
    [self scrollRowToVisible:row];
}

@end

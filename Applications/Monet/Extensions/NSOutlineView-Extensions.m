//  This file is part of SNFoundation, a personal collection of Foundation 
//  extensions. Copyright (C) 2004-2012 Steve Nygard.  All rights reserved.

#import "NSOutlineView-Extensions.h"

@implementation NSOutlineView (Extensions)

- (id)selectedItem;
{
    if ([self numberOfSelectedRows] == 1)
        return [self itemAtRow:[self selectedRow]];

    return nil;
}

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
        [self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
        [self scrollRowToVisible:row];
    }
}

- (void)scrollRowForItemToVisible:(id)anItem;
{
    NSInteger row;

    if (anItem == nil)
        return;

    row = [self rowForItem:anItem];
    [self scrollRowToVisible:row];
}

@end

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
    id selectedItem = [self selectedItem];
    if ([selectedItem isKindOfClass:aClass])
        return selectedItem;

    return nil;
}

- (void)selectItem:(id)item;
{
    if (item == nil)
        [self deselectAll:nil];
    else {
        NSInteger row = [self rowForItem:item];
        [self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
        [self scrollRowToVisible:row];
    }
}

- (void)scrollRowForItemToVisible:(id)item;
{
    if (item == nil)
        return;

    NSInteger row = [self rowForItem:item];
    [self scrollRowToVisible:row];
}

@end

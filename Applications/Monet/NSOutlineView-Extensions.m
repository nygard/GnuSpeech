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

- (void)resizeOutlineColumnToFit;
{
    NSArray *columns;
    int count, index;
    float totalWidth, remainingWidth;
    NSTableColumn *outlineColumn;
    NSRect bounds;

    NSLog(@" > %s", _cmd);

    bounds = [self bounds];
    NSLog(@"bounds: %@", NSStringFromRect(bounds));
    NSLog(@"visibleRect: %@", NSStringFromRect([self visibleRect]));

    columns = [self tableColumns];
    outlineColumn = [self outlineTableColumn];

    totalWidth = 0;
    count = [columns count];
    for (index = 0; index < count; index++) {
        NSTableColumn *aColumn;

        aColumn = [columns objectAtIndex:index];
        totalWidth += [aColumn width];
    }

    NSLog(@"totalWidth: %f", totalWidth);
    NSLog(@"[outlineColumn width]: %f", [outlineColumn width]);
    totalWidth -= [outlineColumn width];
    NSLog(@"width without outline column: %f", totalWidth);

    remainingWidth = bounds.size.width - totalWidth;
    NSLog(@"remainingWidth: %f", remainingWidth);

    if (remainingWidth < [outlineColumn minWidth])
        remainingWidth = [outlineColumn minWidth];

    if (remainingWidth > [outlineColumn maxWidth])
        remainingWidth = [outlineColumn maxWidth];

    NSLog(@"adjusted remainingWidth: %f", remainingWidth);

    [outlineColumn setWidth:remainingWidth];
    [self sizeToFit];
    [self setNeedsDisplay:YES];

    NSLog(@"<  %s", _cmd);
}

@end

//  This file is part of SNFoundation, a personal collection of Foundation 
//  extensions. Copyright (C) 2004-2012 Steve Nygard.  All rights reserved.

#import <Cocoa/Cocoa.h>

@interface NSOutlineView (Extensions)

- (id)selectedItem;
- (id)selectedItemOfClass:(Class)aClass;

- (void)selectItem:(id)item;
- (void)scrollRowForItemToVisible:(id)item;

@end

//
// $Id: NSOutlineView-Extensions.h,v 1.3 2004/03/24 19:43:35 nygard Exp $
//

//  This file is part of SNFoundation, a personal collection of Foundation extensions.
//  Copyright (C) 2004 Steve Nygard.  All rights reserved.

#import <AppKit/NSOutlineView.h>

@interface NSOutlineView (Extensions)

- (id)selectedItem;
- (id)selectedItemOfClass:(Class)aClass;

- (void)selectItem:(id)anItem;
- (void)scrollRowForItemToVisible:(id)anItem;

- (void)resizeOutlineColumnToFit;

@end

//
// $Id: NSOutlineView-Extensions.h,v 1.2 2004/03/23 06:23:04 nygard Exp $
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <AppKit/NSOutlineView.h>

@interface NSOutlineView (Extensions)

- (id)selectedItem;
- (id)selectedItemOfClass:(Class)aClass;

- (void)resizeOutlineColumnToFit;

@end

//
// $Id: MCommentCell.h,v 1.1 2004/03/19 04:18:23 nygard Exp $
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <AppKit/NSImageCell.h>

@interface MCommentCell : NSImageCell
{
}

+ (void)initialize;

//- (void)setObjectValue:(id)newObjectValue;

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;

@end

//
// $Id: MUnarchiver.h,v 1.1 2004/03/18 23:43:55 nygard Exp $
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSArchiver.h>

@interface MUnarchiver : NSUnarchiver
{
    id userInfo;
}

- (void)dealloc;

- (id)userInfo;
- (void)setUserInfo:(id)newUserInfo;

@end

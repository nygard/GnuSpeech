//
// $Id: AppController.h,v 1.1 2004/03/04 20:38:03 nygard Exp $
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>

@interface AppController : NSObject
{
}

- (id)init;
- (void)applicationDidFinishLaunching:(NSNotification *)aNotificatin;

- (void)setObject:(id)object forKey:(id)key;
- (id)objectForKey:(id)key;
- (void)removeObjectForKey:(id)key;

@end

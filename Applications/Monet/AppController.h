//
// $Id: AppController.h,v 1.2 2004/03/04 22:01:42 nygard Exp $
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>

@class NSMutableDictionary;
@class SymbolList;

@interface AppController : NSObject
{
    NSMutableDictionary *namedObjects;

    SymbolList *mainSymbolList;
}

- (id)init;
- (void)dealloc;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotificatin;

- (void)setObject:(id)object forKey:(id)key;
- (id)objectForKey:(id)key;
- (void)removeObjectForKey:(id)key;

@end

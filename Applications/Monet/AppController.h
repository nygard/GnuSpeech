//
// $Id: AppController.h,v 1.3 2004/03/05 02:55:25 nygard Exp $
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class NSMutableDictionary;
@class SymbolList;
@class PrototypeManager;

@interface AppController : NSObject
{
    NSMutableDictionary *namedObjects;

    SymbolList *mainSymbolList;

    IBOutlet PrototypeManager *prototypeManager;
}

- (id)init;
- (void)dealloc;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;

- (void)setObject:(id)object forKey:(id)key;
- (id)objectForKey:(id)key;
- (void)removeObjectForKey:(id)key;

@end

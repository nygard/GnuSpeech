//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "AppController.h"

#import <Foundation/Foundation.h>
#import "MyController.h"
#import "NamedList.h"
#import "PrototypeManager.h"
#import "SymbolList.h"

@implementation AppController

- (id)init;
{
    if ([super init] == nil)
        return nil;

    namedObjects = [[NSMutableDictionary alloc] init];

    mainSymbolList = [[SymbolList alloc] initWithCapacity:15];
    [mainSymbolList addNewValue:@"duration"];

    return self;
}

- (void)dealloc;
{
    [namedObjects release];
    [mainSymbolList release];

    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
{
    NSString *path;
    NSArchiver *stream;

    NSLog(@"[NSApp delegate]: %@", [NSApp delegate]);
    NXNameObject(@"mainSymbolList", mainSymbolList, NSApp);
    NSLog(@"getting it by name: %@", NXGetNamedObject(@"mainSymbolList", NSApp));

    NXNameObject(@"prototypeManager", prototypeManager, NSApp);

    //NSLog(@" > %s", _cmd);

    [prototypeManager applicationDidFinishLaunching:aNotification];


    //NSLog(@"decode List as %@", [NSUnarchiver classNameDecodedForArchiveClassName:@"List"]);
    //NSLog(@"decode Object as %@", [NSUnarchiver classNameDecodedForArchiveClassName:@"Object"]);

    [NSUnarchiver decodeClassName:@"Object" asClassName:@"NSObject"];
    [NSUnarchiver decodeClassName:@"List" asClassName:@"MonetList"];
    [NSUnarchiver decodeClassName:@"Point" asClassName:@"GSMPoint"];

    {
        NamedList *aList;
        NSData *data;
        NSMutableData *mdata;
        NSKeyedArchiver *archiver;

        aList = [[NamedList alloc] init];

        data = [NSArchiver archivedDataWithRootObject:aList];
        [data writeToFile:@"/tmp/test1" atomically:YES];

        data = [NSKeyedArchiver archivedDataWithRootObject:aList];
        [data writeToFile:@"/tmp/test2" atomically:YES];

        mdata = [[NSMutableData alloc] init];
        archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:mdata];
        [archiver setOutputFormat:NSPropertyListXMLFormat_v1_0];
        [archiver encodeObject:aList forKey:@"theRoot"];
        [archiver finishEncoding];
        [mdata writeToFile:@"/tmp/test3" atomically:YES];
        [archiver release];
        [mdata release];

        [aList release];
    }

    path = [[NSBundle mainBundle] pathForResource:@"DefaultPrototypes" ofType:nil];
    //NSLog(@"path: %@", path);

    // Archiver hack for Mac OS X 10.3.  Use nm to find location of archiverDebug, and hope that Foundation doesn't get relocated somewhere else!
#if 0
    {
        char *archiverDebug = (char *)0xa09faf18;
        char *NSDebugEnabled = (char *)0xa09f0338;
        //NSLog(@"archiverDebug: %d", *archiverDebug);
#if 1
        if (*archiverDebug == 0)
            *archiverDebug = 1;
#else
        *NSDebugEnabled = 1;
#endif
    }
#endif

    stream = [[NSUnarchiver alloc] initForReadingWithData:[NSData dataWithContentsOfFile:path]];
    //NSLog(@"stream: %x", stream);
    if (stream) {
        NSLog(@"systemVersion: %u", [stream systemVersion]);

        NS_DURING {
            [prototypeManager readPrototypesFrom:stream];
        } NS_HANDLER {
            NSLog(@"localException: %@", localException);
            NSLog(@"name: %@", [localException name]);
            NSLog(@"reason: %@", [localException reason]);
            NSLog(@"useInfo: %@", [[localException userInfo] description]);
            return;
        } NS_ENDHANDLER;

        [stream release];
    }

    NSLog(@"<  %s", _cmd);
}

- (void)setObject:(id)object forKey:(id)key;
{
    //NSLog(@" > %s", _cmd);
    //NSLog(@"key: %@, object: (%p)%@", key, object, object);
    [namedObjects setObject:object forKey:key];
    //NSLog(@"<  %s", _cmd);
}

- (id)objectForKey:(id)key;
{
    //NSLog(@"-> %s, key: %@, r: %@(%p)", _cmd, key, [namedObjects objectForKey:key], [namedObjects objectForKey:key]);
    return [namedObjects objectForKey:key];
}

- (void)removeObjectForKey:(id)key;
{
    //NSLog(@" > %s", _cmd);
    [namedObjects removeObjectForKey:key];
    //NSLog(@"<  %s", _cmd);
}

@end

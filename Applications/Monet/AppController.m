//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "AppController.h"

#import <Foundation/Foundation.h>
#import "NamedList.h"
#import "PrototypeManager.h"

@implementation AppController

- (id)init;
{
    if ([super init] == nil)
        return nil;

    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotificatin;
{
    NSString *path;
    NSArchiver *stream;

    //NSLog(@" > %s", _cmd);

    //NSLog(@"decode List as %@", [NSUnarchiver classNameDecodedForArchiveClassName:@"List"]);
    //NSLog(@"decode Object as %@", [NSUnarchiver classNameDecodedForArchiveClassName:@"Object"]);
#if 1
    [NSUnarchiver decodeClassName:@"Object" asClassName:@"NSObject"];
    //[NSUnarchiver decodeClassName:@"List" asClassName:@"MyList"];
    [NSUnarchiver decodeClassName:@"List" asClassName:@"MonetList"];
#endif

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

    // Archiver hack
#if 0
    {
        char *archiverDebug = (char *)0xa09faf18;

        //NSLog(@"archiverDebug: %d", *archiverDebug);
        if (*archiverDebug == 0)
            *archiverDebug = 1;
    }
#endif

    stream = [[NSUnarchiver alloc] initForReadingWithData:[NSData dataWithContentsOfFile:path]];
    //NSLog(@"stream: %x", stream);
    if (stream) {
        PrototypeManager *aPrototypeManager;

        NSLog(@"systemVersion: %u", [stream systemVersion]);
        aPrototypeManager = [[PrototypeManager alloc] init];

        NS_DURING {
            [aPrototypeManager readPrototypesFrom:stream];
        } NS_HANDLER {
            NSLog(@"localException: %@", localException);
            NSLog(@"name: %@", [localException name]);
            NSLog(@"reason: %@", [localException reason]);
            NSLog(@"useInfo: %@", [[localException userInfo] description]);
            return;
        } NS_ENDHANDLER;

        //[aPrototypeManager release];
        [stream release];
    }

    NSLog(@"<  %s", _cmd);
}

- (void)setObject:(id)object forKey:(id)key;
{
}

- (id)objectForKey:(id)key;
{
    return nil;
}

- (void)removeObjectForKey:(id)key;
{
}

@end

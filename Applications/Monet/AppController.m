//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "AppController.h"

#import <Foundation/Foundation.h>
#import "BrowserManager.h"
#import "CategoryNode.h"
#import "CategoryList.h"
#import "EventListView.h"
#import "IntonationView.h"
#import "MyController.h"
#import "NamedList.h"
#import "PrototypeManager.h"
#import "RuleManager.h"
#import "StringParser.h"
#import "SymbolList.h"
#import "TransitionView.h"

@implementation AppController

- (id)init;
{
    if ([super init] == nil)
        return nil;

    namedObjects = [[NSMutableDictionary alloc] init];

    mainPhoneList = [[PhoneList alloc] initWithCapacity:15];
    mainCategoryList = [[CategoryList alloc] initWithCapacity:15];
    mainSymbolList = [[SymbolList alloc] initWithCapacity:15];
    mainParameterList = [[ParameterList alloc] initWithCapacity:15];
    mainMetaParameterList = [[ParameterList alloc] initWithCapacity:15];

    [mainSymbolList addNewValue:@"duration"];

    [[mainCategoryList addCategory:@"phone"] setComment:@"This is the static phone category.  It cannot be changed or removed"];

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

    NSLog(@"<%@>[%p]  > %s", NSStringFromClass([self class]), self, _cmd);

    NSLog(@"[NSApp delegate]: %@", [NSApp delegate]);

    // Name them here to make sure all the outlets have been connected
    NXNameObject(@"mainPhoneList", mainPhoneList, NSApp);
    NXNameObject(@"mainCategoryList", mainCategoryList, NSApp);
    NXNameObject(@"mainSymbolList", mainSymbolList, NSApp);
    NXNameObject(@"mainParameterList", mainParameterList, NSApp);
    NXNameObject(@"mainMetaParameterList", mainMetaParameterList, NSApp);

    NXNameObject(@"ruleManager", ruleManager, NSApp);
    NXNameObject(@"prototypeManager", prototypeManager, NSApp);
    NXNameObject(@"transitionBuilder", transitionBuilder, NSApp);
    NXNameObject(@"specialTransitionBuilder", specialTransitionBuilder, NSApp);
    NXNameObject(@"intonationView", intonationView, NSApp);
    NXNameObject(@"stringParser", stringParser, NSApp);

    NXNameObject(@"defaultManager", defaultManager, NSApp);

    NSLog(@"getting it by name: %@", NXGetNamedObject(@"mainSymbolList", NSApp));

    [dataBrowser applicationDidFinishLaunching:aNotification];
    //if (inspectorController)
    //    [inspectorController applicationDidFinishLaunching:aNotification];

    [prototypeManager applicationDidFinishLaunching:aNotification];

    //NSLog(@"decode List as %@", [NSUnarchiver classNameDecodedForArchiveClassName:@"List"]);
    //NSLog(@"decode Object as %@", [NSUnarchiver classNameDecodedForArchiveClassName:@"Object"]);

    [NSUnarchiver decodeClassName:@"Object" asClassName:@"NSObject"];
    [NSUnarchiver decodeClassName:@"List" asClassName:@"MonetList"];
    [NSUnarchiver decodeClassName:@"Point" asClassName:@"GSMPoint"];

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

    [ruleManager applicationDidFinishLaunching:aNotification];
    [transitionBuilder applicationDidFinishLaunching:aNotification]; // not connected yet
    [specialTransitionBuilder applicationDidFinishLaunching:aNotification]; // not connected yet
    [eventListView applicationDidFinishLaunching:aNotification]; // not connected yet
    [intonationView applicationDidFinishLaunching:aNotification]; // not connected yet

    [stringParser applicationDidFinishLaunching:aNotification]; // not connected yet

    [transitionWindow setFrameAutosaveName:@"TransitionWindow"];
    [ruleManagerWindow setFrameAutosaveName:@"RuleManagerWindow"];
    [phonesWindow setFrameAutosaveName:@"DataEntryWindow"];
    [ruleParserWindow setFrameAutosaveName:@"RuleParserWindow"];
    [prototypeWindow setFrameAutosaveName:@"PrototypeManagerWindow"];
    [synthesisWindow setFrameAutosaveName:@"SynthesisWindow"];
    [specialWindow setFrameAutosaveName:@"SpecialTransitionWindow"];
    [synthParmWindow setFrameAutosaveName:@"SynthParameterWindow"];

    NSLog(@"<%@>[%p] <  %s", NSStringFromClass([self class]), self, _cmd);
}

- (void)setObject:(id)object forKey:(id)key;
{
    //NSLog(@" > %s", _cmd);
    //NSLog(@"key: %@, object: (%p)%@", key, object, object);
    if (object == nil) {
        NSLog(@"Error: object for key %@ is nil!", key);
        return;
    }
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

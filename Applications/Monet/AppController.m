//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "AppController.h"

#import <Foundation/Foundation.h>
#import "BrowserManager.h"
#import "CategoryNode.h"
#import "CategoryList.h"
#import "EventListView.h"
#import "Inspector.h"
#import "IntonationView.h"
#import "NamedList.h"
#import "ParameterList.h"
#import "PhoneList.h"
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

#ifdef HAVE_DSP
    initialize_synthesizer_module();
#endif
    //initStringParser();

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

    [stringParser applicationDidFinishLaunching:aNotification];

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


- (void)displayInfoPanel:(id)sender;
{
    if (infoPanel == nil) {
        [NSBundle loadNibNamed:@"Info.nib" owner:self];
    }

    [infoPanel makeKeyAndOrderFront:self];
}

- (void)displayInspectorWindow:(id)sender;
{
    if (inspectorController == nil) {
        [NSBundle loadNibNamed:@"Inspector.nib" owner:self];
        [inspectorController applicationDidFinishLaunching:sender];
    }

    [[inspectorController window] makeKeyAndOrderFront:self];
}

- inspector;
{
    return inspectorController;
}


// Open a .degas file.
- (void)openFile:(id)sender;
{
#ifdef PORTING
    int i, count;
    NSArray *types;
    NSArray *fnames;
    NSString *directory;
    char buf[1024+1];
    FILE *fp;
    unsigned int magic;

    types = [NSArray arrayWithObject: @"degas"];
    [[NSOpenPanel openPanel] setAllowsMultipleSelection:NO];
    if ([[NSOpenPanel openPanel] runModalForTypes:types]) {
        fnames = [[NSOpenPanel openPanel] filenames];
        directory = [[NSOpenPanel openPanel] directory];
        count = [fnames count];
        for (i = 0; i < count; i++) {
            strcpy(buf, [directory cString]);
            strcat(buf, "/");
            strcat(buf, [[fnames objectAtIndex: i] cString]);

            fp = fopen(buf, "r");

            fread(&magic, sizeof(int), 1, fp);
            if (magic == 0x2e646567) {
                NSLog(@"Loading DEGAS File");
                [mainParameterList readDegasFileFormat:fp];
                [mainCategoryList readDegasFileFormat:fp];
                [mainPhoneList readDegasFileFormat:fp];
                [ruleManager readDegasFileFormat:fp];
                [dataBrowser updateBrowser];
            } else {
                NSLog(@"Not a DEGAS file");
            }

            fclose(fp);
        }
    }
#endif
}

- (void)importTRMData:(id)sender;
{
    [mainPhoneList importTRMData:sender];
}

- (void)printData:(id)sender;
{
    const char *temp;
    NSSavePanel *myPanel;
    FILE *fp;

    myPanel = [NSSavePanel savePanel];
    if ([myPanel runModal]) {
        temp = [[myPanel filename] cString];
        fp = fopen(temp,"w");
        if (fp) {
            [mainCategoryList printDataTo:fp];
            [mainParameterList printDataTo:fp];
            [mainSymbolList printDataTo:fp];
            [mainPhoneList printDataTo:fp];
            fclose(fp);
        }
    }
}

- (void)archiveToDisk:(id)sender;
{
    NSMutableData *mdata;
    NSSavePanel *myPanel;
    NSArchiver *stream;

    myPanel = [NSSavePanel savePanel];
    if ([myPanel runModal]) {
        NSLog(@"filename: %@", [myPanel filename]);

        mdata = [NSMutableData dataWithCapacity:16];
        stream = [[NSArchiver alloc] initForWritingWithMutableData:mdata];

        if (stream) {
            [stream setObjectZone:[self zone]];
            [stream encodeRootObject:mainCategoryList];
            [stream encodeRootObject:mainSymbolList];
            [stream encodeRootObject:mainParameterList];
            [stream encodeRootObject:mainMetaParameterList];
            [stream encodeRootObject:mainPhoneList];
            [prototypeManager writePrototypesTo:stream];
            [ruleManager writeRulesTo:stream];
            [mdata writeToFile:[myPanel filename] atomically:NO];
            [stream release];
        } else {
            NSLog(@"Not a MONET file");
        }
    }
}

// Open a .monet file.
- (void)readFromDisk:(id)sender;
{
    int i, count;
    NSArray *types;
    NSArray *fnames;
    NSString *filename;
    NSArchiver *stream;
    NSOpenPanel *openPanel;

    NSLog(@" > %s", _cmd);

    types = [NSArray arrayWithObject:@"monet"];
    openPanel = [NSOpenPanel openPanel]; // Each call resets values, including filenames
    [openPanel setAllowsMultipleSelection:NO];

    if ([openPanel runModalForTypes:types] == NSOKButton) {
        fnames = [openPanel filenames];
        NSLog(@"fnames: %@", [fnames description]);
        count = [fnames count];
        NSLog(@"count: %d", count);
        for (i = 0; i < count; i++) {
            filename = [fnames objectAtIndex:i];
            NSLog(@"filename: %@", filename);
            stream = [[NSUnarchiver alloc] initForReadingWithData:[NSData dataWithContentsOfFile:filename]];
            NSLog(@"stream: %p", stream);

            if (stream) {
                NXUnnameObject(@"mainCategoryList", NSApp);
                NXUnnameObject(@"mainSymbolList", NSApp);
                NXUnnameObject(@"mainParameterList", NSApp);
                NXUnnameObject(@"mainMetaParameterList", NSApp);
                NXUnnameObject(@"mainPhoneList", NSApp);

                [mainPhoneList release];
                [mainCategoryList release];
                [mainSymbolList release];
                [mainParameterList release];
                [mainMetaParameterList release];

                /* Category list must be named immediately */
                mainCategoryList = [[stream decodeObject] retain];
                NSLog(@"mainCategoryList: %@", mainCategoryList);
                NXNameObject(@"mainCategoryList", mainCategoryList, NSApp);

                mainSymbolList = [[stream decodeObject] retain];
                NSLog(@"mainSymbolList: %@", mainSymbolList);
#ifdef PORTING
                mainParameterList = [[stream decodeObject] retain];
                mainMetaParameterList = [[stream decodeObject] retain];
                mainPhoneList = [[stream decodeObject] retain];

                NXNameObject(@"mainSymbolList", mainSymbolList, NSApp);
                NXNameObject(@"mainParameterList", mainParameterList, NSApp);
                NXNameObject(@"mainMetaParameterList", mainMetaParameterList, NSApp);
                NXNameObject(@"mainPhoneList", mainPhoneList, NSApp);

                [prototypeManager readPrototypesFrom:stream];
                [ruleManager readRulesFrom:stream];

                [dataBrowser updateLists];

                [dataBrowser updateBrowser];
                [transitionBuilder applicationDidFinishLaunching:nil];
                [specialTransitionBuilder applicationDidFinishLaunching:nil];

                [stream release];
                initStringParser();
#endif
            } else {
                NSLog(@"Not a MONET file");
            }
        }
    }

    NSLog(@"<  %s", _cmd);
}

- (void)savePrototypes:(id)sender;
{
    NSSavePanel *myPanel;
    NSArchiver *stream;
    NSMutableData *mdata;

    myPanel = [NSSavePanel savePanel];
    if ([myPanel runModal]) {
        mdata = [NSMutableData dataWithCapacity:16];
        stream = [[NSArchiver alloc] initForWritingWithMutableData:mdata];

        if (stream) {
            [prototypeManager writePrototypesTo:stream];
            [mdata writeToFile:[myPanel filename] atomically:NO];
            [stream release];
        } else {
            NSLog(@"Not a MONET file");
        }
    }
}

- (void)loadPrototypes:(id)sender;
{
    NSArray *fnames;
    NSArray *types;
    NSString *directory;
    NSArchiver *stream;
    NSString *filename;

    types = [NSArray array];
    [[NSOpenPanel openPanel] setAllowsMultipleSelection:NO];
    if ([[NSOpenPanel openPanel] runModalForTypes:types]) {
        fnames = [[NSOpenPanel openPanel] filenames];
        directory = [[NSOpenPanel openPanel] directory];
        filename = [directory stringByAppendingPathComponent:[fnames objectAtIndex:0]];

        stream = [[NSUnarchiver alloc] initForReadingWithData:[NSData dataWithContentsOfFile:filename]];

        if (stream) {
            [prototypeManager readPrototypesFrom:stream];
            [stream release];
        } else {
            NSLog(@"Not a MONET file");
        }
    }
}

- (void)addCategory;
{
}

- (void)addParameter;
{
    [(PhoneList *)mainPhoneList addParameter];
    [(RuleManager *)ruleManager addParameter];
}

- (void)addMetaParameter;
{
    [(PhoneList *)mainPhoneList addMetaParameter];
    [(RuleManager *)ruleManager addMetaParameter];
}

- (void)addSymbol;
{
    [(PhoneList *)mainPhoneList addSymbol];
}

- (int)removeCategory:(int)index;
{
    return 0;
}

- (void)removeParameter:(int)index;
{
    [(PhoneList *)mainPhoneList removeParameter:index];
    [(RuleManager *)ruleManager removeParameter:index];
}

- (void)removeMetaParameter:(int)index;
{
    [(PhoneList *)mainPhoneList removeMetaParameter:index];
    [(RuleManager *)ruleManager removeMetaParameter:index];
}

- (void)removeSymbol:(int)index;
{
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

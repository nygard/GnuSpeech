//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "AppController.h"

#import <Foundation/Foundation.h>
#import "BrowserManager.h"
#import "CategoryNode.h"
#import "CategoryList.h"
#import "EventListView.h"
#import "GSXMLFunctions.h"
#import "Inspector.h"
#import "IntonationScrollView.h"
#import "NamedList.h"
#import "ParameterList.h"
#import "PhoneList.h"
#import "PrototypeManager.h"
#import "RuleManager.h"
#import "SpecialView.h"
#import "StringParser.h"
#import "SymbolList.h"
#import "TransitionView.h"

#import "MModel.h"
#import "MUnarchiver.h"

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

    model = [[MModel alloc] init];

    return self;
}

- (void)dealloc;
{
    [namedObjects release];
    [model release];

    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
{
    NSString *path;
    NSArchiver *stream;

    NSLog(@"<%@>[%p]  > %s", NSStringFromClass([self class]), self, _cmd);

    //NSLog(@"[NSApp delegate]: %@", [NSApp delegate]);

    // Name them here to make sure all the outlets have been connected
    NXNameObject(@"mainPhoneList", [model phones], NSApp);
    NXNameObject(@"mainCategoryList", [model categories], NSApp);
    NXNameObject(@"mainSymbolList", [model symbols], NSApp);
    NXNameObject(@"mainParameterList", [model parameters], NSApp);
    NXNameObject(@"mainMetaParameterList", [model metaParameters], NSApp);

    NXNameObject(@"ruleManager", ruleManager, NSApp);
    NXNameObject(@"prototypeManager", prototypeManager, NSApp);
    NXNameObject(@"transitionBuilder", transitionBuilder, NSApp);
    NXNameObject(@"specialTransitionBuilder", specialTransitionBuilder, NSApp);
    NXNameObject(@"intonationView", intonationView, NSApp);
    NXNameObject(@"stringParser", stringParser, NSApp);

    NXNameObject(@"defaultManager", defaultManager, NSApp);

    //NSLog(@"getting it by name: %@", NXGetNamedObject(@"mainSymbolList", NSApp));

    [dataBrowser applicationDidFinishLaunching:aNotification];
    if (inspectorController)
        [inspectorController applicationDidFinishLaunching:aNotification];

    [prototypeManager applicationDidFinishLaunching:aNotification];

    //NSLog(@"decode List as %@", [NSUnarchiver classNameDecodedForArchiveClassName:@"List"]);
    //NSLog(@"decode Object as %@", [NSUnarchiver classNameDecodedForArchiveClassName:@"Object"]);

    [NSUnarchiver decodeClassName:@"Object" asClassName:@"NSObject"];
    [NSUnarchiver decodeClassName:@"List" asClassName:@"MonetList"];
    [NSUnarchiver decodeClassName:@"Point" asClassName:@"MMPoint"];

    [self _disableUnconvertedClassLoading];

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

    stream = [[MUnarchiver alloc] initForReadingWithData:[NSData dataWithContentsOfFile:path]];
    //NSLog(@"stream: %x", stream);
    if (stream) {
        NSLog(@"systemVersion: %u", [stream systemVersion]);

        NS_DURING {
            [model readPrototypes:stream];
        } NS_HANDLER {
            NSLog(@"localException: %@", localException);
            NSLog(@"name: %@", [localException name]);
            NSLog(@"reason: %@", [localException reason]);
            NSLog(@"useInfo: %@", [[localException userInfo] description]);
            return;
        } NS_ENDHANDLER;

        [stream release];
    }

    //[model generateXML:@"DefaultPrototypes"];

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

- (Inspector *)inspector;
{
    return inspectorController;
}


// Open a .degas file.
- (void)openFile:(id)sender;
{
    int i, count;
    NSArray *types;
    NSArray *fnames;
    FILE *fp;
    unsigned int magic;
    NSOpenPanel *openPanel;

    types = [NSArray arrayWithObject: @"degas"];
    openPanel = [NSOpenPanel openPanel]; // Each call resets values, including filenames
    [openPanel setAllowsMultipleSelection:NO];
    if ([openPanel runModalForTypes:types]) {
        fnames = [openPanel filenames];
        count = [fnames count];
        for (i = 0; i < count; i++) {
            fp = fopen([[fnames objectAtIndex:i] UTF8String], "r");

            fread(&magic, sizeof(int), 1, fp);
            if (magic == 0x2e646567) {
                NSLog(@"Loading DEGAS File");
                [[model parameters] readDegasFileFormat:fp];
                [[model categories] readDegasFileFormat:fp];
                [[model phones] readDegasFileFormat:fp];
                [ruleManager readDegasFileFormat:fp];
                [dataBrowser updateBrowser];
            } else {
                NSLog(@"Not a DEGAS file");
            }

            fclose(fp);
        }
    }
}

- (void)importTRMData:(id)sender;
{
    [[model phones] importTRMData:sender];
}

- (void)printData:(id)sender;
{
    const char *temp;
    NSSavePanel *myPanel;
    FILE *fp;

    myPanel = [NSSavePanel savePanel];
    if ([myPanel runModal]) {
        temp = [[myPanel filename] UTF8String];
        fp = fopen(temp,"w");
        if (fp) {
            [[model categories] printDataTo:fp];
            [[model parameters] printDataTo:fp];
            [[model symbols] printDataTo:fp];
            [[model phones] printDataTo:fp];
            fclose(fp);
        }
    }
}

- (void)archiveToDisk:(id)sender;
{
#ifdef PORTING
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
#endif
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
        //NSLog(@"fnames: %@", [fnames description]);
        count = [fnames count];
        //NSLog(@"count: %d", count);
        for (i = 0; i < count; i++) {
            filename = [fnames objectAtIndex:i];
            //NSLog(@"filename: %@", filename);
            stream = [[MUnarchiver alloc] initForReadingWithData:[NSData dataWithContentsOfFile:filename]];
            //NSLog(@"stream: %p", stream);

            if (stream) {
                NXUnnameObject(@"mainCategoryList", NSApp);
                NXUnnameObject(@"mainSymbolList", NSApp);
                NXUnnameObject(@"mainParameterList", NSApp);
                NXUnnameObject(@"mainMetaParameterList", NSApp);
                NXUnnameObject(@"mainPhoneList", NSApp);

                [model release];
                model = [[MModel alloc] initWithCoder:stream];

                [prototypeManager setModel:model];
                [ruleManager setModel:model];

                [dataBrowser updateLists];
                [dataBrowser updateBrowser];

                [transitionBuilder applicationDidFinishLaunching:nil];
                [specialTransitionBuilder applicationDidFinishLaunching:nil];

                [stream release];
#ifdef PORTING
                initStringParser();
#endif

                [model generateXML:filename];
            } else {
                NSLog(@"Not a MONET file");
            }
        }
    }

    NSLog(@"<  %s", _cmd);
}

- (void)savePrototypes:(id)sender;
{
#ifdef PORTING
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
#endif
}

- (void)loadPrototypes:(id)sender;
{
#ifdef PORTING
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
#endif
}

- (void)addCategory;
{
}

- (void)addParameter;
{
    [[model phones] addParameter];
    [(RuleManager *)ruleManager addParameter];
}

- (void)addMetaParameter;
{
    [[model phones] addMetaParameter];
    [(RuleManager *)ruleManager addMetaParameter];
}

- (void)addSymbol;
{
    [[model phones] addSymbol];
}

- (int)removeCategory:(int)index;
{
    return 0;
}

- (void)removeParameter:(int)index;
{
    [[model phones] removeParameter:index];
    [(RuleManager *)ruleManager removeParameter:index];
}

- (void)removeMetaParameter:(int)index;
{
    [[model phones] removeMetaParameter:index];
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

// Converted classes:
// CategoryNode, FormulaExpression, FormulaTerminal, MonetList, NamedList, Parameter, Phone, Point, ProtoEquation, ProtoTemplte, Rule, Symbol, Target
// BooleanExpression, BooleanTerminal, Slope, SlopeRatio

- (void)_disableUnconvertedClassLoading;
{
    NSString *names[] = { @"IntonationPoint", @"RuleManager", nil };
    int index = 0;

    while (names[index] != nil) {
        [NSUnarchiver decodeClassName:names[index] asClassName:[NSString stringWithFormat:@"%@_NOT_CONVERTED", names[index]]];
        index++;
    }
}

@end

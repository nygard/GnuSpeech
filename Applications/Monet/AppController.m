//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "AppController.h"

#import <Foundation/Foundation.h>
#import "MMCategory.h"
#import "CategoryList.h"
#import "EventListView.h"
#import "GSXMLFunctions.h"
#import "Inspector.h"
#import "IntonationScrollView.h"
#import "NamedList.h"
#import "ParameterList.h"
#import "PhoneList.h"
#import "PrototypeManager.h"
#import "StringParser.h"
#import "SymbolList.h"
#import "TargetList.h"
#import "TRMData.h"

#import "MModel.h"
#import "MUnarchiver.h"

#import "MDataEntryController.h"
#import "MMPosture.h"
#import "MMTarget.h"
#import "MPostureEditor.h"
#import "MPrototypeManager.h"
#import "MRuleManager.h"
#import "MRuleTester.h"
#import "MSpecialTransitionEditor.h"
#import "MTransitionEditor.h"

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

    [dataEntryController release];
    [postureEditor release];
    [newPrototypeManager release];
    [transitionEditor release];
    [specialTransitionEditor release];

    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
{
    NSString *path;
    NSArchiver *stream;

    NSLog(@"<%@>[%p]  > %s", NSStringFromClass([self class]), self, _cmd);

    //NSLog(@"[NSApp delegate]: %@", [NSApp delegate]);

    // Name them here to make sure all the outlets have been connected
    NXNameObject(@"mainCategoryList", [model categories], NSApp);
    NXNameObject(@"mainParameterList", [model parameters], NSApp);
    NXNameObject(@"mainMetaParameterList", [model metaParameters], NSApp);
    NXNameObject(@"mainSymbolList", [model symbols], NSApp);
    NXNameObject(@"mainPhoneList", [model postures], NSApp);
    NXNameObject(@"rules", [model rules], NSApp);

    NXNameObject(@"prototypeManager", prototypeManager, NSApp);
    NXNameObject(@"intonationView", intonationView, NSApp);
    NXNameObject(@"stringParser", stringParser, NSApp);

    NXNameObject(@"defaultManager", defaultManager, NSApp);


    //NSLog(@"getting it by name: %@", NXGetNamedObject(@"mainSymbolList", NSApp));

    if (inspectorController)
        [inspectorController applicationDidFinishLaunching:aNotification];

    //NSLog(@"decode List as %@", [NSUnarchiver classNameDecodedForArchiveClassName:@"List"]);
    //NSLog(@"decode Object as %@", [NSUnarchiver classNameDecodedForArchiveClassName:@"Object"]);

    [NSUnarchiver decodeClassName:@"Object" asClassName:@"NSObject"];
    [NSUnarchiver decodeClassName:@"List" asClassName:@"MonetList"];

    [NSUnarchiver decodeClassName:@"CategoryNode" asClassName:@"MMCategory"];
    [NSUnarchiver decodeClassName:@"Parameter" asClassName:@"MMParameter"];
    [NSUnarchiver decodeClassName:@"Phone" asClassName:@"MMPosture"];
    [NSUnarchiver decodeClassName:@"Point" asClassName:@"MMPoint"];
    [NSUnarchiver decodeClassName:@"ProtoEquation" asClassName:@"MMEquation"];
    [NSUnarchiver decodeClassName:@"ProtoTemplate" asClassName:@"MMTransition"];
    [NSUnarchiver decodeClassName:@"Rule" asClassName:@"MMRule"];
    [NSUnarchiver decodeClassName:@"Slope" asClassName:@"MMSlope"];
    [NSUnarchiver decodeClassName:@"SlopeRatio" asClassName:@"MMSlopeRatio"];
    [NSUnarchiver decodeClassName:@"Symbol" asClassName:@"MMSymbol"];
    [NSUnarchiver decodeClassName:@"Target" asClassName:@"MMTarget"];

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

    [eventListView applicationDidFinishLaunching:aNotification]; // not connected yet
    [intonationView applicationDidFinishLaunching:aNotification]; // not connected yet

    [stringParser applicationDidFinishLaunching:aNotification];

    [synthesisWindow setFrameAutosaveName:@"SynthesisWindow"];
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
- (IBAction)openFile:(id)sender;
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
                [model readDegasFileFormat:fp];
            } else {
                NSLog(@"Not a DEGAS file");
            }

            fclose(fp);
        }
    }
}

- (IBAction)importTRMData:(id)sender;
{
    NSArray *types;
    TRMData *trmData;
    NSArray *fnames;
    int count, index;
    NSOpenPanel *openPanel;

    types = [NSArray arrayWithObject:@"trm"];

    openPanel = [NSOpenPanel openPanel]; // Each call resets values, including filenames
    [openPanel setAllowsMultipleSelection:YES];
    if ([openPanel runModalForTypes:types] == NSCancelButton)
        return;

    fnames = [openPanel filenames];

    trmData = [[TRMData alloc] init];

    count = [fnames count];
    for (index = 0; index < count; index++) {
        NSString *filename;
        NSString *str;
        MMPosture *newPhone;
        TargetList *parameterTargets;

        filename = [fnames objectAtIndex:index];
        str = [[filename lastPathComponent] stringByDeletingPathExtension];

        /*  Read the file data and store it in the object  */
        if ([trmData readFromFile:filename] == NO) {
            NSBeep();
            break;
        }

        newPhone = [[MMPosture alloc] initWithModel:model];
        [newPhone setSymbol:str];
        [model addPosture:newPhone];

        parameterTargets = [newPhone parameterTargets];

        // TODO (2004-03-25): These used to set the default flag as well, but I plan to remove that flag.
        // TODO (2004-03-25): Look up parameter indexes by name, so this will still work if they get rearranged in the Monet file.
        /*  Get the values of the needed parameters  */
        [[parameterTargets objectAtIndex:0] setValue:[trmData glotPitch]];
        [[parameterTargets objectAtIndex:1] setValue:[trmData glotVol]];
        [[parameterTargets objectAtIndex:2] setValue:[trmData aspVol]];
        [[parameterTargets objectAtIndex:3] setValue:[trmData fricVol]];
        [[parameterTargets objectAtIndex:4] setValue:[trmData fricPos]];
        [[parameterTargets objectAtIndex:5] setValue:[trmData fricCF]];
        [[parameterTargets objectAtIndex:6] setValue:[trmData fricBW]];
        [[parameterTargets objectAtIndex:7] setValue:[trmData r1]];
        [[parameterTargets objectAtIndex:8] setValue:[trmData r2]];
        [[parameterTargets objectAtIndex:9] setValue:[trmData r3]];
        [[parameterTargets objectAtIndex:10] setValue:[trmData r4]];
        [[parameterTargets objectAtIndex:11] setValue:[trmData r5]];
        [[parameterTargets objectAtIndex:12] setValue:[trmData r6]];
        [[parameterTargets objectAtIndex:13] setValue:[trmData r7]];
        [[parameterTargets objectAtIndex:14] setValue:[trmData r8]];
        [[parameterTargets objectAtIndex:15] setValue:[trmData velum]];

        [newPhone release];
    }

    [trmData release];
}

- (IBAction)printData:(id)sender;
{
    FILE *fp;
#if 0
    const char *temp;
    NSSavePanel *myPanel;

    myPanel = [NSSavePanel savePanel];
    if ([myPanel runModal]) {
        temp = [[myPanel filename] UTF8String];
        fp = fopen(temp, "w");
        if (fp) {
            [model writeDataToFile:fp];
            fclose(fp);
        }
    }
#else
    fp = fopen("/tmp/data.txt", "w");
    if (fp) {
        [model writeDataToFile:fp];
        fclose(fp);
    }
#endif
}

- (IBAction)archiveToDisk:(id)sender;
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
            //[ruleManager writeRulesTo:stream];
            [mdata writeToFile:[myPanel filename] atomically:NO];
            [stream release];
        } else {
            NSLog(@"Not a MONET file");
        }
    }
#endif
}

// Open a .monet file.
- (IBAction)readFromDisk:(id)sender;
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
                NXUnnameObject(@"mainParameterList", NSApp);
                NXUnnameObject(@"mainMetaParameterList", NSApp);
                NXUnnameObject(@"mainSymbolList", NSApp);
                NXUnnameObject(@"mainPhoneList", NSApp);
                NXUnnameObject(@"rules", NSApp);

                [model release];
                model = [[MModel alloc] initWithCoder:stream];

                NXNameObject(@"mainCategoryList", [model categories], NSApp);
                NXNameObject(@"mainParameterList", [model parameters], NSApp);
                NXNameObject(@"mainMetaParameterList", [model metaParameters], NSApp);
                NXNameObject(@"mainSymbolList", [model symbols], NSApp);
                NXNameObject(@"mainPhoneList", [model postures], NSApp);
                NXNameObject(@"rules", [model rules], NSApp);

                [prototypeManager setModel:model];
                [dataEntryController setModel:model];
                [postureEditor setModel:model];
                [newPrototypeManager setModel:model];
                [transitionEditor setModel:model];
                [specialTransitionEditor setModel:model];
                [ruleTester setModel:model];
                [newRuleManager setModel:model];

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

- (IBAction)savePrototypes:(id)sender;
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

- (IBAction)loadPrototypes:(id)sender;
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

- (void)setObject:(id)object forKey:(id)key;
{
    if (object == nil) {
        NSLog(@"Error: object for key %@ is nil!", key);
        return;
    }
    [namedObjects setObject:object forKey:key];
}

- (id)objectForKey:(id)key;
{
    return [namedObjects objectForKey:key];
}

- (void)removeObjectForKey:(id)key;
{
    [namedObjects removeObjectForKey:key];
}

// Converted classes:
// MMCategory, FormulaExpression, FormulaTerminal, MonetList, NamedList, Parameter, Phone, Point, MMEquation, ProtoTemplte, MMRule, Symbol, Target
// BooleanExpression, BooleanTerminal, MMSlope, MMSlopeRatio

- (void)_disableUnconvertedClassLoading;
{
    NSString *names[] = { @"IntonationPoint", @"RuleManager", nil };
    int index = 0;

    while (names[index] != nil) {
        [NSUnarchiver decodeClassName:names[index] asClassName:[NSString stringWithFormat:@"%@_NOT_CONVERTED", names[index]]];
        index++;
    }
}

- (IBAction)showNewDataEntryWindow:(id)sender;
{
    if (dataEntryController == nil) {
        dataEntryController = [[MDataEntryController alloc] initWithModel:model];
    }

    [dataEntryController setModel:model];
    [dataEntryController showWindow:self];
}

- (IBAction)showPostureEditor:(id)sender;
{
    if (postureEditor == nil) {
        postureEditor = [[MPostureEditor alloc] initWithModel:model];
    }

    [postureEditor setModel:model];
    [postureEditor showWindow:self];
}

- (IBAction)showPrototypeManager:(id)sender;
{
    if (newPrototypeManager == nil) {
        newPrototypeManager = [[MPrototypeManager alloc] initWithModel:model];
    }

    [newPrototypeManager setModel:model];
    [newPrototypeManager showWindow:self];
}

- (MTransitionEditor *)transitionEditor;
{
    if (transitionEditor == nil) {
        transitionEditor = [[MTransitionEditor alloc] initWithModel:model];
    }

    return transitionEditor;
}

- (IBAction)showTransitionEditor:(id)sender;
{
    [self transitionEditor]; // Make sure it's been created
    [transitionEditor setModel:model];
    [transitionEditor showWindow:self];
}

- (MSpecialTransitionEditor *)specialTransitionEditor;
{
    if (specialTransitionEditor == nil) {
        specialTransitionEditor = [[MSpecialTransitionEditor alloc] initWithModel:model];
    }

    return specialTransitionEditor;
}

- (IBAction)showSpecialTransitionEditor:(id)sender;
{
    [self specialTransitionEditor]; // Make sure it's been created
    [specialTransitionEditor setModel:model];
    [specialTransitionEditor showWindow:self];
}

- (MRuleTester *)ruleTester;
{
    if (ruleTester == nil)
        ruleTester = [[MRuleTester alloc] initWithModel:model];

    return ruleTester;
}

- (IBAction)showRuleTester:(id)sender;
{
    [self ruleTester]; // Make sure it's been created
    [ruleTester setModel:model];
    [ruleTester showWindow:self];
}

- (MRuleManager *)ruleManager;
{
    if (newRuleManager == nil)
        newRuleManager = [[MRuleManager alloc] initWithModel:model];

    return newRuleManager;
}

- (IBAction)showRuleManager:(id)sender;
{
    [self ruleManager]; // Make sure it's been created
    [newRuleManager setModel:model];
    [newRuleManager showWindow:self];
}

- (IBAction)generateXML:(id)sender;
{
    [model generateXML:@""];
}

- (void)editTransition:(MMTransition *)aTransition;
{
    [self transitionEditor]; // Make sure it's been created

    [transitionEditor setTransition:aTransition];
    [transitionEditor showWindow:self];
}

- (void)editSpecialTransition:(MMTransition *)aTransition;
{
    [self specialTransitionEditor]; // Make sure it's been created

    [specialTransitionEditor setTransition:aTransition];
    [specialTransitionEditor showWindow:self];
}

@end

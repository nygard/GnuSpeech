//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "AppController.h"

#import <Foundation/Foundation.h>

#import "MModel.h"
#import "MUnarchiver.h"

#import "MDataEntryController.h"
#import "MDocument.h"
#import "MMPosture.h"
#import "MMTarget.h"
#import "MPostureCategoryController.h"
#import "MPostureEditor.h"
#import "MPrototypeManager.h"
#import "MRuleManager.h"
#import "MRuleTester.h"
#import "MSpecialTransitionEditor.h"
#import "MSynthesisController.h"
#import "MSynthesisParameterEditor.h"
#import "MTransitionEditor.h"
#import "MWindowController.h"

@implementation AppController

- (id)init;
{
    if ([super init] == nil)
        return nil;

    filename = nil;
    model = [[MModel alloc] init];

    return self;
}

- (void)dealloc;
{
    [filename release];
    [model release];

    [dataEntryController release];
    [postureEditor release];
    [prototypeManager release];
    [transitionEditor release];
    [specialTransitionEditor release];
    [ruleTester release];
    [ruleManager release];
    [synthesisParameterEditor release];
    [synthesisController release];

    [super dealloc];
}

- (void)setFilename:(NSString *)newFilename;
{
    if (newFilename == filename)
        return;

    [filename release];
    filename = [newFilename retain];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
{
    NSString *path;

    //NSLog(@"<%@>[%p]  > %s", NSStringFromClass([self class]), self, _cmd);

    //NSLog(@"[NSApp delegate]: %@", [NSApp delegate]);

    //NSLog(@"decode List as %@", [NSUnarchiver classNameDecodedForArchiveClassName:@"List"]);
    //NSLog(@"decode Object as %@", [NSUnarchiver classNameDecodedForArchiveClassName:@"Object"]);

    [NSUnarchiver decodeClassName:@"Object" asClassName:@"NSObject"];
    [NSUnarchiver decodeClassName:@"List" asClassName:@"MonetList"];

    [NSUnarchiver decodeClassName:@"BooleanExpression" asClassName:@"MMBooleanExpression"];
    [NSUnarchiver decodeClassName:@"BooleanTerminal" asClassName:@"MMBooleanTerminal"];
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

    path = [[NSBundle mainBundle] pathForResource:@"Default" ofType:@"mxml"];
    //NSLog(@"path: %@", path);

    [self _loadMonetXMLFile:path];
    [self setFilename:nil];

    [[self dataEntryController] showWindowIfVisibleOnLaunch];
    [[self postureCategoryController] showWindowIfVisibleOnLaunch];
    [[self postureEditor] showWindowIfVisibleOnLaunch];
    [[self prototypeManager] showWindowIfVisibleOnLaunch];
    [[self transitionEditor] showWindowIfVisibleOnLaunch];
    [[self specialTransitionEditor] showWindowIfVisibleOnLaunch];
    [[self ruleTester] showWindowIfVisibleOnLaunch];
    [[self ruleManager] showWindowIfVisibleOnLaunch];
    [[self synthesisParameterEditor] showWindowIfVisibleOnLaunch];
    [[self synthesisController] showWindowIfVisibleOnLaunch];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"shouldActivateOnLaunch"])
        [NSApp activateIgnoringOtherApps:YES];

    //NSLog(@"<%@>[%p] <  %s", NSStringFromClass([self class]), self, _cmd);
}

- (void)applicationWillTerminate:(NSNotification *)notification;
{
    // I think this will be more reliable that using -windowWillClose:, since the windows do close when the app terminates...
    [[self dataEntryController] saveWindowIsVisibleOnLaunch];
    [[self postureCategoryController] saveWindowIsVisibleOnLaunch];
    [[self postureEditor] saveWindowIsVisibleOnLaunch];
    [[self prototypeManager] saveWindowIsVisibleOnLaunch];
    [[self transitionEditor] saveWindowIsVisibleOnLaunch];
    [[self specialTransitionEditor] saveWindowIsVisibleOnLaunch];
    [[self ruleTester] saveWindowIsVisibleOnLaunch];
    [[self ruleManager] saveWindowIsVisibleOnLaunch];
    [[self synthesisParameterEditor] saveWindowIsVisibleOnLaunch];
    [[self synthesisController] saveWindowIsVisibleOnLaunch];
    //[[self intonationController] saveWindowIsVisibleOnLaunch];
    //[[self intonationParameterEditor] saveWindowIsVisibleOnLaunch];
}

- (void)displayInfoPanel:(id)sender;
{
    if (infoPanel == nil) {
        [NSBundle loadNibNamed:@"Info.nib" owner:self];
    }

    [infoPanel makeKeyAndOrderFront:self];
}

- (IBAction)openFile:(id)sender;
{
    int count, index;
    NSArray *types;
    NSArray *fnames;
    NSOpenPanel *openPanel;

    NSLog(@" > %s", _cmd);

    types = [NSArray arrayWithObjects:@"monet", @"degas", @"mxml", nil];
    openPanel = [NSOpenPanel openPanel]; // Each call resets values, including filenames
    [openPanel setAllowsMultipleSelection:NO];

    if ([openPanel runModalForTypes:types] == NSCancelButton)
        return;

    fnames = [openPanel filenames];
    count = [fnames count];
    for (index = 0; index < count; index++)
        [self _loadFile:[fnames objectAtIndex:index]];

    NSLog(@"<  %s", _cmd);
}

- (IBAction)importTRMData:(id)sender;
{
    NSArray *types;
    NSArray *fnames;
    int count, index;
    NSOpenPanel *openPanel;

    types = [NSArray arrayWithObject:@"trm"];

    openPanel = [NSOpenPanel openPanel]; // Each call resets values, including filenames
    [openPanel setAllowsMultipleSelection:YES];
    if ([openPanel runModalForTypes:types] == NSCancelButton)
        return;

    fnames = [openPanel filenames];

    count = [fnames count];
    for (index = 0; index < count; index++) {
        NSString *aFilename;
        NSString *postureName;
        NSData *data;
        NSUnarchiver *unarchiver;

        aFilename = [fnames objectAtIndex:index];
        postureName = [[aFilename lastPathComponent] stringByDeletingPathExtension];

        data = [NSData dataWithContentsOfFile:aFilename];
        unarchiver = [[NSUnarchiver alloc] initForReadingWithData:data];
        if ([model importPostureNamed:postureName fromTRMData:unarchiver] == NO) {
            [unarchiver release];
            NSBeep();
            break;
        }

        [unarchiver release];
    }
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
            //[prototypeManager writePrototypesTo:stream];
            //[ruleManager writeRulesTo:stream];
            [mdata writeToFile:[myPanel filename] atomically:NO];
            [stream release];
        } else {
            NSLog(@"Not a MONET file");
        }
    }
#endif
}


- (void)setModel:(MModel *)newModel;
{
    if (newModel == model)
        return;

    [model release];
    model = [newModel retain];

    [dataEntryController setModel:model];
    [postureCategoryController setModel:model];
    [postureEditor setModel:model];
    [prototypeManager setModel:model];
    [transitionEditor setModel:model];
    [specialTransitionEditor setModel:model];
    [ruleTester setModel:model];
    [ruleManager setModel:model];
    [synthesisParameterEditor setModel:model];
    [synthesisController setModel:model];
}

- (void)_loadFile:(NSString *)aFilename;
{
    NSString *extension;

    extension = [aFilename pathExtension];
    if ([extension isEqualToString:@"monet"] == YES) {
        [self _loadMonetFile:aFilename];
    } else if ([extension isEqualToString:@"degas"] == YES) {
        [self _loadDegasFile:aFilename];
    } else if ([extension isEqualToString:@"mxml"] == YES) {
        [self _loadMonetXMLFile:aFilename];
    }
}

- (void)_loadMonetFile:(NSString *)aFilename;
{
    NSArchiver *stream;

    stream = [[MUnarchiver alloc] initForReadingWithData:[NSData dataWithContentsOfFile:aFilename]];

    if (stream) {
        MModel *newModel;

        newModel = [[MModel alloc] initWithCoder:stream];
        [self setModel:newModel];
        [newModel release];

        [self setFilename:aFilename];

        [stream release];
        [model writeXMLToFile:@"/tmp/out.xml" comment:aFilename];
    } else {
        NSLog(@"Not a MONET file");
    }
}

#define DEGAS_MAGIC 0x2e646567

// TODO (2004-04-21): This actually imports instead of loading.  Should create new model, like in Monet file case
- (void)_loadDegasFile:(NSString *)aFilename;
{
    FILE *fp;
    unsigned int magic;

    fp = fopen([aFilename UTF8String], "r");

    fread(&magic, sizeof(int), 1, fp);
    if (magic == DEGAS_MAGIC) {
        NSLog(@"Loading DEGAS File");
        [model readDegasFileFormat:fp];
    } else {
        NSLog(@"Not a DEGAS file");
    }

    fclose(fp);
}

- (void)_loadMonetXMLFile:(NSString *)aFilename;
{
    MDocument *document;
    BOOL result;

    document = [[MDocument alloc] init];
    result = [document loadFromXMLFile:aFilename];
    if (result == YES) {
        [self setModel:[document model]];
        [self setFilename:aFilename];
    }

    [document release];
}

- (IBAction)saveDocument:(id)sender;
{
    if (filename == nil) {
        [self saveDocumentAs:sender];
    } else {
        NSString *extension;
        BOOL result;

        extension = [filename pathExtension];

        if ([@"mxml" isEqualToString:extension] == NO) {
            NSString *newFilename;

            newFilename = [[filename stringByDeletingPathExtension] stringByAppendingPathExtension:@"mxml"];
            result = [model writeXMLToFile:newFilename comment:nil];
            if (result == YES) {
                NSLog(@"Renamed file from %@ to %@", [filename lastPathComponent], [newFilename lastPathComponent]);
                [self setFilename:newFilename];
            }
        } else
            result = [model writeXMLToFile:filename comment:nil];

        if (result == NO)
            NSRunAlertPanel(@"Save Failed", @"Couldn't save document to %@", @"OK", nil, nil, filename);
        else
            NSLog(@"Saved file: %@", filename);
    }
}

- (IBAction)saveDocumentAs:(id)sender;
{
    NSSavePanel *savePanel;

    savePanel = [NSSavePanel savePanel];
    [savePanel setRequiredFileType:@"mxml"];
    if ([savePanel runModalForDirectory:nil file:[filename lastPathComponent]] == NSFileHandlingPanelOKButton) {
        NSString *newFilename;
        BOOL result;

        newFilename = [savePanel filename];

        result = [model writeXMLToFile:newFilename comment:nil];

        if (result == NO)
            NSRunAlertPanel(@"Save Failed", @"Couldn't save document to %@", @"OK", nil, nil, filename);
        else {
            [self setFilename:newFilename];
            NSLog(@"Saved file: %@", newFilename);
        }
    }
}

// TODO (2004-05-20): We could only enable this when filename != nil, or just wait until we start using the document architecture.
- (IBAction)revertDocumentToSaved:(id)sender;
{
    if (filename == nil)
        NSBeep();
    else
        [self _loadFile:filename];
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
            //[prototypeManager writePrototypesTo:stream];
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
    NSString *aFilename;

    types = [NSArray array];
    [[NSOpenPanel openPanel] setAllowsMultipleSelection:NO];
    if ([[NSOpenPanel openPanel] runModalForTypes:types]) {
        fnames = [[NSOpenPanel openPanel] filenames];
        directory = [[NSOpenPanel openPanel] directory];
        aFilename = [directory stringByAppendingPathComponent:[fnames objectAtIndex:0]];

        stream = [[NSUnarchiver alloc] initForReadingWithData:[NSData dataWithContentsOfFile:aFilename]];

        if (stream) {
            //[prototypeManager readPrototypesFrom:stream];
            [stream release];
        } else {
            NSLog(@"Not a MONET file");
        }
    }
#endif
}

// Converted classes:
// MMCategory, FormulaExpression, FormulaTerminal, MonetList, NamedList, Parameter, Phone, Point, MMEquation, ProtoTemplte, MMRule, Symbol, Target
// MMBooleanExpression, MMBooleanTerminal, MMSlope, MMSlopeRatio

- (void)_disableUnconvertedClassLoading;
{
    NSString *names[] = { @"IntonationPoint", @"RuleManager", nil };
    int index = 0;

    while (names[index] != nil) {
        [NSUnarchiver decodeClassName:names[index] asClassName:[NSString stringWithFormat:@"%@_NOT_CONVERTED", names[index]]];
        index++;
    }
}

- (MDataEntryController *)dataEntryController;
{
    if (dataEntryController == nil) {
        dataEntryController = [[MDataEntryController alloc] initWithModel:model];
    }

    return dataEntryController;
}

// TODO (2004-05-26): Rename method, without the "New"
- (IBAction)showNewDataEntryWindow:(id)sender;
{
    [self dataEntryController]; // Make sure it's been created
    [dataEntryController setModel:model];
    [dataEntryController showWindow:self];
}

- (MPostureCategoryController *)postureCategoryController;
{
    if (postureCategoryController == nil)
        postureCategoryController = [[MPostureCategoryController alloc] initWithModel:model];

    return postureCategoryController;
}

- (IBAction)showPostureCategoryWindow:(id)sender;
{
    [self postureCategoryController]; // Make sure it's been created
    [postureCategoryController setModel:model];
    [postureCategoryController showWindow:self];
}

- (MPostureEditor *)postureEditor;
{
    if (postureEditor == nil) {
        postureEditor = [[MPostureEditor alloc] initWithModel:model];
    }

    return postureEditor;
}

- (IBAction)showPostureEditor:(id)sender;
{
    [self postureEditor]; // Make sure it's been created
    [postureEditor setModel:model];
    [postureEditor showWindow:self];
}

- (MPrototypeManager *)prototypeManager;
{
    if (prototypeManager == nil) {
        prototypeManager = [[MPrototypeManager alloc] initWithModel:model];
    }

    return prototypeManager;
}

- (IBAction)showPrototypeManager:(id)sender;
{
    [self prototypeManager]; // Make sure it's been created
    [prototypeManager setModel:model];
    [prototypeManager showWindow:self];
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
    if (ruleManager == nil)
        ruleManager = [[MRuleManager alloc] initWithModel:model];

    return ruleManager;
}

- (IBAction)showRuleManager:(id)sender;
{
    [self ruleManager]; // Make sure it's been created
    [ruleManager setModel:model];
    [ruleManager showWindow:self];
}

- (MSynthesisParameterEditor *)synthesisParameterEditor;
{
    if (synthesisParameterEditor == nil)
        synthesisParameterEditor = [[MSynthesisParameterEditor alloc] initWithModel:model];

    return synthesisParameterEditor;
}

- (IBAction)showSynthesisParameterEditor:(id)sender;
{
    [self synthesisParameterEditor]; // Make sure it's been created
    [synthesisParameterEditor setModel:model];
    [synthesisParameterEditor showWindow:self];
}

- (MSynthesisController *)synthesisController;
{
    if (synthesisController == nil)
        synthesisController = [[MSynthesisController alloc] initWithModel:model];

    return synthesisController;
}

- (IBAction)showSynthesisController:(id)sender;
{
    [self synthesisController]; // Make sure it's been created
    [synthesisController setModel:model];
    [synthesisController showWindow:self];
}

- (IBAction)showIntonationWindow:(id)sender;
{
    [self synthesisController]; // Make sure it's been created
    [synthesisController setModel:model];
    [synthesisController showIntonationWindow:self];
}

- (IBAction)showIntonationParameterWindow:(id)sender;
{
    [self synthesisController]; // Make sure it's been created
    [synthesisController setModel:model];
    [synthesisController showIntonationParameterWindow:self];
}

- (IBAction)generateXML:(id)sender;
{
    [model writeXMLToFile:@"/tmp/out.xml" comment:nil];
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

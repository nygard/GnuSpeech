//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "AppController.h"

#import <GnuSpeech/GnuSpeech.h>

#import "MDataEntryController.h"
#import "MPostureCategoryController.h"
#import "MPostureEditor.h"
#import "MPrototypeManager.h"
#import "MReleaseNotesController.h"
#import "MRuleManager.h"
#import "MRuleTester.h"
#import "MSpecialTransitionEditor.h"
#import "MSynthesisController.h"
#import "MSynthesisParameterEditor.h"
#import "MTransitionEditor.h"
#import "MWindowController.h"

#define MDK_MonetFileDirectory @"MonetFileDirectory"

@interface AppController ()

- (void)_loadFile:(NSString *)aFilename;
- (void)_loadMonetXMLFile:(NSString *)aFilename;

@property (nonatomic, readonly) MDataEntryController *dataEntryController;
@property (nonatomic, readonly) MPostureCategoryController *postureCategoryController;
@property (nonatomic, readonly) MPostureEditor *postureEditor;
@property (nonatomic, readonly) MPrototypeManager *prototypeManager;
@property (nonatomic, readonly) MTransitionEditor *transitionEditor;
@property (nonatomic, readonly) MSpecialTransitionEditor *specialTransitionEditor;
@property (nonatomic, readonly) MRuleTester *ruleTester;
@property (nonatomic, readonly) MRuleManager *ruleManager;
@property (nonatomic, readonly) MSynthesisParameterEditor *synthesisParameterEditor;
@property (nonatomic, readonly) MSynthesisController *synthesisController;
@property (nonatomic, readonly) MReleaseNotesController *releaseNotesController;
@end

#pragma mark -

@implementation AppController
{
    IBOutlet NSPanel *infoPanel;
    
    NSString *m_filename;
    MModel *model;
    
    MDataEntryController *dataEntryController;
    MPostureCategoryController *postureCategoryController;
    MPostureEditor *postureEditor;
    MPrototypeManager *prototypeManager;
    MTransitionEditor *transitionEditor;
    MSpecialTransitionEditor *specialTransitionEditor;
    MRuleTester *ruleTester;
    MRuleManager *ruleManager;
    MSynthesisParameterEditor *synthesisParameterEditor;
    MSynthesisController *synthesisController;
    MReleaseNotesController *releaseNotesController;
}

- (id)init;
{
    if ((self = [super init])) {
        m_filename = nil;
        model = [[MModel alloc] init];
    }
	
    return self;
}

- (void)dealloc;
{
    [m_filename release];
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
    [releaseNotesController release];

    [super dealloc];
}

@synthesize filename = m_filename;

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
    //NSLog(@"<%@>[%p]  > %s", NSStringFromClass([self class]), self, _cmd);

    //NSLog(@"[NSApp delegate]: %@", [NSApp delegate]);

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
    [[self releaseNotesController] showWindowIfVisibleOnLaunch];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"shouldActivateOnLaunch"])
        [NSApp activateIgnoringOtherApps:YES];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"Diphones" ofType:@"mxml"];
    //path = [[NSBundle mainBundle] pathForResource:@"Default" ofType:@"mxml"];	
    [self _loadMonetXMLFile:path];	
	
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
    [[self releaseNotesController] saveWindowIsVisibleOnLaunch];
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
    NSUInteger count, index;
    NSArray *types;
    NSArray *fnames;
    NSOpenPanel *openPanel;

    NSLog(@" > %s", __PRETTY_FUNCTION__);

    types = [NSArray arrayWithObjects:@"mxml", nil];
    openPanel = [NSOpenPanel openPanel]; // Each call resets values, including filenames
    NSString *path = [[NSUserDefaults standardUserDefaults] objectForKey:MDK_MonetFileDirectory];
    if (path != nil)
        [openPanel setDirectoryURL:[NSURL fileURLWithPath:path]];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setAllowedFileTypes:types];

    if ([openPanel runModal] == NSFileHandlingPanelCancelButton)
        return;

    [[NSUserDefaults standardUserDefaults] setObject:[[openPanel directoryURL] path] forKey:MDK_MonetFileDirectory];

    fnames = [openPanel URLs];
    count = [fnames count];
    for (index = 0; index < count; index++)
        [self _loadFile:[[fnames objectAtIndex:index] path]];

    NSLog(@"<  %s", __PRETTY_FUNCTION__);
}

- (IBAction)importTRMData:(id)sender;
{
#if 0
    // 2012-04-21: Check to see what this was supposed to do, and replace functionality if necessary.
    NSArray *types;
    NSArray *fnames;
    NSUInteger count, index;
    NSOpenPanel *openPanel;

    types = [NSArray arrayWithObject:@"trm"];

    openPanel = [NSOpenPanel openPanel]; // Each call resets values, including filenames
    [openPanel setAllowsMultipleSelection:YES];
    [openPanel setAllowedFileTypes:types];
    if ([openPanel runModal] == NSFileHandlingPanelCancelButton)
        return;

    fnames = [openPanel URLs];

    count = [fnames count];
    for (index = 0; index < count; index++) {
        NSString *aFilename;
        NSString *postureName;
        NSData *data;
        NSUnarchiver *unarchiver;

        aFilename = [[fnames objectAtIndex:index] path];
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
    NSString *extension = [aFilename pathExtension];
    if ([extension isEqualToString:@"mxml"] == YES) {
        [self _loadMonetXMLFile:aFilename];
    }
}

- (void)_loadMonetXMLFile:(NSString *)aFilename;
{
    MDocument *document = [[MDocument alloc] init];
    BOOL result = [document loadFromXMLFile:aFilename];
    if (result == YES) {
        [self setModel:[document model]];
        [self setFilename:aFilename];
    }

    [document release];
}

- (IBAction)saveDocument:(id)sender;
{
    if (self.filename == nil) {
        [self saveDocumentAs:sender];
    } else {
        BOOL result;

        NSString *extension = [self.filename pathExtension];

        if ([@"mxml" isEqualToString:extension] == NO) {
            NSString *newFilename;

            newFilename = [[self.filename stringByDeletingPathExtension] stringByAppendingPathExtension:@"mxml"];
            result = [model writeXMLToFile:newFilename comment:nil];
            if (result == YES) {
                NSLog(@"Renamed file from %@ to %@", [self.filename lastPathComponent], [newFilename lastPathComponent]);
                [self setFilename:newFilename];
            }
        } else
            result = [model writeXMLToFile:self.filename comment:nil];

        if (result == NO)
            NSRunAlertPanel(@"Save Failed", @"Couldn't save document to %@", @"OK", nil, nil, self.filename);
        else
            NSLog(@"Saved file: %@", self.filename);
    }
}

- (IBAction)saveDocumentAs:(id)sender;
{
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    NSString *path = [[NSUserDefaults standardUserDefaults] objectForKey:MDK_MonetFileDirectory];
    if (path != nil)
        [savePanel setDirectoryURL:[NSURL fileURLWithPath:path]];
    [savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"mxml"]];
    [savePanel setNameFieldStringValue:[self.filename lastPathComponent]];
    if ([savePanel runModal] == NSFileHandlingPanelOKButton) {
        [[NSUserDefaults standardUserDefaults] setObject:[[savePanel directoryURL] path] forKey:MDK_MonetFileDirectory];

        NSString *newFilename = [[savePanel URL] path];

        BOOL result = [model writeXMLToFile:newFilename comment:nil];

        if (result == NO)
            NSRunAlertPanel(@"Save Failed", @"Couldn't save document to %@", @"OK", nil, nil, self.filename);
        else {
            [self setFilename:newFilename];
            NSLog(@"Saved file: %@", newFilename);
        }
    }
}

// TODO (2004-05-20): We could only enable this when filename != nil, or just wait until we start using the document architecture.
- (IBAction)revertDocumentToSaved:(id)sender;
{
    if (self.filename == nil)
        NSBeep();
    else
        [self _loadFile:self.filename];
}

- (IBAction)savePrototypes:(id)sender;
{
#ifdef PORTING
    NSSavePanel *myPanel = [NSSavePanel savePanel];
    if ([myPanel runModal]) {
        NSMutableData *mdata = [NSMutableData dataWithCapacity:16];
        NSArchiver *stream = [[NSArchiver alloc] initForWritingWithMutableData:mdata];

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
    NSArray *types = [NSArray array];
    [[NSOpenPanel openPanel] setAllowsMultipleSelection:NO];
    [[NSOpenPanel openPanel] setAllowedFileTypes:types];
    if ([[NSOpenPanel openPanel] runModal] == NSFileHandlingPanelOKButton) {
        NSArray *fnames = [[NSOpenPanel openPanel] filenames];
        NSString *directory = [[NSOpenPanel openPanel] directory];
        NSString *aFilename = [directory stringByAppendingPathComponent:[fnames objectAtIndex:0]];

        NSArchiver *stream = [[NSUnarchiver alloc] initForReadingWithData:[NSData dataWithContentsOfFile:aFilename]];

        if (stream) {
            //[prototypeManager readPrototypesFrom:stream];
            [stream release];
        } else {
            NSLog(@"Not a MONET file");
        }
    }
#endif
}

#pragma mark - Data Entry Controllers

- (MDataEntryController *)dataEntryController;
{
    if (dataEntryController == nil) {
        dataEntryController = [[MDataEntryController alloc] initWithModel:model];
    }

    return dataEntryController;
}

- (IBAction)showDataEntryWindow:(id)sender;
{
    [self.dataEntryController setModel:model];
    [self.dataEntryController showWindow:self];
}

#pragma mark - Posture Category Controller

- (MPostureCategoryController *)postureCategoryController;
{
    if (postureCategoryController == nil)
        postureCategoryController = [[MPostureCategoryController alloc] initWithModel:model];

    return postureCategoryController;
}

- (IBAction)showPostureCategoryWindow:(id)sender;
{
    [self.postureCategoryController setModel:model];
    [self.postureCategoryController showWindow:self];
}

#pragma mark - Posture Editor

- (MPostureEditor *)postureEditor;
{
    if (postureEditor == nil) {
        postureEditor = [[MPostureEditor alloc] initWithModel:model];
    }

    return postureEditor;
}

- (IBAction)showPostureEditor:(id)sender;
{
    [self.postureEditor setModel:model];
    [self.postureEditor showWindow:self];
}

#pragma mark - Prototype Manager

- (MPrototypeManager *)prototypeManager;
{
    if (prototypeManager == nil) {
        prototypeManager = [[MPrototypeManager alloc] initWithModel:model];
    }

    return prototypeManager;
}

- (IBAction)showPrototypeManager:(id)sender;
{
    [self.prototypeManager setModel:model];
    [self.prototypeManager showWindow:self];
}

#pragma mark - Transition Editor

- (MTransitionEditor *)transitionEditor;
{
    if (transitionEditor == nil) {
        transitionEditor = [[MTransitionEditor alloc] init];
        transitionEditor.model = model;
    }

    return transitionEditor;
}

- (IBAction)showTransitionEditor:(id)sender;
{
    [self.transitionEditor setModel:model];
    [self.transitionEditor showWindow:self];
}

#pragma mark - Special Transition Editor

- (MSpecialTransitionEditor *)specialTransitionEditor;
{
    if (specialTransitionEditor == nil) {
        specialTransitionEditor = [[MSpecialTransitionEditor alloc] init];
        specialTransitionEditor.model = model;
    }

    return specialTransitionEditor;
}

- (IBAction)showSpecialTransitionEditor:(id)sender;
{
    [self.specialTransitionEditor setModel:model];
    [self.specialTransitionEditor showWindow:self];
}

#pragma mark - Rule Tester

- (MRuleTester *)ruleTester;
{
    if (ruleTester == nil)
        ruleTester = [[MRuleTester alloc] initWithModel:model];

    return ruleTester;
}

- (IBAction)showRuleTester:(id)sender;
{
    [self.ruleTester setModel:model];
    [self.ruleTester showWindow:self];
}

#pragma mark - Rule Manager

- (MRuleManager *)ruleManager;
{
    if (ruleManager == nil)
        ruleManager = [[MRuleManager alloc] initWithModel:model];

    return ruleManager;
}

- (IBAction)showRuleManager:(id)sender;
{
    [self.ruleManager setModel:model];
    [self.ruleManager showWindow:self];
}

#pragma mark - Synthesis Paremeter Editor

- (MSynthesisParameterEditor *)synthesisParameterEditor;
{
    if (synthesisParameterEditor == nil)
        synthesisParameterEditor = [[MSynthesisParameterEditor alloc] initWithModel:model];

    return synthesisParameterEditor;
}

- (IBAction)showSynthesisParameterEditor:(id)sender;
{
    [self.synthesisParameterEditor setModel:model];
    [self.synthesisParameterEditor showWindow:self];
}

#pragma mark - Synthesis Controller

- (MSynthesisController *)synthesisController;
{
    if (synthesisController == nil)
        synthesisController = [[MSynthesisController alloc] initWithModel:model];

    return synthesisController;
}

- (IBAction)showSynthesisController:(id)sender;
{
    [self.synthesisController setModel:model];
    [self.synthesisController showWindow:self];
}

#pragma mark - Intonation Widnow

- (IBAction)showIntonationWindow:(id)sender;
{
    [self.synthesisController setModel:model];
    [self.synthesisController showIntonationWindow:self];
}

#pragma mark - Intonation Parameter Window

- (IBAction)showIntonationParameterWindow:(id)sender;
{
    [self.synthesisController setModel:model];
    [self.synthesisController showIntonationParameterWindow:self];
}

#pragma mark - Release Notes Controller

- (MReleaseNotesController *)releaseNotesController;
{
    if (releaseNotesController == nil)
        releaseNotesController = [[MReleaseNotesController alloc] init];

    return releaseNotesController;
}

- (IBAction)showReleaseNotes:(id)sender;
{
    [self.releaseNotesController showWindow:self];
}

#pragma mark - Other

- (IBAction)generateXML:(id)sender;
{
    [model writeXMLToFile:@"/tmp/out.xml" comment:nil];
}

- (void)editTransition:(MMTransition *)transition;
{
    [self.transitionEditor setTransition:transition];
    [self.transitionEditor showWindow:self];
}

- (void)editSpecialTransition:(MMTransition *)transition;
{
    [self.specialTransitionEditor setTransition:transition];
    [self.specialTransitionEditor showWindow:self];
}

@end

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

#import "MMIntonation-Monet.h"

#define MDK_MonetFileDirectory @"MonetFileDirectory"

@interface AppController ()

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
    NSString *_filename;
    MModel *_model;

    MDataEntryController *_dataEntryController;
    MPostureCategoryController *_postureCategoryController;
    MPostureEditor *_postureEditor;
    MPrototypeManager *_prototypeManager;
    MTransitionEditor *_transitionEditor;
    MSpecialTransitionEditor *_specialTransitionEditor;
    MRuleTester *_ruleTester;
    MRuleManager *_ruleManager;
    MSynthesisParameterEditor *_synthesisParameterEditor;
    MSynthesisController *_synthesisController;
    MReleaseNotesController *_releaseNotesController;
}

- (id)init;
{
    if ((self = [super init])) {
        _filename = nil;
        _model = [[MModel alloc] init];
    }
	
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
    //NSLog(@"<%@>[%p]  > %s", NSStringFromClass([self class]), self, _cmd);

    //NSLog(@"[NSApp delegate]: %@", [NSApp delegate]);

    [MMIntonation setupUserDefaults];

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
    if (newModel == _model)
        return;

    _model = newModel;

    [_dataEntryController setModel:_model];
    [_postureCategoryController setModel:_model];
    [_postureEditor setModel:_model];
    [_prototypeManager setModel:_model];
    [_transitionEditor setModel:_model];
    [_specialTransitionEditor setModel:_model];
    [_ruleTester setModel:_model];
    [_ruleManager setModel:_model];
    [_synthesisParameterEditor setModel:_model];
    [_synthesisController setModel:_model];
}

- (void)_loadFile:(NSString *)aFilename;
{
    NSString *extension = [aFilename pathExtension];
    if ([extension isEqualToString:@"mxml"] == YES) {
        [self _loadMonetXMLFile:aFilename];
    }
}

- (void)_loadMonetXMLFile:(NSString *)filename;
{
    MDocument *document = [[MDocument alloc] initWithXMLFile:filename error:NULL];
    if (document != nil) {
        [self setModel:[document model]];
        [self setFilename:filename];
    }
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
            result = [_model writeXMLToFile:newFilename comment:nil];
            if (result == YES) {
                NSLog(@"Renamed file from %@ to %@", [self.filename lastPathComponent], [newFilename lastPathComponent]);
                [self setFilename:newFilename];
            }
        } else
            result = [_model writeXMLToFile:self.filename comment:nil];

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

        BOOL result = [_model writeXMLToFile:newFilename comment:nil];

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
    if (_dataEntryController == nil) {
        _dataEntryController = [[MDataEntryController alloc] initWithModel:_model];
    }

    return _dataEntryController;
}

- (IBAction)showDataEntryWindow:(id)sender;
{
    [self.dataEntryController setModel:_model];
    [self.dataEntryController showWindow:self];
}

#pragma mark - Posture Category Controller

- (MPostureCategoryController *)postureCategoryController;
{
    if (_postureCategoryController == nil)
        _postureCategoryController = [[MPostureCategoryController alloc] initWithModel:_model];

    return _postureCategoryController;
}

- (IBAction)showPostureCategoryWindow:(id)sender;
{
    [self.postureCategoryController setModel:_model];
    [self.postureCategoryController showWindow:self];
}

#pragma mark - Posture Editor

- (MPostureEditor *)postureEditor;
{
    if (_postureEditor == nil) {
        _postureEditor = [[MPostureEditor alloc] initWithModel:_model];
    }

    return _postureEditor;
}

- (IBAction)showPostureEditor:(id)sender;
{
    [self.postureEditor setModel:_model];
    [self.postureEditor showWindow:self];
}

#pragma mark - Prototype Manager

- (MPrototypeManager *)prototypeManager;
{
    if (_prototypeManager == nil) {
        _prototypeManager = [[MPrototypeManager alloc] initWithModel:_model];
    }

    return _prototypeManager;
}

- (IBAction)showPrototypeManager:(id)sender;
{
    [self.prototypeManager setModel:_model];
    [self.prototypeManager showWindow:self];
}

#pragma mark - Transition Editor

- (MTransitionEditor *)transitionEditor;
{
    if (_transitionEditor == nil) {
        _transitionEditor = [[MTransitionEditor alloc] init];
        _transitionEditor.model = _model;
    }

    return _transitionEditor;
}

- (IBAction)showTransitionEditor:(id)sender;
{
    [self.transitionEditor setModel:_model];
    [self.transitionEditor showWindow:self];
}

#pragma mark - Special Transition Editor

- (MSpecialTransitionEditor *)specialTransitionEditor;
{
    if (_specialTransitionEditor == nil) {
        _specialTransitionEditor = [[MSpecialTransitionEditor alloc] init];
        _specialTransitionEditor.model = _model;
    }

    return _specialTransitionEditor;
}

- (IBAction)showSpecialTransitionEditor:(id)sender;
{
    [self.specialTransitionEditor setModel:_model];
    [self.specialTransitionEditor showWindow:self];
}

#pragma mark - Rule Tester

- (MRuleTester *)ruleTester;
{
    if (_ruleTester == nil)
        _ruleTester = [[MRuleTester alloc] initWithModel:_model];

    return _ruleTester;
}

- (IBAction)showRuleTester:(id)sender;
{
    [self.ruleTester setModel:_model];
    [self.ruleTester showWindow:self];
}

#pragma mark - Rule Manager

- (MRuleManager *)ruleManager;
{
    if (_ruleManager == nil)
        _ruleManager = [[MRuleManager alloc] initWithModel:_model];

    return _ruleManager;
}

- (IBAction)showRuleManager:(id)sender;
{
    [self.ruleManager setModel:_model];
    [self.ruleManager showWindow:self];
}

#pragma mark - Synthesis Paremeter Editor

- (MSynthesisParameterEditor *)synthesisParameterEditor;
{
    if (_synthesisParameterEditor == nil)
        _synthesisParameterEditor = [[MSynthesisParameterEditor alloc] initWithModel:_model];

    return _synthesisParameterEditor;
}

- (IBAction)showSynthesisParameterEditor:(id)sender;
{
    [self.synthesisParameterEditor setModel:_model];
    [self.synthesisParameterEditor showWindow:self];
}

#pragma mark - Synthesis Controller

- (MSynthesisController *)synthesisController;
{
    if (_synthesisController == nil)
        _synthesisController = [[MSynthesisController alloc] initWithModel:_model];

    return _synthesisController;
}

- (IBAction)showSynthesisController:(id)sender;
{
    [self.synthesisController setModel:_model];
    [self.synthesisController showWindow:self];
}

#pragma mark - Intonation Widnow

- (IBAction)showIntonationWindow:(id)sender;
{
    [self.synthesisController setModel:_model];
    [self.synthesisController showIntonationWindow:self];
}

#pragma mark - Intonation Parameter Window

- (IBAction)showIntonationParameterWindow:(id)sender;
{
    [self.synthesisController setModel:_model];
    [self.synthesisController showIntonationParameterWindow:self];
}

#pragma mark - Release Notes Controller

- (MReleaseNotesController *)releaseNotesController;
{
    if (_releaseNotesController == nil)
        _releaseNotesController = [[MReleaseNotesController alloc] init];

    return _releaseNotesController;
}

- (IBAction)showReleaseNotes:(id)sender;
{
    [self.releaseNotesController showWindow:self];
}

#pragma mark - Other

- (IBAction)generateXML:(id)sender;
{
    [_model writeXMLToFile:@"/tmp/out.xml" comment:nil];
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

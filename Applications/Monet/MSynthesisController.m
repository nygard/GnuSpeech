//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MSynthesisController.h"

#import <Tube/Tube.h>
#import <GnuSpeech/GnuSpeech.h>

#import "NSNumberFormatter-Extensions.h"

#import "MExtendedTableView.h"
#import "MMDisplayParameter.h"

#import "MIntonationParameterEditor.h"
#import "MMIntonation-Monet.h"
#import "MEventTableController.h"

#import "MIntonationController.h"
#import "MDisplayParametersController.h"
#import "MAGraphView.h"
#import "MAGraphNameView.h"
#import "MARulePhoneView.h"
#import "MAScrollView.h"
#import "MGraphViewController.h"

#define MDK_DefaultUtterances          @"DefaultUtterances"

#define MDK_GraphImagesDirectory       @"GraphImagesDirectory"
#define MDK_SoundOutputDirectory       @"SoundOutputDirectory"
#define MDK_IntonationContourDirectory @"IntonationContourDirectory"
#define MDK_DisplayedGraphNames        @"DisplayedGraphNames"

@interface MSynthesisController () <NSTableViewDataSource, NSComboBoxDelegate, NSTextViewDelegate, NSFileManagerDelegate, MAGraphViewDelegate>

@property (weak) IBOutlet NSScrollView *leftScrollView;
@property (weak) IBOutlet NSStackView *leftStackView;

@property (weak) IBOutlet NSScrollView *topScrollView;
@property (weak) IBOutlet MARulePhoneView *rulePhoneView;

@property (weak) IBOutlet NSScrollView *graphScrollView;
@property (weak) IBOutlet NSStackView *graphStackView;

@property (weak) IBOutlet NSTextField *mouseTimeField;
@property (weak) IBOutlet NSTextField *mouseValueField;

@property (readonly) EventList *eventList;
@property (readonly) TRMSynthesizer *synthesizer;
@property (strong) STLogger *logger;
@property (strong) MEventTableController *eventTableController;
@property (strong) MIntonationController *intonationController;
@property (strong) MDisplayParametersController *displayParametersController;

@property (strong) NSArray *graphNameViews;
@property (strong) NSArray *graphViews;
@end

#pragma mark -

@implementation MSynthesisController
{
    // Synthesis window
	IBOutlet NSComboBox *_textStringTextField;
	IBOutlet NSTextView *_phoneStringTextView;
	IBOutlet NSScrollView *_scrollView;
    IBOutlet NSButton *_parametersStore;

    // Save panel accessory view
    IBOutlet NSView *_savePanelAccessoryView;
    IBOutlet NSPopUpButton *_fileTypePopUpButton;

    MModel *_model;
    NSArray *_displayParameters;
    EventList *_eventList;
    TRMSynthesizer *_synthesizer;
	MMTextToPhone *_textToPhone;
}

+ (void)initialize;
{
    NSArray *defaultUtterances = [NSArray arrayWithObjects:
                                  @"I'm sorry David, I'm afraid I can't do that.",
                                  @"Just what do you think you're doing, David?",
                                  @"Look David, I can see you're really upset about this. I honestly think you ought to sit down calmly, take a stress pill, and think things over.",
                                  @"I know you believe you understand what you think I said, but I'm not sure you realize that what you heard is not what I meant.",
                                  @"Is that cheese to eat, or is it to put in a mouse trap?",
                                  nil];	
	
    NSMutableDictionary *defaultValues = [[NSMutableDictionary alloc] init];
    [defaultValues setObject:defaultUtterances forKey:MDK_DefaultUtterances];
    [defaultValues setObject:[@"~/Desktop" stringByExpandingTildeInPath] forKey:MDK_GraphImagesDirectory];
    [defaultValues setObject:[@"~/Desktop" stringByExpandingTildeInPath] forKey:MDK_SoundOutputDirectory];
    [defaultValues setObject:[@"~/Desktop" stringByExpandingTildeInPath] forKey:MDK_IntonationContourDirectory];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}

- (id)initWithModel:(MModel *)model;
{
    if ((self = [super initWithWindowNibName:@"Synthesis"])) {
        _model = model;
        _displayParameters = [[NSMutableArray alloc] init];

        _eventList = [[EventList alloc] init];
        
        [self setWindowFrameAutosaveName:@"Synthesis"];
        
        _synthesizer = [[TRMSynthesizer alloc] init];
        
        _textToPhone = [[MMTextToPhone alloc] init];
        
        _eventTableController = [[MEventTableController alloc] init];
        _eventTableController.eventList = _eventList;

        _intonationController = [[MIntonationController alloc] init];
        _intonationController.eventList = _eventList;
        _intonationController.nextResponder = self;

        _displayParametersController = [[MDisplayParametersController alloc] init];

        if (_model != nil) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayParameterDidChange:) name:MMDisplayParameterNotification_DidChange object:_model];
        }
    }

    return self;
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

- (void)setModel:(MModel *)newModel;
{
    if (newModel != _model) {
        if (_model != nil) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:MMDisplayParameterNotification_DidChange object:_model];
        }
        _model = newModel;
        
        _eventList.model = _model;

        [self _updateDisplayParameters];
        [self _updateDisplayedParameters];
        self.eventTableController.displayParameters = _displayParameters;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayParameterDidChange:) name:MMDisplayParameterNotification_DidChange object:_model];
    }
}

- (NSUndoManager *)undoManager;
{
    return nil;
}

- (void)windowDidLoad;
{
    [_textStringTextField removeAllItems];
    [_textStringTextField addItemsWithObjectValues:[[NSUserDefaults standardUserDefaults] objectForKey:MDK_DefaultUtterances]];
    [_textStringTextField selectItemAtIndex:0];
	[_phoneStringTextView setFont:[NSFont systemFontOfSize:13]];
	[_phoneStringTextView setString:[_textToPhone phoneForText:[_textStringTextField stringValue]]];

    [self _updateDisplayParameters];
    [self _updateDisplayedParameters];
    self.eventTableController.displayParameters = _displayParameters;

    // This makes sure the graphs are at the top, even when the scrollview is tall compared to the height of the stack view.
    NSLayoutConstraint *c1 = [NSLayoutConstraint constraintWithItem:self.leftStackView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                             toItem:self.leftStackView.superview // clipview
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1.0
                                                           constant:0];
    [self.leftStackView.enclosingScrollView addConstraint:c1];

    self.rulePhoneView.eventList = self.eventList;

    NSLayoutConstraint *c2 = [NSLayoutConstraint constraintWithItem:self.graphStackView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                             toItem:self.graphStackView.superview // clipview
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1.0
                                                           constant:0];
    [self.graphStackView.enclosingScrollView addConstraint:c2];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollViewDidScroll:) name:NSScrollViewDidLiveScrollNotification object:self.graphScrollView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollViewDidScroll:) name:NSScrollViewDidLiveScrollNotification object:self.topScrollView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollViewDidScroll:) name:NSScrollViewDidLiveScrollNotification object:self.leftScrollView];
    // This doesn't work.  Nor does 0, 0.
//    [self.graphScrollView scrollRectToVisible:CGRectMake(0, 2900, 10, 10)];

    [self updateLeftScrollViewInset];

    // On 10.10.3 I'm getting notified immediately, so the call to -updateLeftScrollViewInset above isn't strictly necessary.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredScrollerStyleDidChange:) name:NSPreferredScrollerStyleDidChangeNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollerVisibilityDidChange:) name:MAScrollViewNotification_DidChangeScrollerVisibility object:self.graphScrollView];
}

#pragma mark -

- (void)_updateDisplayParameters;
{
    NSInteger currentTag = 0;

    NSArray *defaultDisplayedNames = [[NSUserDefaults standardUserDefaults] objectForKey:MDK_DisplayedGraphNames];

    NSMutableArray *displayParameters = [[NSMutableArray alloc] init];

    NSArray *parameters = self.model.parameters;
    NSUInteger count = [parameters count];
    for (NSUInteger index = 0; index < count && index < 16; index++) { // TODO (2004-03-30): Some hardcoded limits exist in Event
        MMParameter *currentParameter = parameters[index];
		
        MMDisplayParameter *displayParameter = [[MMDisplayParameter alloc] initWithParameter:currentParameter];
        displayParameter.tag = currentTag++;

        if (defaultDisplayedNames == nil || [defaultDisplayedNames containsObject:displayParameter.name]) {
            displayParameter.shouldDisplay = YES;
        } else {
            displayParameter.shouldDisplay = NO;
        }

        [displayParameters addObject:displayParameter];
    }
	
    for (NSUInteger index = 0; index < count && index < 16; index++) { // TODO (2004-03-30): Some hardcoded limits exist in Event
        MMParameter *currentParameter = parameters[index];
		
        MMDisplayParameter *displayParameter = [[MMDisplayParameter alloc] initWithParameter:currentParameter];
        displayParameter.isSpecial = YES;
        displayParameter.tag = currentTag++;

        if (defaultDisplayedNames == nil || [defaultDisplayedNames containsObject:displayParameter.name]) {
            displayParameter.shouldDisplay = YES;
        } else {
            displayParameter.shouldDisplay = NO;
        }

        [displayParameters addObject:displayParameter];
    }

    // TODO (2004-03-30): This used to have Intonation (tag=32).  How did that work?

    _displayParameters = displayParameters;

    for (NSView *view in self.leftStackView.views) {
        [self.leftStackView removeView:view];
    }

    NSMutableArray *graphNameViews = [[NSMutableArray alloc] init];
    NSMutableArray *graphViews = [[NSMutableArray alloc] init];

    for (MMDisplayParameter *displayParameter in _displayParameters) {
        MAGraphNameView *graphNameView = [[MAGraphNameView alloc] initWithFrame:CGRectZero];
        graphNameView.translatesAutoresizingMaskIntoConstraints = NO;
        graphNameView.displayParameter = displayParameter;
        [self.leftStackView addView:graphNameView inGravity:NSStackViewGravityTop];
        [graphNameViews addObject:graphNameView];


        MAGraphView *gv1 = [[MAGraphView alloc] initWithFrame:CGRectMake(0, 0, 300, 100)];
        gv1.translatesAutoresizingMaskIntoConstraints = NO;
        gv1.displayParameter = displayParameter;
        gv1.eventList = self.eventList;
        gv1.delegate = self;
        [self.graphStackView addView:gv1 inGravity:NSStackViewGravityTop];
        [graphViews addObject:gv1];

        if (!displayParameter.shouldDisplay) {
            [self.leftStackView  setVisibilityPriority:NSStackViewVisibilityPriorityNotVisible forView:graphNameView];
            [self.graphStackView setVisibilityPriority:NSStackViewVisibilityPriorityNotVisible forView:gv1];
        }
    }

    self.graphNameViews = [graphNameViews copy];
    self.graphViews     = [graphViews copy];
}

- (void)_updateDisplayedParameters;
{
    NSMutableArray *array = [[NSMutableArray alloc] init];

    for (MMDisplayParameter *displayParameter in _displayParameters) {
        if ([displayParameter shouldDisplay])
            [array addObject:displayParameter];
    }

    for (MAGraphNameView *graphNameView in self.graphNameViews) {
        MMDisplayParameter *displayParameter = graphNameView.displayParameter;
        if ([displayParameter shouldDisplay]) {
            [self.leftStackView setVisibilityPriority:NSStackViewVisibilityPriorityMustHold forView:graphNameView];
        } else {
            [self.leftStackView setVisibilityPriority:NSStackViewVisibilityPriorityNotVisible forView:graphNameView];
        }
    }

    for (MAGraphView *graphView in self.graphViews) {
        MMDisplayParameter *displayParameter = graphView.displayParameter;
        if ([displayParameter shouldDisplay]) {
            [self.graphStackView setVisibilityPriority:NSStackViewVisibilityPriorityMustHold forView:graphView];
        } else {
            [self.graphStackView setVisibilityPriority:NSStackViewVisibilityPriorityNotVisible forView:graphView];
        }
    }
}

- (void)_saveDisplayedParameterPreferences;
{
    NSMutableArray *names = [[NSMutableArray alloc] init];
    for (MMDisplayParameter *displayParameter in _displayParameters) {
        if (displayParameter.shouldDisplay) {
            [names addObject:displayParameter.name];
        }
    }

    [[NSUserDefaults standardUserDefaults] setObject:names forKey:MDK_DisplayedGraphNames];
}

- (IBAction)showEventTable:(id)sender;
{
    [self.eventTableController showWindow:self];
}

- (IBAction)showIntonationWindow:(id)sender;
{
    [self window]; // Make sure the nib is loaded

    [self.intonationController showWindow:self];
}

#pragma mark -

- (IBAction)synthesize:(id)sender;
{
    NSLog(@" > %s", __PRETTY_FUNCTION__);
    [self.synthesizer setShouldSaveToSoundFile:NO];
    MMIntonation *intonation = [[MMIntonation alloc] initFromUserDefaults];
    [_eventList resetWithIntonation:intonation phoneString:[self getAndSyncPhoneString]];
    [self continueSynthesis];
    NSLog(@"<  %s", __PRETTY_FUNCTION__);
}

- (IBAction)synthesizeToFile:(id)sender;
{
    NSLog(@" > %s", __PRETTY_FUNCTION__);
	
    NSString *directory = [[NSUserDefaults standardUserDefaults] objectForKey:MDK_SoundOutputDirectory];
	
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    savePanel.canSelectHiddenExtension = YES;
    savePanel.allowedFileTypes = @[ @"au", @"aiff", @"wav" ];
    savePanel.accessoryView = _savePanelAccessoryView;
    if (directory != nil)
        savePanel.directoryURL = [NSURL fileURLWithPath:directory];
    [self fileTypeDidChange:nil];
    // TODO (2012-04-18): Might need to set up "Untitled" in name
	
    [savePanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            [[NSUserDefaults standardUserDefaults] setObject:savePanel.directoryURL.path forKey:MDK_SoundOutputDirectory];
            self.synthesizer.shouldSaveToSoundFile = YES;
            self.synthesizer.fileType = [[_fileTypePopUpButton selectedItem] tag];
            self.synthesizer.filename = savePanel.URL.path;
            MMIntonation *intonation = [[MMIntonation alloc] initFromUserDefaults];
            [_eventList resetWithIntonation:intonation phoneString:[self getAndSyncPhoneString]];
            [self continueSynthesis];
        }
    }];
	
    NSLog(@"<  %s", __PRETTY_FUNCTION__);
}

- (IBAction)synthesizeWithContour:(id)sender;
{
    [_eventList clearIntonationEvents];
    [self.synthesizer setShouldSaveToSoundFile:NO];
    [self continueSynthesis];
}

- (NSString *)getAndSyncPhoneString;
{
	NSString *phoneString = [[_phoneStringTextView string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if (phoneString == NULL || [phoneString length] == 0) {
		phoneString = [[_textToPhone phoneForText:[_textStringTextField stringValue]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		[_phoneStringTextView setFont:[NSFont systemFontOfSize:13]];
		[_phoneStringTextView setString:phoneString];
		[_textStringTextField setTextColor:[NSColor blackColor]];
	} else {
		NSString *textStringPhones = [[_textToPhone phoneForText:[_textStringTextField stringValue]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if ([phoneString isEqualToString:textStringPhones]) {
			[_textStringTextField setTextColor:[NSColor blackColor]];
			[_phoneStringTextView setTextColor:[NSColor blackColor]];
		} else {
			if ([_phoneStringTextView textColor] == [NSColor redColor])  // not last edited
				phoneString = textStringPhones;	
		}
	}
	return phoneString;
}

- (IBAction)fileTypeDidChange:(id)sender;
{
    NSString *extension;
	
    NSSavePanel *savePanel = (NSSavePanel *)[_fileTypePopUpButton window];
    switch ([[_fileTypePopUpButton selectedItem] tag]) {
		case 1: extension = @"aiff"; break;
		case 2: extension = @"wav"; break;
		case 0:
		default:
			extension = @"au"; break;
    }
	
    [savePanel setAllowedFileTypes:@[ extension ]];
}

- (void)parseText:(id)sender;
{
	NSString *phoneString = [_textToPhone phoneForText:[_textStringTextField stringValue]];
	[_phoneStringTextView setTextColor:[NSColor blackColor]];	
	[_phoneStringTextView setString:phoneString];
	[_textStringTextField setTextColor:[NSColor blackColor]];

}

- (void)continueSynthesis;
{
    [_eventList applyIntonation];
	
    //[eventList printDataStructures:@"Before synthesis"];
    self.eventTableController.eventList = _eventList;

    [self.synthesizer setupSynthesisParameters:self.model.synthesisParameters]; // TODO (2004-08-22): This may overwrite the file type...
    [self.synthesizer removeAllParameters];

    if ([_parametersStore state]) {
        [_eventList generateOutputForSynthesizer:self.synthesizer saveParametersToFilename:@"/tmp/Monet.parameters"];
    } else {
        [_eventList generateOutputForSynthesizer:self.synthesizer];
    }
	
    [self.synthesizer synthesize];
}

- (IBAction)addTextString:(id)sender;
{
    NSString *str = [_textStringTextField stringValue];
    [_textStringTextField removeItemWithObjectValue:str];
    [_textStringTextField insertItemWithObjectValue:str atIndex:0];
    [_textStringTextField setTextColor:[NSColor blackColor]];

    str = [[_textToPhone phoneForText:[_textStringTextField stringValue]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [_phoneStringTextView setFont:[NSFont systemFontOfSize:13]];
    [_phoneStringTextView setString:str];
    [_phoneStringTextView setTextColor:[NSColor blackColor]];

    [[NSUserDefaults standardUserDefaults] setObject:[_textStringTextField objectValues] forKey:MDK_DefaultUtterances];
}

#pragma mark - Save Graph Images

- (IBAction)generateGraphImages:(id)sender;
{
    NSString *directory = [[NSUserDefaults standardUserDefaults] objectForKey:MDK_GraphImagesDirectory];
	
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setAllowedFileTypes:nil]; // TODO (2012-04-18): Not sure if nil is ok.
    if (directory != nil)
        [savePanel setDirectoryURL:[NSURL fileURLWithPath:directory]];

    [savePanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            [[NSUserDefaults standardUserDefaults] setObject:[[savePanel directoryURL] path] forKey:MDK_GraphImagesDirectory];
            [self saveGraphImagesToPath:[[savePanel URL] path]];
        }
    }];
}

// TODO: error handling is basically non-existant in this method.
- (void)saveGraphImagesToPath:(NSString *)basePath;
{
    NSLog(@" > %s", __PRETTY_FUNCTION__);

    // 1. Create directory as basePath.
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSError *error;
    if (![fileManager createDirectoryAtPath:basePath withIntermediateDirectories:NO attributes:nil error:&error]) {
        NSLog(@"Error: %@", error);
        return;
    }

    // 2. Synthesize, saving sound to file under basePath.
    MMIntonation *intonation = [[MMIntonation alloc] initFromUserDefaults];
    [_eventList resetWithIntonation:intonation phoneString:[self getAndSyncPhoneString]];
    {
        // This is basically from -continueSynthesis
        [_eventList applyIntonation];

        self.eventTableController.eventList = _eventList;

        [self.synthesizer setupSynthesisParameters:self.model.synthesisParameters];
        [self.synthesizer removeAllParameters];

        [_eventList generateOutputForSynthesizer:self.synthesizer saveParametersToFilename:[basePath stringByAppendingPathComponent:@"Monet.parameters"]];
    }

    self.synthesizer.fileType = 0;
    self.synthesizer.filename = [basePath stringByAppendingPathComponent:@"output.au"];
    self.synthesizer.shouldSaveToSoundFile = YES;
    [self.synthesizer synthesize];

    // 3. Create the index.html xml tree
    NSURL *templateURL = [[NSBundle mainBundle] URLForResource:@"graph-template" withExtension:@"html"];
    NSError *xmlError;
    NSXMLDocument *doc = [[NSXMLDocument alloc] initWithContentsOfURL:templateURL options:0 error:&xmlError];
    if (doc == nil) {
        NSLog(@"xmlError: %@", xmlError);
        return;
    }

    {
        NSError *xpathError;
        NSArray *timeGenText = [doc nodesForXPath:@"/html/body/p[@id='time-generated']/text()" error:&xpathError];
        NSXMLNode *generatedTextNode = [timeGenText lastObject];
        if (generatedTextNode != nil) {
            generatedTextNode.stringValue = [NSString stringWithFormat:@"Generated %@", [[NSCalendarDate calendarDate] description]];
        }
    }

    NSError *xpathError;
    NSArray *graphImagesElements = [doc nodesForXPath:@"/html/body/p[@id='graph-images']" error:&xpathError];
    NSXMLElement *graphImagesElement = [graphImagesElements lastObject];

    // 4. Save series of images, and add reference to HTML as we go.  Going to say we only show the graphs the user has selected to display.
    {
        NSMutableArray *groups = [[NSMutableArray alloc] init];
        NSMutableArray *current;
        for (MMDisplayParameter *displayParameter in _displayParameters) {
            if (current == nil) current = [[NSMutableArray alloc] init];
            if (displayParameter.shouldDisplay)
                [current addObject:displayParameter];
            if ([current count] == 4) {
                [groups addObject:current];
                current = nil;
            }
        }
        if (current != nil)
            [groups addObject:current];

        NSUInteger index = 1;
        for (NSArray *group in groups) {
            MGraphViewController *controller = [[MGraphViewController alloc] init];
            controller.displayParameters = group;
            controller.eventList = self.eventList;
            controller.scale = self.rulePhoneView.scale;

            NSMutableArray *parameterNames = [[NSMutableArray alloc] init];
            for (MMDisplayParameter *displayParameter in group) {
                [parameterNames addObject:displayParameter.parameter.name];
            }

            [controller.window layoutIfNeeded];

            NSImage *image = [[NSImage alloc] initWithSize:controller.view.bounds.size];
            [image lockFocus];
            {
                CGContextRef context = [NSGraphicsContext currentContext].graphicsPort;
                [controller.view.layer renderInContext:context];
            }
            [image unlockFocus];

            NSData *tiffData = [image TIFFRepresentationUsingCompression:NSTIFFCompressionLZW factor:0.95];

            NSBitmapImageRep *bitmapImageRep = [[NSBitmapImageRep alloc] initWithData:tiffData];
            NSData *PNGData = [bitmapImageRep representationUsingType:NSPNGFileType properties:nil];
            NSString *graphFilename = [NSString stringWithFormat:@"graph-%lu.png", index++];
            [PNGData writeToFile:[basePath stringByAppendingPathComponent:graphFilename] atomically:YES];

            NSXMLElement *imgElement = [[NSXMLElement alloc] initWithName:@"img"];
            [imgElement addAttribute:[NSXMLNode attributeWithName:@"src"    stringValue:graphFilename]];
            [imgElement addAttribute:[NSXMLNode attributeWithName:@"width"  stringValue:[NSString stringWithFormat:@"%.0f", image.size.width]]];
            [imgElement addAttribute:[NSXMLNode attributeWithName:@"height" stringValue:[NSString stringWithFormat:@"%.0f", image.size.height]]];
            [imgElement addAttribute:[NSXMLNode attributeWithName:@"alt"    stringValue:[parameterNames componentsJoinedByString:@", "]]];
            [graphImagesElement addChild:imgElement];
        }
    }

    // 5. Save the HTML.
    NSData *xmlData = [doc XMLDataWithOptions:NSXMLDocumentXHTMLKind|NSXMLNodePrettyPrint];
    NSError *indexError;
    if (![xmlData writeToFile:[basePath stringByAppendingPathComponent:@"index.html"] options:0 error:&indexError]) {
        NSLog(@"index error: %@", indexError);
        return;
    }

    // 6. Open the HTML.
    [[NSWorkspace sharedWorkspace] openFile:[basePath stringByAppendingPathComponent:@"index.html"]];

    NSLog(@"<  %s", __PRETTY_FUNCTION__);
}

#pragma mark - NSComboBoxDelegate

- (void)controlTextDidChange:(NSNotification *)notification;
{
	[_textStringTextField setTextColor:[NSColor blackColor]];	
	[_phoneStringTextView setTextColor:[NSColor redColor]];	
}

- (void)controlTextDidEndEditing:(NSNotification *)notification;
{
}		
		
#pragma mark - NSTextViewDelegate

- (void)textDidChange:(NSNotification *)notification;
{
	NSString *phoneString = [_phoneStringTextView string];
	if (phoneString == NULL || [phoneString length] == 0) {
		[_phoneStringTextView setFont:[NSFont systemFontOfSize:13]];
		[_phoneStringTextView setString:phoneString];
	}
	[_phoneStringTextView setTextColor:[NSColor blackColor]];	
	[_textStringTextField setTextColor:[NSColor redColor]];
}

#pragma mark -

- (IBAction)editDisplayParameters:(id)sender;
{
    NSPopover *popover = [[NSPopover alloc] init];
    popover.contentViewController = self.displayParametersController;
    popover.behavior = NSPopoverBehaviorTransient;
    self.displayParametersController.displayParameters = _displayParameters;
    [popover showRelativeToRect:CGRectZero ofView:sender preferredEdge:NSMaxYEdge];
}

- (void)displayParameterDidChange:(NSNotification *)notification;
{
    [self _updateDisplayedParameters];
    [self _saveDisplayedParameterPreferences];
}

- (void)scrollViewDidScroll:(NSNotification *)notification;
{
    if (notification.object == self.graphScrollView) {
        NSRect r1 = self.graphScrollView.documentVisibleRect;
        NSRect r2 = self.leftStackView.visibleRect;

        r2.origin.y = r1.origin.y;
        [self.leftStackView scrollRectToVisible:r2];

        NSRect r3 = self.topScrollView.documentVisibleRect;
        r3.origin.x = r1.origin.x;
        [self.rulePhoneView scrollRectToVisible:r3];
    } else if (notification.object == self.leftScrollView) {
        NSRect r1 = self.leftScrollView.documentVisibleRect;
        NSRect r2 = self.graphScrollView.documentVisibleRect;
        r2.origin.y = r1.origin.y;
        [self.graphStackView scrollRectToVisible:r2];
    } else if (notification.object == self.topScrollView) {
        NSRect r1 = self.topScrollView.documentVisibleRect;
        NSRect r2 = self.graphScrollView.documentVisibleRect;
        r2.origin.x = r1.origin.x;
        [self.graphStackView scrollRectToVisible:r2];
    }
}

#pragma mark -

- (void)preferredScrollerStyleDidChange:(NSNotification *)notification;
{
    [self updateLeftScrollViewInset];
}

/// Update the bottom inset to account for the horizontal scroller, since the origin is in the bottom left corner.
///
/// This is necessary to keep the scrollers lined up properly with the synchronization.
- (void)updateLeftScrollViewInset;
{
    //NSLog(@"has horizontal scroller? %d", self.graphScrollView.hasHorizontalScroller);
    //NSLog(@"%s, horizontal scroller hidden? %d", __PRETTY_FUNCTION__, self.graphScrollView.horizontalScroller.hidden);
    if ([NSScroller preferredScrollerStyle] == NSScrollerStyleLegacy) {
        if (!self.graphScrollView.horizontalScroller.hidden) {
            NSScroller *scroller = self.graphScrollView.horizontalScroller;
            CGFloat width = [NSScroller scrollerWidthForControlSize:scroller.controlSize scrollerStyle:scroller.scrollerStyle];
            self.leftStackView.edgeInsets = NSEdgeInsetsMake(0, 0, width, 0);
        } else {
            self.leftStackView.edgeInsets = NSEdgeInsetsMake(0, 0, 0, 0);
        }
        if (!self.graphScrollView.verticalScroller.hidden) {
            NSScroller *scroller = self.graphScrollView.verticalScroller;
            CGFloat width = [NSScroller scrollerWidthForControlSize:scroller.controlSize scrollerStyle:scroller.scrollerStyle];
            self.rulePhoneView.rightEdgeInset = width;
        } else {
            self.rulePhoneView.rightEdgeInset = 0;
        }
    } else {
        self.leftStackView.edgeInsets = NSEdgeInsetsMake(0, 0, 0, 0);
        self.rulePhoneView.rightEdgeInset = 0;
    }
}

- (IBAction)logHorizontalConstraints:(id)sender;
{
    NSLog(@"%s", __PRETTY_FUNCTION__);

    NSLog(@"scrollview horizontal constraints:\n%@", [self.leftScrollView constraintsAffectingLayoutForOrientation:NSLayoutConstraintOrientationHorizontal]);
    NSLog(@"stackview horizontal constraints:\n%@", [self.leftStackView constraintsAffectingLayoutForOrientation:NSLayoutConstraintOrientationHorizontal]);
}

- (IBAction)updateScale:(id)sender;
{
    double scale = [sender doubleValue];
    self.rulePhoneView.scale = scale;

    for (MAGraphView *graphView in self.graphViews) {
        graphView.scale = scale;
    }
}

//- (void)updateGraphTracking:(NSDictionary *)userInfo;
//{
//    //NSLog(@"%s, userInfo: %@", __PRETTY_FUNCTION__, userInfo);
//
//    NSNumber *time = userInfo[@"time"];
//    if (time != nil) {
//        // TODO: Use formatter instead.
//        self.mouseTimeField.stringValue = [NSString stringWithFormat:@"%.0f", time.doubleValue];
//    } else {
//        self.mouseTimeField.stringValue = @"---";
//    }
//
//    NSNumber *value = userInfo[@"value"];
//    if (userInfo[@"value"] != nil) {
//        self.mouseValueField.stringValue = [NSString stringWithFormat:@"%.1f", value.doubleValue];
//    } else {
//        self.mouseValueField.stringValue = @"---";
//    }
//}

- (void)scrollerVisibilityDidChange:(NSNotification *)notification;
{
    [self updateLeftScrollViewInset];
}

#pragma mark - MAGraphViewDelegate

- (void)graphView:(MAGraphView *)graphView didSelectXPosition:(CGFloat)xPosition;
{
    for (MAGraphView *graphView in self.graphViews) {
        graphView.selectedXPosition = xPosition;
    }
}

- (void)graphView:(MAGraphView *)graphView trackingTime:(NSNumber *)time value:(NSNumber *)value;
{
    if (time != nil) {
        // TODO: Use formatter instead.
        self.mouseTimeField.stringValue = [NSString stringWithFormat:@"%.0f", time.doubleValue];
    } else {
        self.mouseTimeField.stringValue = @"---";
    }

    if (value != nil) {
        self.mouseValueField.stringValue = [NSString stringWithFormat:@"%.1f", value.doubleValue];
    } else {
        self.mouseValueField.stringValue = @"---";
    }
}

@end

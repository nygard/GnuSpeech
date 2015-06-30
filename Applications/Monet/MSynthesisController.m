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

#define MDK_DefaultUtterances          @"DefaultUtterances"

#define MDK_GraphImagesDirectory       @"GraphImagesDirectory"
#define MDK_SoundOutputDirectory       @"SoundOutputDirectory"
#define MDK_IntonationContourDirectory @"IntonationContourDirectory"

@interface MSynthesisController () <NSTableViewDataSource, NSComboBoxDelegate, NSTextViewDelegate, NSFileManagerDelegate>

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

    NSMutableArray *displayParameters = [[NSMutableArray alloc] init];

    NSArray *parameters = self.model.parameters;
    NSUInteger count = [parameters count];
    for (NSUInteger index = 0; index < count && index < 16; index++) { // TODO (2004-03-30): Some hardcoded limits exist in Event
        MMParameter *currentParameter = parameters[index];
		
        MMDisplayParameter *displayParameter = [[MMDisplayParameter alloc] initWithParameter:currentParameter];
        displayParameter.tag = currentTag++;
        [displayParameters addObject:displayParameter];
    }
	
    for (NSUInteger index = 0; index < count && index < 16; index++) { // TODO (2004-03-30): Some hardcoded limits exist in Event
        MMParameter *currentParameter = parameters[index];
		
        MMDisplayParameter *displayParameter = [[MMDisplayParameter alloc] initWithParameter:currentParameter];
        displayParameter.isSpecial = YES;
        displayParameter.tag = currentTag++;
        [displayParameters addObject:displayParameter];
    }

    // TODO (2004-03-30): This used to have Intonation (tag=32).  How did that work?

    _displayParameters = displayParameters;

    for (NSView *view in self.leftStackView.views) {
        [self.leftStackView removeView:view];
    }

    for (MMDisplayParameter *displayParameter in _displayParameters) {
        MAGraphNameView *graphNameView = [[MAGraphNameView alloc] initWithFrame:CGRectZero];
        graphNameView.translatesAutoresizingMaskIntoConstraints = NO;
        graphNameView.displayParameter = displayParameter;
        [self.leftStackView addView:graphNameView inGravity:NSStackViewGravityTop];


        MAGraphView *gv1 = [[MAGraphView alloc] initWithFrame:CGRectMake(0, 0, 300, 100)];
        gv1.translatesAutoresizingMaskIntoConstraints = NO;
        gv1.displayParameter = displayParameter;
        gv1.eventList = self.eventList;
        [self.graphStackView addView:gv1 inGravity:NSStackViewGravityTop];

        if (!displayParameter.shouldDisplay) {
            [self.leftStackView  setVisibilityPriority:NSStackViewVisibilityPriorityNotVisible forView:graphNameView];
            [self.graphStackView setVisibilityPriority:NSStackViewVisibilityPriorityNotVisible forView:gv1];
        }
    }
}

- (void)_updateDisplayedParameters;
{
    NSMutableArray *array = [[NSMutableArray alloc] init];

    for (MMDisplayParameter *displayParameter in _displayParameters) {
        if ([displayParameter shouldDisplay])
            [array addObject:displayParameter];
    }

    for (NSView *view in self.leftStackView.views) {
        if ([view respondsToSelector:@selector(displayParameter)]) {
            MAGraphNameView *graphNameView = (MAGraphNameView *)view;
            MMDisplayParameter *displayParameter = graphNameView.displayParameter;
            if ([displayParameter shouldDisplay]) {
                [self.leftStackView setVisibilityPriority:NSStackViewVisibilityPriorityMustHold forView:graphNameView];
            } else {
                [self.leftStackView setVisibilityPriority:NSStackViewVisibilityPriorityNotVisible forView:graphNameView];
            }
        }
    }

    for (NSView *view in self.graphStackView.views) {
        if ([view respondsToSelector:@selector(displayParameter)]) {
            MAGraphView *graphView = (MAGraphView *)view;
            MMDisplayParameter *displayParameter = graphView.displayParameter;
            if ([displayParameter shouldDisplay]) {
                [self.graphStackView setVisibilityPriority:NSStackViewVisibilityPriorityMustHold forView:graphView];
            } else {
                [self.graphStackView setVisibilityPriority:NSStackViewVisibilityPriorityNotVisible forView:graphView];
            }
        }
    }
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
    self.synthesizer.fileType = 0;
    self.synthesizer.filename = [basePath stringByAppendingPathComponent:@"output.au"];
    self.synthesizer.shouldSaveToSoundFile = YES;
    [self.synthesizer synthesize];

    // 3. Copy /tmp/Monet.parameters.
    // TODO: (2015-06-29) Would be better just to save it there directly during synthesis.
    error = nil;
    if (![fileManager copyItemAtPath:@"/tmp/Monet.parameters" toPath:[basePath stringByAppendingPathComponent:@"Monet.parameters"] error:&error]) {
        NSLog(@"Error: %@", error);
        return;
    }

    // 4. Create the index.html xml tree
    // 5. Save series of images, and add reference to HTML as we go.  Going to say we only show the graphs the user has selected to display.
    // 6. Save the HTML.
    // 7. Open the HTML. (LaunchServices)
#if 0
    NSMutableString *html = [NSMutableString string];
	
    [html appendString:@"<?xml version='1.0' encoding='utf-8'?>\n"];
    [html appendString:@"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n"];
    [html appendString:@"<html xmlns='http://www.w3.org/1999/xhtml' xml:lang='en' lang='en'>\n"];
    [html appendString:@"  <head>\n"];
    [html appendString:@"    <title>Monet Parameter Graphs</title>\n"];
    [html appendString:@"    <meta http-equiv='Content-type' content='text/html; charset=utf-8'/>\n"];
    [html appendString:@"  </head>\n"];
    [html appendString:@"  <body>\n"];
    [html appendString:@"    <p>Parameter graphs for phone string:</p>\n"];
    [html appendFormat:@"    <p>%@</p>\n", GSXMLCharacterData([_textStringTextField stringValue])];
    [html appendString:@"    <p>[<a href='Monet.parameters'>Monet.parameters</a>] [<a href='output.au'>output.au</a>]</p>\n"];
    [html appendString:@"    <p><object type='audio/basic' data='output.au'></object></p>\n"];
    [html appendFormat:@"    <p>Generated %@</p>\n", GSXMLCharacterData([[NSCalendarDate calendarDate] description])];
    [html appendString:@"    <p>\n"];


    NSDictionary *jpegProperties = @{
                                     NSImageCompressionFactor : @(0.95),
                                     };

    NSUInteger number = 1;

    NSUInteger count = [_displayParameters count];
    for (NSUInteger index = 0; index < count; index += 4) {
        NSMutableArray *parms = [[NSMutableArray alloc] init];
        for (NSUInteger offset = 0; offset < 4 && index + offset < count; offset++) {
            [parms addObject:[_displayParameters objectAtIndex:index + offset]];
        }
        [_eventListView setDisplayParameters:parms];
		
        NSData *pdfData = [_eventListView dataWithPDFInsideRect:[_eventListView bounds]];
        NSString *filename1 = [NSString stringWithFormat:@"graph-%lu.pdf", number];
        [pdfData writeToFile:[basePath stringByAppendingPathComponent:filename1] atomically:YES];
        [html appendFormat:@"      <img src='%@' alt='parameter graph %lu'/>\n", GSXMLAttributeString(filename1, YES), number];
		
        NSImage *image = [[NSImage alloc] initWithData:pdfData];
        //NSLog(@"image: %@", image);
		
        // Generate TIFF data first, otherwise JPEG generation fails.
        NSData *tiffData = [image TIFFRepresentationUsingCompression:NSTIFFCompressionLZW factor:0.95];
		
        NSBitmapImageRep *bitmapImageRep = [[NSBitmapImageRep alloc] initWithData:tiffData];
        //NSLog(@"bitmapImageRep: %@, size: %@", bitmapImageRep, NSStringFromSize([bitmapImageRep size]));
        //NSLog(@"bitsPerPixel: %d, samplesPerPixel: %d", [bitmapImageRep bitsPerPixel], [bitmapImageRep samplesPerPixel]);
		
        NSData *jpegData = [bitmapImageRep representationUsingType:NSJPEGFileType properties:jpegProperties];
        NSString *filename2 = [NSString stringWithFormat:@"graph-%lu.jpg", number];
        [jpegData writeToFile:[basePath stringByAppendingPathComponent:filename2] atomically:YES];

        number++;
    }
	
    [html appendString:@"    </p>\n"];
    [html appendString:@"  </body>\n"];
    [html appendString:@"</html>\n"];
	
    [[html dataUsingEncoding:NSUTF8StringEncoding] writeToFile:[basePath stringByAppendingPathComponent:@"index.html"] atomically:YES];
	

    [self _updateDisplayedParameters];
	
    system([[NSString stringWithFormat:@"open %@", [basePath stringByAppendingPathComponent:@"index.html"]] UTF8String]);
#endif
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
}

- (void)scrollViewDidScroll:(NSNotification *)notification;
{
    if (notification.object == self.graphScrollView) {
        NSRect r1 = self.graphScrollView.documentVisibleRect;
        NSRect r2 = self.leftScrollView.documentVisibleRect;
        r2 = self.leftStackView.visibleRect;

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

    // TODO: (2015-06-27) Probably easier just to keep our own array of the MAGraphViews and iterate through that.
    for (NSView *view in self.graphStackView.views) {
        if ([view respondsToSelector:@selector(setScale:)]) {
            [(MAGraphView *)view setScale:scale];
        }
    }
}

- (void)updateGraphTracking:(NSDictionary *)userInfo;
{
    //NSLog(@"%s, userInfo: %@", __PRETTY_FUNCTION__, userInfo);

    NSNumber *time = userInfo[@"time"];
    if (time != nil) {
        // TODO: Use formatter instead.
        self.mouseTimeField.stringValue = [NSString stringWithFormat:@"%.0f", time.doubleValue];
    } else {
        self.mouseTimeField.stringValue = @"---";
    }

    NSNumber *value = userInfo[@"value"];
    if (userInfo[@"value"] != nil) {
        self.mouseValueField.stringValue = [NSString stringWithFormat:@"%.1f", value.doubleValue];
    } else {
        self.mouseValueField.stringValue = @"---";
    }
}

- (void)scrollerVisibilityDidChange:(NSNotification *)notification;
{
    [self updateLeftScrollViewInset];
}

@end

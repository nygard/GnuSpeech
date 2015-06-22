//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MSynthesisController.h"

#import <GnuSpeech/GnuSpeech.h>

#import "NSNumberFormatter-Extensions.h"

#import "EventListView.h"
#import "MAIntonationScrollView.h"
#import "MAIntonationView.h"
#import "MExtendedTableView.h"
#import "MMDisplayParameter.h"

#import "MIntonationParameterEditor.h"
#import "MMIntonation-Monet.h"
#import "MEventTableController.h"

#define MDK_DefaultUtterances          @"DefaultUtterances"

#define MDK_GraphImagesDirectory       @"GraphImagesDirectory"
#define MDK_SoundOutputDirectory       @"SoundOutputDirectory"
#define MDK_IntonationContourDirectory @"IntonationContourDirectory"

@interface MSynthesisController () <NSTableViewDataSource, NSComboBoxDelegate, NSTextViewDelegate, EventListDelegate, NSFileManagerDelegate>

@property (readonly) EventList *eventList;
@property (readonly) TRMSynthesizer *synthesizer;
@property (strong) STLogger *logger;
@property (strong) MEventTableController *eventTableController;

@end

#pragma mark -

@implementation MSynthesisController
{
    // Synthesis window
	IBOutlet NSComboBox *_textStringTextField;
	IBOutlet NSTextView *_phoneStringTextView;
    IBOutlet NSTableView *_parameterTableView;
    IBOutlet EventListView *_eventListView;
	IBOutlet NSScrollView *_scrollView;
    IBOutlet NSButton *_parametersStore;

	IBOutlet NSTextField *_mouseTimeField;
    IBOutlet NSTextField *_mouseValueField;

    // Save panel accessory view
    IBOutlet NSView *_savePanelAccessoryView;
    IBOutlet NSPopUpButton *_fileTypePopUpButton;

    // Intonation window
    IBOutlet NSWindow *_intonationWindow;
    IBOutlet MAIntonationScrollView *_intonationScrollView;
    IBOutlet MAIntonationView *_intonationView;

    IBOutlet NSTextField *_semitoneTextField;
    IBOutlet NSTextField *_hertzTextField;
    IBOutlet NSTextField *_slopeTextField;

    IBOutlet NSTableView *_intonationRuleTableView;
    IBOutlet NSTextField *_beatTextField;
    IBOutlet NSTextField *_beatOffsetTextField;
    IBOutlet NSTextField *_absTimeTextField;

    NSPrintInfo *_intonationPrintInfo;

    MModel *_model;
    NSArray *_displayParameters;
    EventList *_eventList;
    STLogger *_logger;

    TRMSynthesizer *_synthesizer;

	MMTextToPhone *_textToPhone;

    MEventTableController *_eventTableController;
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
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(intonationPointDidChange:)
                                                     name:EventListDidChangeIntonationPoints
                                                   object:_eventList];
        
        [self setWindowFrameAutosaveName:@"Synthesis"];
        
        _synthesizer = [[TRMSynthesizer alloc] init];
        
        _textToPhone = [[MMTextToPhone alloc] init];
        
        _intonationPrintInfo = [[NSPrintInfo alloc] init];
        [_intonationPrintInfo setHorizontalPagination:NSAutoPagination];
        [_intonationPrintInfo setVerticalPagination:NSFitPagination];
        [_intonationPrintInfo setOrientation:NSPaperOrientationLandscape];

        _eventTableController = [[MEventTableController alloc] init];
        _eventTableController.eventList = _eventList;
    }
	
    return self;
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

- (MModel *)model;
{
    return _model;
}

- (void)setModel:(MModel *)newModel;
{
    if (newModel != _model) {
        _model = newModel;
        
        [_eventList setModel:_model];
        [_intonationRuleTableView reloadData]; // Because EventList doesn't send out a notification yet.
        
        [self _updateDisplayParameters];
        self.eventTableController.displayParameters = _displayParameters;
    }
}

- (NSUndoManager *)undoManager;
{
    return nil;
}

- (void)windowDidLoad;
{
	// Added by dalmazio, April 11, 2009.
	_eventListView = [[EventListView alloc] initWithFrame:[[_scrollView contentView] frame]];
	[_eventListView setAutoresizingMask:[_scrollView autoresizingMask]];
	[_eventListView setMouseTimeField:_mouseTimeField];
	[_eventListView setMouseValueField:_mouseValueField];
	[_scrollView setDocumentView:_eventListView];
	
    [_intonationWindow setFrameAutosaveName:@"Intonation"];

    NSButtonCell *checkboxCell = [[NSButtonCell alloc] initTextCell:@""];
    [checkboxCell setControlSize:NSSmallControlSize];
    [checkboxCell setButtonType:NSSwitchButton];
    [checkboxCell setImagePosition:NSImageOnly];
    [checkboxCell setEditable:NO];
	
    [[_parameterTableView tableColumnWithIdentifier:@"shouldDisplay"] setDataCell:checkboxCell];

	
    NSNumberFormatter *defaultNumberFormatter = [NSNumberFormatter defaultNumberFormatter];
    [_semitoneTextField setFormatter:defaultNumberFormatter];
    [_hertzTextField setFormatter:defaultNumberFormatter];
    [_slopeTextField setFormatter:defaultNumberFormatter];
    [_beatTextField setFormatter:defaultNumberFormatter];
    [_beatOffsetTextField setFormatter:defaultNumberFormatter];
    [_absTimeTextField setFormatter:defaultNumberFormatter];
	
    [_intonationView setDelegate:self];
    [_intonationView setEventList:_eventList];
	
    [self _updateSelectedPointDetails];

    [_textStringTextField removeAllItems];
    [_textStringTextField addItemsWithObjectValues:[[NSUserDefaults standardUserDefaults] objectForKey:MDK_DefaultUtterances]];
    [_textStringTextField selectItemAtIndex:0];
	[_phoneStringTextView setFont:[NSFont fontWithName:@"Lucida Grande" size:13]];	
	[_phoneStringTextView setString:[_textToPhone phoneForText:[_textStringTextField stringValue]]];

    [self _updateDisplayParameters];
    self.eventTableController.displayParameters = _displayParameters;
}

#pragma mark -

- (void)_updateDisplayParameters;
{
    NSInteger currentTag = 0;

    NSMutableArray *displayParameters = [[NSMutableArray alloc] init];

    NSArray *parameters = [_model parameters];
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
	
    [_parameterTableView reloadData];
}

- (void)_updateDisplayedParameters;
{
    NSUInteger count, index;
	
    NSMutableArray *array = [[NSMutableArray alloc] init];
    count = [_displayParameters count];
    for (index = 0; index < count; index++) {
        MMDisplayParameter *displayParameter = [_displayParameters objectAtIndex:index];
        if ([displayParameter shouldDisplay])
            [array addObject:displayParameter];
    }
    [_eventListView setDisplayParameters:array];
	
    [_parameterTableView reloadData];
}

- (void)_updateSelectedPointDetails;
{
    MMIntonationPoint *selectedIntonationPoint = [self selectedIntonationPoint];
	
    if (selectedIntonationPoint == nil) {
        [_semitoneTextField setStringValue:@""];
        [_hertzTextField setStringValue:@""];
        [_slopeTextField setStringValue:@""];
        [_beatTextField setStringValue:@""];
        [_beatOffsetTextField setStringValue:@""];
        [_absTimeTextField setStringValue:@""];
    } else {
        [_semitoneTextField setDoubleValue:[selectedIntonationPoint semitone]];
        [_hertzTextField setDoubleValue:[selectedIntonationPoint semitoneInHertz]];
        [_slopeTextField setDoubleValue:[selectedIntonationPoint slope]];
        [_beatTextField setDoubleValue:[selectedIntonationPoint beatTime]];
        [_beatOffsetTextField setDoubleValue:[selectedIntonationPoint offsetTime]];
        [_absTimeTextField setDoubleValue:[selectedIntonationPoint absoluteTime]];
		
        [_intonationRuleTableView scrollRowToVisible:[selectedIntonationPoint ruleIndex]];
        [_intonationRuleTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:[selectedIntonationPoint ruleIndex]] byExtendingSelection:NO];
    }
}

- (IBAction)showEventTable:(id)sender;
{
    [self.eventTableController showWindow:self];
}

- (IBAction)showIntonationWindow:(id)sender;
{
    [self window]; // Make sure the nib is loaded
    [_intonationWindow makeKeyAndOrderFront:self];
}

- (IBAction)synthesizeWithSoftware:(id)sender;
{
    NSLog(@" > %s", __PRETTY_FUNCTION__);
    [self.synthesizer setShouldSaveToSoundFile:NO];
    [self synthesize];
    NSLog(@"<  %s", __PRETTY_FUNCTION__);
}

- (IBAction)synthesizeToFile:(id)sender;
{
    NSLog(@" > %s", __PRETTY_FUNCTION__);
	
    NSString *directory = [[NSUserDefaults standardUserDefaults] objectForKey:MDK_SoundOutputDirectory];
	
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setCanSelectHiddenExtension:YES];
    [savePanel setAllowedFileTypes:[NSArray arrayWithObjects:@"au", @"aiff", @"wav", nil]];
    [savePanel setAccessoryView:_savePanelAccessoryView];
    if (directory != nil)
        [savePanel setDirectoryURL:[NSURL fileURLWithPath:directory]];
    [self fileTypeDidChange:nil];
    // TODO (2012-04-18): Might need to set up "Untitled" in name
	
    [savePanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            [[NSUserDefaults standardUserDefaults] setObject:[[savePanel directoryURL] path] forKey:MDK_SoundOutputDirectory];
            [self.synthesizer setShouldSaveToSoundFile:YES];
            [self.synthesizer setFileType:[[_fileTypePopUpButton selectedItem] tag]];
            [self.synthesizer setFilename:[[savePanel URL] path]];
            [self synthesize];
        }
    }];
	
    NSLog(@"<  %s", __PRETTY_FUNCTION__);
}

- (void)synthesize;
{
	NSString *phoneString = [self getAndSyncPhoneString];
		
    [self prepareForSynthesis];
	
    [_eventList parsePhoneString:phoneString]; // This creates the tone groups, feet.
    [_eventList applyRhythm];
    [_eventList applyRules]; // This applies the rules, adding events to the EventList.
    [_eventList generateIntonationPoints];
    [_intonationRuleTableView reloadData];
	
    [self continueSynthesis];
}

- (NSString *)getAndSyncPhoneString;
{
	NSString *phoneString = [[_phoneStringTextView string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if (phoneString == NULL || [phoneString length] == 0) {
		phoneString = [[_textToPhone phoneForText:[_textStringTextField stringValue]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		[_phoneStringTextView setFont:[NSFont fontWithName:@"Lucida Grande" size:13]];
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
	
    [savePanel setAllowedFileTypes:[NSArray arrayWithObject:extension]];
}

- (void)parseText:(id)sender;
{
	NSString *phoneString = [_textToPhone phoneForText:[_textStringTextField stringValue]];
	[_phoneStringTextView setTextColor:[NSColor blackColor]];	
	[_phoneStringTextView setString:phoneString];
	[_textStringTextField setTextColor:[NSColor blackColor]];

}

- (IBAction)synthesizeWithContour:(id)sender;
{
    [_eventList clearIntonationEvents];
    [self.synthesizer setShouldSaveToSoundFile:NO];
    [self continueSynthesis];
}

- (void)prepareForSynthesis;
{
    [_eventList setUp];
	
    [_eventList setPitchMean:[[[self model] synthesisParameters] pitch]];

    MMIntonation *intonation = [[MMIntonation alloc] initFromUserDefaults];
    _eventList.intonation = intonation;

    NSLog(@"%s, drift deviation: %f, cutoff: %f", __PRETTY_FUNCTION__, intonation.driftDeviation, intonation.driftCutoff);
    [_eventList.driftGenerator configureWithDeviation:intonation.driftDeviation sampleRate:500 lowpassCutoff:intonation.driftCutoff];
    //[eventList.driftGenerator setupWithDeviation:0.5 sampleRate:250 lowpassCutoff:0.5];
}

- (void)continueSynthesis;
{
    [_eventList applyIntonation];
	
    //[eventList printDataStructures:@"Before synthesis"];
    self.eventTableController.eventList = _eventList;

    [self.synthesizer setupSynthesisParameters:[[self model] synthesisParameters]]; // TODO (2004-08-22): This may overwrite the file type...
    [self.synthesizer removeAllParameters];
    
    [_eventList setDelegate:self];
    [_eventList generateOutput];
    [_eventList setDelegate:nil];
	
    [self.synthesizer synthesize];
	
    [_eventListView setEventList:_eventList];
    [_eventListView display]; // TODO (2004-03-17): It's not updating otherwise
	
    [_intonationView updateEvents]; // Because it doesn't post notifications yet.  We need to resize the width.
}

- (IBAction)generateContour:(id)sender;
{
    NSLog(@" > %s", __PRETTY_FUNCTION__);
	
    MMIntonation *intonation = [[MMIntonation alloc] initFromUserDefaults];
    _eventList.intonation = intonation;

    [_intonationView setShouldDrawSmoothPoints:[[NSUserDefaults standardUserDefaults] boolForKey:MDK_ShouldUseSmoothIntonation]];
	
    [_eventList generateIntonationPoints];
    [_intonationRuleTableView reloadData];
    self.eventTableController.eventList = _eventList;
    if ([[_eventList intonationPoints] count] > 0)
        [_intonationView selectIntonationPoint:[[_eventList intonationPoints] objectAtIndex:0]];
    [_intonationScrollView display];
	
    NSLog(@"<  %s", __PRETTY_FUNCTION__);
}

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
    NSUInteger count, index, offset;
    NSDictionary *jpegProperties = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
	
    NSLog(@" > %s", __PRETTY_FUNCTION__);
	
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
	
    NSUInteger number = 1;
	
    NSError *error = nil;
    if (![fileManager createDirectoryAtPath:basePath withIntermediateDirectories:NO attributes:nil error:&error]) {
        NSLog(@"Error: %@", error);
    }
    error = nil;
    if (![fileManager copyItemAtPath:@"/tmp/Monet.parameters" toPath:[basePath stringByAppendingPathComponent:@"Monet.parameters"] error:&error]) {
        NSLog(@"Error: %@", error);
    }

    jpegProperties = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithFloat:0.95], NSImageCompressionFactor,
					  nil];

    count = [_displayParameters count];
    for (index = 0; index < count; index += 4) {
        NSMutableArray *parms = [[NSMutableArray alloc] init];
        for (offset = 0; offset < 4 && index + offset < count; offset++) {
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
	
    [self.synthesizer setFileType:0];
    [self.synthesizer setFilename:[basePath stringByAppendingPathComponent:@"output.au"]];
    [self.synthesizer setShouldSaveToSoundFile:YES];
    [self.synthesizer synthesize];
	
    [self _updateDisplayedParameters];
	
    system([[NSString stringWithFormat:@"open %@", [basePath stringByAppendingPathComponent:@"index.html"]] UTF8String]);
	
    NSLog(@"<  %s", __PRETTY_FUNCTION__);
}

- (IBAction)addTextString:(id)sender;
{
    NSString *str = [_textStringTextField stringValue];
    [_textStringTextField removeItemWithObjectValue:str];
    [_textStringTextField insertItemWithObjectValue:str atIndex:0];
	[_textStringTextField setTextColor:[NSColor blackColor]];

	str = [[_textToPhone phoneForText:[_textStringTextField stringValue]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	[_phoneStringTextView setFont:[NSFont fontWithName:@"Lucida Grande" size:13]];
	[_phoneStringTextView setString:str];
	[_phoneStringTextView setTextColor:[NSColor blackColor]];
	
    [[NSUserDefaults standardUserDefaults] setObject:[_textStringTextField objectValues] forKey:MDK_DefaultUtterances];
}

#pragma mark - Intonation Point details

- (MMIntonationPoint *)selectedIntonationPoint;
{
    return [_intonationView selectedIntonationPoint];
}

- (IBAction)setSemitone:(id)sender;
{
    [[self selectedIntonationPoint] setSemitone:[_semitoneTextField doubleValue]];
}

- (IBAction)setHertz:(id)sender;
{
    [[self selectedIntonationPoint] setSemitoneInHertz:[_hertzTextField doubleValue]];
}

- (IBAction)setSlope:(id)sender;
{
    [[self selectedIntonationPoint] setSlope:[_slopeTextField doubleValue]];
}

- (IBAction)setBeatOffset:(id)sender;
{
    [[self selectedIntonationPoint] setOffsetTime:[_beatOffsetTextField doubleValue]];
}

- (IBAction)openIntonationContour:(id)sender;
{
    NSString *directory = [[NSUserDefaults standardUserDefaults] objectForKey:MDK_IntonationContourDirectory];
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setAllowedFileTypes:[NSArray arrayWithObject:@"org.gnu.gnuspeech.intonation-contour"]];
    if (directory != nil)
        [openPanel setDirectoryURL:[NSURL fileURLWithPath:directory]];
	
    [openPanel beginSheetModalForWindow:_intonationWindow completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            [[NSUserDefaults standardUserDefaults] setObject:[[openPanel directoryURL] path] forKey:MDK_IntonationContourDirectory];
			
            [self prepareForSynthesis];
			
            [_eventList loadIntonationContourFromXMLFile:[[openPanel URL] path]];
			
            //[phoneStringTextField setStringValue:[eventList phoneString]];
            [_intonationRuleTableView reloadData];
        }
    }];
}

- (IBAction)saveIntonationContour:(id)sender;
{
    NSString *directory = [[NSUserDefaults standardUserDefaults] objectForKey:MDK_IntonationContourDirectory];
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"org.gnu.gnuspeech.intonation-contour"]];
    if (directory != nil)
        [savePanel setDirectoryURL:[NSURL fileURLWithPath:directory]];

    [savePanel beginSheetModalForWindow:_intonationWindow completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            [[NSUserDefaults standardUserDefaults] setObject:[[savePanel directoryURL] path] forKey:MDK_IntonationContourDirectory];
            [_eventList writeXMLToFile:[[savePanel URL] path] comment:nil];
        }
    }];
}

- (IBAction)runPageLayout:(id)sender;
{
    NSPageLayout *pageLayout = [NSPageLayout pageLayout];
    [pageLayout runModalWithPrintInfo:_intonationPrintInfo];
}

// Currently set up to print the intonation contour.
- (IBAction)printDocument:(id)sender;
{
    NSSize printableSize = [_intonationScrollView printableSize];
    NSRect printFrame;
    printFrame.origin = NSZeroPoint;
    printFrame.size = [NSScrollView frameSizeForContentSize:printableSize horizontalScrollerClass:nil verticalScrollerClass:nil borderType:NSNoBorder controlSize:NSRegularControlSize scrollerStyle:NSScrollerStyleLegacy];

    MAIntonationScrollView *printView = [[MAIntonationScrollView alloc] initWithFrame:printFrame];
    [printView setBorderType:NSNoBorder];
    [printView setHasHorizontalScroller:NO];
	
    [[printView documentView] setEventList:_eventList];
    [[printView documentView] setShouldDrawSelection:NO];
    [[printView documentView] setShouldDrawSmoothPoints:[_intonationView shouldDrawSmoothPoints]];
	
    NSPrintOperation *printOperation = [NSPrintOperation printOperationWithView:printView printInfo:_intonationPrintInfo];
    [printOperation setShowsPrintPanel:YES];
    [printOperation setShowsProgressPanel:YES];
	
    [printOperation runOperation];
}

- (void)intonationPointDidChange:(NSNotification *)aNotification;
{
    [self _updateSelectedPointDetails];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
{
    if (tableView == _parameterTableView)
        return [_displayParameters count];
	
    if (tableView == _intonationRuleTableView)
        return [_eventList ruleCount];

    return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
    id identifier = [tableColumn identifier];
	
    if (tableView == _parameterTableView) {
        MMDisplayParameter *displayParameter = [_displayParameters objectAtIndex:row];
		
        if ([@"name" isEqual:identifier]) {
            return [displayParameter name];
        } else if ([@"shouldDisplay" isEqual:identifier]) {
            return [NSNumber numberWithBool:[displayParameter shouldDisplay]];
        }
    } else if (tableView == _intonationRuleTableView) {
        if ([@"rule" isEqual:identifier]) {
            return [_eventList ruleDescriptionAtIndex:row];
        } else if ([@"number" isEqual:identifier]) {
            return [NSString stringWithFormat:@"%lu.", row + 1];
        }
    }
	
    return nil;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
    id identifier = [tableColumn identifier];
	
    if (tableView == _parameterTableView) {
        MMDisplayParameter *displayParameter = [_displayParameters objectAtIndex:row];
		
        if ([@"shouldDisplay" isEqual:identifier]) {
            [displayParameter setShouldDisplay:[object boolValue]];
            [self _updateDisplayedParameters];
        }
    }
}

#pragma mark - MExtendedTableView delegate

- (BOOL)control:(NSControl *)control shouldProcessCharacters:(NSString *)characters;
{
    if ([characters isEqualToString:@" "]) {
        NSInteger selectedRow = [_parameterTableView selectedRow];
        if (selectedRow != -1) {
            [[_displayParameters objectAtIndex:selectedRow] toggleShouldDisplay];
            [self _updateDisplayedParameters];
            [(MExtendedTableView *)control doNotCombineNextKey];
            return NO;
        }
    } else {
        NSUInteger count, index;
		
        count = [_displayParameters count];
        for (index = 0; index < count; index++) {
            if ([[[[_displayParameters objectAtIndex:index] parameter] name] hasPrefix:characters ignoreCase:YES]) {
                [_parameterTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
                [_parameterTableView scrollRowToVisible:index];
                return NO;
            }
        }
    }
	
    return YES;
}

#pragma mark - MAIntonationView delegate

- (void)intonationViewSelectionDidChange:(NSNotification *)notification;
{
    [self _updateSelectedPointDetails];
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
		[_phoneStringTextView setFont:[NSFont fontWithName:@"Lucida Grande" size:13]];
		[_phoneStringTextView setString:phoneString];
	}
	[_phoneStringTextView setTextColor:[NSColor blackColor]];	
	[_textStringTextField setTextColor:[NSColor redColor]];
}

#pragma mark - EventListDelegate

- (void)eventListWillGenerateOutput:(EventList *)eventList;
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    // Open file and save initial parameters
    if ([_parametersStore state]) {
        NSError *error = nil;
        STLogger *logger = [[STLogger alloc] initWithOutputToPath:@"/tmp/Monet.parameters" error:&error];
        if (logger == nil) {
            NSLog(@"Error logging to file: %@", error);
        } else {
            self.logger = logger;
        }
        
        [self.model.synthesisParameters logToLogger:self.logger];
    }
}

- (void)eventList:(EventList *)eventList generatedOutputValues:(float *)valPtr valueCount:(NSUInteger)count;
{
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    [self.synthesizer addParameters:valPtr];
    // Write values to file
    NSMutableArray *a1 = [NSMutableArray array];
    for (NSUInteger index = 0; index < count; index++)
        [a1 addObject:[NSString stringWithFormat:@"%.3f", valPtr[index]]];
    [self.logger log:@"%@", [a1 componentsJoinedByString:@" "]];
}

- (void)eventListDidGenerateOutput:(EventList *)eventList;
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    // Close file
    self.logger = nil;
}

@end

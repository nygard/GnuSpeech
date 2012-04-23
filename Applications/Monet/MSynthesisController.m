//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MSynthesisController.h"

#include <sys/time.h>
#import <GnuSpeech/GnuSpeech.h>

#import "NSNumberFormatter-Extensions.h"

#import "EventListView.h"
#import "MAIntonationScrollView.h"
#import "MAIntonationView.h"
#import "MExtendedTableView.h"
#import "MMDisplayParameter.h"

#define MDK_ShouldUseSmoothIntonation  @"ShouldUseSmoothIntonation"
#define MDK_ShouldUseMacroIntonation   @"ShouldUseMacroIntonation"
#define MDK_ShouldUseMicroIntonation   @"ShouldUseMicroIntonation"
#define MDK_ShouldUseDrift             @"ShouldUseDrift"
#define MDK_DefaultUtterances          @"DefaultUtterances"

#define MDK_GraphImagesDirectory       @"GraphImagesDirectory"
#define MDK_SoundOutputDirectory       @"SoundOutputDirectory"
#define MDK_IntonationContourDirectory @"IntonationContourDirectory"

@interface MSynthesisController () <NSTableViewDataSource, NSTableViewDelegate, NSComboBoxDelegate, NSTextViewDelegate>

- (void)_updateDisplayParameters;
- (void)_updateEventColumns;
- (void)updateViews;
- (void)_updateDisplayedParameters;
- (void)_takeIntonationParametersFromUI;
- (void)_updateSelectedPointDetails;

- (void)synthesize;
- (NSString *)getAndSyncPhoneString;
- (void)prepareForSynthesis;
- (void)continueSynthesis;

- (void)intonationPointDidChange:(NSNotification *)aNotification;
- (void)saveGraphImagesToPath:(NSString *)basePath;

@end

#pragma mark -

@implementation MSynthesisController
{
    // Synthesis window
	IBOutlet NSComboBox *textStringTextField;
	IBOutlet NSTextView *phoneStringTextView;
    IBOutlet NSTableView *parameterTableView;
    IBOutlet EventListView *eventListView;
	IBOutlet NSScrollView *scrollView;
    IBOutlet NSButton *parametersStore;
	
	IBOutlet NSTextField *mouseTimeField;
    IBOutlet NSTextField *mouseValueField;
	
    // Save panel accessory view
    IBOutlet NSView *savePanelAccessoryView;
    IBOutlet NSPopUpButton *fileTypePopUpButton;
	
    // Intonation parameter window
    IBOutlet NSWindow *intonationParameterWindow;
	
    IBOutlet NSTextField *tempoField;
    IBOutlet NSForm *intonParmsField;
    IBOutlet NSTextField *radiusMultiplyField;
	
    IBOutlet NSMatrix *intonationMatrix;
    IBOutlet NSTextField *driftDeviationField;
    IBOutlet NSTextField *driftCutoffField;
    IBOutlet NSButton *smoothIntonationSwitch;
	
    // Intonation window
    IBOutlet NSWindow *intonationWindow;
    IBOutlet MAIntonationScrollView *intonationView;
	
    IBOutlet NSTextField *semitoneTextField;
    IBOutlet NSTextField *hertzTextField;
    IBOutlet NSTextField *slopeTextField;
	
    IBOutlet NSTableView *intonationRuleTableView;
    IBOutlet NSTextField *beatTextField;
    IBOutlet NSTextField *beatOffsetTextField;
    IBOutlet NSTextField *absTimeTextField;
	
    NSPrintInfo *intonationPrintInfo;
	
    struct _intonationParameters intonationParameters;
	
    MModel *model;
    NSMutableArray *displayParameters;
    EventList *eventList;
	
    TRMSynthesizer *synthesizer;
	
	MMTextToPhone *textToPhone;
	
    // Event Table stuff
    IBOutlet NSTableView *eventTableView;
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
	
    NSMutableDictionary *defaultValues = [[[NSMutableDictionary alloc] init] autorelease];
    [defaultValues setObject:defaultUtterances forKey:MDK_DefaultUtterances];
    [defaultValues setObject:[@"~/Desktop" stringByExpandingTildeInPath] forKey:MDK_GraphImagesDirectory];
    [defaultValues setObject:[@"~/Desktop" stringByExpandingTildeInPath] forKey:MDK_SoundOutputDirectory];
    [defaultValues setObject:[@"~/Desktop" stringByExpandingTildeInPath] forKey:MDK_IntonationContourDirectory];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}

- (id)initWithModel:(MModel *)aModel;
{
    if ((self = [super initWithWindowNibName:@"Synthesis"])) {
        model = [aModel retain];
        displayParameters = [[NSMutableArray alloc] init];
        [self _updateDisplayParameters];
        
        eventList = [[EventList alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(intonationPointDidChange:)
                                                     name:EventListDidChangeIntonationPoints
                                                   object:eventList];
        
        [self setWindowFrameAutosaveName:@"Synthesis"];
        
        synthesizer = [[TRMSynthesizer alloc] init];
        
        textToPhone = [[MMTextToPhone alloc] init];
        
        intonationPrintInfo = [[NSPrintInfo alloc] init];
        [intonationPrintInfo setHorizontalPagination:NSAutoPagination];
        [intonationPrintInfo setVerticalPagination:NSFitPagination];
        [intonationPrintInfo setOrientation:NSLandscapeOrientation];
    }
	
    return self;
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[eventListView release];
	
    [model release];
    [displayParameters release];
    [eventList release];
    [synthesizer release];
	[textToPhone release];
	
    [intonationPrintInfo release];
	
    [super dealloc];
}

#pragma mark -

- (MModel *)model;
{
    return model;
}

- (void)setModel:(MModel *)newModel;
{
    if (newModel != model) {
        [model release];
        model = [newModel retain];
        
        [eventList setModel:model];
        [intonationRuleTableView reloadData]; // Because EventList doesn't send out a notification yet.
        
        [self _updateDisplayParameters];
        [self _updateEventColumns];
        [self updateViews];
    }
}

- (NSUndoManager *)undoManager;
{
    return nil;
}

- (void)windowDidLoad;
{
	// Added by dalmazio, April 11, 2009.
	eventListView = [[EventListView alloc] initWithFrame:[[scrollView contentView] frame]];
	[eventListView setAutoresizingMask:[scrollView autoresizingMask]];
	[eventListView setMouseTimeField:mouseTimeField];
	[eventListView setMouseValueField:mouseValueField];
	[scrollView setDocumentView:eventListView];
	
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
    [intonationParameterWindow setFrameAutosaveName:@"Intonation Parameters"];
    [intonationWindow setFrameAutosaveName:@"Intonation"];
    [[intonationView documentView] setShouldDrawSmoothPoints:[[NSUserDefaults standardUserDefaults] boolForKey:MDK_ShouldUseSmoothIntonation]];
	
    NSButtonCell *checkboxCell = [[NSButtonCell alloc] initTextCell:@""];
    [checkboxCell setControlSize:NSSmallControlSize];
    [checkboxCell setButtonType:NSSwitchButton];
    [checkboxCell setImagePosition:NSImageOnly];
    [checkboxCell setEditable:NO];
	
    [[parameterTableView tableColumnWithIdentifier:@"shouldDisplay"] setDataCell:checkboxCell];
    NSButtonCell *checkboxCell2 = [checkboxCell copy]; // So that making it transparent doesn't affect the other one.
    [[eventTableView tableColumnWithIdentifier:@"flag"] setDataCell:checkboxCell2];
    [checkboxCell2 release];
	
    [checkboxCell release];
	
    NSNumberFormatter *defaultNumberFormatter = [NSNumberFormatter defaultNumberFormatter];
    [semitoneTextField setFormatter:defaultNumberFormatter];
    [hertzTextField setFormatter:defaultNumberFormatter];
    [slopeTextField setFormatter:defaultNumberFormatter];
    [beatTextField setFormatter:defaultNumberFormatter];
    [beatOffsetTextField setFormatter:defaultNumberFormatter];
    [absTimeTextField setFormatter:defaultNumberFormatter];
	
    [[intonationView documentView] setDelegate:self];
    [[intonationView documentView] setEventList:eventList];
	
    [self _updateSelectedPointDetails];
	
    [self updateViews];
	
    // Set up default values for intonation checkboxes
    [smoothIntonationSwitch setState:[defaults boolForKey:MDK_ShouldUseSmoothIntonation]];
    [[intonationMatrix cellAtRow:0 column:0] setState:[defaults boolForKey:MDK_ShouldUseMacroIntonation]];
    [[intonationMatrix cellAtRow:1 column:0] setState:[defaults boolForKey:MDK_ShouldUseMicroIntonation]];
    [[intonationMatrix cellAtRow:2 column:0] setState:[defaults boolForKey:MDK_ShouldUseDrift]];
	
    [textStringTextField removeAllItems];
    [textStringTextField addItemsWithObjectValues:[[NSUserDefaults standardUserDefaults] objectForKey:MDK_DefaultUtterances]];
    [textStringTextField selectItemAtIndex:0];
	[phoneStringTextView setFont:[NSFont fontWithName:@"Lucida Grande" size:13]];	
	[phoneStringTextView setString:[textToPhone phoneForText:[textStringTextField stringValue]]];
	
    [[[eventTableView tableColumnWithIdentifier:@"flag"] dataCell] setFormatter:defaultNumberFormatter];
	
    [self _updateEventColumns];
}

- (void)_updateDisplayParameters;
{
    NSUInteger count, index;
    NSInteger currentTag = 0;
	
    [displayParameters removeAllObjects];
	
    NSArray *parameters = [model parameters];
    count = [parameters count];
    for (index = 0; index < count && index < 16; index++) { // TODO (2004-03-30): Some hardcoded limits exist in Event
        MMParameter *currentParameter = [parameters objectAtIndex:index];
		
        MMDisplayParameter *displayParameter = [[MMDisplayParameter alloc] initWithParameter:currentParameter];
        [displayParameter setTag:currentTag++];
        [displayParameters addObject:displayParameter];
        [displayParameter release];
    }
	
    for (index = 0; index < count && index < 16; index++) { // TODO (2004-03-30): Some hardcoded limits exist in Event
        MMParameter *currentParameter = [parameters objectAtIndex:index];
		
        MMDisplayParameter *displayParameter = [[MMDisplayParameter alloc] initWithParameter:currentParameter];
        [displayParameter setIsSpecial:YES];
        [displayParameter setTag:currentTag++];
        [displayParameters addObject:displayParameter];
        [displayParameter release];
    }
	
    // TODO (2004-03-30): This used to have Intonation (tag=32).  How did that work?
	
    [parameterTableView reloadData];
}

- (void)_updateEventColumns;
{
    NSInteger count, index;
    NSString *others[4] = { @"Semitone", @"Slope", @"2nd Derivative?", @"3rd Derivative?"};
	
    NSArray *tableColumns = [eventTableView tableColumns];
    for (index = [tableColumns count] - 1; index >= 0; index--) { // Note that this fails if we make count an "unsigned int".
        NSTableColumn *tableColumn = [tableColumns objectAtIndex:index];
        if ([[tableColumn identifier] isKindOfClass:[NSNumber class]])
            [eventTableView removeTableColumn:tableColumn];
    }
	
    NSNumberFormatter *defaultNumberFormatter = [NSNumberFormatter defaultNumberFormatter2];
	
    count = [displayParameters count];
    for (index = 0; index < count; index++) {
        MMDisplayParameter *displayParameter = [displayParameters objectAtIndex:index];
		
        if ([displayParameter isSpecial] == NO) {
            NSTableColumn *tableColumn = [[NSTableColumn alloc] initWithIdentifier:[NSString stringWithFormat:@"%lu", [displayParameter tag]]];
            [tableColumn setEditable:NO];
            [[tableColumn headerCell] setTitle:[[displayParameter parameter] name]];
            [[tableColumn dataCell] setFormatter:defaultNumberFormatter];
            [[tableColumn dataCell] setAlignment:NSRightTextAlignment];
#ifndef GNUSTEP
			[[tableColumn dataCell] setDrawsBackground:NO];
#endif
            [tableColumn setWidth:60.0];
            [eventTableView addTableColumn:tableColumn];
            [tableColumn release];
        }
    }
	
    // And finally add columns for the intonation values:
    for (index = 0; index < 4; index++) {
        NSTableColumn *tableColumn = [[NSTableColumn alloc] initWithIdentifier:[NSString stringWithFormat:@"%lu", 32 + index]];
        [tableColumn setEditable:NO];
        [[tableColumn headerCell] setTitle:others[index]];
        [[tableColumn dataCell] setFormatter:defaultNumberFormatter];
        [[tableColumn dataCell] setAlignment:NSRightTextAlignment];
#ifndef GNUSTEP
        [[tableColumn dataCell] setDrawsBackground:NO];
#endif
        [tableColumn setWidth:60.0];
        [eventTableView addTableColumn:tableColumn];
        [tableColumn release];
    }
	
    [eventTableView reloadData];
}

- (void)updateViews;
{
}

- (void)_updateDisplayedParameters;
{
    NSUInteger count, index;
	
    NSMutableArray *array = [[NSMutableArray alloc] init];
    count = [displayParameters count];
    for (index = 0; index < count; index++) {
        MMDisplayParameter *displayParameter = [displayParameters objectAtIndex:index];
        if ([displayParameter shouldDisplay] == YES)
            [array addObject:displayParameter];
    }
    [eventListView setDisplayParameters:array];
    [array release];
	
    [parameterTableView reloadData];
}

- (void)_takeIntonationParametersFromUI;
{
    intonationParameters.notionalPitch = [[intonParmsField cellAtIndex:0] floatValue];
    intonationParameters.pretonicRange = [[intonParmsField cellAtIndex:1] floatValue];
    intonationParameters.pretonicLift = [[intonParmsField cellAtIndex:2] floatValue];
    intonationParameters.tonicRange = [[intonParmsField cellAtIndex:3] floatValue];
    intonationParameters.tonicMovement = [[intonParmsField cellAtIndex:4] floatValue];
}

- (void)_updateSelectedPointDetails;
{
    MMIntonationPoint *selectedIntonationPoint = [self selectedIntonationPoint];
	
    if (selectedIntonationPoint == nil) {
        [semitoneTextField setStringValue:@""];
        [hertzTextField setStringValue:@""];
        [slopeTextField setStringValue:@""];
        [beatTextField setStringValue:@""];
        [beatOffsetTextField setStringValue:@""];
        [absTimeTextField setStringValue:@""];
    } else {
        [semitoneTextField setDoubleValue:[selectedIntonationPoint semitone]];
        [hertzTextField setDoubleValue:[selectedIntonationPoint semitoneInHertz]];
        [slopeTextField setDoubleValue:[selectedIntonationPoint slope]];
        [beatTextField setDoubleValue:[selectedIntonationPoint beatTime]];
        [beatOffsetTextField setDoubleValue:[selectedIntonationPoint offsetTime]];
        [absTimeTextField setDoubleValue:[selectedIntonationPoint absoluteTime]];
		
        [intonationRuleTableView scrollRowToVisible:[selectedIntonationPoint ruleIndex]];
        [intonationRuleTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:[selectedIntonationPoint ruleIndex]] byExtendingSelection:NO];
    }
}

- (IBAction)showIntonationWindow:(id)sender;
{
    [self window]; // Make sure the nib is loaded
    [intonationWindow makeKeyAndOrderFront:self];
}

- (IBAction)showIntonationParameterWindow:(id)sender;
{
    [self window]; // Make sure the nib is loaded
    [intonationParameterWindow makeKeyAndOrderFront:self];
}

- (IBAction)synthesizeWithSoftware:(id)sender;
{
    NSLog(@" > %s", __PRETTY_FUNCTION__);
    [synthesizer setShouldSaveToSoundFile:NO];
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
    [savePanel setAccessoryView:savePanelAccessoryView];
    if (directory != nil)
        [savePanel setDirectoryURL:[NSURL fileURLWithPath:directory]];
    [self fileTypeDidChange:nil];
    // TODO (2012-04-18): Might need to set up "Untitled" in name
	
    [savePanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            [[NSUserDefaults standardUserDefaults] setObject:[[savePanel directoryURL] path] forKey:MDK_SoundOutputDirectory];
            [synthesizer setShouldSaveToSoundFile:YES];
            [synthesizer setFileType:[[fileTypePopUpButton selectedItem] tag]];
            [synthesizer setFilename:[[savePanel URL] path]];
            [self synthesize];
        }
    }];
	
    NSLog(@"<  %s", __PRETTY_FUNCTION__);
}

- (void)synthesize;
{
	NSString *phoneString = [self getAndSyncPhoneString];
		
    [self prepareForSynthesis];
	
    [eventList parsePhoneString:phoneString]; // This creates the tone groups, feet.
    [eventList applyRhythm];
    [eventList applyRules]; // This applies the rules, adding events to the EventList.
    [eventList generateIntonationPoints];
    [intonationRuleTableView reloadData];
	
    [self continueSynthesis];
}

- (NSString *)getAndSyncPhoneString;
{
	NSString *phoneString = [[phoneStringTextView string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if (phoneString == NULL || [phoneString length] == 0) {
		phoneString = [[textToPhone phoneForText:[textStringTextField stringValue]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		[phoneStringTextView setFont:[NSFont fontWithName:@"Lucida Grande" size:13]];
		[phoneStringTextView setString:phoneString];
		[textStringTextField setTextColor:[NSColor blackColor]];
	} else {
		NSString * textStringPhones = [[textToPhone phoneForText:[textStringTextField stringValue]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if ([phoneString isEqualToString:textStringPhones]) {
			[textStringTextField setTextColor:[NSColor blackColor]];
			[phoneStringTextView setTextColor:[NSColor blackColor]];
		} else {
			if ([phoneStringTextView textColor] == [NSColor redColor])  // not last edited
				phoneString = textStringPhones;	
		}
	}
	return phoneString;
}

- (IBAction)fileTypeDidChange:(id)sender;
{
    NSString *extension;
	
    NSSavePanel *savePanel = (NSSavePanel *)[fileTypePopUpButton window];
    switch ([[fileTypePopUpButton selectedItem] tag]) {
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
	NSString *phoneString = [textToPhone phoneForText:[textStringTextField stringValue]];
	[phoneStringTextView setTextColor:[NSColor blackColor]];	
	[phoneStringTextView setString:phoneString];
	[textStringTextField setTextColor:[NSColor blackColor]];

}

- (IBAction)synthesizeWithContour:(id)sender;
{
    [eventList clearIntonationEvents];
    [synthesizer setShouldSaveToSoundFile:NO];
    [self continueSynthesis];
}

- (void)prepareForSynthesis;
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
    if ([parametersStore state])
        [[[self model] synthesisParameters] writeToFile:@"/tmp/Monet.parameters" includeComments:YES];
	
    [eventList setUp];
	
    [eventList setPitchMean:[[[self model] synthesisParameters] pitch]];
    [eventList setGlobalTempo:[tempoField doubleValue]];
    [eventList setShouldStoreParameters:[parametersStore state]];
	
    [eventList setShouldUseMacroIntonation:[defaults boolForKey:MDK_ShouldUseMacroIntonation]];
    [eventList setShouldUseMicroIntonation:[defaults boolForKey:MDK_ShouldUseMicroIntonation]];
    [eventList setShouldUseDrift:[defaults boolForKey:MDK_ShouldUseDrift]];
    NSLog(@"%s, drift deviation: %f, cutoff: %f", __PRETTY_FUNCTION__, [driftDeviationField floatValue], [driftCutoffField floatValue]);
    [eventList.driftGenerator configureWithDeviation:[driftDeviationField floatValue] sampleRate:500 lowpassCutoff:[driftCutoffField floatValue]];
    //[eventList.driftGenerator setupWithDeviation:0.5 sampleRate:250 lowpassCutoff:0.5];
	
    [eventList setRadiusMultiply:[radiusMultiplyField doubleValue]];
	
    [self _takeIntonationParametersFromUI];
    [eventList setIntonationParameters:intonationParameters];
}

- (void)continueSynthesis;
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
    [eventList setShouldUseSmoothIntonation:[defaults boolForKey:MDK_ShouldUseSmoothIntonation]];
    [eventList applyIntonation];
	
    //[eventList printDataStructures:@"Before synthesis"];
    [eventTableView reloadData];
	
    [synthesizer setupSynthesisParameters:[[self model] synthesisParameters]]; // TODO (2004-08-22): This may overwrite the file type...
    [synthesizer removeAllParameters];
	
    [eventList setDelegate:synthesizer];
    [eventList generateOutput];
    [eventList setDelegate:nil];
	
    [synthesizer synthesize];
	
    [eventListView setEventList:eventList];
    [eventListView display]; // TODO (2004-03-17): It's not updating otherwise
	
    [[intonationView documentView] updateEvents]; // Because it doesn't post notifications yet.  We need to resize the width.
}

- (IBAction)generateContour:(id)sender;
{
    NSLog(@" > %s", __PRETTY_FUNCTION__);
	
    [self _takeIntonationParametersFromUI];
    [[intonationView documentView] setShouldDrawSmoothPoints:[[NSUserDefaults standardUserDefaults] boolForKey:MDK_ShouldUseSmoothIntonation]];
    [eventList setIntonationParameters:intonationParameters];
	
    [eventList generateIntonationPoints];
    [intonationRuleTableView reloadData];
    [eventTableView reloadData];
    if ([[eventList intonationPoints] count] > 0)
        [[intonationView documentView] selectIntonationPoint:[[eventList intonationPoints] objectAtIndex:0]];
    [intonationView display];
	
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
    [html appendFormat:@"    <p>%@</p>\n", GSXMLCharacterData([textStringTextField stringValue])];
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

    count = [displayParameters count];
    for (index = 0; index < count; index += 4) {
        NSMutableArray *parms = [[NSMutableArray alloc] init];
        for (offset = 0; offset < 4 && index + offset < count; offset++) {
            [parms addObject:[displayParameters objectAtIndex:index + offset]];
        }
        [eventListView setDisplayParameters:parms];
        [parms release];
		
        NSData *pdfData = [eventListView dataWithPDFInsideRect:[eventListView bounds]];
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
		
        [bitmapImageRep release];
        [image release];
		
        number++;
    }
	
    [html appendString:@"    </p>\n"];
    [html appendString:@"  </body>\n"];
    [html appendString:@"</html>\n"];
	
    [[html dataUsingEncoding:NSUTF8StringEncoding] writeToFile:[basePath stringByAppendingPathComponent:@"index.html"] atomically:YES];
	
    [synthesizer setFileType:0];
    [synthesizer setFilename:[basePath stringByAppendingPathComponent:@"output.au"]];
    [synthesizer setShouldSaveToSoundFile:YES];
    [synthesizer synthesize];
	
    [jpegProperties release];
	
    [self _updateDisplayedParameters];
	
    system([[NSString stringWithFormat:@"open %@", [basePath stringByAppendingPathComponent:@"index.html"]] UTF8String]);
	
    NSLog(@"<  %s", __PRETTY_FUNCTION__);
}

- (IBAction)addTextString:(id)sender;
{
    NSString *str = [textStringTextField stringValue];
    [textStringTextField removeItemWithObjectValue:str];
    [textStringTextField insertItemWithObjectValue:str atIndex:0];
	[textStringTextField setTextColor:[NSColor blackColor]];

	str = [[textToPhone phoneForText:[textStringTextField stringValue]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	[phoneStringTextView setFont:[NSFont fontWithName:@"Lucida Grande" size:13]];
	[phoneStringTextView setString:str];
	[phoneStringTextView setTextColor:[NSColor blackColor]];
	
    [[NSUserDefaults standardUserDefaults] setObject:[textStringTextField objectValues] forKey:MDK_DefaultUtterances];
}

#pragma mark - Intonation Point details

- (MMIntonationPoint *)selectedIntonationPoint;
{
    return [[intonationView documentView] selectedIntonationPoint];
}

- (IBAction)setSemitone:(id)sender;
{
    [[self selectedIntonationPoint] setSemitone:[semitoneTextField doubleValue]];
}

- (IBAction)setHertz:(id)sender;
{
    [[self selectedIntonationPoint] setSemitoneInHertz:[hertzTextField doubleValue]];
}

- (IBAction)setSlope:(id)sender;
{
    [[self selectedIntonationPoint] setSlope:[slopeTextField doubleValue]];
}

- (IBAction)setBeatOffset:(id)sender;
{
    [[self selectedIntonationPoint] setOffsetTime:[beatOffsetTextField doubleValue]];
}

- (IBAction)openIntonationContour:(id)sender;
{
    NSString *directory = [[NSUserDefaults standardUserDefaults] objectForKey:MDK_IntonationContourDirectory];
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setAllowedFileTypes:[NSArray arrayWithObject:@"org.gnu.gnuspeech.intonation-contour"]];
    if (directory != nil)
        [openPanel setDirectoryURL:[NSURL fileURLWithPath:directory]];
	
    [openPanel beginSheetModalForWindow:intonationWindow completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            [[NSUserDefaults standardUserDefaults] setObject:[[openPanel directoryURL] path] forKey:MDK_IntonationContourDirectory];
			
            [self prepareForSynthesis];
			
            [eventList loadIntonationContourFromXMLFile:[[openPanel URL] path]];
			
            //[phoneStringTextField setStringValue:[eventList phoneString]];
            [intonationRuleTableView reloadData];
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

    [savePanel beginSheetModalForWindow:intonationWindow completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            [[NSUserDefaults standardUserDefaults] setObject:[[savePanel directoryURL] path] forKey:MDK_IntonationContourDirectory];
            [eventList writeXMLToFile:[[savePanel URL] path] comment:nil];
        }
    }];
}

- (IBAction)runPageLayout:(id)sender;
{
    NSPageLayout *pageLayout = [NSPageLayout pageLayout];
    [pageLayout runModalWithPrintInfo:intonationPrintInfo];
}

// Currently set up to print the intonation contour.
- (IBAction)printDocument:(id)sender;
{
    NSSize printableSize = [intonationView printableSize];
    NSRect printFrame;
    printFrame.origin = NSZeroPoint;
    printFrame.size = [NSScrollView frameSizeForContentSize:printableSize hasHorizontalScroller:NO hasVerticalScroller:NO borderType:NSNoCellMask];
	
    MAIntonationScrollView *printView = [[MAIntonationScrollView alloc] initWithFrame:printFrame];
    [printView setBorderType:NSNoCellMask];
    [printView setHasHorizontalScroller:NO];
	
    [[printView documentView] setEventList:eventList];
    [[printView documentView] setShouldDrawSelection:NO];
    [[printView documentView] setShouldDrawSmoothPoints:[[intonationView documentView] shouldDrawSmoothPoints]];
	
    NSPrintOperation *printOperation = [NSPrintOperation printOperationWithView:printView printInfo:intonationPrintInfo];
    [printOperation setShowsPrintPanel:YES];
    [printOperation setShowsProgressPanel:YES];
	
    [printOperation runOperation];
    [printView release];
}

- (void)intonationPointDidChange:(NSNotification *)aNotification;
{
    [self _updateSelectedPointDetails];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
{
    if (tableView == parameterTableView)
        return [displayParameters count];
	
    if (tableView == intonationRuleTableView)
        return [eventList ruleCount];
	
    if (tableView == eventTableView)
        return [[eventList events] count] * 2;
	
    return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
    id identifier = [tableColumn identifier];
	
    if (tableView == parameterTableView) {
        MMDisplayParameter *displayParameter = [displayParameters objectAtIndex:row];
		
        if ([@"name" isEqual:identifier] == YES) {
            return [displayParameter name];
        } else if ([@"shouldDisplay" isEqual:identifier] == YES) {
            return [NSNumber numberWithBool:[displayParameter shouldDisplay]];
        }
    } else if (tableView == intonationRuleTableView) {
        if ([@"rule" isEqual:identifier] == YES) {
            return [eventList ruleDescriptionAtIndex:row];
        } else if ([@"number" isEqual:identifier] == YES) {
            return [NSString stringWithFormat:@"%lu.", row + 1];
        }
    } else if (tableView == eventTableView) {
        int eventNumber = row / 2;
        if ([@"time" isEqual:identifier] == YES) {
            return [NSNumber numberWithInt:[[[eventList events] objectAtIndex:eventNumber] time]];
        } else if ([@"flag" isEqual:identifier] == YES) {
            return [NSNumber numberWithBool:[[[eventList events] objectAtIndex:eventNumber] flag]];
        } else {
            NSInteger rowOffset = row % 2;
            NSInteger index = [identifier intValue] + rowOffset * 16;
            if (rowOffset == 0 || index < 32) {
                double value = [[[eventList events] objectAtIndex:eventNumber] getValueAtIndex:index];
                return [NSNumber numberWithDouble:value];
            }
        }
    }
	
    return nil;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
    id identifier = [tableColumn identifier];
	
    if (tableView == parameterTableView) {
        MMDisplayParameter *displayParameter = [displayParameters objectAtIndex:row];
		
        if ([@"shouldDisplay" isEqual:identifier] == YES) {
            [displayParameter setShouldDisplay:[object boolValue]];
            [self _updateDisplayedParameters];
        }
    }
}

#pragma mark - NSTableViewDelegate

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
    id identifier = [tableColumn identifier];
	
    if (tableView == eventTableView) {
        if ([@"time" isEqual:identifier] && (row % 2) == 1) {
            [cell setObjectValue:nil];
        } else if ([@"flag" isEqual:identifier]) {
            if ((row % 2) == 0)
                [cell setTransparent:NO];
            else
                [cell setTransparent:YES];
        }
    }
}

#pragma mark - MExtendedTableView delegate

- (BOOL)control:(NSControl *)aControl shouldProcessCharacters:(NSString *)characters;
{
    if ([characters isEqualToString:@" "]) {
        NSInteger selectedRow = [parameterTableView selectedRow];
        if (selectedRow != -1) {
            [[displayParameters objectAtIndex:selectedRow] toggleShouldDisplay];
            [self _updateDisplayedParameters];
            [(MExtendedTableView *)aControl doNotCombineNextKey];
            return NO;
        }
    } else {
        NSUInteger count, index;
		
        count = [displayParameters count];
        for (index = 0; index < count; index++) {
            if ([[[[displayParameters objectAtIndex:index] parameter] name] hasPrefix:characters ignoreCase:YES]) {
                [parameterTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
                [parameterTableView scrollRowToVisible:index];
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
	[textStringTextField setTextColor:[NSColor blackColor]];	
	[phoneStringTextView setTextColor:[NSColor redColor]];	
}

- (void)controlTextDidEndEditing:(NSNotification *)notification;
{
}		
		
#pragma mark - NSTextViewDelegate

- (void)textDidChange:(NSNotification *)notification;
{
	NSString *phoneString = [phoneStringTextView string];
	if (phoneString == NULL || [phoneString length] == 0) {
		[phoneStringTextView setFont:[NSFont fontWithName:@"Lucida Grande" size:13]];
		[phoneStringTextView setString:phoneString];
	}
	[phoneStringTextView setTextColor:[NSColor blackColor]];	
	[textStringTextField setTextColor:[NSColor redColor]];
}

#pragma mark - Intonation Parameters

- (IBAction)updateSmoothIntonation:(id)sender;
{
    [[NSUserDefaults standardUserDefaults] setBool:[sender state] forKey:MDK_ShouldUseSmoothIntonation];
}

- (IBAction)updateMacroIntonation:(id)sender;
{
    [[NSUserDefaults standardUserDefaults] setBool:[[sender selectedCell] state] forKey:MDK_ShouldUseMacroIntonation];
}

- (IBAction)updateMicroIntonation:(id)sender;
{
    [[NSUserDefaults standardUserDefaults] setBool:[[sender selectedCell] state] forKey:MDK_ShouldUseMicroIntonation];
}

- (IBAction)updateDrift:(id)sender;
{
    [[NSUserDefaults standardUserDefaults] setBool:[[sender selectedCell] state] forKey:MDK_ShouldUseDrift];
}

@end

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MSynthesisController.h"

#include <sys/time.h>
#import <AppKit/AppKit.h>
#import "GSXMLFunctions.h"
#import "NSNumberFormatter-Extensions.h"
#import "NSString-Extensions.h"

#import "Event.h" // For MAX_EVENTS
#import "EventList.h"
#import "EventListView.h"
#import "IntonationView.h"
#import "MExtendedTableView.h"
#import "MMDisplayParameter.h"
#import "MMIntonationPoint.h"
#import "MModel.h"
#import "MMParameter.h"
#import "MMSynthesisParameters.h"
#include "driftGenerator.h"

#import "TRMSynthesizer.h"

#define MDK_ShouldUseSmoothIntonation @"ShouldUseSmoothIntonation"
#define MDK_ShouldUseMacroIntonation @"ShouldUseMacroIntonation"
#define MDK_ShouldUseMicroIntonation @"ShouldUseMicroIntonation"
#define MDK_ShouldUseDrift @"ShouldUseDrift"
#define MDK_DefaultUtterances @"DefaultUtterances"

// TODO (2004-03-31): The original code changed the rule index of the currently selected intonation point when the browser was hit, and then added that point to the intonation view again...

@implementation MSynthesisController

+ (void)initialize;
{
    NSMutableDictionary *defaultValues;
    NSArray *defaultUtterances;

    defaultUtterances = [NSArray arrayWithObjects:@"/c // /3 # /w i_z /w /_dh_aa_t /w /_ch_ee_z /w t_uu /w /l /*ee_t # ^ // /2 # /w aw_r /w i_z /w /_i_t /w t_uu /w /_p_u_t /w i_n /w uh /w /l /*m_ah_uu_s./\"t_r_aa_p # // /c ",
                                 @"/c // /1 # /w /*n_y_uu /w /l /*s_p_ee_ch # // /c",
                                 @"/c // /0 # /w /_ah_i /w /_w_u_d /w /_l_ah_i_k /w t_uu /w /_b_ah_i /w /_s_a_m /w /l /*ch_ee_z # // /c ",
                                 @"/c // /2 # /w /_h_aa_v /w y_uu /w /_s_ee_n /w dh_uh /w /_s_i_ll_k_s /w /_w_i /w /_g_o_t /w f_r_a_m /w /l /*f_r_aa_n_s # // /c ",
                                 @"/c // /3 # /w /_ah_i /w /_n_uh_uu /w y_uu /w b_i./_l_ee_v /w y_uu /w a_n.d_uh_r./_s_t_aa_n_d /w /_w_o_t /w y_uu /w /_th_i_ng_k /w /_ah_i /w /l /*s_e_d # ^ // /0 # /w b_a_t /w /_ah_i /w /_aa_m /w /_n_o_t /w /_sh_u_r /w y_uu /w /_r_ee.uh_l.ah_i_z /w /_dh_aa_t /w /_w_o_t /w y_uu /w /_h_uh_r_d /w i_z /w /_n_o_t /w /_w_o_t /w /_ah_i /w /l /*m_e_n_t # // /c ",
                                 nil];

    defaultValues = [[NSMutableDictionary alloc] init];
    [defaultValues setObject:defaultUtterances forKey:MDK_DefaultUtterances];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
    [defaultValues release];
}

- (id)initWithModel:(MModel *)aModel;
{
    if ([super initWithWindowNibName:@"Synthesis"] == nil)
        return nil;

    model = [aModel retain];
    displayParameters = [[NSMutableArray alloc] init];
    [self _updateDisplayParameters];

    eventList = [[EventList alloc] init];

    [self setWindowFrameAutosaveName:@"Synthesis"];

    synthesizer = [[TRMSynthesizer alloc] init];

    return self;
}

- (void)dealloc;
{
    [model release];
    [displayParameters release];
    [eventList release];
    [synthesizer release];

    [super dealloc];
}

- (MModel *)model;
{
    return model;
}

- (void)setModel:(MModel *)newModel;
{
    if (newModel == model)
        return;

    [model release];
    model = [newModel retain];

    [eventList setModel:model];

    [self _updateDisplayParameters];
    [self _updateEventColumns];
    [self updateViews];
}

- (NSUndoManager *)undoManager;
{
    return nil;
}

- (void)windowDidLoad;
{
    NSNumberFormatter *defaultNumberFormatter;
    NSButtonCell *checkboxCell, *checkboxCell2;
    NSUserDefaults *defaults;

    defaults = [NSUserDefaults standardUserDefaults];

    [intonationParameterWindow setFrameAutosaveName:@"Intonation Parameters"];
    [intonationWindow setFrameAutosaveName:@"Intonation"];
    [[intonationView documentView] setShouldDrawSmoothPoints:[[NSUserDefaults standardUserDefaults] boolForKey:MDK_ShouldUseSmoothIntonation]];

    checkboxCell = [[NSButtonCell alloc] initTextCell:@""];
    [checkboxCell setControlSize:NSSmallControlSize];
    [checkboxCell setButtonType:NSSwitchButton];
    [checkboxCell setImagePosition:NSImageOnly];
    [checkboxCell setEditable:NO];

    [[parameterTableView tableColumnWithIdentifier:@"shouldDisplay"] setDataCell:checkboxCell];
    checkboxCell2 = [checkboxCell copy]; // So that making it transparent doesn't affect the other one.
    [[eventTableView tableColumnWithIdentifier:@"flag"] setDataCell:checkboxCell2];
    [checkboxCell2 release];

    [checkboxCell release];

    defaultNumberFormatter = [NSNumberFormatter defaultNumberFormatter];
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

    [stringTextField removeAllItems];
    [stringTextField addItemsWithObjectValues:[[NSUserDefaults standardUserDefaults] objectForKey:MDK_DefaultUtterances]];
    [stringTextField selectItemAtIndex:0];

    [[[eventTableView tableColumnWithIdentifier:@"flag"] dataCell] setFormatter:defaultNumberFormatter];

    [self _updateEventColumns];
}

- (void)_updateDisplayParameters;
{
    NSArray *parameters;
    unsigned int count, index;
    int currentTag = 0;
    MMParameter *currentParameter;
    MMDisplayParameter *displayParameter;

    [displayParameters removeAllObjects];

    parameters = [model parameters];
    count = [parameters count];
    for (index = 0; index < count && index < 16; index++) { // TODO (2004-03-30): Some hardcoded limits exist in Event
        currentParameter = [parameters objectAtIndex:index];

        displayParameter = [[MMDisplayParameter alloc] initWithParameter:currentParameter];
        [displayParameter setTag:currentTag++];
        [displayParameters addObject:displayParameter];
        [displayParameter release];
    }

    for (index = 0; index < count && index < 16; index++) { // TODO (2004-03-30): Some hardcoded limits exist in Event
        currentParameter = [parameters objectAtIndex:index];

        displayParameter = [[MMDisplayParameter alloc] initWithParameter:currentParameter];
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
    NSArray *tableColumns;
    int count, index;
    NSNumberFormatter *defaultNumberFormatter;
    NSString *others[4] = { @"Semitone", @"Slope", @"2nd Derivative?", @"3rd Derivative?"};

    tableColumns = [eventTableView tableColumns];
    for (index = [tableColumns count] - 1; index >= 0; index--) { // Note that this fails if we make count an "unsigned int".
        NSTableColumn *tableColumn;

        tableColumn = [tableColumns objectAtIndex:index];
        if ([[tableColumn identifier] isKindOfClass:[NSNumber class]])
            [eventTableView removeTableColumn:tableColumn];
    }

    defaultNumberFormatter = [NSNumberFormatter defaultNumberFormatter2];

    count = [displayParameters count];
    for (index = 0; index < count; index++) {
        MMDisplayParameter *displayParameter;
        NSTableColumn *tableColumn;

        displayParameter = [displayParameters objectAtIndex:index];

        if ([displayParameter isSpecial] == NO) {
            tableColumn = [[NSTableColumn alloc] initWithIdentifier:[NSNumber numberWithInt:[displayParameter tag]]];
            [tableColumn setEditable:NO];
            [[tableColumn headerCell] setTitle:[[displayParameter parameter] name]];
            [[tableColumn dataCell] setFormatter:defaultNumberFormatter];
            [[tableColumn dataCell] setAlignment:NSRightTextAlignment];
            [[tableColumn dataCell] setDrawsBackground:NO];
            [tableColumn setWidth:60.0];
            [eventTableView addTableColumn:tableColumn];
            [tableColumn release];
        }
    }

    // And finally add columns for the intonation values:
    for (index = 0; index < 4; index++) {
        NSTableColumn *tableColumn;

        tableColumn = [[NSTableColumn alloc] initWithIdentifier:[NSNumber numberWithInt:32 + index]];
        [tableColumn setEditable:NO];
        [[tableColumn headerCell] setTitle:others[index]];
        [[tableColumn dataCell] setFormatter:defaultNumberFormatter];
        [[tableColumn dataCell] setAlignment:NSRightTextAlignment];
        [[tableColumn dataCell] setDrawsBackground:NO];
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
    NSMutableArray *array;
    unsigned int count, index;
    MMDisplayParameter *displayParameter;

    array = [[NSMutableArray alloc] init];
    count = [displayParameters count];
    for (index = 0; index < count; index++) {
        displayParameter = [displayParameters objectAtIndex:index];
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
    MMIntonationPoint *selectedIntonationPoint;

    selectedIntonationPoint = [self selectedIntonationPoint];

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

        NSLog(@"ruleIndex: %d", [selectedIntonationPoint ruleIndex]);
        [intonationRuleTableView scrollRowToVisible:[selectedIntonationPoint ruleIndex]];
        [intonationRuleTableView selectRow:[selectedIntonationPoint ruleIndex] byExtendingSelection:NO];
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

// This isn't used right now, but it did things slightly differently w.r.t. intonation, for example.
- (IBAction)parseStringButton:(id)sender;
{
#if 0
    struct timeval tp1, tp2;
    struct timezone tzp;
    NSUserDefaults *defaults;

    NSLog(@" > %s", _cmd);

    defaults = [NSUserDefaults standardUserDefaults];
    //[self parseString:[stringTextField stringValue]];

    gettimeofday(&tp1, &tzp);

    [eventList setUp];

    [eventList setPitchMean:[[[self model] synthesisParameters] pitch]];
    [eventList setGlobalTempo:[tempoField doubleValue]];
    [eventList setShouldStoreParameters:[parametersStore state]];

    [eventList setShouldUseMacroIntonation:[defaults boolForKey:MDK_ShouldUseMacroIntonation]];
    [eventList setShouldUseMicroIntonation:[defaults boolForKey:MDK_ShouldUseMicroIntonation]];
    [eventList setShouldUseDrift:[defaults boolForKey:MDK_ShouldUseDrift]];
    setDriftGenerator([driftDeviationField floatValue], 500, [driftCutoffField floatValue]);

    [eventList setRadiusMultiply:[radiusMultiplyField doubleValue]];

    //[eventList setIntonation:[intonationFlag state]];
    [self _takeIntonationParametersFromUI];
    [eventList setIntonationParameters:intonationParameters];

    [eventList parsePhoneString:[stringTextField stringValue] withModel:[self model]];

    [eventList generateEventListWithModel:model];

    if ([defaults boolForKey:MDK_ShouldUseSmoothIntonation])
        [eventList applySmoothIntonation];
    else
        [eventList applyIntonation_fromIntonationView];

    [eventList setShouldUseSmoothIntonation:[defaults boolForKey:MDK_ShouldUseSmoothIntonation]];

    gettimeofday(&tp2, &tzp);
    NSLog(@"%ld", (tp2.tv_sec*1000000 + tp2.tv_usec) - (tp1.tv_sec*1000000 + tp1.tv_usec));

    NSLog(@"\n***\n");
    //[eventList printDataStructures:@""];
#if 0
    for (i = 0; i < [eventList count]; i++) {
        printf("Time: %d  | ", [[eventList objectAt:i] time]);
        for (j = 0 ; j < 16; j++) {
            printf("%.3f ", [[eventList objectAt:i] getValueAtIndex:j]);
        }
        printf("\n");
    }
#endif

    if ([sender tag]) {
        NSLog(@"this case, trying to synthesize to file.");
        if ([[filenameField stringValue] length])
            [eventList synthesizeToFile:[filenameField stringValue]];
        else
            NSBeep();
    } else
        [eventList synthesizeToFile:nil];

    [eventList generateOutput];
    [eventListView setEventList:eventList];
    [[intonationView documentView] updateEvents];
    [stringTextField selectText:self];

    NSLog(@"<  %s", _cmd);
#endif
}

- (IBAction)synthesizeWithSoftware:(id)sender;
{
    NSLog(@" > %s", _cmd);
    [self synthesizeToSoundFile:NO];
    NSLog(@"<  %s", _cmd);
}

- (IBAction)synthesizeToFile:(id)sender;
{
    NSLog(@" > %s", _cmd);
    [self synthesizeToSoundFile:YES];
    NSLog(@"<  %s", _cmd);
}

- (void)synthesizeToSoundFile:(BOOL)shouldSaveToSoundFile;
{
    NSUserDefaults *defaults;

    defaults = [NSUserDefaults standardUserDefaults];

    if ([parametersStore state] == YES)
        [[[self model] synthesisParameters] writeToFile:@"/tmp/Monet.parameters" includeComments:YES];

    [eventList setUp];

    [eventList setPitchMean:[[[self model] synthesisParameters] pitch]];
    [eventList setGlobalTempo:[tempoField doubleValue]];
    [eventList setShouldStoreParameters:[parametersStore state]];

    [eventList setShouldUseMacroIntonation:[defaults boolForKey:MDK_ShouldUseMacroIntonation]];
    [eventList setShouldUseMicroIntonation:[defaults boolForKey:MDK_ShouldUseMicroIntonation]];
    [eventList setShouldUseDrift:[defaults boolForKey:MDK_ShouldUseDrift]];
    setDriftGenerator([driftDeviationField floatValue], 500, [driftCutoffField floatValue]);
    //setDriftGenerator(0.5, 250, 0.5);

    [eventList setRadiusMultiply:[radiusMultiplyField doubleValue]];

    [self _takeIntonationParametersFromUI];
    [eventList setIntonationParameters:intonationParameters];

    // This adds events to the EventList
    [eventList parsePhoneString:[stringTextField stringValue] withModel:[self model]];

    [eventList generateEventListWithModel:model];

    [eventList generateIntonationPoints];
    [self continueSynthesisToSoundFile:shouldSaveToSoundFile];
}

- (IBAction)synthesizeWithContour:(id)sender;
{
    [eventList clearIntonationEvents];
    [self continueSynthesisToSoundFile:NO];
}

- (void)continueSynthesisToSoundFile:(BOOL)shouldSaveToSoundFile;
{
    NSUserDefaults *defaults;

    defaults = [NSUserDefaults standardUserDefaults];

    if ([defaults boolForKey:MDK_ShouldUseSmoothIntonation])
        [eventList applySmoothIntonation];
    else
        [eventList applyIntonation_fromIntonationView];

    [eventList setShouldUseSmoothIntonation:[defaults boolForKey:MDK_ShouldUseSmoothIntonation]];

    [eventList printDataStructures:@"Before synthesis"];
    [eventTableView reloadData];
    {
        [synthesizer setupSynthesisParameters:[[self model] synthesisParameters]];
        [synthesizer removeAllParameters];
        [eventList setDelegate:synthesizer];
        [eventList generateOutput];
        [eventList setDelegate:nil];
        if (shouldSaveToSoundFile == YES)
            [synthesizer synthesizeToSoundFile:[filenameField stringValue] type:[[fileTypePopUpButton selectedItem] tag]];
        else
            [synthesizer synthesize];
    }

    [eventListView setEventList:eventList];
    [eventListView display]; // TODO (2004-03-17): It's not updating otherwise

    [[intonationView documentView] updateEvents];
}

- (IBAction)generateContour:(id)sender;
{
    NSLog(@" > %s", _cmd);

    [self _takeIntonationParametersFromUI];
    [[intonationView documentView] setShouldDrawSmoothPoints:[[NSUserDefaults standardUserDefaults] boolForKey:MDK_ShouldUseSmoothIntonation]];
    [eventList setIntonationParameters:intonationParameters];

    [eventList generateIntonationPoints];
    [intonationRuleTableView reloadData];
    [eventTableView reloadData];
    if ([[eventList intonationPoints] count] > 0)
        [[intonationView documentView] selectIntonationPoint:[[eventList intonationPoints] objectAtIndex:0]];
    [intonationView display];

    NSLog(@"<  %s", _cmd);
}

- (IBAction)generateGraphImages:(id)sender;
{
    unsigned int count, index, offset;
    int pid;
    int number = 1;
    static int group = 1; // Mmm, mmm
    NSDictionary *jpegProperties;
    NSMutableString *html;
    NSString *basePath;
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSLog(@" > %s", _cmd);

    html = [NSMutableString string];

    [html appendString:@"<?xml version='1.0' encoding='utf-8'?>\n"];
    [html appendString:@"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n"];
    [html appendString:@"<html xmlns='http://www.w3.org/1999/xhtml' xml:lang='en' lang='en'>\n"];
    [html appendString:@"  <head>\n"];
    [html appendString:@"    <title>Monet Parameter Graphs</title>\n"];
    [html appendString:@"    <meta http-equiv='Content-type' content='text/html; charset=utf-8'/>\n"];
    [html appendString:@"  </head>\n"];
    [html appendString:@"  <body>\n"];
    [html appendString:@"    <p>Parameter graphs for phone string:</p>\n"];
    [html appendFormat:@"    <p>%@</p>\n", GSXMLCharacterData([stringTextField stringValue])];
    [html appendString:@"    <p>[<a href='Monet.parameters'>Monet.parameters</a>] [<a href='output.au'>output.au</a>]</p>\n"];
    [html appendString:@"    <p><object type='audio/basic' data='output.au'></object></p>\n"];
    [html appendFormat:@"    <p>Generated %@</p>\n", GSXMLCharacterData([[NSCalendarDate calendarDate] description])];
    [html appendString:@"    <p>\n"];

    pid = [[NSProcessInfo processInfo] processIdentifier];
    number = 1;

    basePath = [NSString stringWithFormat:@"/tmp/Monet-%d-%d", pid, group++];
    [fileManager createDirectoryAtPath:basePath attributes:nil];
    [fileManager copyPath:@"/tmp/Monet.parameters" toPath:[basePath stringByAppendingPathComponent:@"Monet.parameters"] handler:nil];

    jpegProperties = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithFloat:0.95], NSImageCompressionFactor,
                                           nil];

    count = [displayParameters count];
    for (index = 0; index < count; index += 4) {
        NSMutableArray *parms;
        NSData *pdfData, *tiffData, *jpegData;
        NSString *filename1, *filename2;
        NSImage *image;
        NSBitmapImageRep *bitmapImageRep;

        parms = [[NSMutableArray alloc] init];
        for (offset = 0; offset < 4 && index + offset < count; offset++) {
            [parms addObject:[displayParameters objectAtIndex:index + offset]];
        }
        [eventListView setDisplayParameters:parms];
        [parms release];

        pdfData = [eventListView dataWithPDFInsideRect:[eventListView bounds]];
        filename1 = [NSString stringWithFormat:@"graph-%d.pdf", number];
        [pdfData writeToFile:[basePath stringByAppendingPathComponent:filename1] atomically:YES];
        [html appendFormat:@"      <img src='%@' alt='parameter graph %d'/>\n", GSXMLAttributeString(filename1, YES), number];

        image = [[NSImage alloc] initWithData:pdfData];
        //NSLog(@"image: %@", image);

        // Generate TIFF data first, otherwise JPEG generation fails.
        tiffData = [image TIFFRepresentationUsingCompression:NSTIFFCompressionLZW factor:0.95];

        bitmapImageRep = [[NSBitmapImageRep alloc] initWithData:tiffData];
        //NSLog(@"bitmapImageRep: %@, size: %@", bitmapImageRep, NSStringFromSize([bitmapImageRep size]));
        //NSLog(@"bitsPerPixel: %d, samplesPerPixel: %d", [bitmapImageRep bitsPerPixel], [bitmapImageRep samplesPerPixel]);

        jpegData = [bitmapImageRep representationUsingType:NSJPEGFileType properties:jpegProperties];
        filename2 = [NSString stringWithFormat:@"graph-%d.jpg", number];
        [jpegData writeToFile:[basePath stringByAppendingPathComponent:filename2] atomically:YES];

        [bitmapImageRep release];
        [image release];

        number++;
    }

    [html appendString:@"    </p>\n"];
    [html appendString:@"  </body>\n"];
    [html appendString:@"</html>\n"];

    [[html dataUsingEncoding:NSUTF8StringEncoding] writeToFile:[basePath stringByAppendingPathComponent:@"index.html"] atomically:YES];

#if 0
    // TODO (2004-05-13): We should use TRMSynthesizer now to generate the sound file.  For now we'll just copy /tmp/out.au, which we always generate.
    {
        NSString *command;

        command = [NSString stringWithFormat:@"~nygard/Source/net/gnuspeech/trillium/src/softwareTRM/tube %@/Monet.parameters %@/output.au", basePath, basePath];
        if (system([command UTF8String]) != 0)
            NSLog(@"command failed: %@", command);
    }
#endif
    [fileManager copyPath:@"/tmp/out.au" toPath:[basePath stringByAppendingPathComponent:@"output.au"] handler:nil];

    [jpegProperties release];

    [self _updateDisplayedParameters];

    system([[NSString stringWithFormat:@"open %@", [basePath stringByAppendingPathComponent:@"index.html"]] UTF8String]);

    NSLog(@"<  %s", _cmd);
}

- (IBAction)addPhoneString:(id)sender;
{
    NSString *str;

    str = [stringTextField stringValue];
    [stringTextField removeItemWithObjectValue:str];
    [stringTextField insertItemWithObjectValue:str atIndex:0];
    [[NSUserDefaults standardUserDefaults] setObject:[stringTextField objectValues] forKey:MDK_DefaultUtterances];
}

//
// Intonation Point details
//

- (MMIntonationPoint *)selectedIntonationPoint;
{
    return [[intonationView documentView] selectedIntonationPoint];
}

- (IBAction)setSemitone:(id)sender;
{
    [[self selectedIntonationPoint] setSemitone:[semitoneTextField doubleValue]];
    [[intonationView documentView] setNeedsDisplay:YES];
    [self _updateSelectedPointDetails];
}

- (IBAction)setHertz:(id)sender;
{
    [[self selectedIntonationPoint] setSemitoneInHertz:[hertzTextField doubleValue]];
    [[intonationView documentView] setNeedsDisplay:YES];
    [self _updateSelectedPointDetails];
}

- (IBAction)setSlope:(id)sender;
{
    [[self selectedIntonationPoint] setSlope:[slopeTextField doubleValue]];
    [[intonationView documentView] setNeedsDisplay:YES];
}

- (IBAction)setBeatOffset:(id)sender;
{
    [[self selectedIntonationPoint] setOffsetTime:[beatOffsetTextField doubleValue]];
    [eventList addIntonationPoint:[self selectedIntonationPoint]]; // TODO (2004-03-31): Not sure about this.
    [[intonationView documentView] setNeedsDisplay:YES];
}

//
// NSTableView data source
//

- (int)numberOfRowsInTableView:(NSTableView *)tableView;
{
    if (tableView == parameterTableView)
        return [displayParameters count];

    if (tableView == intonationRuleTableView)
        return [eventList numberOfRules];

    if (tableView == eventTableView)
        return [[eventList events] count] * 2;

    return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row;
{
    id identifier;

    identifier = [tableColumn identifier];

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
            return [NSString stringWithFormat:@"%d.", row + 1];
        }
    } else if (tableView == eventTableView) {
        int eventNumber;

        eventNumber = row / 2;
        if ([@"time" isEqual:identifier] == YES) {
            return [NSNumber numberWithInt:[[[eventList events] objectAtIndex:eventNumber] time]];
        } else if ([@"flag" isEqual:identifier] == YES) {
            return [NSNumber numberWithBool:[[[eventList events] objectAtIndex:eventNumber] flag]];
        } else if ([identifier isKindOfClass:[NSNumber class]]) {
            double value;
            int rowOffset, index;

            rowOffset = row % 2;
            index = [identifier intValue] + rowOffset * 16;
            if (rowOffset == 0 || index < 32) {
                value = [[[eventList events] objectAtIndex:eventNumber] getValueAtIndex:index];
                return [NSNumber numberWithDouble:value];
            }
        }
    }

    return nil;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(int)row;
{
    id identifier;

    identifier = [tableColumn identifier];

    if (tableView == parameterTableView) {
        MMDisplayParameter *displayParameter = [displayParameters objectAtIndex:row];

        if ([@"shouldDisplay" isEqual:identifier] == YES) {
            [displayParameter setShouldDisplay:[object boolValue]];
            [self _updateDisplayedParameters];
        }
    }
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int)row;
{
    id identifier;

    identifier = [tableColumn identifier];

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

//
// MExtendedTableView delegate
//

- (BOOL)control:(NSControl *)aControl shouldProcessCharacters:(NSString *)characters;
{
    if ([characters isEqualToString:@" "]) {
        int selectedRow;

        selectedRow = [parameterTableView selectedRow];
        if (selectedRow != -1) {
            [[displayParameters objectAtIndex:selectedRow] toggleShouldDisplay];
            [self _updateDisplayedParameters];
            [(MExtendedTableView *)aControl doNotCombineNextKey];
            return NO;
        }
    } else {
        unsigned int count, index;

        count = [displayParameters count];
        for (index = 0; index < count; index++) {
            if ([[[[displayParameters objectAtIndex:index] parameter] name] hasPrefix:characters ignoreCase:YES]) {
                [parameterTableView selectRow:index byExtendingSelection:NO];
                [parameterTableView scrollRowToVisible:index];
                return NO;
            }
        }
    }

    return YES;
}

//
// IntonationView delegate
//

- (void)intonationViewSelectionDidChange:(NSNotification *)aNotification;
{
    NSLog(@" > %s", _cmd);
    [self _updateSelectedPointDetails];
    NSLog(@"<  %s", _cmd);
}

//
// Intonation Parameters
//

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

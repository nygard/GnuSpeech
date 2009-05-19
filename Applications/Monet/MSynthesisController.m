////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
//  
//  Contributors: Steve Nygard, Dalmazio Brisinda
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
////////////////////////////////////////////////////////////////////////////////
//
//  MSynthesisController.m
//  Monet
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.9.7
//
////////////////////////////////////////////////////////////////////////////////

#import "MSynthesisController.h"

#include <sys/time.h>
#import <AppKit/AppKit.h>
#import <GnuSpeech/GnuSpeech.h>

#import "NSNumberFormatter-Extensions.h"

#import "EventListView.h"
#import "MAIntonationScrollView.h"
#import "MAIntonationView.h"
#import "MExtendedTableView.h"
#import "MMDisplayParameter.h"

#define MDK_ShouldUseSmoothIntonation @"ShouldUseSmoothIntonation"
#define MDK_ShouldUseMacroIntonation @"ShouldUseMacroIntonation"
#define MDK_ShouldUseMicroIntonation @"ShouldUseMicroIntonation"
#define MDK_ShouldUseDrift @"ShouldUseDrift"
#define MDK_DefaultUtterances @"DefaultUtterances"

#define MDK_GraphImagesDirectory @"GraphImagesDirectory"
#define MDK_SoundOutputDirectory @"SoundOutputDirectory"
#define MDK_IntonationContourDirectory @"IntonationContourDirectory"

@implementation MSynthesisController

+ (void)initialize;
{
    NSMutableDictionary *defaultValues;
    NSArray *defaultUtterances;
	
	//    defaultUtterances = [NSArray arrayWithObjects:@"/c // /3 # /w i_z /w /_dh_aa_t /w /_ch_ee_z /w t_uu /w /l /*ee_t # ^ // /2 # /w aw_r /w i_z /w /_i_t /w t_uu /w /_p_u_t /w i_n /w uh /w /l /*m_ah_uu_s./\"t_r_aa_p # // /c ",
	//								 @"/c // /1 # /w /*n_y_uu /w /l /*s_p_ee_ch # // /c",
	//                                 @"/c // /0 # /w /_ah_i /w /_w_u_d /w /_l_ah_i_k /w t_uu /w /_b_ah_i /w /_s_a_m /w /l /*ch_ee_z # // /c ",
	//                                 @"/c // /2 # /w /_h_aa_v /w y_uu /w /_s_ee_n /w dh_uh /w /_s_i_ll_k_s /w /_w_i /w /_g_o_t /w f_r_a_m /w /l /*f_r_aa_n_s # // /c ",
	//                                 @"/c // /3 # /w /_ah_i /w /_n_uh_uu /w y_uu /w b_i./_l_ee_v /w y_uu /w a_n.d_uh_r./_s_t_aa_n_d /w /_w_o_t /w y_uu /w /_th_i_ng_k /w /_ah_i /w /l /*s_e_d # ^ // /0 # /w b_a_t /w /_ah_i /w /_aa_m /w /_n_o_t /w /_sh_u_r /w y_uu /w /_r_ee.uh_l.ah_i_z /w /_dh_aa_t /w /_w_o_t /w y_uu /w /_h_uh_r_d /w i_z /w /_n_o_t /w /_w_o_t /w /_ah_i /w /l /*m_e_n_t # // /c ",
	//                                 @"/c // /0 # /w /_aw_l /w /_y_aw_r /w /_b_e_i_s /w ar_r /w b_i./_l_o_ng /w t_uu /w /l /*a_s # // /c ",
	//                                 @"/c // /0 # /w /_s_a_m.w_a_n /w /_s_e_t /w /_a_p /w /_a_s /w dh_uh /w /l /*b_o_m # // /c ",
	//                                 nil];
	
    defaultUtterances = [NSArray arrayWithObjects:
						 @"I'm sorry David, I'm afraid I can't do that.",
						 @"Just what do you think you're doing, David?",
						 @"Look David, I can see you're really upset about this. I honestly think you ought to sit down calmly, take a stress pill, and think things over.",
						 @"I know you believe you understand what you think I said, but I'm not sure you realize that what you heard is not what I meant.",
						 @"Is that cheese to eat, or is it to put in a mouse trap?",
						 nil];	
	
    defaultValues = [[NSMutableDictionary alloc] init];
    [defaultValues setObject:defaultUtterances forKey:MDK_DefaultUtterances];
    [defaultValues setObject:[@"~/Desktop" stringByExpandingTildeInPath] forKey:MDK_GraphImagesDirectory];
    [defaultValues setObject:[@"~/Desktop" stringByExpandingTildeInPath] forKey:MDK_SoundOutputDirectory];
    [defaultValues setObject:[@"~/Desktop" stringByExpandingTildeInPath] forKey:MDK_IntonationContourDirectory];
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
	
    return self;
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[eventListView release];  // db
	
    [model release];
    [displayParameters release];
    [eventList release];
    [synthesizer release];
	[textToPhone release];
	
    [intonationPrintInfo release];
	
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
    [intonationRuleTableView reloadData]; // Because EventList doesn't send out a notification yet.
	
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
	
	// Added by dalmazio, April 11, 2009.
	eventListView = [[EventListView alloc] initWithFrame:[[scrollView contentView] frame]];
	[eventListView setAutoresizingMask:[scrollView autoresizingMask]];
	[eventListView setMouseTimeField:mouseTimeField];
	[eventListView setMouseValueField:mouseValueField];
	[scrollView setDocumentView:eventListView];
	
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
        NSTableColumn *tableColumn;
		
        tableColumn = [[NSTableColumn alloc] initWithIdentifier:[NSNumber numberWithInt:32 + index]];
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

- (IBAction)synthesizeWithSoftware:(id)sender;
{
    NSLog(@" > %s", _cmd);
    [synthesizer setShouldSaveToSoundFile:NO];
    [self synthesize];
    NSLog(@"<  %s", _cmd);
}

- (IBAction)synthesizeToFile:(id)sender;
{
    NSString *directory;
    NSSavePanel *savePanel;
	
    NSLog(@" > %s", _cmd);
	
    directory = [[NSUserDefaults standardUserDefaults] objectForKey:MDK_SoundOutputDirectory];
	
    savePanel = [NSSavePanel savePanel];
    [savePanel setCanSelectHiddenExtension:YES];
    [savePanel setAllowedFileTypes:[NSArray arrayWithObjects:@"au", @"aiff", @"wav", nil]];
    [savePanel setAccessoryView:savePanelAccessoryView];
    [self fileTypeDidChange:nil];
	
    [savePanel beginSheetForDirectory:directory file:@"Untitled" modalForWindow:[self window] modalDelegate:self didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:) contextInfo:MDK_SoundOutputDirectory];
	
    NSLog(@"<  %s", _cmd);
}

- (void)synthesize;
{
	NSString * phoneString = [self getAndSyncPhoneString];
		
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
	NSString * phoneString = [[phoneStringTextView string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
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
    NSSavePanel *savePanel;
    NSString *extension;
	
    savePanel = (NSSavePanel *)[fileTypePopUpButton window];
    switch ([[fileTypePopUpButton selectedItem] tag]) {
		case 1: extension = @"aiff"; break;
		case 2: extension = @"wav"; break;
		case 0:
		default:
			extension = @"au"; break;
    }
	
    [savePanel setRequiredFileType:extension];
}

- (void)parseText:(id)sender;
{
	NSString * phoneString = [textToPhone phoneForText:[textStringTextField stringValue]];
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
}

- (void)continueSynthesis;
{
    NSUserDefaults *defaults;
	
    defaults = [NSUserDefaults standardUserDefaults];
	
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
    NSString *directory;
    NSSavePanel *savePanel;
	
    directory = [[NSUserDefaults standardUserDefaults] objectForKey:MDK_GraphImagesDirectory];
	
    savePanel = [NSSavePanel savePanel];
    [savePanel setRequiredFileType:nil];
	
    [savePanel beginSheetForDirectory:directory file:@"Untitled" modalForWindow:[self window] modalDelegate:self didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:) contextInfo:MDK_GraphImagesDirectory];
}

- (void)openPanelDidEnd:(NSOpenPanel *)openPanel returnCode:(int)returnCode contextInfo:(void *)contextInfo;
{
    if (contextInfo == intonationWindow) {
        if (returnCode == NSOKButton) {
            [[NSUserDefaults standardUserDefaults] setObject:[openPanel directory] forKey:MDK_IntonationContourDirectory];
			
            [self prepareForSynthesis];
			
            [eventList loadIntonationContourFromXMLFile:[openPanel filename]];
			
            //[phoneStringTextField setStringValue:[eventList phoneString]];
            [intonationRuleTableView reloadData];
        }
    }
}

- (void)savePanelDidEnd:(NSSavePanel *)savePanel returnCode:(int)returnCode contextInfo:(void *)contextInfo;
{
    if (contextInfo == MDK_GraphImagesDirectory) {
        if (returnCode == NSOKButton) {
            [[NSUserDefaults standardUserDefaults] setObject:[savePanel directory] forKey:MDK_GraphImagesDirectory];
            [self saveGraphImagesToPath:[savePanel filename]];
        }
    } else if (contextInfo == MDK_IntonationContourDirectory) {
        if (returnCode == NSOKButton) {
            [[NSUserDefaults standardUserDefaults] setObject:[savePanel directory] forKey:MDK_IntonationContourDirectory];
            [eventList writeXMLToFile:[savePanel filename] comment:nil];
        }
    } else if (contextInfo == MDK_SoundOutputDirectory) {
        if (returnCode == NSOKButton) {
            [[NSUserDefaults standardUserDefaults] setObject:[savePanel directory] forKey:MDK_SoundOutputDirectory];
            [synthesizer setShouldSaveToSoundFile:YES];
            [synthesizer setFileType:[[fileTypePopUpButton selectedItem] tag]];
            [synthesizer setFilename:[savePanel filename]];
            [self synthesize];
        }
    }
}

- (void)saveGraphImagesToPath:(NSString *)basePath;
{
    unsigned int count, index, offset;
    int number = 1;
    NSDictionary *jpegProperties = nil;
    NSMutableString *html;
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
    [html appendFormat:@"    <p>%@</p>\n", GSXMLCharacterData([textStringTextField stringValue])];
    [html appendString:@"    <p>[<a href='Monet.parameters'>Monet.parameters</a>] [<a href='output.au'>output.au</a>]</p>\n"];
    [html appendString:@"    <p><object type='audio/basic' data='output.au'></object></p>\n"];
    [html appendFormat:@"    <p>Generated %@</p>\n", GSXMLCharacterData([[NSCalendarDate calendarDate] description])];
    [html appendString:@"    <p>\n"];
	
    number = 1;
	
    [fileManager createDirectoryAtPath:basePath attributes:nil];
    [fileManager copyPath:@"/tmp/Monet.parameters" toPath:[basePath stringByAppendingPathComponent:@"Monet.parameters"] handler:nil];
#ifndef GNUSTEP
    jpegProperties = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithFloat:0.95], NSImageCompressionFactor,
					  nil];
#endif
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
	
    [synthesizer setFileType:0];
    [synthesizer setFilename:[basePath stringByAppendingPathComponent:@"output.au"]];
    [synthesizer setShouldSaveToSoundFile:YES];
    [synthesizer synthesize];
	
    [jpegProperties release];
	
    [self _updateDisplayedParameters];
	
    system([[NSString stringWithFormat:@"open %@", [basePath stringByAppendingPathComponent:@"index.html"]] UTF8String]);
	
    NSLog(@"<  %s", _cmd);
}

- (IBAction) addTextString:(id)sender;
{
    NSString *str;
	
    str = [textStringTextField stringValue];
    [textStringTextField removeItemWithObjectValue:str];
    [textStringTextField insertItemWithObjectValue:str atIndex:0];
	[textStringTextField setTextColor:[NSColor blackColor]];

	str = [[textToPhone phoneForText:[textStringTextField stringValue]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	[phoneStringTextView setFont:[NSFont fontWithName:@"Lucida Grande" size:13]];
	[phoneStringTextView setString:str];
	[phoneStringTextView setTextColor:[NSColor blackColor]];
	
    [[NSUserDefaults standardUserDefaults] setObject:[textStringTextField objectValues] forKey:MDK_DefaultUtterances];
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
    NSString *directory;
    NSOpenPanel *openPanel;
	
    directory = [[NSUserDefaults standardUserDefaults] objectForKey:MDK_IntonationContourDirectory];
    openPanel = [NSOpenPanel openPanel];
    [openPanel setRequiredFileType:@"contour"];
	
    [openPanel beginSheetForDirectory:directory file:nil types:[NSArray arrayWithObject:@"contour"] modalForWindow:intonationWindow modalDelegate:self didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:) contextInfo:intonationWindow];
}

- (IBAction)saveIntonationContour:(id)sender;
{
    NSString *directory;
    NSSavePanel *savePanel;
	
    directory = [[NSUserDefaults standardUserDefaults] objectForKey:MDK_IntonationContourDirectory];
    savePanel = [NSSavePanel savePanel];
    [savePanel setRequiredFileType:@"contour"];
	
    [savePanel beginSheetForDirectory:directory file:@"Untitled" modalForWindow:intonationWindow modalDelegate:self didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:) contextInfo:MDK_IntonationContourDirectory];
}

- (IBAction)runPageLayout:(id)sneder;
{
    NSPageLayout *pageLayout;
	
    pageLayout = [NSPageLayout pageLayout];
    [pageLayout runModalWithPrintInfo:intonationPrintInfo];
}

// Currently set up to print the intonation contour.
- (IBAction)printDocument:(id)sender;
{
    MAIntonationScrollView *printView;
    NSPrintOperation *printOperation;
    NSRect printFrame;
    NSSize printableSize;
	
    printableSize = [intonationView printableSize];
    printFrame.origin = NSZeroPoint;
    printFrame.size = [NSScrollView frameSizeForContentSize:printableSize hasHorizontalScroller:NO hasVerticalScroller:NO borderType:NSNoCellMask];
	
    printView = [[MAIntonationScrollView alloc] initWithFrame:printFrame];
    [printView setBorderType:NSNoCellMask];
    [printView setHasHorizontalScroller:NO];
	
    [[printView documentView] setEventList:eventList];
    [[printView documentView] setShouldDrawSelection:NO];
    [[printView documentView] setShouldDrawSmoothPoints:[[intonationView documentView] shouldDrawSmoothPoints]];
	
    printOperation = [NSPrintOperation printOperationWithView:printView printInfo:intonationPrintInfo];
    [printOperation setShowPanels:YES];
	
    [printOperation runOperation];
    [printView release];
}

- (void)intonationPointDidChange:(NSNotification *)aNotification;
{
    [self _updateSelectedPointDetails];
}

//
// NSTableView data source
//

- (int)numberOfRowsInTableView:(NSTableView *)tableView;
{
    if (tableView == parameterTableView)
        return [displayParameters count];
	
    if (tableView == intonationRuleTableView)
        return [eventList ruleCount];
	
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
// MAIntonationView delegate
//

- (void)intonationViewSelectionDidChange:(NSNotification *)aNotification;
{
    [self _updateSelectedPointDetails];
}

//
// NSComboBox delegate
//
- (void)controlTextDidChange:(NSNotification *)aNotification;
{
	[textStringTextField setTextColor:[NSColor blackColor]];	
	[phoneStringTextView setTextColor:[NSColor redColor]];	
}

- (void)controlTextDidEndEditing:(NSNotification *)aNotification;
{
}		
		
//
// NSTextView delegate
//
- (void)textDidChange:(NSNotification *)aNotification;
{
	NSString * phoneString = [phoneStringTextView string];
	if (phoneString == NULL || [phoneString length] == 0) {
		[phoneStringTextView setFont:[NSFont fontWithName:@"Lucida Grande" size:13]];
		[phoneStringTextView setString:phoneString];
	}
	[phoneStringTextView setTextColor:[NSColor blackColor]];	
	[textStringTextField setTextColor:[NSColor redColor]];
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

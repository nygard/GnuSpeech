//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MIntonationController.h"

#import <GnuSpeech/GnuSpeech.h>

#import "NSNumberFormatter-Extensions.h"
#import "MAIntonationView.h"
#import "MAIntonationScrollView.h"
#import "MMIntonation-Monet.h"

#define MDK_IntonationContourDirectory @"IntonationContourDirectory"

@interface MIntonationController ()
@property (weak) IBOutlet MAIntonationScrollView *intonationScrollView;
@property (weak) IBOutlet MAIntonationView *intonationView;
@property (weak) IBOutlet NSTextField *semitoneTextField;
@property (weak) IBOutlet NSTextField *hertzTextField;
@property (weak) IBOutlet NSTextField *slopeTextField;
@property (weak) IBOutlet NSTableView *intonationRuleTableView;
@property (weak) IBOutlet NSTextField *beatTextField;
@property (weak) IBOutlet NSTextField *beatOffsetTextField;
@property (weak) IBOutlet NSTextField *absoluteTimeTextField;
@property (strong) NSPrintInfo *intonationPrintInfo;

@end

@implementation MIntonationController

- (id)init;
{
    if ((self = [super initWithWindowNibName:@"Intonation"])) {
        _intonationPrintInfo = [[NSPrintInfo alloc] init];
        _intonationPrintInfo.horizontalPagination = NSAutoPagination;
        _intonationPrintInfo.verticalPagination   = NSFitPagination;
        _intonationPrintInfo.orientation          = NSPaperOrientationLandscape;
    }

    return self;
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EventListDidGenerateIntonationPoints object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EventListDidChangeIntonationPoints   object:nil];
}

#pragma mark -

- (void)windowDidLoad;
{
    [super windowDidLoad];

    NSNumberFormatter *defaultNumberFormatter = [NSNumberFormatter defaultNumberFormatter];
    self.semitoneTextField.formatter     = defaultNumberFormatter;
    self.hertzTextField.formatter        = defaultNumberFormatter;
    self.slopeTextField.formatter        = defaultNumberFormatter;
    self.beatTextField.formatter         = defaultNumberFormatter;
    self.beatOffsetTextField.formatter   = defaultNumberFormatter;
    self.absoluteTimeTextField.formatter = defaultNumberFormatter;

    [self.intonationView setShouldDrawSmoothPoints:[[NSUserDefaults standardUserDefaults] boolForKey:MDK_ShouldUseSmoothIntonation]];
    [self.intonationView setDelegate:self];
    [self.intonationView setEventList:self.eventList];

    [self _updateSelectedPointDetails];

}

#pragma mark -

- (void)setEventList:(EventList *)eventList;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EventListDidGenerateIntonationPoints object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EventListDidChangeIntonationPoints   object:nil];
    _eventList = eventList;
    if (_eventList != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventListDidGenerateIntonationPoints:) name:EventListDidGenerateIntonationPoints object:_eventList];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(intonationPointDidChange:)             name:EventListDidChangeIntonationPoints   object:_eventList];
    }
}

#pragma mark -

- (void)_updateSelectedPointDetails;
{
    MMIntonationPoint *selectedIntonationPoint = [self selectedIntonationPoint];

    if (selectedIntonationPoint == nil) {
        self.semitoneTextField.stringValue     = @"";
        self.hertzTextField.stringValue        = @"";
        self.slopeTextField.stringValue        = @"";
        self.beatTextField.stringValue         = @"";
        self.beatOffsetTextField.stringValue   = @"";
        self.absoluteTimeTextField.stringValue = @"";
    } else {
        self.semitoneTextField.doubleValue     = selectedIntonationPoint.semitone;
        self.hertzTextField.doubleValue        = selectedIntonationPoint.semitoneInHertz;
        self.slopeTextField.doubleValue        = selectedIntonationPoint.slope;
        self.beatTextField.doubleValue         = selectedIntonationPoint.beatTime;
        self.beatOffsetTextField.doubleValue   = selectedIntonationPoint.offsetTime;
        self.absoluteTimeTextField.doubleValue = selectedIntonationPoint.absoluteTime;

        [self.intonationRuleTableView scrollRowToVisible:selectedIntonationPoint.ruleIndex];
        [self.intonationRuleTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedIntonationPoint.ruleIndex] byExtendingSelection:NO];
    }
}

#pragma mark -

- (IBAction)generateContour:(id)sender;
{
    NSLog(@" > %s", __PRETTY_FUNCTION__);

    MMIntonation *intonation = [[MMIntonation alloc] initFromUserDefaults];
    self.eventList.intonation = intonation;

    [self.eventList generateIntonationPoints];
    [_intonationScrollView display];

    NSLog(@"<  %s", __PRETTY_FUNCTION__);
}

#pragma mark - Intonation Point details

- (MMIntonationPoint *)selectedIntonationPoint;
{
    return [self.intonationView selectedIntonationPoint];
}

- (IBAction)setSemitone:(id)sender;
{
    self.selectedIntonationPoint.semitone = self.semitoneTextField.doubleValue;
}

- (IBAction)setHertz:(id)sender;
{
    self.selectedIntonationPoint.semitoneInHertz = self.hertzTextField.doubleValue;
}

- (IBAction)setSlope:(id)sender;
{
    self.selectedIntonationPoint.slope = self.slopeTextField.doubleValue;
}

- (IBAction)setBeatOffset:(id)sender;
{
    self.selectedIntonationPoint.offsetTime = self.beatOffsetTextField.doubleValue;
}

- (IBAction)openIntonationContour:(id)sender;
{
    NSString *directory = [[NSUserDefaults standardUserDefaults] objectForKey:MDK_IntonationContourDirectory];
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setAllowedFileTypes:@[ @"org.gnu.gnuspeech.intonation-contour" ]];
    if (directory != nil)
        [openPanel setDirectoryURL:[NSURL fileURLWithPath:directory]];

    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            [[NSUserDefaults standardUserDefaults] setObject:[[openPanel directoryURL] path] forKey:MDK_IntonationContourDirectory];

            MMIntonation *intonation = [[MMIntonation alloc] initFromUserDefaults];
            [self.eventList resetWithIntonation:intonation];

            [self.eventList loadIntonationContourFromXMLFile:[[openPanel URL] path]];

            // TODO: (2015-06-24) Update the phone string shown by the synthesizer controller.  Also update the text, but need to save the text in contour for that.
            //[phoneStringTextField setStringValue:[eventList phoneString]];
            [self.intonationView setShouldDrawSmoothPoints:[[NSUserDefaults standardUserDefaults] boolForKey:MDK_ShouldUseSmoothIntonation]];
            if ([[self.eventList intonationPoints] count] > 0)
                [self.intonationView selectIntonationPoint:[[self.eventList intonationPoints] objectAtIndex:0]];
            [_intonationRuleTableView reloadData];
        }
    }];
}

- (IBAction)saveIntonationContour:(id)sender;
{
    NSString *directory = [[NSUserDefaults standardUserDefaults] objectForKey:MDK_IntonationContourDirectory];
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setAllowedFileTypes:@[ @"org.gnu.gnuspeech.intonation-contour" ]];
    if (directory != nil)
        [savePanel setDirectoryURL:[NSURL fileURLWithPath:directory]];

    [savePanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            [[NSUserDefaults standardUserDefaults] setObject:[[savePanel directoryURL] path] forKey:MDK_IntonationContourDirectory];
            [self.eventList writeIntonationContourToXMLFile:[[savePanel URL] path] comment:nil];
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

    [[printView documentView] setEventList:self.eventList];
    [[printView documentView] setShouldDrawSelection:NO];
    [[printView documentView] setShouldDrawSmoothPoints:[self.intonationView shouldDrawSmoothPoints]];

    NSPrintOperation *printOperation = [NSPrintOperation printOperationWithView:printView printInfo:_intonationPrintInfo];
    [printOperation setShowsPrintPanel:YES];
    [printOperation setShowsProgressPanel:YES];

    [printOperation runOperation];
}

- (void)intonationPointDidChange:(NSNotification *)notification;
{
    [self _updateSelectedPointDetails];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
{
    if (tableView == self.intonationRuleTableView)
        return [self.eventList ruleCount];

    return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
    id identifier = [tableColumn identifier];

    if (tableView == self.intonationRuleTableView) {
        if ([@"rule" isEqual:identifier]) {
            MMRuleValues *ruleValues = self.eventList.appliedRules[row];
            return ruleValues.matchedPhonesDescription;
        } else if ([@"number" isEqual:identifier]) {
            return [NSString stringWithFormat:@"%lu.", row + 1];
        }
    }

    return nil;
}

#pragma mark - MAIntonationView delegate

- (void)intonationViewSelectionDidChange:(NSNotification *)notification;
{
    [self _updateSelectedPointDetails];
}

#pragma mark -

- (void)eventListDidGenerateIntonationPoints:(NSNotificationCenter *)notification;
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self.intonationView setShouldDrawSmoothPoints:[[NSUserDefaults standardUserDefaults] boolForKey:MDK_ShouldUseSmoothIntonation]];
    if ([[self.eventList intonationPoints] count] > 0)
        [self.intonationView selectIntonationPoint:[[self.eventList intonationPoints] objectAtIndex:0]];
    [_intonationRuleTableView reloadData];
}

#pragma mark -


@end

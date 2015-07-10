//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MEventTableController.h"

#import <GnuSpeech/GnuSpeech.h>
#import "NSNumberFormatter-Extensions.h"
#import "MMDisplayParameter.h"

@interface MEventTableController ()
@property (weak) IBOutlet NSTableView *eventTableView;
@end

// 2015-06-20: This generates the following message when synthesizing and then showing the events:
// Layout still needs update after calling -[NSScrollView layout].  NSScrollView or one of its superclasses may have overridden -layout without calling super. Or, something may have dirtied layout in the middle of updating it.  Both are programming errors in Cocoa Autolayout.  The former is pretty likely to arise if some pre-Cocoa Autolayout class had a method called layout, but it should be fixed.
// This is on OS X 10.10.3.  Searches show other people getting the same message, and it might be an Apple bug.  Not investigating further right now.

// TODO: (2015-06-23) Intonation values don't get updated after Generate Contour.  It looks like the intonation points are separate from the values in the EventList, and the EventList values aren't getting updated.  This was true before my recent changes.


@implementation MEventTableController

- (id)init;
{
    if ((self = [super initWithWindowNibName:@"EventTable"])) {
    }

    return self;
}

- (void)windowDidLoad;
{
    NSButtonCell *checkboxCell = [[NSButtonCell alloc] initTextCell:@""];
    [checkboxCell setControlSize:NSSmallControlSize];
    [checkboxCell setButtonType:NSSwitchButton];
    [checkboxCell setImagePosition:NSImageOnly];
    [checkboxCell setEditable:NO];
    [[self.eventTableView tableColumnWithIdentifier:@"isAtPosture"] setDataCell:checkboxCell];


    NSNumberFormatter *defaultNumberFormatter = [NSNumberFormatter defaultNumberFormatter];
    [[[self.eventTableView tableColumnWithIdentifier:@"time"] dataCell] setFormatter:defaultNumberFormatter];

    [self _updateEventColumns];
    [self.eventTableView reloadData];
}

#pragma mark -

- (void)setEventList:(EventList *)eventList;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EventListDidGenerateIntonationPoints object:nil];
    _eventList = eventList;
    if (_eventList != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventListDidGenerateIntonationPoints:) name:EventListDidGenerateIntonationPoints object:_eventList];
    }
    [self.eventTableView reloadData];
}

- (void)setDisplayParameters:(NSArray *)displayParameters;
{
    _displayParameters = [displayParameters copy];
    [self _updateEventColumns];
    [self.eventTableView reloadData];
}

/// Create a column for each non-special dispaly parameter.  The special ones will be displayed in a second row of the same column.
/// Add four columns for the intonation values at the end.
- (void)_updateEventColumns;
{
    NSMutableArray *tableColumns = [[_eventTableView tableColumns] mutableCopy];
    [tableColumns removeObject:[_eventTableView tableColumnWithIdentifier:@"time"]];
    [tableColumns removeObject:[_eventTableView tableColumnWithIdentifier:@"isAtPosture"]];
    for (NSTableColumn *tableColumn in tableColumns) {
        [_eventTableView removeTableColumn:tableColumn];
    }

    NSNumberFormatter *defaultNumberFormatter = [NSNumberFormatter defaultNumberFormatter2];

    NSUInteger count = [_displayParameters count];
    for (NSUInteger index = 0; index < count; index++) {
        MMDisplayParameter *displayParameter = _displayParameters[index];

        if ([displayParameter isSpecial] == NO) {
            NSTableColumn *tableColumn = [[NSTableColumn alloc] initWithIdentifier:[NSString stringWithFormat:@"%lu", displayParameter.tag]];
            [tableColumn setEditable:NO];
            [[tableColumn headerCell] setTitle:[[displayParameter parameter] name]];
            [[tableColumn dataCell] setFormatter:defaultNumberFormatter];
            [[tableColumn dataCell] setAlignment:NSRightTextAlignment];
            [[tableColumn dataCell] setDrawsBackground:NO];
            [tableColumn setWidth:60.0];
            [_eventTableView addTableColumn:tableColumn];
        }
    }

    // And finally add columns for the intonation values:
    NSArray *others = @[ @"Semitone", @"Slope", @"2nd Derivative", @"3rd Derivative" ];
    for (NSUInteger index = 0; index < [others count]; index++) {
        NSTableColumn *tableColumn = [[NSTableColumn alloc] initWithIdentifier:[NSString stringWithFormat:@"%lu", 32 + index]];
        [tableColumn setEditable:NO];
        [[tableColumn headerCell] setTitle:others[index]];
        [[tableColumn dataCell] setFormatter:defaultNumberFormatter];
        [[tableColumn dataCell] setAlignment:NSRightTextAlignment];
        [[tableColumn dataCell] setDrawsBackground:NO];
        [tableColumn setWidth:80.0];
        [_eventTableView addTableColumn:tableColumn];
    }

    [_eventTableView reloadData];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
{
    if (tableView == self.eventTableView)
        return [self.eventList.events count] * 2;

    return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
    id identifier = [tableColumn identifier];

    if (tableView == self.eventTableView) {
        NSInteger eventNumber = row / 2;
        if ([@"time" isEqual:identifier]) {
            Event *event = self.eventList.events[eventNumber];
            return @(event.time);
        } else if ([@"isAtPosture" isEqual:identifier]) {
            Event *event = self.eventList.events[eventNumber];
            return @(event.isAtPosture);
        } else {
            NSInteger rowOffset = row % 2;
            NSInteger index = [identifier intValue] + rowOffset * 16;
            if (rowOffset == 0 || index < 32) {
                double value = [self.eventList.events[eventNumber] getValueAtIndex:index];
                if (value == NaN) return nil;
                return [NSNumber numberWithDouble:value];
            }
        }
    }

    return nil;
}

#pragma mark - NSTableViewDelegate

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
    id identifier = [tableColumn identifier];

    if (tableView == _eventTableView) {
        if ([@"time" isEqual:identifier] && (row % 2) == 1) {
            [cell setObjectValue:nil];
        } else if ([@"isAtPosture" isEqual:identifier]) {
            if ((row % 2) == 0)
                [cell setTransparent:NO];
            else
                [cell setTransparent:YES];
        }
    }
}

#pragma mark -

- (void)eventListDidGenerateIntonationPoints:(NSNotificationCenter *)notification;
{
    [self.eventTableView reloadData];
}

@end

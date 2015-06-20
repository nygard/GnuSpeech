//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MEventTableController.h"

#import <GnuSpeech/GnuSpeech.h>
#import "NSNumberFormatter-Extensions.h"

@interface MEventTableController ()
@property (weak) IBOutlet NSTableView *eventTableView;
@end

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
    [[self.eventTableView tableColumnWithIdentifier:@"flag"] setDataCell:checkboxCell];


    NSNumberFormatter *defaultNumberFormatter = [NSNumberFormatter defaultNumberFormatter];
    [[[self.eventTableView tableColumnWithIdentifier:@"flag"] dataCell] setFormatter:defaultNumberFormatter];
}

#pragma mark -

- (void)setEventList:(EventList *)eventList;
{
    _eventList = eventList;
    [self.eventTableView reloadData];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
{
    if (tableView == self.eventTableView)
        return [[_eventList events] count] * 2;

    return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
    id identifier = [tableColumn identifier];

    if (tableView == _eventTableView) {
        NSInteger eventNumber = row / 2;
        if ([@"time" isEqual:identifier] == YES) {
            return [NSNumber numberWithInteger:[[[_eventList events] objectAtIndex:eventNumber] time]];
        } else if ([@"flag" isEqual:identifier] == YES) {
            return [NSNumber numberWithBool:[[[_eventList events] objectAtIndex:eventNumber] flag]];
        } else {
            NSInteger rowOffset = row % 2;
            NSInteger index = [identifier intValue] + rowOffset * 16;
            if (rowOffset == 0 || index < 32) {
                double value = [[[_eventList events] objectAtIndex:eventNumber] getValueAtIndex:index];
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
        } else if ([@"flag" isEqual:identifier]) {
            if ((row % 2) == 0)
                [cell setTransparent:NO];
            else
                [cell setTransparent:YES];
        }
    }
}

@end

//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MDisplayParametersController.h"

#import <GnuSpeech/GnuSpeech.h>
#import "MMDisplayParameter.h"
#import "MExtendedTableView.h"

@interface MDisplayParametersController ()
@property (weak) IBOutlet MExtendedTableView *parameterTableView;
@end

@implementation MDisplayParametersController

- (id)init;
{
    if ((self = [super initWithNibName:@"DisplayParameters" bundle:nil])) {
    }

    return self;
}

#pragma mark -

- (void)setDisplayParameters:(NSArray *)displayParameters;
{
    _displayParameters = displayParameters;
    [self.parameterTableView reloadData];
}

#pragma mark -

- (void)viewDidLoad;
{
    [super viewDidLoad];

    NSButtonCell *checkboxCell = [[NSButtonCell alloc] initTextCell:@""];
    [checkboxCell setControlSize:NSSmallControlSize];
    [checkboxCell setButtonType:NSSwitchButton];
    [checkboxCell setImagePosition:NSImageOnly];
    [checkboxCell setEditable:NO];

    [[self.parameterTableView tableColumnWithIdentifier:@"shouldDisplay"] setDataCell:checkboxCell];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
{
    if (tableView == self.parameterTableView)
        return [self.displayParameters count];

    return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
    id identifier = tableColumn.identifier;

    if (tableView == self.parameterTableView) {
        MMDisplayParameter *displayParameter = self.displayParameters[row];

        if ([@"name" isEqual:identifier]) {
            return displayParameter.name;
        } else if ([@"shouldDisplay" isEqual:identifier]) {
            return @(displayParameter.shouldDisplay);
        }
    }

    return nil;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
    id identifier = [tableColumn identifier];

    if (tableView == self.parameterTableView) {
        MMDisplayParameter *displayParameter = self.displayParameters[row];

        if ([@"shouldDisplay" isEqual:identifier]) {
            displayParameter.shouldDisplay = [object boolValue];
            [self.parameterTableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row] columnIndexes:[NSIndexSet indexSetWithIndex:[self.parameterTableView.tableColumns indexOfObject:tableColumn]]];
        }
    }
}

#pragma mark - MExtendedTableView delegate

- (BOOL)control:(NSControl *)control shouldProcessCharacters:(NSString *)characters;
{
    if ([characters isEqualToString:@" "]) {
        NSInteger selectedRow = [self.parameterTableView selectedRow];
        if (selectedRow != -1) {
            MMDisplayParameter *displayParameter = self.displayParameters[selectedRow];
            [displayParameter toggleShouldDisplay];
            NSIndexSet *columnIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self.parameterTableView.tableColumns count])];
            [self.parameterTableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow] columnIndexes:columnIndexSet];
            [(MExtendedTableView *)control doNotCombineNextKey];
            return NO;
        }
    } else {
        NSUInteger count = [self.displayParameters count];
        for (NSUInteger index = 0; index < count; index++) {
            MMDisplayParameter *displayParameter = self.displayParameters[index];
            if ([displayParameter.parameter.name hasPrefix:characters ignoreCase:YES]) {
                [self.parameterTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
                [self.parameterTableView scrollRowToVisible:index];
                return NO;
            }
        }
    }
    
    return YES;
}

@end

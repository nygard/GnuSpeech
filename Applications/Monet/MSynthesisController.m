//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MSynthesisController.h"

#import <AppKit/AppKit.h>
#import "MMDisplayParameter.h"
#import "MModel.h"
#import "ParameterList.h"

@implementation MSynthesisController

- (id)initWithModel:(MModel *)aModel;
{
    if ([super initWithWindowNibName:@"Synthesis"] == nil)
        return nil;

    model = [aModel retain];
    displayParameters = [[NSMutableArray alloc] init];
    [self _updateDisplayParameters];

    [self setWindowFrameAutosaveName:@"Synthesis"];

    return self;
}

- (void)dealloc;
{
    [model release];
    [displayParameters release];

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

    [self _updateDisplayParameters];
    [self updateViews];
}

- (NSUndoManager *)undoManager;
{
    return nil;
}

- (void)windowDidLoad;
{
    NSButtonCell *checkboxCell;

    checkboxCell = [[NSButtonCell alloc] initTextCell:@""];
    [checkboxCell setControlSize:NSSmallControlSize];
    [checkboxCell setButtonType:NSSwitchButton];
    [checkboxCell setImagePosition:NSImageOnly];
    [checkboxCell setEditable:NO];

    [[parameterTableView tableColumnWithIdentifier:@"shouldDisplay"] setDataCell:checkboxCell];

    [checkboxCell release];

    [self updateViews];
}

- (void)_updateDisplayParameters;
{
    ParameterList *parameters;
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

    // TODO (2004-03-30): This used to have Intonation.  How did that work?

    [parameterTableView reloadData];
}

- (void)updateViews;
{
}

- (void)_updateDisplayedParameters;
{
    NSLog(@"%s", _cmd);
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

- (IBAction)parseStringButton:(id)sender;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
}

- (IBAction)synthesizeWithSoftware:(id)sender;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
}

- (IBAction)synthesizeToFile:(id)sender;
{
}

//
// NSTableView data source
//

- (int)numberOfRowsInTableView:(NSTableView *)tableView;
{
    return [displayParameters count];
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

@end

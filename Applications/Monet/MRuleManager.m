//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MRuleManager.h"

#import <AppKit/AppKit.h>
#import "MModel.h"
#import "MMRule.h"
#import "RuleList.h"

@implementation MRuleManager

- (id)initWithModel:(MModel *)aModel;
{
    if ([super initWithWindowNibName:@"RuleManager"] == nil)
        return nil;

    model = [aModel retain];

    [self setWindowFrameAutosaveName:@"New Rule Manager"];

    return self;
}

- (void)dealloc;
{
    [model release];

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

    [self updateViews];
}

- (NSUndoManager *)undoManager;
{
    return nil;
}

- (void)windowDidLoad;
{
    [self updateViews];
}

- (void)updateViews;
{
}

//
// NSTableView data source
//

- (int)numberOfRowsInTableView:(NSTableView *)tableView;
{
    if (tableView == ruleTableView) {
        return [[model rules] count];
    }

    return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row;
{
    id identifier;

    identifier = [tableColumn identifier];

    if (tableView == ruleTableView) {
        if ([@"number" isEqual:identifier] == YES) {
            //return [NSNumber numberWithInt:row + 1];
            return [NSString stringWithFormat:@"%d.", row + 1];
        } else if ([@"rule" isEqual:identifier] == YES) {
            return [[[model rules] objectAtIndex:row] ruleString];
        }
    }

    return nil;
}

@end

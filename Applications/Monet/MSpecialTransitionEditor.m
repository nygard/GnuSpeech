//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MSpecialTransitionEditor.h"

#import <AppKit/AppKit.h>
#import "MModel.h"

@implementation MSpecialTransitionEditor

- (id)initWithModel:(MModel *)aModel;
{
    if ([super initWithWindowNibName:@"SpecialTransitionEditor"] == nil)
        return nil;

    model = [aModel retain];

    [self setWindowFrameAutosaveName:@"Special Transition Editor"];

    return self;
}

@end

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MMObject.h"

#import <Foundation/Foundation.h>

@implementation MMObject

- (MModel *)model;
{
    return nonretained_model;
}

- (void)setModel:(MModel *)newModel;
{
    nonretained_model = newModel;
}

- (NSUndoManager *)undoManager;
{
    return nil;
}

@end

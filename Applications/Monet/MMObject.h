//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>
#import <Foundation/NSUndoManager.h>

@class MModel;

@interface MMObject : NSObject
{
    MModel *nonretained_model;
}

- (MModel *)model;
- (void)setModel:(MModel *)newModel;

- (NSUndoManager *)undoManager;

@end

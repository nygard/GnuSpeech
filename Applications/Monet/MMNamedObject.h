//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MMObject.h"

@interface MMNamedObject : MMObject
{
    NSString *name;
    NSString *comment;
}

- (void)dealloc;

- (NSString *)name;
- (void)setName:(NSString *)newName;

- (NSString *)comment;
- (void)setComment:(NSString *)newComment;
- (BOOL)hasComment;

- (void)loadFromXMLElement:(NSXMLElement *)element context:(id)context;

@end

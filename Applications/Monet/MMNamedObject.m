//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MMNamedObject.h"

#import "GSXMLFunctions.h"
#import "MModel.h"

@implementation MMNamedObject

- (void)dealloc;
{
    [name release];
    [comment release];

    [super dealloc];
}

- (NSString *)name;
{
    return name;
}

- (void)setName:(NSString *)newName;
{
    if (newName == name)
        return;

    [name release];
    name = [newName retain];
}

- (NSString *)comment;
{
    return comment;
}

- (void)setComment:(NSString *)newComment;
{
    if (newComment == comment)
        return;

    [comment release];
    comment = [newComment retain];
}

- (BOOL)hasComment;
{
    return comment != nil && [comment length] > 0;
}

- (void)loadFromXMLElement:(NSXMLElement *)element context:(id)context;
{
    NSArray *comments;
    unsigned int count, index;

    [self setName:[[element attributeForName:@"name"] stringValue]];

    comments = [element elementsForName:@"comment"];
    count = [comments count];
    for (index = 0; index < count; index++) {
        NSXMLElement *commentElement;

        commentElement = [comments objectAtIndex:index];
        [self setComment:[commentElement stringValue]];
    }
}

@end

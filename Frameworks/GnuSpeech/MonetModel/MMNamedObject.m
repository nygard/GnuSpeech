//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMNamedObject.h"

#import "GSXMLFunctions.h"
#import "MModel.h"

#import "MXMLParser.h"
#import "MXMLPCDataDelegate.h"

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

- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
{
    // TODO (2004-08-12): I'm a little wary of calling init here, since subclasses may want to use a different designated initializer, but I'll try it.
    if ([self init] == nil)
        return nil;

    [self setName:[attributes objectForKey:@"name"]];

    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    if ([elementName isEqualToString:@"comment"]) {
        MXMLPCDataDelegate *newDelegate;

        newDelegate = [[MXMLPCDataDelegate alloc] initWithElementName:elementName delegate:self setSelector:@selector(setComment:)];
        [(MXMLParser *)parser pushDelegate:newDelegate];
        [newDelegate release];
    } else {
        NSLog(@"%@, Unknown element: '%@', skipping", self, elementName);
        [(MXMLParser *)parser skipTree];
    }
}

@end

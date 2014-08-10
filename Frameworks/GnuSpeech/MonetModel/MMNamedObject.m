//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMNamedObject.h"

#import "GSXMLFunctions.h"
#import "MModel.h"

#import "MXMLParser.h"
#import "MXMLPCDataDelegate.h"

@implementation MMNamedObject
{
    NSString *_name;
    NSString *_comment;
}

#pragma mark -

- (BOOL)hasComment;
{
    return self.comment != nil && [self.comment length] > 0;
}

#pragma mark - XML Archiving

- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
{
    // TODO (2004-08-12): I'm a little wary of calling init here, since subclasses may want to use a different designated initializer, but I'll try it.
    if ((self = [self init])) {
        [self setName:[attributes objectForKey:@"name"]];
    }

    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    if ([elementName isEqualToString:@"comment"]) {
        MXMLPCDataDelegate *newDelegate = [[MXMLPCDataDelegate alloc] initWithElementName:elementName delegate:self setSelector:@selector(setComment:)];
        [(MXMLParser *)parser pushDelegate:newDelegate];
    } else {
        NSLog(@"%@, Unknown element: '%@', skipping", self, elementName);
        [(MXMLParser *)parser skipTree];
    }
}

@end

//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "NamedList.h"

#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"
#import "MMEquation.h"
#import "MMTarget.h" // Just to get -appendXMLToString:level:, this is just a quick hack
#import "MMTransition.h"

#import "GSXMLFunctions.h"
#import "MXMLParser.h"
#import "MXMLPCDataDelegate.h"

@implementation NamedList
{
    __weak MModel *nonretained_model;
    
    NSString *name;
    NSString *comment;
}

- (void)dealloc;
{
    [comment release];
    [name release];

    [super dealloc];
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p> name: %@, comment: %@",
            NSStringFromClass([self class]), self, name, comment];
}

#pragma mark -

- (MModel *)model;
{
    return nonretained_model;
}

- (void)setModel:(MModel *)newModel;
{
    nonretained_model = newModel;

    for (id currentObject in self.ilist) {
        if ([currentObject respondsToSelector:@selector(setModel:)])
            [currentObject setModel:newModel];
    }
}

- (NSUndoManager *)undoManager;
{
    return nil;
}

@synthesize name, comment;

- (BOOL)hasComment;
{
    return comment != nil && [comment length] > 0;
}

- (void)appendXMLToString:(NSMutableString *)resultString elementName:(NSString *)elementName level:(NSUInteger)level;
{
    NSUInteger count = [self.ilist count];
    if (count == 0)
        return;

    [resultString indentToLevel:level];
    [resultString appendFormat:@"<%@ name=\"%@\"", elementName, GSXMLAttributeString(name, NO)];

    if (comment != nil)
        [resultString appendFormat:@" comment=\"%@\"", GSXMLAttributeString(comment, NO)];

    [resultString appendString:@">\n"];

    for (NSUInteger index = 0; index < count; index++) {
        id anObject = [self.ilist objectAtIndex:index];
        [anObject appendXMLToString:resultString level:level+1];
    }

    [resultString indentToLevel:level];
    [resultString appendFormat:@"</%@>\n", elementName];
}

- (void)addObject:(id)anObject;
{
    [super addObject:anObject];

    if ([anObject respondsToSelector:@selector(setGroup:)] == YES)
        [anObject setGroup:self];
    if ([anObject respondsToSelector:@selector(setModel:)] == YES)
        [anObject setModel:[self model]];
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;
{
    [self.ilist insertObject:anObject atIndex:index];

    if ([anObject respondsToSelector:@selector(setGroup:)] == YES)
        [anObject setGroup:self];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;
{
    [self.ilist replaceObjectAtIndex:index withObject:anObject];

    if ([anObject respondsToSelector:@selector(setGroup:)] == YES)
        [anObject setGroup:self];
}

- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
{
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
        [newDelegate release];
    } else if ([elementName isEqualToString:@"equation"]) {
        MMEquation *newDelegate = [MMEquation objectWithXMLAttributes:attributeDict context:[(MXMLParser *)parser context]];
        [self addObject:newDelegate];

        // Set the formula after adding it to the group, so that it has access to the model for the symbols
        NSString *str = [attributeDict objectForKey:@"formula"];
        if (str != nil && [str length] > 0)
            [newDelegate setFormulaString:str];
        [(MXMLParser *)parser pushDelegate:newDelegate];
    } else if ([elementName isEqualToString:@"transition"]) {
        MMTransition *newDelegate = [MMTransition objectWithXMLAttributes:attributeDict context:[(MXMLParser *)parser context]];
        [self addObject:newDelegate];
        [(MXMLParser *)parser pushDelegate:newDelegate];
    } else {
        NSLog(@"%@, Unknown element: '%@', skipping", [self shortDescription], elementName);
        [(MXMLParser *)parser skipTree];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    [(MXMLParser *)parser popDelegate];
}

@end

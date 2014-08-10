//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMGroup.h"

#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"
#import "MMEquation.h"
#import "MMTarget.h" // Just to get -appendXMLToString:level:, this is just a quick hack
#import "MMTransition.h"
#import "MMGroupedObject.h"

#import "GSXMLFunctions.h"
#import "MXMLParser.h"
#import "MXMLPCDataDelegate.h"

@interface MMGroup ()
@end

@implementation MMGroup
{
    NSMutableArray *_objects;
}

- (id)init;
{
    if ((self = [super init])) {
        _objects = [[NSMutableArray alloc] init];
    }
    
    return self;
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p> name: %@, comment: %@, objects: %@",
            NSStringFromClass([self class]), self,
            self.name, self.comment, self.objects];
}

#pragma mark -

- (NSArray *)objects;
{
    return [_objects copy];
}

- (void)setModel:(MModel *)newModel;
{
    [super setModel:newModel];
    
    for (id currentObject in self.objects) {
        if ([currentObject respondsToSelector:@selector(setModel:)])
            [currentObject setModel:newModel];
    }
}

- (void)addObject:(MMGroupedObject *)object;
{
    [_objects addObject:object];

    object.model = self.model;
    object.group = self;
}

- (id)objectWithName:(NSString *)name;
{
    for (MMNamedObject *object in _objects) {
        if ([name isEqualToString:object.name])
            return object;
    }
    
    return nil;
}

#pragma mark - XML Archiving

- (void)appendXMLToString:(NSMutableString *)resultString elementName:(NSString *)elementName level:(NSUInteger)level;
{
    NSUInteger count = [self.objects count];
    if (count == 0)
        return;
    
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<%@ name=\"%@\"", elementName, GSXMLAttributeString(self.name, NO)];
    
    if (self.comment != nil)
        [resultString appendFormat:@" comment=\"%@\"", GSXMLAttributeString(self.comment, NO)];
    
    [resultString appendString:@">\n"];
    
    for (NSUInteger index = 0; index < count; index++) {
        id anObject = [self.objects objectAtIndex:index];
        [anObject appendXMLToString:resultString level:level+1];
    }
    
    [resultString indentToLevel:level];
    [resultString appendFormat:@"</%@>\n", elementName];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    if ([elementName isEqualToString:@"equation"]) {
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
        [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qName attributes:attributeDict];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
#if 0
    if ([elementName isEqualToString:@"posture"])
        [(MXMLParser *)parser popDelegate];
    else
        [NSException raise:@"Unknown close tag" format:@"Unknown closing tag (%@) in %@", elementName, NSStringFromClass([self class])];
#else
    [(MXMLParser *)parser popDelegate];
#endif
}

@end

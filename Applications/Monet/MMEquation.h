#import <Foundation/NSObject.h>

@class FormulaExpression, NamedList;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface MMEquation : NSObject
{
    NamedList *nonretained_group;

    NSString *name;
    NSString *comment;
    FormulaExpression *expression;

    int cacheTag;
    double cacheValue;
}

- (id)init;
- (id)initWithName:(NSString *)newName;
- (void)dealloc;

- (NamedList *)group;
- (void)setGroup:(NamedList *)newGroup;

- (NSString *)name;
- (void)setName:(NSString *)newName;

- (NSString *)comment;
- (void)setComment:(NSString *)newComment;
- (BOOL)hasComment;

- (FormulaExpression *)expression;
- (void)setExpression:(FormulaExpression *)newExpression;

- (void)setFormulaString:(NSString *)formulaString;

- (double)evaluate:(double *)ruleSymbols tempos:(double *)tempos phones:phones andCacheWith:(int)newCacheTag;
- (double)evaluate:(double *)ruleSymbols phones:phones andCacheWith:(int)newCacheTag;
- (double)cacheValue;

- (id)initWithCoder:(NSCoder *)aDecoder;

- (NSString *)description;

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;

- (NSString *)equationPath;

- (id)initWithXMLAttributes:(NSDictionary *)attributes;
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

@end

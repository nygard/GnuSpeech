#import "MMEquation.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "GSXMLFunctions.h"
#import "MMFormulaNode.h"
#import "MMFormulaParser.h"
#import "MModel.h"
#import "MMOldFormulaNode.h"
#import "MUnarchiver.h"
#import "MXMLParser.h"
#import "MXMLPCDataDelegate.h"
#import "NamedList.h"

@implementation MMEquation

- (id)init;
{
    if ([super init] == nil)
        return nil;

    name = nil;
    comment = nil;
    expression = nil;

    cacheTag = 0;
    cacheValue = 0.0;

    return self;
}

- (id)initWithName:(NSString *)newName;
{
    if ([self init] == nil)
        return nil;

    [self setName:newName];

    return self;
}

- (void)dealloc;
{
    [name release];
    [comment release];
    [expression release];

    [super dealloc];
}

- (NamedList *)group;
{
    return nonretained_group;
}

- (void)setGroup:(NamedList *)newGroup;
{
    nonretained_group = newGroup;
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

- (MMFormulaNode *)expression;
{
    return expression;
}

- (void)setExpression:(MMFormulaNode *)newExpression;
{
    if (newExpression == expression)
        return;

    [expression release];
    expression = [newExpression retain];
}

- (void)setFormulaString:(NSString *)formulaString;
{
    MMFormulaParser *formulaParser;
    MMFormulaNode *result;
    NSString *errorString;

    formulaParser = [[MMFormulaParser alloc] init];
    [formulaParser setSymbolList:[[self model] symbols]];

    result = [formulaParser parseString:formulaString];
    [self setExpression:result];

    errorString = [formulaParser errorMessage];
    if ([errorString length] > 0)
        NSLog(@"Warning: (%@) error parsing formula: '%@', at %@:'%@', error string: %@", name, formulaString, NSStringFromRange([formulaParser errorRange]), [formulaString substringFromIndex:[formulaParser errorRange].location], errorString);

    // TODO (2004-04-22): A few formulas are failing to parse.  Try just rewriting the formula parser.

    [formulaParser release];
}

- (double)evaluate:(double *)ruleSymbols tempos:(double *)tempos phones:phones andCacheWith:(int)newCacheTag;
{
    if (newCacheTag != cacheTag) {
        cacheTag = newCacheTag;
        cacheValue = [expression evaluate:ruleSymbols phones:phones tempos:tempos];
    }

    return cacheValue;
}

- (double)evaluate:(double *)ruleSymbols phones:phones andCacheWith:(int)newCacheTag;
{
    if (newCacheTag != cacheTag) {
        cacheTag = newCacheTag;
        cacheValue = [expression evaluate:ruleSymbols phones:phones];
    }

    return cacheValue;
}

- (double)cacheValue;
{
    return cacheValue;
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    unsigned archivedVersion;
    char *c_name, *c_comment;
    MMOldFormulaNode *archivedExpression;
    NSString *expressionString;
    MModel *model;

    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    model = [(MUnarchiver *)aDecoder userInfo];

    cacheTag = 0;
    cacheValue = 0.0;

    //NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    archivedVersion = [aDecoder versionForClassName:NSStringFromClass([self class])];
    //NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

    [aDecoder decodeValuesOfObjCTypes:"**", &c_name, &c_comment];
    //NSLog(@"c_name: %s, c_comment: %s", c_name, c_comment);

    name = [[NSString stringWithASCIICString:c_name] retain];
    comment = [[NSString stringWithASCIICString:c_comment] retain];
    archivedExpression = [aDecoder decodeObject];
    if (archivedExpression != nil) {
        expressionString = [archivedExpression expressionString];
        expression = [[MMFormulaParser parsedExpressionFromString:expressionString symbolList:[model symbols]] retain];
    }

    //NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);
    return self;
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: name: %@, comment: %@, expression: %@, cacheTag: %d, cacheValue: %g",
                     NSStringFromClass([self class]), self, name, comment, expression, cacheTag, cacheValue];
}

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
{
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<equation name=\"%@\"", GSXMLAttributeString(name, NO)];
    if (expression != nil)
        [resultString appendFormat:@" formula=\"%@\"", GSXMLAttributeString([expression expressionString], NO)];

    if (comment == nil) {
        [resultString appendString:@"/>\n"];
    } else {
        [resultString appendString:@">\n"];

        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<comment>%@</comment>\n", GSXMLCharacterData(comment)];

        [resultString indentToLevel:level];
        [resultString appendFormat:@"</equation>\n"];
    }
}

- (NSString *)equationPath;
{
    return [NSString stringWithFormat:@"%@:%@", [[self group] name], name];
}

- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
{
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
        NSLog(@"%@, Unknown element: '%@', skipping", [self shortDescription], elementName);
        [(MXMLParser *)parser skipTree];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    [(MXMLParser *)parser popDelegate];
}

@end

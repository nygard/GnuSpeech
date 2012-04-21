//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMEquation.h"

#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "GSXMLFunctions.h"
#import "MMFormulaNode.h"
#import "MMFormulaParser.h"
#import "MModel.h"
#import "MXMLParser.h"
#import "MXMLPCDataDelegate.h"
#import "NamedList.h"

@implementation MMEquation
{
    __weak NamedList *nonretained_group;
    
    NSString *name;
    NSString *comment;
    MMFormulaNode *formula;
    
    NSUInteger cacheTag;
    double cacheValue;
}

- (id)init;
{
    if ((self = [super init])) {
        name = nil;
        comment = nil;
        formula = nil;

        cacheTag = 0;
        cacheValue = 0.0;
    }

    return self;
}

- (id)initWithName:(NSString *)newName;
{
    if ((self = [self init])) {
        [self setName:newName];
    }

    return self;
}

- (void)dealloc;
{
    [name release];
    [comment release];
    [formula release];

    [super dealloc];
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p> name: %@, comment: %@, formula: %@, cacheTag: %lu, cacheValue: %g",
            NSStringFromClass([self class]), self, name, comment, formula, cacheTag, cacheValue];
}

#pragma mark -

@synthesize group = nonretained_group;
@synthesize name, comment;

- (BOOL)hasComment;
{
    return comment != nil && [comment length] > 0;
}

@synthesize formula;

- (void)setFormulaString:(NSString *)formulaString;
{
    MMFormulaParser *formulaParser = [[MMFormulaParser alloc] initWithModel:[self model]];

    MMFormulaNode *result = [formulaParser parseString:formulaString];
    [self setFormula:result];

    NSString *errorString = [formulaParser errorMessage];
    if ([errorString length] > 0)
        NSLog(@"Warning: (%@) error parsing formula: '%@', at %@:'%@', error string: %@", name, formulaString, NSStringFromRange([formulaParser errorRange]), [formulaString substringFromIndex:[formulaParser errorRange].location], errorString);

    [formulaParser release];
}

- (double)evaluate:(MMFRuleSymbols *)ruleSymbols tempos:(double *)tempos postures:(NSArray *)postures andCacheWith:(NSUInteger)newCacheTag;
{
    if (newCacheTag != cacheTag) {
        cacheTag = newCacheTag;
        cacheValue = [formula evaluate:ruleSymbols postures:postures tempos:tempos];
    }

    return cacheValue;
}

- (double)evaluate:(MMFRuleSymbols *)ruleSymbols postures:(NSArray *)postures andCacheWith:(NSUInteger)newCacheTag;
{
    if (newCacheTag != cacheTag) {
        cacheTag = newCacheTag;
        cacheValue = [formula evaluate:ruleSymbols postures:postures];
    }

    return cacheValue;
}

- (double)cacheValue;
{
    return cacheValue;
}

- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<equation name=\"%@\"", GSXMLAttributeString(name, NO)];
    if (formula != nil)
        [resultString appendFormat:@" formula=\"%@\"", GSXMLAttributeString([formula expressionString], NO)];

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

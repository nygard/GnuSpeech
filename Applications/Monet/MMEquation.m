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
#import "NamedList.h"

@implementation MMEquation

- (id)init;
{
    if ([super init] == nil)
        return nil;

    name = nil;
    comment = nil;
    formula = nil;

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
    [formula release];

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

- (MMFormulaNode *)formula;
{
    return formula;
}

- (void)setFormula:(MMFormulaNode *)newFormula;
{
    if (newFormula == formula)
        return;

    [formula release];
    formula = [newFormula retain];
}

- (void)setFormulaString:(NSString *)formulaString;
{
    MMFormulaParser *formulaParser;
    MMFormulaNode *result;
    NSString *errorString;

    if (formulaString == nil) {
        [self setFormula:nil];
        return;
    }

    formulaParser = [[MMFormulaParser alloc] initWithModel:[self model]];

    result = [formulaParser parseString:formulaString];
    [self setFormula:result];

    errorString = [formulaParser errorMessage];
    if ([errorString length] > 0)
        NSLog(@"Warning: (%@) error parsing formula: '%@', at %@:'%@', error string: %@", name, formulaString, NSStringFromRange([formulaParser errorRange]), [formulaString substringFromIndex:[formulaParser errorRange].location], errorString);

    [formulaParser release];
}

- (double)evaluate:(MMFRuleSymbols *)ruleSymbols tempos:(double *)tempos postures:(NSArray *)postures andCacheWith:(int)newCacheTag;
{
    if (newCacheTag != cacheTag) {
        cacheTag = newCacheTag;
        cacheValue = [formula evaluate:ruleSymbols postures:postures tempos:tempos];
    }

    return cacheValue;
}

- (double)evaluate:(MMFRuleSymbols *)ruleSymbols postures:(NSArray *)postures andCacheWith:(int)newCacheTag;
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

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: name: %@, comment: %@, formula: %@, cacheTag: %d, cacheValue: %g",
                     NSStringFromClass([self class]), self, name, comment, formula, cacheTag, cacheValue];
}

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
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

- (void)loadFromXMLElement:(NSXMLElement *)element context:(id)context;
{
    NSArray *comments;
    unsigned int count, index;

    [self setName:[[element attributeForName:@"name"] stringValue]];

    [self setModel:context]; // Need to make sure this is set before we set the formula string.
    [self setFormulaString:[[element attributeForName:@"formula"] stringValue]];

    comments = [element elementsForName:@"comment"];
    count = [comments count];
    for (index = 0; index < count; index++) {
        NSXMLElement *commentElement;

        commentElement = [comments objectAtIndex:index];
        [self setComment:[commentElement stringValue]];
    }
}

@end

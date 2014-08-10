//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMEquation.h"

#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "GSXMLFunctions.h"
#import "MMFormulaNode.h"
#import "MMFormulaParser.h"
#import "MModel.h"
#import "MMGroup.h"

@implementation MMEquation
{
    MMFormulaNode *_formula;

    NSUInteger _cacheTag;
    double _cacheValue;
}

- (id)init;
{
    if ((self = [super init])) {
        _formula = nil;

        _cacheTag = 0;
        _cacheValue = 0.0;
    }

    return self;
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p> name: %@, comment: %@, formula: %@, cacheTag: %lu, cacheValue: %g",
            NSStringFromClass([self class]), self, self.name, self.comment, _formula, _cacheTag, _cacheValue];
}

#pragma mark -

- (void)setFormulaString:(NSString *)formulaString;
{
    MMFormulaParser *formulaParser = [[MMFormulaParser alloc] initWithModel:[self model]];

    MMFormulaNode *result = [formulaParser parseString:formulaString];
    [self setFormula:result];

    NSString *errorString = [formulaParser errorMessage];
    if ([errorString length] > 0)
        NSLog(@"Warning: (%@) error parsing formula: '%@', at %@:'%@', error string: %@", self.name, formulaString, NSStringFromRange([formulaParser errorRange]), [formulaString substringFromIndex:[formulaParser errorRange].location], errorString);
}

- (double)evaluateWithPhonesInArray:(NSArray *)phones ruleSymbols:(MMFRuleSymbols *)ruleSymbols andCacheWithTag:(NSUInteger)newCacheTag;
{
    if (newCacheTag != _cacheTag) {
        _cacheTag = newCacheTag;
        _cacheValue = [_formula evaluateWithPhonesInArray:phones ruleSymbols:ruleSymbols];
    }

    return _cacheValue;
}

- (double)cacheValue;
{
    return _cacheValue;
}

- (NSString *)equationPath;
{
    return [NSString stringWithFormat:@"%@:%@", [[self group] name], self.name];
}

- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<equation name=\"%@\"", GSXMLAttributeString(self.name, NO)];
    if (_formula != nil)
        [resultString appendFormat:@" formula=\"%@\"", GSXMLAttributeString([_formula expressionString], NO)];

    if (self.comment == nil) {
        [resultString appendString:@"/>\n"];
    } else {
        [resultString appendString:@">\n"];

        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<comment>%@</comment>\n", GSXMLCharacterData(self.comment)];

        [resultString indentToLevel:level];
        [resultString appendFormat:@"</equation>\n"];
    }
}

@end

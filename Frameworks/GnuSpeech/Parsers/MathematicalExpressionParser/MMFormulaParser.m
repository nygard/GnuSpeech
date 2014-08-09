//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright (c) 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMFormulaParser.h"

#import "NSScanner-Extensions.h"
#import "MMFormulaExpression.h"
#import "MMFormulaTerminal.h"
#import "MMSymbol.h"
#import "MModel.h"

enum {
    MMFormulaParserToken_Add              = 0,
    MMFormulaParserToken_Subtract         = 1,
    MMFormulaParserToken_Multiply         = 2,
    MMFormulaParserToken_Divide           = 3,
    MMFormulaParserToken_LeftParenthesis  = 4,
    MMFormulaParserToken_RightParenthesis = 5,
    MMFormulaParserToken_Symbol           = 6,
    MMFormulaParserToken_Constant         = 7,
    MMFormulaParserToken_End              = 8,
    MMFormulaParserToken_Error            = -1,
};
typedef NSInteger MMBooleanParserToken;

@interface MMFormulaParser ()

@property (assign) NSUInteger lookahead;

- (MMBooleanParserToken)scanNextToken;
- (BOOL)scanNumber;

- (void)match:(MMBooleanParserToken)token;
- (MMFormulaNode *)parseExpression;
- (MMFormulaNode *)parseTerm;
- (MMFormulaNode *)parseFactor;

- (MMFormulaTerminal *)parseNumber;
- (MMFormulaNode *)parseSymbol;
@end

#pragma mark -

@implementation MMFormulaParser
{
    MModel *m_model;
    
    NSUInteger m_lookahead;
}

+ (MMFormulaNode *)parsedExpressionFromString:(NSString *)string model:(MModel *)model;
{
    MMFormulaParser *parser = [[MMFormulaParser alloc] initWithModel:model];
    MMFormulaNode *result = [parser parseString:string];

    return result;
}

+ (NSString *)nameForToken:(NSUInteger)token;
{
    switch (token) {
        case MMFormulaParserToken_Add:              return @"'+'";
        case MMFormulaParserToken_Subtract:         return @"'-'";
        case MMFormulaParserToken_Multiply:         return @"'*'";
        case MMFormulaParserToken_Divide:           return @"'/'";
        case MMFormulaParserToken_LeftParenthesis:  return @"'('";
        case MMFormulaParserToken_RightParenthesis: return @"')'";
        case MMFormulaParserToken_Symbol:           return @"<symbol>";
        case MMFormulaParserToken_Constant:         return @"<constant>";
        case MMFormulaParserToken_End:              return @"<eof>";
    }
    
    return [NSString stringWithFormat:@"<unknown token %lu>", token];
}

- (id)initWithModel:(MModel *)model;
{
    if ((self = [super init])) {
        m_model = model;
    }

    return self;
}

#pragma mark -

@synthesize model = m_model;
@synthesize lookahead = m_lookahead;

- (MMBooleanParserToken)scanNextToken;
{
    [self.scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:NULL];
    self.startOfTokenLocation = [self.scanner scanLocation];

    // TODO (2004-03-03): It used to end on a newline as well...
    if ([self.scanner isAtEnd])
        return MMFormulaParserToken_End;

    if ([self.scanner scanString:@"(" intoString:NULL]) {
        [self setSymbolString:@"("];
        return MMFormulaParserToken_LeftParenthesis;
    }

    if ([self.scanner scanString:@")" intoString:NULL]) {
        [self setSymbolString:@")"];
        return MMFormulaParserToken_RightParenthesis;
    }

    if ([self.scanner scanString:@"+" intoString:NULL]) {
        [self setSymbolString:@"+"];
        return MMFormulaParserToken_Add;
    }

    if ([self.scanner scanString:@"-" intoString:NULL]) {
        [self setSymbolString:@"-"];
        return MMFormulaParserToken_Subtract;
    }

    if ([self.scanner scanString:@"*" intoString:NULL]) {
        [self setSymbolString:@"*"];
        return MMFormulaParserToken_Multiply;
    }

    if ([self.scanner scanString:@"/" intoString:NULL]) {
        [self setSymbolString:@"/"];
        return MMFormulaParserToken_Divide;
    }

    if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[self.scanner peekChar]]) {
        if ([self scanNumber])
            return MMFormulaParserToken_Constant;

        return MMFormulaParserToken_Error;
    }

    NSString *str;
    if ([self.scanner scanIdentifierIntoString:&str]) {
        [self setSymbolString:str];
        return MMFormulaParserToken_Symbol;
    }

    return MMFormulaParserToken_Error;
}

- (BOOL)scanNumber;
{
    NSString *firstPart, *secondPart;

    if ([self.scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&firstPart] == YES) {
        if ([self.scanner scanString:@"." intoString:NULL]) {
            if ([self.scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&secondPart] == YES) {
                [self setSymbolString:[NSString stringWithFormat:@"%@.%@", firstPart, secondPart]];
                return YES;
            }
        }

        [self setSymbolString:firstPart];
        return YES;
    }

    return NO;
}

- (void)match:(MMBooleanParserToken)token;
{
    if (self.lookahead != token) {
        [self appendErrorFormat:@"Expected token %@, got %@", [[self class] nameForToken:token], [[self class] nameForToken:self.lookahead]];
        [NSException raise:GSParserSyntaxErrorException format:@"Expected token %@, got %@", [[self class] nameForToken:token], [[self class] nameForToken:self.lookahead]];
    }

    self.lookahead = [self scanNextToken];
}

- (MMFormulaNode *)parseExpression;
{
    MMFormulaNode *result = [self parseTerm];

    while (1) {
        if (self.lookahead == MMFormulaParserToken_Add) {
            [self match:MMFormulaParserToken_Add];
            MMFormulaNode *right = [self parseTerm];

            MMFormulaExpression *expr = [[MMFormulaExpression alloc] init];
            [expr setOperation:MMFormulaOperation_Add];
            [expr setOperandOne:result];
            [expr setOperandTwo:right];
            result = expr;
        } else if (self.lookahead == MMFormulaParserToken_Subtract) {
            [self match:MMFormulaParserToken_Subtract];
            MMFormulaNode *right = [self parseTerm];

            MMFormulaExpression *expr = [[MMFormulaExpression alloc] init];
            [expr setOperation:MMFormulaOperation_Subtract]; // TODO (2012-04-20): This isn't right.  Use operation, not token
            [expr setOperandOne:result];
            [expr setOperandTwo:right];
            result = expr;
        } else
            break;
    }

    return result;
}

- (MMFormulaNode *)parseTerm;
{
    MMFormulaNode *result = [self parseFactor];

    while (1) {
        if (self.lookahead == MMFormulaParserToken_Multiply) {
            [self match:MMFormulaParserToken_Multiply];
            MMFormulaNode *right = [self parseFactor];

            MMFormulaExpression *expr = [[MMFormulaExpression alloc] init];
            [expr setOperation:MMFormulaOperation_Multiply];
            [expr setOperandOne:result];
            [expr setOperandTwo:right];
            result = expr;
        } else if (self.lookahead == MMFormulaParserToken_Divide) {
            [self match:MMFormulaParserToken_Divide];
            MMFormulaNode *right = [self parseFactor];

            MMFormulaExpression *expr = [[MMFormulaExpression alloc] init];
            [expr setOperation:MMFormulaOperation_Divide];
            [expr setOperandOne:result];
            [expr setOperandTwo:right];
            result = expr;
        } else
            break;
    }

    return result;
}

- (MMFormulaNode *)parseFactor;
{
    MMFormulaNode *result = nil;

    if (self.lookahead == MMFormulaParserToken_LeftParenthesis) {
        [self match:MMFormulaParserToken_LeftParenthesis];
        result = [self parseExpression];
        [self match:MMFormulaParserToken_RightParenthesis];
    } else if (self.lookahead == MMFormulaParserToken_Symbol) {
        result = [self parseSymbol];
    } else /*if (lookahead == MMFormulaParserToken_Constant)*/ {
        result = [self parseNumber];
    }

    return result;
}

- (MMFormulaTerminal *)parseNumber;
{
    MMFormulaTerminal *result = nil;

    // TODO (2004-05-17): Handle unary +, - here.  Hmm, maybe in parseFactor instead, so it can do -(1), or -ident
    if (self.lookahead == MMFormulaParserToken_Add) {
        [self match:MMFormulaParserToken_Add];
        result = [self parseNumber];
    } else if (self.lookahead == MMFormulaParserToken_Subtract) {
        [self match:MMFormulaParserToken_Subtract];
        result = [self parseNumber];
        [result setValue:-[result value]];
    } else {
        if (self.lookahead == MMFormulaParserToken_Constant) {
            result = [[MMFormulaTerminal alloc] init];
            [result setValue:[self.symbolString doubleValue]];
        }
        [self match:MMFormulaParserToken_Constant];
    }

    return result;
}

- (MMFormulaNode *)parseSymbol;
{
    MMFormulaTerminal *result = nil;

    if (self.lookahead == MMFormulaParserToken_Symbol) {
        result = [[MMFormulaTerminal alloc] init];

        if ([self.symbolString isEqualToString:@"rd"])            { [result setWhichPhone:MMPhoneIndex_RuleDuration];
        } else if ([self.symbolString isEqualToString:@"beat"])   { [result setWhichPhone:MMPhoneIndex_Beat];
        } else if ([self.symbolString isEqualToString:@"mark1"])  { [result setWhichPhone:MMPhoneIndex_Mark1];
        } else if ([self.symbolString isEqualToString:@"mark2"])  { [result setWhichPhone:MMPhoneIndex_Mark2];
        } else if ([self.symbolString isEqualToString:@"mark3"])  { [result setWhichPhone:MMPhoneIndex_Mark3];
        } else if ([self.symbolString isEqualToString:@"tempo1"]) { [result setWhichPhone:MMPhoneIndex_Tempo0];
        } else if ([self.symbolString isEqualToString:@"tempo2"]) { [result setWhichPhone:MMPhoneIndex_Tempo1];
        } else if ([self.symbolString isEqualToString:@"tempo3"]) { [result setWhichPhone:MMPhoneIndex_Tempo2];
        } else if ([self.symbolString isEqualToString:@"tempo4"]) { [result setWhichPhone:MMPhoneIndex_Tempo3];
        } else {
            NSInteger whichPhone = [self.symbolString characterAtIndex:[self.symbolString length] - 1] - '1';
            if ( (whichPhone < 0) || (whichPhone > 3)) {
                [self appendErrorFormat:@"Error, incorrect phone index %d", whichPhone];
                [NSException raise:GSParserSyntaxErrorException format:@"incorrect phone index %lu", whichPhone];
                return nil;
            }

            NSString *baseSymbolName = [self.symbolString substringToIndex:[self.symbolString length] - 1];

            MMSymbol *symbol = [self.model symbolWithName:baseSymbolName];
            if (symbol) {
                [result setSymbol:symbol];
                [result setWhichPhone:whichPhone];
            } else {
                [self appendErrorFormat:@"Unknown symbol %@.", self.symbolString];
                [NSException raise:GSParserSyntaxErrorException format:@"Unknown symbol %@.", self.symbolString];
                return nil;
            }
        }
    }

    [self match:MMFormulaParserToken_Symbol];

    return result;
}

- (id)beginParseString;
{
    self.lookahead = [self scanNextToken];

    id result = (self.lookahead == MMFormulaParserToken_End) ? nil : [self parseExpression];
    [self match:MMFormulaParserToken_End];

    return result;
}

@end

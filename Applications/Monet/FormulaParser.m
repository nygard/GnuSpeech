#import "FormulaParser.h"

#import <Foundation/Foundation.h>
#import "NSScanner-Extensions.h"
#import "FormulaSymbols.h"
#import "MMFormulaExpression.h"
#import "MMFormulaTerminal.h"
#import "MMSymbol.h"
#import "SymbolList.h"

//static int operatorPrec[8] = {1, 1, 2, 2, 3, 0, 4, 4};

@implementation FormulaParser

+ (MMFormulaNode *)parsedExpressionFromString:(NSString *)aString symbolList:(SymbolList *)aSymbolList;
{
    FormulaParser *parser;
    MMFormulaNode *result;

    parser = [[FormulaParser alloc] init];
    [parser setSymbolList:aSymbolList];

    result = [parser parseString:aString];

    [parser release];

    return result;
}

- (void)dealloc;
{
    [symbolList release];

    [super dealloc];
}

- (SymbolList *)symbolList;
{
    return symbolList;
}

- (void)setSymbolList:(SymbolList *)newSymbolList;
{
    if (newSymbolList == symbolList)
        return;

    [symbolList release];
    symbolList = [newSymbolList retain];
}

- (int)nextToken;
{
    NSString *str;

    [scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:NULL];
    startOfTokenLocation = [scanner scanLocation];

    // TODO (2004-03-03): It used to end on a newline as well...
    if ([scanner isAtEnd])
        return TK_F_END;

    if ([scanner scanString:@"(" intoString:NULL] == YES) {
        [self setSymbolString:@"("];
        return TK_F_LPAREN;
    }

    if ([scanner scanString:@")" intoString:NULL] == YES) {
        [self setSymbolString:@")"];
        return TK_F_RPAREN;
    }

    if ([scanner scanString:@"+" intoString:NULL] == YES) {
        [self setSymbolString:@"+"];
        return TK_F_ADD;
    }

    if ([scanner scanString:@"-" intoString:NULL] == YES) {
        [self setSymbolString:@"-"];
        return TK_F_SUB;
    }

    if ([scanner scanString:@"*" intoString:NULL] == YES) {
        [self setSymbolString:@"*"];
        return TK_F_MULT;
    }

    if ([scanner scanString:@"/" intoString:NULL] == YES) {
        [self setSymbolString:@"/"];
        return TK_F_DIV;
    }

    if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[scanner peekChar]]) {
        if ([self scanNumber])
            return TK_F_CONST;

        return TK_F_ERROR;
    }

    if ([scanner scanIdentifierIntoString:&str] == YES) {
        [self setSymbolString:str];
        return TK_F_SYMBOL;
    }

    return TK_F_ERROR;
}

- (BOOL)scanNumber;
{
    NSString *firstPart, *secondPart;

    if ([scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&firstPart] == YES) {
        if ([scanner scanString:@"." intoString:NULL] == YES) {
            if ([scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&secondPart] == YES) {
                [self setSymbolString:[NSString stringWithFormat:@"%@.%@", firstPart, secondPart]];
                return YES;
            }
        }

        [self setSymbolString:firstPart];
        return YES;
    }

    return NO;
}

- (void)match:(int)token;
{
    if (lookahead != token) {
        [self appendErrorFormat:@"Expected token %d, got %d", token, lookahead];
        [NSException raise:GSParserSyntaxErrorException format:@"Expected token %d, got %d", token, lookahead];
    }

    lookahead = [self nextToken];
}

- (MMFormulaNode *)parseExpression;
{
    MMFormulaNode *result, *right;
    MMFormulaExpression *expr;

    result = [self parseTerm];

    while (1) {
        if (lookahead == TK_F_ADD) {
            [self match:TK_F_ADD];
            right = [self parseTerm];

            expr = [[[MMFormulaExpression alloc] init] autorelease];
            [expr setOperation:TK_F_ADD];
            //[expr setPrecedence:1];
            [expr setOperandOne:result];
            [expr setOperandTwo:right];
            result = expr;
        } else if (lookahead == TK_F_SUB) {
            [self match:TK_F_SUB];
            right = [self parseTerm];

            expr = [[[MMFormulaExpression alloc] init] autorelease];
            [expr setOperation:TK_F_SUB];
            //[expr setPrecedence:1];
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
    MMFormulaNode *result, *right;
    MMFormulaExpression *expr;

    result = [self parseFactor];

    while (1) {
        if (lookahead == TK_F_MULT) {
            [self match:TK_F_MULT];
            right = [self parseFactor];

            expr = [[[MMFormulaExpression alloc] init] autorelease];
            [expr setOperation:TK_F_MULT];
            //[expr setPrecedence:2];
            [expr setOperandOne:result];
            [expr setOperandTwo:right];
            result = expr;
        } else if (lookahead == TK_F_DIV) {
            [self match:TK_F_DIV];
            right = [self parseFactor];

            expr = [[[MMFormulaExpression alloc] init] autorelease];
            [expr setOperation:TK_F_DIV];
            //[expr setPrecedence:2];
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

    if (lookahead == TK_F_LPAREN) {
        [self match:TK_F_LPAREN];
        result = [self parseExpression];
        [self match:TK_F_RPAREN];
    } else if (lookahead == TK_F_SYMBOL) {
        result = [self parseSymbol];
    } else /*if (lookahead == TK_F_CONST)*/ {
        result = [self parseNumber];
    }

    return result;
}

- (MMFormulaTerminal *)parseNumber;
{
    MMFormulaTerminal *result = nil;

    // TODO (2004-05-17): Handle unary +, - here.  Hmm, maybe in parseFactor instead, so it can do -(1), or -ident
    if (lookahead == TK_F_ADD) {
        [self match:TK_F_ADD];
        result = [self parseNumber];
    } else if (lookahead == TK_F_SUB) {
        [self match:TK_F_SUB];
        result = [self parseNumber];
        [result setValue:-[result value]];
    } else {
        if (lookahead == TK_F_CONST) {
            result = [[[MMFormulaTerminal alloc] init] autorelease];
            [result setValue:[symbolString doubleValue]];
        }
        [self match:TK_F_CONST];
    }

    return result;
}

- (MMFormulaNode *)parseSymbol;
{
    MMFormulaTerminal *result = nil;

    if (lookahead == TK_F_SYMBOL) {
        result = [[[MMFormulaTerminal alloc] init] autorelease];

        if ([symbolString isEqualToString:@"rd"]) {
            [result setWhichPhone:RULEDURATION];
        } else if ([symbolString isEqualToString:@"beat"]) {
            [result setWhichPhone:BEAT];
        } else if ([symbolString isEqualToString:@"mark1"]) {
            [result setWhichPhone:MARK1];
        } else if ([symbolString isEqualToString:@"mark2"]) {
            [result setWhichPhone:MARK2];
        } else if ([symbolString isEqualToString:@"mark3"]) {
            [result setWhichPhone:MARK3];
        } else if ([symbolString isEqualToString:@"tempo1"]) {
            [result setWhichPhone:TEMPO0];
        } else if ([symbolString isEqualToString:@"tempo2"]) {
            [result setWhichPhone:TEMPO1];
        } else if ([symbolString isEqualToString:@"tempo3"]) {
            [result setWhichPhone:TEMPO2];
        } else if ([symbolString isEqualToString:@"tempo4"]) {
            [result setWhichPhone:TEMPO3];
        } else {
            int whichPhone;
            NSString *baseSymbolName;
            MMSymbol *aSymbol;

            whichPhone = [symbolString characterAtIndex:[symbolString length] - 1] - '1';
            //NSLog(@"Phone = %d", whichPhone);
            if ( (whichPhone < 0) || (whichPhone > 3)) {
                [self appendErrorFormat:@"Error, incorrect phone index %d", whichPhone];
                [NSException raise:GSParserSyntaxErrorException format:@"incorrect phone index %d", whichPhone];
                return nil;
            }

            baseSymbolName = [symbolString substringToIndex:[symbolString length] - 1];

            aSymbol = [symbolList findSymbol:baseSymbolName];
            if (aSymbol) {
                [result setSymbol:aSymbol];
                [result setWhichPhone:whichPhone];
            } else {
                [self appendErrorFormat:@"Unknown symbol %@.", symbolString];
                [NSException raise:GSParserSyntaxErrorException format:@"Unknown symbol %@.", symbolString];
                //NSLog(@"\t Error, Undefined Symbol %@", tempSymbolString);
                return nil;
            }
        }
    }

    [self match:TK_F_SYMBOL];

    return result;
}

- (id)beginParseString;
{
    id result;

    lookahead = [self nextToken];

    result = [self parseExpression];
    [self match:TK_F_END];

    return result;
}

@end

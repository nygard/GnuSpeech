#import "FormulaParser.h"

#import <Foundation/Foundation.h>
#import "NSScanner-Extensions.h"
#import "FormulaExpression.h"
#import "FormulaSymbols.h"
#import "FormulaTerminal.h"
#import "MMSymbol.h"
#import "SymbolList.h"

//static int operatorPrec[8] = {1, 1, 2, 2, 3, 0, 4, 4};

@implementation FormulaParser

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

- (id)beginParseString;
{
    // FormulaTerminal,
    id tempExpression = nil;

    switch ([self nextToken]) {
      case TK_F_SUB:
          NSLog(@"Sub");
          break;

      case TK_F_ADD:
          [self appendErrorFormat:@"Unary + is the instrument of satan"];
          return nil;

      case TK_F_MULT:
          [self appendErrorFormat:@"Unexpected * operator."];
          return nil;

      case TK_F_DIV:
          [self appendErrorFormat:@"Unexpected / operator."];
          return nil;

      case TK_F_LPAREN:
          tempExpression = [self leftParen];
          break;

      case TK_F_RPAREN:
          [self appendErrorFormat:@"Unexpected ')'."];
          return nil;

      case TK_F_SYMBOL:
          tempExpression = [self parseSymbol];
          if (tempExpression == nil)
              return nil;
          break;

      case TK_F_CONST:
          tempExpression = [[[FormulaTerminal alloc] init] autorelease];
          [tempExpression setValue:[symbolString doubleValue]];
          break;

      case TK_F_ERROR:
      case TK_F_END:
          [self appendErrorFormat:@"Unexpected End."];
          return nil;

    }

    tempExpression = [self continueParse:tempExpression];

    return tempExpression;
}

- (id)continueParse:currentExpression;
{
    int token;

    while ( (token = [self nextToken]) != TK_F_END) {
        switch (token) {
          default:
          case TK_F_END:
              [self appendErrorFormat:@"Unexpected End."];
              return nil;

          case TK_F_ADD:
              currentExpression = [self addOperation:currentExpression];
              break;

          case TK_F_SUB:
              currentExpression = [self subOperation:currentExpression];
              break;

          case TK_F_MULT:
              currentExpression = [self multOperation:currentExpression];
              break;

          case TK_F_DIV:
              currentExpression = [self divOperation:currentExpression];
              break;

          case TK_F_LPAREN:
              [self appendErrorFormat:@"Unexpected '('."];
              return nil;

          case TK_F_RPAREN:
              [self appendErrorFormat:@"Unexpected ')'."];
              return nil;

          case TK_F_SYMBOL:
              [self appendErrorFormat:@"Unexpected symbol %@.", symbolString];
              return nil;

          case TK_F_CONST:
              [self appendErrorFormat:@"Unexpected symbol %@.", symbolString];
              return nil;
        }
    }

    return currentExpression;
}

- (id)parseSymbol;
{
    FormulaTerminal *aTerminal = nil;

    NSLog(@"Symbol = |%@|", symbolString);

    aTerminal = [[[FormulaTerminal alloc] init] autorelease];

    if ([symbolString isEqualToString:@"rd"]) {
        [aTerminal setWhichPhone:RULEDURATION];
    } else if ([symbolString isEqualToString:@"beat"]) {
        [aTerminal setWhichPhone:BEAT];
    } else if ([symbolString isEqualToString:@"mark1"]) {
        [aTerminal setWhichPhone:MARK1];
    } else if ([symbolString isEqualToString:@"mark2"]) {
        [aTerminal setWhichPhone:MARK2];
    } else if ([symbolString isEqualToString:@"mark3"]) {
        [aTerminal setWhichPhone:MARK3];
    } else if ([symbolString isEqualToString:@"tempo1"]) {
        [aTerminal setWhichPhone:TEMPO0];
    } else if ([symbolString isEqualToString:@"tempo2"]) {
        [aTerminal setWhichPhone:TEMPO1];
    } else if ([symbolString isEqualToString:@"tempo3"]) {
        [aTerminal setWhichPhone:TEMPO2];
    } else if ([symbolString isEqualToString:@"tempo4"]) {
        [aTerminal setWhichPhone:TEMPO3];
    } else {
        int whichPhone;
        NSString *baseSymbolName;
        MMSymbol *aSymbol;

        whichPhone = [symbolString characterAtIndex:[symbolString length] - 1] - '1';
        NSLog(@"Phone = %d", whichPhone);
        if ( (whichPhone < 0) || (whichPhone > 3)) {
            [self appendErrorFormat:@"Error, incorrect phone index %d", whichPhone];
            return nil;
        }

        baseSymbolName = [symbolString substringToIndex:[symbolString length] - 1];

        aSymbol = [symbolList findSymbol:baseSymbolName];
        if (aSymbol) {
            [aTerminal setSymbol:aSymbol];
            [aTerminal setWhichPhone:whichPhone];
        } else {
            [self appendErrorFormat:@"Unknown symbol %@.", symbolString];
            //NSLog(@"\t Error, Undefined Symbol %@", tempSymbolString);
            return nil;
        }
    }

    return aTerminal;
}

- (id)addOperation:operand;
{
    id expression1 = nil, expression2 = nil, returnExp = nil;
    FormulaTerminal *aTerminal;

    //NSLog(@"ADD");

    expression1 = [[[FormulaExpression alloc] init] autorelease];
    [expression1 setPrecedence:1];
    [expression1 setOperation:TK_F_ADD];

    if ([operand precedence] >= 1) {
        /* Current Sub Expression has higher precedence */
        [expression1 setOperandOne:operand];
        returnExp = expression1;
    } else {
        /* Currend Sub Expression has lower Precedence.  Restructure Tree */
        expression2 = [operand operandTwo];
        [expression1 setOperandOne:expression2];
        [operand setOperandTwo:expression1];
        returnExp = operand;
    }

    switch ([self nextToken]) {
      case TK_F_END:
          [self appendErrorFormat:@"Error, unexpected END at index %d", [scanner scanLocation]];
          return nil;

      case TK_F_ADD:
      case TK_F_SUB:
      case TK_F_MULT:
      case TK_F_DIV:
          [self appendErrorFormat:@"Error, unexpected %@ operation at index %d", symbolString, [scanner scanLocation]];
          return nil;

      case TK_F_RPAREN:
          [self appendErrorFormat:@"Error, unexpected ')' at index %d", [scanner scanLocation]];
          return nil;

      case TK_F_LPAREN:
          [expression1 setOperandTwo:[self leftParen]];
          break;

      case TK_F_SYMBOL:
          aTerminal = [self parseSymbol];
          if (aTerminal == nil)
              return nil;
          [expression1 setOperandTwo:aTerminal];
          break;

      case TK_F_CONST:
          aTerminal = [[FormulaTerminal alloc] init];
          [aTerminal setValue:[symbolString doubleValue]];
          [expression1 setOperandTwo:aTerminal];
          [aTerminal release];
          break;
    }

    return returnExp;
}

- (id)subOperation:operand;
{
    id expression1 = nil, expression2 = nil, returnExp = nil;
    FormulaTerminal *aTerminal;

    //NSLog(@"SUB");

    expression1 = [[[FormulaExpression alloc] init] autorelease];;
    [expression1 setPrecedence:1];
    [expression1 setOperation:TK_F_SUB];

    if ([operand precedence] >= 1) {
        /* Current Sub Expression has higher precedence */
        [expression1 setOperandOne:operand];
        returnExp = expression1;
    } else {
        /* Currend Sub Expression has lower Precedence.  Restructure Tree */
        expression2 = [operand operandTwo];
        [expression1 setOperandOne:expression2];
        [operand setOperandTwo:expression1];
        returnExp = operand;
    }

    switch ([self nextToken]) {
      case TK_F_END:
          [self appendErrorFormat:@"Error, unexpected END at index %d", [scanner scanLocation]];
          return nil;

      case TK_F_ADD:
      case TK_F_SUB:
      case TK_F_MULT:
      case TK_F_DIV:
          [self appendErrorFormat:@"Error, unexpected %@ operation at index %d", symbolString, [scanner scanLocation]];
          return nil;

      case TK_F_RPAREN:
          [self appendErrorFormat:@"Error, unexpected ')' at index %d", [scanner scanLocation]];
          return nil;

      case TK_F_LPAREN:
          [expression1 setOperandTwo:[self leftParen]];
          break;

      case TK_F_SYMBOL:
          aTerminal = [self parseSymbol];
          if (aTerminal == nil)
              return nil;
          [expression1 setOperandTwo:aTerminal];
          break;

      case TK_F_CONST:
          aTerminal = [[FormulaTerminal alloc] init];
          [aTerminal setValue:[symbolString doubleValue]];
          [expression1 setOperandTwo:aTerminal];
          [aTerminal release];
          break;
    }

    return returnExp;
}

- (id)multOperation:operand;
{
    id expression1 = nil, expression2 = nil, returnExp = nil;
    FormulaTerminal *aTerminal;

    //NSLog(@"MULT");

    expression1 = [[[FormulaExpression alloc] init] autorelease];
    [expression1 setPrecedence:2];
    [expression1 setOperation:TK_F_MULT];

    if ([operand precedence] >= 2) {
        /* Current Sub Expression has higher precedence */
        [expression1 setOperandOne:operand];
        returnExp = expression1;
    } else {
        /* Currend Sub Expression has lower Precedence.  Restructure Tree */
        expression2 = [operand operandTwo];
        [expression1 setOperandOne:expression2];
        [operand setOperandTwo:expression1];
        returnExp = operand;
    }

    switch ([self nextToken]) {
      case TK_F_END:
          [self appendErrorFormat:@"Error, unexpected END at index %d", [scanner scanLocation]];
          return nil;

      case TK_F_ADD:
      case TK_F_SUB:
      case TK_F_MULT:
      case TK_F_DIV:
          [self appendErrorFormat:@"Error, unexpected %@ operation at index %d", symbolString, [scanner scanLocation]];
          return nil;

      case TK_F_RPAREN:
          [self appendErrorFormat:@"Error, unexpected ')' at index %d", [scanner scanLocation]];
          return nil;

      case TK_F_LPAREN:
          [expression1 setOperandTwo:[self leftParen]];
          break;

      case TK_F_SYMBOL:
          aTerminal = [self parseSymbol];
          if (aTerminal == nil)
              return nil;
          [expression1 setOperandTwo:aTerminal];
          break;

      case TK_F_CONST:
          aTerminal = [[FormulaTerminal alloc] init];
          [aTerminal setValue:[symbolString doubleValue]];
          [expression1 setOperandTwo:aTerminal];
          [aTerminal release];
          break;
    }

    return returnExp;
}

- (id)divOperation:operand;
{
    id expression1 = nil, expression2 = nil, returnExp = nil;
    FormulaTerminal *aTerminal;

    //NSLog(@"DIV");

    expression1 = [[[FormulaExpression alloc] init] autorelease];
    [expression1 setPrecedence:2];
    [expression1 setOperation:TK_F_DIV];

    if ([operand precedence] >= 2) {
        /* Current Sub Expression has higher precedence */
        [expression1 setOperandOne:operand];
        returnExp = expression1;
    } else {
        /* Currend Sub Expression has lower Precedence.  Restructure Tree */
        expression2 = [operand operandTwo];
        [expression1 setOperandOne:expression2];
        [operand setOperandTwo:expression1];
        returnExp = operand;
    }

    switch ([self nextToken]) {
      case TK_F_END:
          [self appendErrorFormat:@"Error, unexpected END at index %d", [scanner scanLocation]];
          return nil;

      case TK_F_ADD:
      case TK_F_SUB:
      case TK_F_MULT:
      case TK_F_DIV:
          [self appendErrorFormat:@"Error, unexpected %@ operation at index %d", symbolString, [scanner scanLocation]];
          return nil;

      case TK_F_RPAREN:
          [self appendErrorFormat:@"Error, unexpected ')' at index %d", [scanner scanLocation]];
          return nil;

      case TK_F_LPAREN:
          [self leftParen];
          [expression1 setOperandTwo:[self leftParen]];
          break;

      case TK_F_SYMBOL:
          aTerminal = [self parseSymbol];
          if (aTerminal == nil)
              return nil;
          [expression1 setOperandTwo:aTerminal];
          break;

      case TK_F_CONST:
          aTerminal = [[FormulaTerminal alloc] init];
          [aTerminal setValue:[symbolString doubleValue]];
          [expression1 setOperandTwo:aTerminal];
          [aTerminal release];
          break;
    }

    return returnExp;
}

- (id)leftParen;
{
    id expression1 = nil;
    FormulaTerminal *aTerminal, *tempTerm;
    int token;

    switch ([self nextToken]) {
      case TK_F_END:
          [self appendErrorFormat:@"Error, unexpected end at index %d", [scanner scanLocation]];
          return nil;

      case TK_F_RPAREN:
          return expression1;

      case TK_F_LPAREN:
          expression1 = [self leftParen];
          break;

      case TK_F_ADD:
      case TK_F_SUB:
      case TK_F_MULT:
      case TK_F_DIV:
          [self appendErrorFormat:@"Error, unexpected %@ operation at index %d", symbolString, [scanner scanLocation]];
          break;

      case TK_F_SYMBOL:
          tempTerm = [self parseSymbol];
          if (tempTerm == nil)
              return nil;
          expression1 = tempTerm;
          break;

      case TK_F_CONST:
          expression1 = [[[FormulaTerminal alloc] init] autorelease];
          [expression1 setValue:[symbolString doubleValue]];
          //NSLog(@"%@ = %f", symbolString, [expression1 value]);
          break;
    }

    while ( (token = [self nextToken]) != TK_F_RPAREN) {
        switch (token) {
          case TK_F_END:
              [self appendErrorFormat:@"Error, unexpected end at index %d", [scanner scanLocation]];
              return nil;

          case TK_F_RPAREN:
              return expression1;

          case TK_F_LPAREN:
              [self appendErrorFormat:@"Error, unexpected '(' at index %d", [scanner scanLocation]];
              return nil;

          case TK_F_ADD:
              expression1 = [self addOperation:expression1];
              break;

          case TK_F_SUB:
              expression1 = [self subOperation:expression1];
              break;

          case TK_F_MULT:
              expression1 = [self multOperation:expression1];
              break;

          case TK_F_DIV:
              expression1 = [self divOperation:expression1];
              break;

          case TK_F_SYMBOL:
              aTerminal = [self parseSymbol];
              if (aTerminal == nil)
                  return nil;
              [expression1 setOperandTwo:aTerminal];
              break;

          case TK_F_CONST:
              //NSLog(@"Here!!");
              aTerminal = [[FormulaTerminal alloc] init];
              [aTerminal setValue:[symbolString doubleValue]];
              [expression1 setOperandTwo:aTerminal];
              [aTerminal release];
              break;
        }
    }

    /* Set Paren precedence */
    [expression1 setPrecedence:3];

    return expression1;
}

@end

#import "FormulaParser.h"

#import <Foundation/Foundation.h>
#import "NSScanner-Extensions.h"
#import "FormulaExpression.h"
#import "FormulaSymbols.h"
#import "FormulaTerminal.h"
#import "Symbol.h"
#import "SymbolList.h"

static int operatorPrec[8] = {1, 1, 2, 2, 3, 0, 4, 4};

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

    // TODO (2004-03-03): It used to end on a newline as well...
    if ([scanner isAtEnd])
        return TK_F_END;

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
    id tempExpression = nil;
    FormulaTerminal *tempTerminal;
    int temp;

    temp = [self nextToken];
    switch (temp) {
      case TK_F_SUB:
          //NSLog(@"Sub");
          break;

      case TK_F_ADD:
          [self outputError:@"Unary + is the instrument of satan"];
          return nil;

      case TK_F_MULT:
          [self outputError:@"Unexpected * operator."];
          return nil;

      case TK_F_DIV:
          [self outputError:@"Unexpected / operator."];
          return nil;

      case TK_F_LPAREN:
          tempExpression = [self leftParen];
          break;

      case TK_F_RPAREN:
          [self outputError:@"Unexpected ')'."];
          return nil;

      case TK_F_SYMBOL:
          tempTerminal = [self parseSymbol];
          if (tempTerminal) {
              tempExpression = tempTerminal;
          } else {
              return nil;
          }
          break;

      case TK_F_CONST:
          tempTerminal = [[[FormulaTerminal alloc] init] autorelease];
          [tempTerminal setValue:[symbolString doubleValue]];
          tempExpression = tempTerminal;
          break;

      case TK_F_ERROR:
      case TK_F_END:
          [self outputError:@"Unexpected End."];
          return nil;

    }

    tempExpression = [self continueParse:tempExpression];

    return tempExpression;
}

- (id)continueParse:currentExpression;
{
    int tempToken;

    while ( (tempToken = [self nextToken]) != TK_F_END) {
        switch (tempToken) {
          default:
          case TK_F_END:
              [self outputError:@"Unexpected End."];
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
              [self outputError:@"Unexpected '('."];
              return nil;

          case TK_F_RPAREN:
              [self outputError:@"Unexpected ')'."];
              return nil;

          case TK_F_SYMBOL:
              [self outputError:@"Unexpected symbol %@." with:symbolString];
              return nil;

          case TK_F_CONST:
              [self outputError:@"Unexpected symbol %@." with:symbolString];
              return nil;
        }
    }

    return currentExpression;
}

- (id)parseSymbol;
{
    FormulaTerminal *tempTerminal = nil;
    Symbol *tempSymbol;

    NSLog(@"Symbol = |%@|", symbolString);

    tempTerminal = [[[FormulaTerminal alloc] init] autorelease];

    if ([symbolString isEqualToString:@"rd"]) {
        [tempTerminal setWhichPhone:RULEDURATION];
    } else if ([symbolString isEqualToString:@"beat"]) {
        [tempTerminal setWhichPhone:BEAT];
    } else if ([symbolString isEqualToString:@"mark1"]) {
        [tempTerminal setWhichPhone:MARK1];
    } else if ([symbolString isEqualToString:@"mark2"]) {
        [tempTerminal setWhichPhone:MARK2];
    } else if ([symbolString isEqualToString:@"mark3"]) {
        [tempTerminal setWhichPhone:MARK3];
    } else if ([symbolString isEqualToString:@"tempo1"]) {
        [tempTerminal setWhichPhone:TEMPO0];
    } else if ([symbolString isEqualToString:@"tempo2"]) {
        [tempTerminal setWhichPhone:TEMPO1];
    } else if ([symbolString isEqualToString:@"tempo3"]) {
        [tempTerminal setWhichPhone:TEMPO2];
    } else if ([symbolString isEqualToString:@"tempo4"]) {
        [tempTerminal setWhichPhone:TEMPO3];
    } else {
        int whichPhone;
        NSString *baseSymbolName;

        whichPhone = [symbolString characterAtIndex:[symbolString length] - 1] - '1';
        NSLog(@"Phone = %d", whichPhone);
        if ( (whichPhone < 0) || (whichPhone > 3)) {
            NSLog(@"\tError, incorrect phone index %d", whichPhone);
            return nil;
        }

        baseSymbolName = [symbolString substringToIndex:[symbolString length] - 1];

        tempSymbol = [symbolList findSymbol:baseSymbolName];
        if (tempSymbol) {
            [tempTerminal setSymbol:tempSymbol];
            [tempTerminal setWhichPhone:whichPhone];
        } else {
            [self outputError:@"Unknown symbol %@." with:symbolString];
            //NSLog(@"\t Error, Undefined Symbol %@", tempSymbolString);
            return nil;
        }
    }

    return tempTerminal;
}

- (id)addOperation:operand;
{
    id temp = nil, temp1 = nil, returnExp = nil;
    FormulaTerminal *tempTerminal;

    //NSLog(@"ADD");

    temp = [[FormulaExpression alloc] init];
    [temp setPrecedence:1];
    [temp setOperation:TK_F_ADD];

    if ([operand precedence] >= 1) {
        /* Current Sub Expression has higher precedence */
        [temp setOperandOne:operand];
        returnExp = temp;
    } else {
        /* Currend Sub Expression has lower Precedence.  Restructure Tree */
        temp1 = [operand operandTwo];
        [temp setOperandOne:temp1];
        [operand setOperandTwo:temp];
        returnExp = operand;
    }

    switch ([self nextToken]) {
      case TK_F_END:
          NSLog(@"\tError, unexpected END at index %d", [scanner scanLocation]);
          return nil;

      case TK_F_ADD:
      case TK_F_SUB:
      case TK_F_MULT:
      case TK_F_DIV:
          NSLog(@"\tError, unexpected %@ operation at index %d", symbolString, [scanner scanLocation]);
          return nil;

      case TK_F_RPAREN:
          NSLog(@"\tError, unexpected ')' at index %d", [scanner scanLocation]);
          return nil;

      case TK_F_LPAREN:
          [temp setOperandTwo:[self leftParen]];
          break;

      case TK_F_SYMBOL:
          tempTerminal = [self parseSymbol];
          if (tempTerminal) {
              [temp setOperandTwo:tempTerminal];
          } else {
              return nil;
          }
          break;

      case TK_F_CONST:
          tempTerminal = [[FormulaTerminal alloc] init];
          [tempTerminal setValue:[symbolString doubleValue]];
          [temp setOperandTwo:tempTerminal];
          break;
    }

    return returnExp;
}

- (id)subOperation:operand;
{
    id temp = nil, temp1 = nil, returnExp = nil;
    FormulaTerminal *tempTerminal;

    //NSLog(@"SUB");

    temp = [[FormulaExpression alloc] init];
    [temp setPrecedence:1];
    [temp setOperation:TK_F_SUB];

    if ([operand precedence] >= 1) {
        /* Current Sub Expression has higher precedence */
        [temp setOperandOne:operand];
        returnExp = temp;
    } else {
        /* Currend Sub Expression has lower Precedence.  Restructure Tree */
        temp1 = [operand operandTwo];
        [temp setOperandOne:temp1];
        [operand setOperandTwo:temp];
        returnExp = operand;
    }

    switch ([self nextToken]) {
      case TK_F_END:
          NSLog(@"\tError, unexpected END at index %d", [scanner scanLocation]);
          return nil;

      case TK_F_ADD:
      case TK_F_SUB:
      case TK_F_MULT:
      case TK_F_DIV:
          NSLog(@"\tError, unexpected %@ operation at index %d", symbolString, [scanner scanLocation]);
          return nil;

      case TK_F_RPAREN:
          NSLog(@"\tError, unexpected ')' at index %d", [scanner scanLocation]);
          return nil;

      case TK_F_LPAREN:
          [temp setOperandTwo:[self leftParen]];
          break;

      case TK_F_SYMBOL:
          tempTerminal = [self parseSymbol];
          if (tempTerminal) {
              [temp setOperandTwo:tempTerminal];
          } else {
              return nil;
          }
          break;

      case TK_F_CONST:
          tempTerminal = [[FormulaTerminal alloc] init];
          [tempTerminal setValue:[symbolString doubleValue]];
          [temp setOperandTwo:tempTerminal];
          break;
    }

    return returnExp;
}

- (id)multOperation:operand;
{
    id temp = nil, temp1 = nil, returnExp = nil;
    FormulaTerminal *tempTerminal;

    //NSLog(@"MULT");

    temp = [[FormulaExpression alloc] init];
    [temp setPrecedence:2];
    [temp setOperation:TK_F_MULT];

    if ([operand precedence] >= 2) {
        /* Current Sub Expression has higher precedence */
        [temp setOperandOne:operand];
        returnExp = temp;
    } else {
        /* Currend Sub Expression has lower Precedence.  Restructure Tree */
        temp1 = [operand operandTwo];
        [temp setOperandOne:temp1];
        [operand setOperandTwo:temp];
        returnExp = operand;
    }

    switch ([self nextToken]) {
      case TK_F_END:
          NSLog(@"\tError, unexpected END at index %d", [scanner scanLocation]);
          return nil;

      case TK_F_ADD:
      case TK_F_SUB:
      case TK_F_MULT:
      case TK_F_DIV:
          NSLog(@"\tError, unexpected %@ operation at index %d", symbolString, [scanner scanLocation]);
          return nil;

      case TK_F_RPAREN:
          NSLog(@"\tError, unexpected ')' at index %d", [scanner scanLocation]);
          return nil;

      case TK_F_LPAREN:
          [temp setOperandTwo:[self leftParen]];
          break;

      case TK_F_SYMBOL:
          tempTerminal = [self parseSymbol];
          if (tempTerminal) {
              [temp setOperandTwo:tempTerminal];
          } else {
              return nil;
          }
          break;

      case TK_F_CONST:
          tempTerminal = [[FormulaTerminal alloc] init];
          [tempTerminal setValue:[symbolString doubleValue]];
          [temp setOperandTwo:tempTerminal];
          break;
    }

    return returnExp;
}

- (id)divOperation:operand;
{
    id temp = nil, temp1 = nil, returnExp = nil;
    FormulaTerminal *tempTerminal;

    //NSLog(@"DIV");

    temp = [[FormulaExpression alloc] init];
    [temp setPrecedence:2];
    [temp setOperation:TK_F_DIV];

    if ([operand precedence] >= 2) {
        /* Current Sub Expression has higher precedence */
        [temp setOperandOne:operand];
        returnExp = temp;
    } else {
        /* Currend Sub Expression has lower Precedence.  Restructure Tree */
        temp1 = [operand operandTwo];
        [temp setOperandOne:temp1];
        [operand setOperandTwo:temp];
        returnExp = operand;
    }

    switch ([self nextToken]) {
      case TK_F_END:
          NSLog(@"\tError, unexpected END at index %d", [scanner scanLocation]);
          return nil;

      case TK_F_ADD:
      case TK_F_SUB:
      case TK_F_MULT:
      case TK_F_DIV:
          NSLog(@"\tError, unexpected %@ operation at index %d", symbolString, [scanner scanLocation]);
          return nil;

      case TK_F_RPAREN:
          NSLog(@"\tError, unexpected ')' at index %d", [scanner scanLocation]);
          return nil;

      case TK_F_LPAREN:
          [self leftParen];
          [temp setOperandTwo:[self leftParen]];
          break;

      case TK_F_SYMBOL:
          tempTerminal = [self parseSymbol];
          if (tempTerminal) {
              [temp setOperandTwo:tempTerminal];
          } else {
              return nil;
          }
          break;

      case TK_F_CONST:
          tempTerminal = [[FormulaTerminal alloc] init];
          [tempTerminal setValue:[symbolString doubleValue]];
          [temp setOperandTwo:tempTerminal];
          break;
    }

    return returnExp;
}

- (id)leftParen;
{
    id temp = nil;
    FormulaTerminal *tempTerminal, *tempTerm;
    int tempToken;

    switch ([self nextToken]) {
      case TK_F_END:
          NSLog(@"\tError, unexpected end at index %d", [scanner scanLocation]);
          return nil;

      case TK_F_RPAREN:
          return temp;

      case TK_F_LPAREN:
          temp = [self leftParen];
          break;

      case TK_F_ADD:
      case TK_F_SUB:
      case TK_F_MULT:
      case TK_F_DIV:
          NSLog(@"\tError, unexpected %@ operation at index %d", symbolString, [scanner scanLocation]);
          break;

      case TK_F_SYMBOL:
          tempTerm = [self parseSymbol];
          if (tempTerm) {
              temp = tempTerm;
          } else {
              return nil;
          }
          break;

      case TK_F_CONST:
          temp = [[FormulaTerminal alloc] init];
          [temp setValue:[symbolString doubleValue]];
          //NSLog(@"%@ = %f", symbolString, [temp value]);
          break;
    }

    while ( (tempToken = [self nextToken]) != TK_F_RPAREN) {
        switch (tempToken) {
          case TK_F_END:
              NSLog(@"\tError, unexpected end at index %d", [scanner scanLocation]);
              return nil;

          case TK_F_RPAREN:
              return temp;

          case TK_F_LPAREN:
              NSLog(@"\tError, unexpected '(' at index %d", [scanner scanLocation]);
              return nil;

          case TK_F_ADD:
              temp = [self addOperation:temp];
              break;

          case TK_F_SUB:
              temp = [self subOperation:temp];
              break;

          case TK_F_MULT:
              temp = [self multOperation:temp];
              break;

          case TK_F_DIV:
              temp = [self divOperation:temp];
              break;

          case TK_F_SYMBOL:
              tempTerminal = [self parseSymbol];
              if (tempTerminal) {
                  [temp setOperandTwo:tempTerminal];
              } else {
                  return nil;
              }
              break;

          case TK_F_CONST:
              //NSLog(@"Here!!");
              tempTerminal = [[FormulaTerminal alloc] init];
              [tempTerminal setValue:[symbolString doubleValue]];
              [temp setOperandTwo:tempTerminal];
              break;
        }
    }

    /* Set Paren precedence */
    [temp setPrecedence:3];

    return temp;
}

@end

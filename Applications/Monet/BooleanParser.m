#import "BooleanParser.h"

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "NSScanner-Extensions.h"
#import "BooleanExpression.h"
#import "BooleanSymbols.h"
#import "BooleanTerminal.h"
#import "CategoryNode.h"
#import "CategoryList.h"
#import "Phone.h"
#import "PhoneList.h"

@implementation BooleanParser

- (id)init;
{
    if ([super init] == nil)
        return nil;

    symbolString = nil;
    categoryList = nil;
    phoneList = nil;

    return self;
}

- (void)dealloc;
{
    [symbolString release];
    [categoryList release];
    [phoneList release];

    [super dealloc];
}

- (NSString *)symbolString;
{
    return symbolString;
}

- (void)setSymbolString:(NSString *)newString;
{
    if (newString == symbolString)
        return;

    [symbolString release];
    symbolString = [newString retain];
}

- (CategoryList *)categoryList;
{
    return categoryList;
}

- (void)setCategoryList:(CategoryList *)aList;
{
    if (aList == categoryList)
        return;

    [categoryList release];
    categoryList = [aList retain];
}

- (PhoneList *)phoneList;
{
    return phoneList;
}

- (void)setPhoneList: (PhoneList *)aList;
{
    if (aList == phoneList)
        return;

    [phoneList release];
    phoneList = [aList retain];
}

- (void)setErrorOutput:(NSTextField *)aTextField;
{
    nonretained_errorTextField = aTextField;
}

- (void)outputError:(NSString *)errorText;
{
    [nonretained_errorTextField setStringValue:[NSString stringWithFormat:@"%@\n", errorText]];
}

- (void)outputError:(NSString *)errorText with:(NSString *)symbol;
{
    [nonretained_errorTextField setStringValue:[NSString stringWithFormat:errorText, symbol]];
    // TODO (2004-03-02): Used to append a newline.
}

- (CategoryNode *)categorySymbol:(NSString *)symbol;
{
#ifdef PORTING
    char temp[256], *temp1;
    Phone *tempPhone;
    int dummy;

    bzero(temp, 256);
    if (index(symbol, '*'))
    {
        strcpy(temp, symbol);
        temp1 = index(temp, '*');
        *temp1 = '\000';
    }
    else
        strcpy(temp, symbol);

    tempPhone = [phoneList binarySearchPhone:temp index:&dummy];

    if (tempPhone)
    {
//        printf("%s: native category\n", symbol);
        return [[tempPhone categoryList] findSymbol:temp];
    }
//    printf("%s: NON native category\n", symbol);
    return [categoryList findSymbol:symbol];
#endif
    return nil;
}

- (int)nextToken;
{
    NSString *scannedString;

    consumed = NO;

    [scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:NULL];

    if ([scanner scanString:@"(" intoString:NULL] == YES) {
        [self setSymbolString:@"("];
        return TK_LPAREN;
    }

    if ([scanner scanString:@")" intoString:NULL] == YES) {
        [self setSymbolString:@")"];
        return TK_RPAREN;
    }

    scannedString = nil;
    [scanner scanCharactersFromSet:[NSScanner gsBooleanIdentifierCharacterSet] intoString:&scannedString];
    if ([scanner scanString:@"*" intoString:NULL] == YES) {
        if (scannedString == nil)
            scannedString = @"*";
        else
            scannedString = [scannedString stringByAppendingString:@"*"];
    }

    [self setSymbolString:scannedString];

    if ([symbolString isEqual:@"and"])
        return TK_AND;
    if ([symbolString isEqual:@"or"])
        return TK_OR;
    if ([symbolString isEqual:@"not"])
        return TK_NOT;
    if ([symbolString isEqual:@"xor"])
        return TK_XOR;

    if (symbolString == nil || [symbolString length] == 0)
        return TK_END;
#if 0
    // TODO (2004-03-01): This is a probably programming error, with the ';' at the end of the if statement it doesn't do anything.
    if (![self categorySymbol:symbolString]);
//     printf("Category Not Found!\n");
    return TK_CATEGORY;
#endif
    if ([self categorySymbol:symbolString] == nil) {
        /* do nothing? */;
        printf("Category Not Found!\n");
    }

    return TK_CATEGORY;
}

- (void)consumeToken;
{
    consumed = YES;
}

- (id)parseString:(NSString *)aString;
{
    BooleanExpression *result;

    if (scanner != nil)
        [scanner release];

    nonretained_parseString = aString;
    scanner = [[NSScanner alloc] initWithString:aString];
    [scanner setCharactersToBeSkipped:nil];

    result = [self beginParseString];

    nonretained_parseString = nil;
    [scanner release];
    scanner = nil;

    return result;
}

- (id)beginParseString;
{
    CategoryNode *aCategory;
    id resultExpression = nil;

    switch ([self nextToken]) {
      default:
      case TK_END:
          [self outputError:@"Error, unexpected End."];
          return nil;

      case TK_OR:
      case TK_AND:
      case TK_XOR:
          [self outputError:@"Error, unexpected %@ operation." with:symbolString];
          return nil;

      case TK_NOT:
          resultExpression = [self notOperation];
          break;

      case TK_LPAREN:
          resultExpression = [self leftParen];
          break;

      case TK_RPAREN:
          [self outputError:@"Error, unexpected ')'."];
          break;

      case TK_CATEGORY:
          aCategory = [self categorySymbol:symbolString];
          if (aCategory == nil) {
              [self outputError:@"Error, unknown category %@." with:symbolString];
              return nil;
          } else {
              BooleanTerminal *aTerminal = nil;

              aTerminal = [[[BooleanTerminal alloc] init] autorelease];
              [aTerminal setCategory:aCategory];
              if ([symbolString hasSuffix:@"*"])
                  [aTerminal setShouldMatchAll:YES];
              resultExpression = aTerminal;
          }
          break;

    }
    if (resultExpression == nil)
        return nil;

    resultExpression = [self continueParse:resultExpression];

    return resultExpression;
}

- (id)continueParse:(id)currentExpression;
{
    int token;

    while ( (token = [self nextToken]) != TK_END) {
        switch (token) {
          default:
          case TK_END:
              [self outputError:@"Error, unexpected End."];
              [currentExpression release];
              return nil;

          case TK_OR:
              currentExpression = [self orOperation:currentExpression];
              break;

          case TK_AND:
              currentExpression = [self andOperation:currentExpression];
              break;

          case TK_XOR:
              currentExpression = [self xorOperation:currentExpression];
              break;

          case TK_NOT:
              [self outputError:@"Error, unexpected NOT operation."];
              [currentExpression release];
              return nil;

          case TK_LPAREN:
              [self outputError:@"Error, unexpected '('."];
              [currentExpression release];
              return nil;

          case TK_RPAREN:
              [self outputError:@"Error, unexpected ')'."];
              [currentExpression release];
              return nil;

          case TK_CATEGORY:
              [currentExpression release];
              [self outputError:@"Error, unexpected category %@." with:symbolString];
              return nil;
        }

        if (currentExpression == nil)
            return nil;
    }

    return currentExpression;
}

- (id)notOperation;
{
    BooleanExpression *resultExpression = nil, *subExpression;
    CategoryNode *aCategory;

    resultExpression = [[[BooleanExpression alloc] init] autorelease];
    [resultExpression setOperation:NOT_OP];

    switch ([self nextToken]) {
      case TK_AND:
      case TK_XOR:
      case TK_OR:
      case TK_NOT:
          [self outputError:@"Error, unexpected %@ operation." with:symbolString];
          return nil;

      case TK_CATEGORY:
          aCategory = [self categorySymbol:symbolString];
          if (aCategory == nil) {
              [self outputError:@"Error, unknown category %@." with:symbolString];
              return nil;
          } else {
              BooleanTerminal *aTerminal;

              aTerminal = [[BooleanTerminal alloc] init];
              [aTerminal setCategory:aCategory];
              if ([symbolString hasSuffix:@"*"])
                  [aTerminal setShouldMatchAll:YES];
              [resultExpression addSubExpression:(BooleanExpression *)aTerminal];
              [aTerminal release];
          }
          break;

      case TK_LPAREN:
          subExpression = [self leftParen];
          if (subExpression != nil)
              [resultExpression addSubExpression:subExpression];
    }

    return resultExpression;
}

- (id)andOperation:(id)operand;
{
    BooleanExpression *resultExpression = nil, *subExpression;
    CategoryNode *aCategory;

    resultExpression = [[[BooleanExpression alloc] init] autorelease];
    [resultExpression addSubExpression:operand];
    [resultExpression setOperation:AND_OP];

    switch ([self nextToken])
    {
      case TK_END:
          [self outputError:@"Error, unexpected End."];
          return nil;

      case TK_AND:
      case TK_OR:
      case TK_XOR:
          [self outputError:@"Error, unexpected %@ operation." with:symbolString];
          return nil;

      case TK_RPAREN:
          [self outputError:@"Error, unexpected ')'."];
          return nil;

      case TK_NOT:
          subExpression = [self notOperation];
          if (subExpression != nil)
              [resultExpression addSubExpression:subExpression];
          break;

      case TK_LPAREN:
          subExpression = [self leftParen];
          if (subExpression != nil)
              [resultExpression addSubExpression:subExpression];
          break;

      case TK_CATEGORY:
          aCategory = [self categorySymbol:symbolString];
          if (aCategory == nil) {
              [self outputError:@"Error, unknown category %@." with:symbolString];
              return nil;
          } else {
              BooleanTerminal *aTerminal;

              aTerminal = [[BooleanTerminal alloc] init];
              [aTerminal setCategory:aCategory];
              if ([symbolString hasSuffix:@"*"])
                  [aTerminal setShouldMatchAll:YES];
              [resultExpression addSubExpression:(BooleanExpression *)aTerminal];
              [aTerminal release];
          }
          break;
    }

    return resultExpression;
}

- (id)orOperation:(id)operand;
{
    BooleanExpression *resultExpression = nil, *subExpression;
    CategoryNode *aCategory;

    resultExpression = [[[BooleanExpression alloc] init] autorelease];
    [resultExpression addSubExpression:operand];
    [resultExpression setOperation:OR_OP];

    switch ([self nextToken]) {
      case TK_END:
          [self outputError:@"Error, unexpected End."];
          return nil;

      case TK_AND:
      case TK_OR:
      case TK_XOR:
          [self outputError:@"Error, unexpected %@ operation." with:symbolString];
          return nil;

      case TK_RPAREN:
          [self outputError:@"Error, unexpected ')'."];
          return nil;

      case TK_NOT:
          subExpression = [self notOperation];
          if (subExpression != nil)
              [resultExpression addSubExpression:subExpression];
          break;

      case TK_LPAREN:
          subExpression = [self leftParen];
          if (subExpression != nil)
              [resultExpression addSubExpression:subExpression];
          break;

      case TK_CATEGORY:
          aCategory = [self categorySymbol:symbolString];
          if (aCategory == nil) {
              [self outputError:@"Error, unknown category %@." with:symbolString];
              return nil;
          } else {
              BooleanTerminal *aTerminal;

              aTerminal = [[BooleanTerminal alloc] init];
              [aTerminal setCategory:aCategory];
              if ([symbolString hasSuffix:@"*"])
                  [aTerminal setShouldMatchAll:YES];
              [resultExpression addSubExpression:(BooleanExpression *)aTerminal];
              [aTerminal release];
          }
          break;
    }

    return resultExpression;
}

- (id)xorOperation:(id)operand;
{
    BooleanExpression *resultExpression = nil, *subExpression;
    CategoryNode *aCategory;

    resultExpression = [[[BooleanExpression alloc] init] autorelease];
    [resultExpression addSubExpression:operand];
    [resultExpression setOperation:XOR_OP];

    switch ([self nextToken])
    {
      case TK_END:
          [self outputError:@"Error, unexpected End."];
          return nil;

      case TK_AND:
      case TK_OR:
      case TK_XOR:
          [self outputError:@"Error, unexpected %@ operation." with:symbolString];
          return nil;

      case TK_RPAREN:
          [self outputError:@"Error, unexpected ')'."];
          return nil;

      case TK_NOT:
          subExpression = [self notOperation];
          if (subExpression != nil)
              [resultExpression addSubExpression:subExpression];
          break;

      case TK_LPAREN:
          subExpression = [self leftParen];
          if (subExpression != nil)
              [resultExpression addSubExpression:subExpression];
          break;

      case TK_CATEGORY:
          aCategory = [self categorySymbol:symbolString];
          if (aCategory == nil) {
              [self outputError:@"Error, unknown category %@." with:symbolString];
              return nil;
          } else {
              BooleanTerminal *aTerminal;

              aTerminal = [[BooleanTerminal alloc] init];
              [aTerminal setCategory:aCategory];
              if ([symbolString hasSuffix:@"*"])
                  [aTerminal setShouldMatchAll:YES];
              [resultExpression addSubExpression:(BooleanExpression *)aTerminal];
              [aTerminal release];
          }
          break;
    }

    return resultExpression;
}


- (id)leftParen;
{
    id resultExpression = nil;
    CategoryNode *aCategory;
    int token;

    switch ([self nextToken]) {
      case TK_END:
          [self outputError:@"Error, unexpected End."];
          return nil;

      case TK_RPAREN:
          return nil;

      case TK_LPAREN:
          resultExpression = [self leftParen];
          break;

      case TK_AND:
      case TK_OR:
      case TK_XOR:
          [self outputError:@"Error, unexpected %@ operation." with:symbolString];
          return nil;

      case TK_NOT:
          resultExpression = [self notOperation];
          break;

      case TK_CATEGORY:
          aCategory = [self categorySymbol:symbolString];
          if (aCategory == nil) {
              [self outputError:@"Error, unknown category %@." with:symbolString];
              return nil;
          } else {
              BooleanTerminal *aTerminal;

              aTerminal = [[[BooleanTerminal alloc] init] autorelease];
              [aTerminal setCategory:aCategory];
              if ([symbolString hasSuffix:@"*"])
                  [aTerminal setShouldMatchAll:YES];
              resultExpression = aTerminal;
          }
          break;
    }

    while ( (token = [self nextToken]) != TK_RPAREN) {
        switch (token) {
          case TK_END:
              [self outputError:@"Error, unexpected End."];
              return nil;

          case TK_RPAREN:
              return nil; // Won't happen

          case TK_LPAREN:
              [self outputError:@"Error, unexpected '('."];
              return nil;

          case TK_AND:
              resultExpression = [self andOperation:resultExpression];
              break;

          case TK_OR:
              resultExpression = [self orOperation:resultExpression];
              break;

          case TK_XOR:
              resultExpression = [self xorOperation:resultExpression];
              break;

          case TK_NOT:
              [self outputError:@"Error, unexpected NOT operation."];
              return nil;

          case TK_CATEGORY:
              [self outputError:@"Error, unexpected category %@." with:symbolString];
              return nil;
        }
    }

    return resultExpression;
}

@end

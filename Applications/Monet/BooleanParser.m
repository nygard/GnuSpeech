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

    categoryList = nil;
    phoneList = nil;

    return self;
}

- (void)dealloc;
{
    [categoryList release];
    [phoneList release];

    [super dealloc];
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

- (CategoryNode *)categorySymbol:(NSString *)symbol;
{
    NSString *baseName;
    Phone *tempPhone;
    int dummy;

    if ([symbol hasSuffix:@"*"]) {
        baseName = [symbol substringToIndex:[symbol length] - 1];
    } else {
        baseName = symbol;
    }

    tempPhone = [phoneList binarySearchPhone:baseName index:&dummy];

    if (tempPhone) {
        //NSLog(@"%@: native category\n", symbol);
        return [[tempPhone categoryList] findSymbol:baseName];
    }

    //NSLog(@"%@: NON native category\n", symbol);
    return [categoryList findSymbol:symbol];
}

- (int)nextToken;
{
    NSString *scannedString;

    [scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:NULL];

    if ([scanner scanString:@"(" intoString:NULL] == YES) {
        [self setSymbolString:@"("];
        return TK_B_LPAREN;
    }

    if ([scanner scanString:@")" intoString:NULL] == YES) {
        [self setSymbolString:@")"];
        return TK_B_RPAREN;
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
        return TK_B_AND;
    if ([symbolString isEqual:@"or"])
        return TK_B_OR;
    if ([symbolString isEqual:@"not"])
        return TK_B_NOT;
    if ([symbolString isEqual:@"xor"])
        return TK_B_XOR;

    if (symbolString == nil || [symbolString length] == 0)
        return TK_B_END;
#if 0
    // TODO (2004-03-01): This is a probably programming error, with the ';' at the end of the if statement it doesn't do anything.
    if (![self categorySymbol:symbolString]);
//     printf("Category Not Found!\n");
    return TK_B_CATEGORY;
#endif
    if ([self categorySymbol:symbolString] == nil) {
        /* do nothing? */;
        printf("Category Not Found!\n");
    }

    return TK_B_CATEGORY;
}

- (id)beginParseString;
{
    CategoryNode *aCategory;
    id resultExpression = nil;

    switch ([self nextToken]) {
      default:
      case TK_B_END:
          [self appendErrorFormat:@"Error, unexpected End."];
          return nil;

      case TK_B_OR:
      case TK_B_AND:
      case TK_B_XOR:
          [self appendErrorFormat:@"Error, unexpected %@ operation.", symbolString];
          return nil;

      case TK_B_NOT:
          resultExpression = [self notOperation];
          break;

      case TK_B_LPAREN:
          resultExpression = [self leftParen];
          break;

      case TK_B_RPAREN:
          [self appendErrorFormat:@"Error, unexpected ')'."];
          break;

      case TK_B_CATEGORY:
          aCategory = [self categorySymbol:symbolString];
          if (aCategory == nil) {
              [self appendErrorFormat:@"Error, unknown category %@.", symbolString];
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

    while ( (token = [self nextToken]) != TK_B_END) {
        switch (token) {
          default:
          case TK_B_END:
              [self appendErrorFormat:@"Error, unexpected End."];
              [currentExpression release];
              return nil;

          case TK_B_OR:
              currentExpression = [self orOperation:currentExpression];
              break;

          case TK_B_AND:
              currentExpression = [self andOperation:currentExpression];
              break;

          case TK_B_XOR:
              currentExpression = [self xorOperation:currentExpression];
              break;

          case TK_B_NOT:
              [self appendErrorFormat:@"Error, unexpected NOT operation."];
              [currentExpression release];
              return nil;

          case TK_B_LPAREN:
              [self appendErrorFormat:@"Error, unexpected '('."];
              [currentExpression release];
              return nil;

          case TK_B_RPAREN:
              [self appendErrorFormat:@"Error, unexpected ')'."];
              [currentExpression release];
              return nil;

          case TK_B_CATEGORY:
              [currentExpression release];
              [self appendErrorFormat:@"Error, unexpected category %@.", symbolString];
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
      case TK_B_AND:
      case TK_B_XOR:
      case TK_B_OR:
      case TK_B_NOT:
          [self appendErrorFormat:@"Error, unexpected %@ operation.", symbolString];
          return nil;

      case TK_B_CATEGORY:
          aCategory = [self categorySymbol:symbolString];
          if (aCategory == nil) {
              [self appendErrorFormat:@"Error, unknown category %@.", symbolString];
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

      case TK_B_LPAREN:
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
      case TK_B_END:
          [self appendErrorFormat:@"Error, unexpected End."];
          return nil;

      case TK_B_AND:
      case TK_B_OR:
      case TK_B_XOR:
          [self appendErrorFormat:@"Error, unexpected %@ operation.", symbolString];
          return nil;

      case TK_B_RPAREN:
          [self appendErrorFormat:@"Error, unexpected ')'."];
          return nil;

      case TK_B_NOT:
          subExpression = [self notOperation];
          if (subExpression != nil)
              [resultExpression addSubExpression:subExpression];
          break;

      case TK_B_LPAREN:
          subExpression = [self leftParen];
          if (subExpression != nil)
              [resultExpression addSubExpression:subExpression];
          break;

      case TK_B_CATEGORY:
          aCategory = [self categorySymbol:symbolString];
          if (aCategory == nil) {
              [self appendErrorFormat:@"Error, unknown category %@.", symbolString];
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
      case TK_B_END:
          [self appendErrorFormat:@"Error, unexpected End."];
          return nil;

      case TK_B_AND:
      case TK_B_OR:
      case TK_B_XOR:
          [self appendErrorFormat:@"Error, unexpected %@ operation.", symbolString];
          return nil;

      case TK_B_RPAREN:
          [self appendErrorFormat:@"Error, unexpected ')'."];
          return nil;

      case TK_B_NOT:
          subExpression = [self notOperation];
          if (subExpression != nil)
              [resultExpression addSubExpression:subExpression];
          break;

      case TK_B_LPAREN:
          subExpression = [self leftParen];
          if (subExpression != nil)
              [resultExpression addSubExpression:subExpression];
          break;

      case TK_B_CATEGORY:
          aCategory = [self categorySymbol:symbolString];
          if (aCategory == nil) {
              [self appendErrorFormat:@"Error, unknown category %@.", symbolString];
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
      case TK_B_END:
          [self appendErrorFormat:@"Error, unexpected End."];
          return nil;

      case TK_B_AND:
      case TK_B_OR:
      case TK_B_XOR:
          [self appendErrorFormat:@"Error, unexpected %@ operation.", symbolString];
          return nil;

      case TK_B_RPAREN:
          [self appendErrorFormat:@"Error, unexpected ')'."];
          return nil;

      case TK_B_NOT:
          subExpression = [self notOperation];
          if (subExpression != nil)
              [resultExpression addSubExpression:subExpression];
          break;

      case TK_B_LPAREN:
          subExpression = [self leftParen];
          if (subExpression != nil)
              [resultExpression addSubExpression:subExpression];
          break;

      case TK_B_CATEGORY:
          aCategory = [self categorySymbol:symbolString];
          if (aCategory == nil) {
              [self appendErrorFormat:@"Error, unknown category %@.", symbolString];
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
      case TK_B_END:
          [self appendErrorFormat:@"Error, unexpected End."];
          return nil;

      case TK_B_RPAREN:
          return nil;

      case TK_B_LPAREN:
          resultExpression = [self leftParen];
          break;

      case TK_B_AND:
      case TK_B_OR:
      case TK_B_XOR:
          [self appendErrorFormat:@"Error, unexpected %@ operation.", symbolString];
          return nil;

      case TK_B_NOT:
          resultExpression = [self notOperation];
          break;

      case TK_B_CATEGORY:
          aCategory = [self categorySymbol:symbolString];
          if (aCategory == nil) {
              [self appendErrorFormat:@"Error, unknown category %@.", symbolString];
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

    while ( (token = [self nextToken]) != TK_B_RPAREN) {
        switch (token) {
          case TK_B_END:
              [self appendErrorFormat:@"Error, unexpected End."];
              return nil;

          case TK_B_RPAREN:
              return nil; // Won't happen

          case TK_B_LPAREN:
              [self appendErrorFormat:@"Error, unexpected '('."];
              return nil;

          case TK_B_AND:
              resultExpression = [self andOperation:resultExpression];
              break;

          case TK_B_OR:
              resultExpression = [self orOperation:resultExpression];
              break;

          case TK_B_XOR:
              resultExpression = [self xorOperation:resultExpression];
              break;

          case TK_B_NOT:
              [self appendErrorFormat:@"Error, unexpected NOT operation."];
              return nil;

          case TK_B_CATEGORY:
              [self appendErrorFormat:@"Error, unexpected category %@.", symbolString];
              return nil;
        }
    }

    return resultExpression;
}

@end

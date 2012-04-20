//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright (c) 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMBooleanParser.h"

#import "NSScanner-Extensions.h"

#import "CategoryList.h"
#import "MMBooleanExpression.h"
#import "MMBooleanNode.h"
#import "MMBooleanSymbols.h"
#import "MMBooleanTerminal.h"
#import "MMCategory.h"
#import "MMPosture.h"
#import "MModel.h"

@implementation MMBooleanParser
{
    MModel *model;
}

- (id)initWithModel:(MModel *)aModel;
{
    if ([super init] == nil)
        return nil;

    model = [aModel retain];

    return self;
}

- (void)dealloc;
{
    [model release];

    [super dealloc];
}

- (MModel *)model;
{
    return model;
}

- (void)setModel:(MModel *)newModel;
{
    if (newModel == model)
        return;

    [model release];
    model = [newModel retain];
}

// This strips off the optional "*" suffix before searching.  A "*" will match either a stressed or unstressed posture.  i.e. ee or ee'.
- (MMCategory *)categoryWithName:(NSString *)aName;
{
    NSString *baseName;
    MMPosture *aPosture;

    if ([aName hasSuffix:@"*"]) {
        baseName = [aName substringToIndex:[aName length] - 1];
    } else {
        baseName = aName;
    }

    // Search first for a native category -- i.e. a posture name
    aPosture = [model postureWithName:baseName];
    //NSLog(@"%s, baseName: %@, aPosture: %p", _cmd, baseName, aPosture);

    if (aPosture != nil) {
        //NSLog(@"%@: native category\n", baseName);
        return [aPosture nativeCategory];
    }

    //NSLog(@"%@: NON native category\n", aName);
    return [model categoryWithName:aName];
}

- (NSUInteger)nextToken;
{
    NSString *scannedString;

    [self.scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:NULL];

    if ([self.scanner scanString:@"(" intoString:NULL] == YES) {
        [self setSymbolString:@"("];
        return TK_B_LPAREN;
    }

    if ([self.scanner scanString:@")" intoString:NULL] == YES) {
        [self setSymbolString:@")"];
        return TK_B_RPAREN;
    }

    scannedString = nil;
    [self.scanner scanCharactersFromSet:[NSScanner gsBooleanIdentifierCharacterSet] intoString:&scannedString];
    if ([self.scanner scanString:@"*" intoString:NULL] == YES) {
        if (scannedString == nil)
            scannedString = @"*";
        else
            scannedString = [scannedString stringByAppendingString:@"*"];
    }

    [self setSymbolString:scannedString];

    if ([self.symbolString isEqual:@"and"])
        return TK_B_AND;
    if ([self.symbolString isEqual:@"or"])
        return TK_B_OR;
    if ([self.symbolString isEqual:@"not"])
        return TK_B_NOT;
    if ([self.symbolString isEqual:@"xor"])
        return TK_B_XOR;

    if (self.symbolString == nil || [self.symbolString length] == 0)
        return TK_B_END;
#if 0
    // TODO (2004-03-01): This is a probably programming error, with the ';' at the end of the if statement it doesn't do anything.
    if (![self categoryWithName:symbolString]);
//     printf("Category Not Found!\n");
    return TK_B_CATEGORY;
#endif
    if ([self categoryWithName:self.symbolString] == nil) {
        /* do nothing? */;
        NSLog(@"Category Not Found! (%@)", self.symbolString);
    }

    return TK_B_CATEGORY;
}

- (id)beginParseString;
{
    MMCategory *aCategory;
    id resultExpression = nil;

    switch ([self nextToken]) {
      default:
      case TK_B_END:
          [self appendErrorFormat:@"Error, unexpected End."];
          return nil;

      case TK_B_OR:
      case TK_B_AND:
      case TK_B_XOR:
          [self appendErrorFormat:@"Error, unexpected %@ operation.", self.symbolString];
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
          aCategory = [self categoryWithName:self.symbolString];
          if (aCategory == nil) {
              [self appendErrorFormat:@"Error, unknown category %@.", self.symbolString];
              return nil;
          } else {
              MMBooleanTerminal *aTerminal = nil;

              aTerminal = [[[MMBooleanTerminal alloc] init] autorelease];
              [aTerminal setCategory:aCategory];
              if ([self.symbolString hasSuffix:@"*"])
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

- (MMBooleanNode *)continueParse:(MMBooleanNode *)currentExpression;
{
    NSUInteger token;

    while ( (token = [self nextToken]) != TK_B_END) {
        switch (token) {
          default:
          case TK_B_END:
              [self appendErrorFormat:@"Error, unexpected End."];
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
              return nil;

          case TK_B_LPAREN:
              [self appendErrorFormat:@"Error, unexpected '('."];
              return nil;

          case TK_B_RPAREN:
              [self appendErrorFormat:@"Error, unexpected ')'."];
              return nil;

          case TK_B_CATEGORY:
              [self appendErrorFormat:@"Error, unexpected category %@.", self.symbolString];
              return nil;
        }

        if (currentExpression == nil)
            return nil;
    }

    return currentExpression;
}

- (MMBooleanNode *)notOperation;
{
    MMBooleanExpression *resultExpression = nil;
    MMBooleanNode *subExpression;
    MMCategory *aCategory;

    resultExpression = [[[MMBooleanExpression alloc] init] autorelease];
    [resultExpression setOperation:NOT_OP];

    switch ([self nextToken]) {
      case TK_B_AND:
      case TK_B_XOR:
      case TK_B_OR:
      case TK_B_NOT:
          [self appendErrorFormat:@"Error, unexpected %@ operation.", self.symbolString];
          return nil;

      case TK_B_CATEGORY:
          aCategory = [self categoryWithName:self.symbolString];
          if (aCategory == nil) {
              [self appendErrorFormat:@"Error, unknown category %@.", self.symbolString];
              return nil;
          } else {
              MMBooleanTerminal *aTerminal;

              aTerminal = [[MMBooleanTerminal alloc] init];
              [aTerminal setCategory:aCategory];
              if ([self.symbolString hasSuffix:@"*"])
                  [aTerminal setShouldMatchAll:YES];
              [resultExpression addSubExpression:aTerminal];
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

- (MMBooleanNode *)andOperation:(MMBooleanNode *)operand;
{
    MMBooleanExpression *resultExpression = nil;
    MMBooleanNode *subExpression;
    MMCategory *aCategory;

    resultExpression = [[[MMBooleanExpression alloc] init] autorelease];
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
          [self appendErrorFormat:@"Error, unexpected %@ operation.", self.symbolString];
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
          aCategory = [self categoryWithName:self.symbolString];
          if (aCategory == nil) {
              [self appendErrorFormat:@"Error, unknown category %@.", self.symbolString];
              return nil;
          } else {
              MMBooleanTerminal *aTerminal;

              aTerminal = [[MMBooleanTerminal alloc] init];
              [aTerminal setCategory:aCategory];
              if ([self.symbolString hasSuffix:@"*"])
                  [aTerminal setShouldMatchAll:YES];
              [resultExpression addSubExpression:aTerminal];
              [aTerminal release];
          }
          break;
    }

    return resultExpression;
}

- (MMBooleanNode *)orOperation:(MMBooleanNode *)operand;
{
    MMBooleanExpression *resultExpression = nil;
    MMBooleanNode *subExpression;
    MMCategory *aCategory;

    resultExpression = [[[MMBooleanExpression alloc] init] autorelease];
    [resultExpression addSubExpression:operand];
    [resultExpression setOperation:OR_OP];

    switch ([self nextToken]) {
      case TK_B_END:
          [self appendErrorFormat:@"Error, unexpected End."];
          return nil;

      case TK_B_AND:
      case TK_B_OR:
      case TK_B_XOR:
          [self appendErrorFormat:@"Error, unexpected %@ operation.", self.symbolString];
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
          aCategory = [self categoryWithName:self.symbolString];
          if (aCategory == nil) {
              [self appendErrorFormat:@"Error, unknown category %@.", self.symbolString];
              return nil;
          } else {
              MMBooleanTerminal *aTerminal;

              aTerminal = [[MMBooleanTerminal alloc] init];
              [aTerminal setCategory:aCategory];
              if ([self.symbolString hasSuffix:@"*"])
                  [aTerminal setShouldMatchAll:YES];
              [resultExpression addSubExpression:aTerminal];
              [aTerminal release];
          }
          break;
    }

    return resultExpression;
}

- (MMBooleanNode *)xorOperation:(MMBooleanNode *)operand;
{
    MMBooleanExpression *resultExpression = nil;
    MMBooleanNode *subExpression;
    MMCategory *aCategory;

    resultExpression = [[[MMBooleanExpression alloc] init] autorelease];
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
          [self appendErrorFormat:@"Error, unexpected %@ operation.", self.symbolString];
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
          aCategory = [self categoryWithName:self.symbolString];
          if (aCategory == nil) {
              [self appendErrorFormat:@"Error, unknown category %@.", self.symbolString];
              return nil;
          } else {
              MMBooleanTerminal *aTerminal;

              aTerminal = [[MMBooleanTerminal alloc] init];
              [aTerminal setCategory:aCategory];
              if ([self.symbolString hasSuffix:@"*"])
                  [aTerminal setShouldMatchAll:YES];
              [resultExpression addSubExpression:aTerminal];
              [aTerminal release];
          }
          break;
    }

    return resultExpression;
}

- (MMBooleanNode *)leftParen;
{
    id resultExpression = nil;
    MMCategory *aCategory;
    NSUInteger token;

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
          [self appendErrorFormat:@"Error, unexpected %@ operation.", self.symbolString];
          return nil;

      case TK_B_NOT:
          resultExpression = [self notOperation];
          break;

      case TK_B_CATEGORY:
          aCategory = [self categoryWithName:self.symbolString];
          if (aCategory == nil) {
              [self appendErrorFormat:@"Error, unknown category %@.", self.symbolString];
              return nil;
          } else {
              MMBooleanTerminal *aTerminal;

              aTerminal = [[[MMBooleanTerminal alloc] init] autorelease];
              [aTerminal setCategory:aCategory];
              if ([self.symbolString hasSuffix:@"*"])
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
              [self appendErrorFormat:@"Error, unexpected category %@.", self.symbolString];
              return nil;
        }
    }

    return resultExpression;
}

@end

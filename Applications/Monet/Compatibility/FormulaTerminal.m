#import "FormulaTerminal.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "MMSymbol.h"

#import "MModel.h"
#import "MUnarchiver.h"

@implementation FormulaTerminal

- (id)init;
{
    if ([super init] == nil)
        return nil;

    symbol = nil;
    value = 0.0;
    whichPhone = -1;

    [self setPrecedence:4];

    return self;
}

- (void)dealloc;
{
    [symbol release];

    [super dealloc];
}

- (MMSymbol *)symbol;
{
    return symbol;
}

- (void)setSymbol:(MMSymbol *)newSymbol;
{
    if (newSymbol == symbol)
        return;

    [symbol release];
    symbol = [newSymbol retain];
}

- (double)value;
{
    return value;
}

- (void)setValue:(double)newValue;
{
    value = newValue;
}

- (int)whichPhone;
{
    return whichPhone;
}

- (void)setWhichPhone:(int)newValue;
{
    whichPhone = newValue;
}

//
// Methods common to "FormulaNode" -- for both FormulaExpression, FormulaTerminal
//

- (void)expressionString:(NSMutableString *)resultString;
{
    switch (whichPhone) {
      case RULEDURATION:
          [resultString appendString:@"rd"];
          break;
      case BEAT:
          [resultString appendString:@"beat"];
          break;
      case MARK1:
          [resultString appendString:@"mark1"];
          break;
      case MARK2:
          [resultString appendString:@"mark2"];
          break;
      case MARK3:
          [resultString appendString:@"mark3"];
          break;
      case TEMPO0:
          [resultString appendString:@"tempo1"];
          break;
      case TEMPO1:
          [resultString appendString:@"tempo2"];
          break;
      case TEMPO2:
          [resultString appendString:@"tempo3"];
          break;
      case TEMPO3:
          [resultString appendString:@"tempo4"];
          break;

      default:
          if (symbol == nil) {
              [resultString appendFormat:@"%f", value];
          } else {
              [resultString appendFormat:@"%@%d", [symbol name], whichPhone+1];
          }
          break;
    }
}

//
// Archiving
//

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    unsigned archivedVersion;
    MModel *model;

    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    model = [(MUnarchiver *)aDecoder userInfo];

    //NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    archivedVersion = [aDecoder versionForClassName:NSStringFromClass([self class])];
    //NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

    symbol = nil;

    if (archivedVersion == 0) {
        char *c_symbolName;
        NSString *symbolName;

        [aDecoder decodeValuesOfObjCTypes:"dii", &value, &whichPhone, &precedence];
        //NSLog(@"value: %g, whichPhone: %d, precedence: %d", value, whichPhone, precedence);

        [aDecoder decodeValueOfObjCType:@encode(char *) at:&c_symbolName];
        symbolName = [NSString stringWithASCIICString:c_symbolName];
        free(c_symbolName);
        //NSLog(@"FormulaTerminal symbolName: %@", symbolName);

        if ([symbolName isEqual:@"No Symbol"] == NO)
            [self setSymbol:[model symbolWithName:symbolName]];
    } else {
        NSLog(@"<%@>: Unknown version %u", NSStringFromClass([self class]), archivedVersion);
        //NSLog(@"<%@>[%p] <  %s", NSStringFromClass([self class]), self, _cmd);
        return nil;
    }

    //NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);
    return self;
}

@end

#import "FormulaTerminal.h"

#import <Foundation/Foundation.h>
#import "MyController.h"
#import "Phone.h"
#import "Symbol.h"
#import "SymbolList.h"
#import "Target.h"
#import "TargetList.h"

@implementation FormulaTerminal

+ (void)initialize;
{
    NSLog(@" > %s", _cmd);
    [self setVersion:1];
    NSLog(@"<  %s", _cmd);
}

- (id)init;
{
    if ([super init] == nil)
        return nil;

    symbol = nil;
    value = 0.0;
    whichPhone = -1;
    precedence = 4;

    return self;
}

- (void)dealloc;
{
    [symbol release];

    [super dealloc];
}

- (Symbol *)symbol;
{
    return symbol;
}

- (void)setSymbol:(Symbol *)newSymbol;
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

- (int)precedence;
{
    return precedence;
}

- (void)setPrecedence:(int)newPrec;
{
    precedence = newPrec;
}

- (double)evaluate:(double *)ruleSymbols phones:phones;
{
    double tempos[4] = {1.0, 1.0, 1.0, 1.0};

    return [self evaluate:ruleSymbols tempos:tempos phones:phones];
}

- (double)evaluate:(double *)ruleSymbols tempos:(double *)tempos phones:phones;
{
    SymbolList *mainSymbolList;
    Target *tempTarget;
    int index;

    /* Duration of the rule itself */
    switch (whichPhone) {
      case RULEDURATION:
          return ruleSymbols[0];
      case BEAT:
          return ruleSymbols[1];
      case MARK1:
          return ruleSymbols[2];
      case MARK2:
          return ruleSymbols[3];
      case MARK3:
          return ruleSymbols[4];
      case TEMPO0:
          return tempos[0];
      case TEMPO1:
          return tempos[1];
      case TEMPO2:
          return tempos[2];
      case TEMPO3:
          return tempos[3];

      default:
          break;
    }

    /* Constant value */
    if (symbol == nil)
        return value;

    /* Resolve the symbol*/
    /* Get main symbolList to determine index of "symbol" */
    mainSymbolList = (SymbolList *)NXGetNamedObject(@"mainSymbolList", NSApp);
    index = [mainSymbolList indexOfObject:symbol];

    /* Use index to index the phone's symbol list */
    tempTarget = [[[phones objectAtIndex:whichPhone] symbolList] objectAtIndex:index];

    //NSLog(@"Evaluate: %@ Index: %d  Value : %f", [[phones objectAtIndex:whichPhone] symbol], index, [tempTarget value]);

    /* Return the value */
    return [tempTarget value];
}

- (void)optimize;
{
}

- (void)optimizeSubExpressions;
{
}

- (int)maxExpressionLevels;
{
    return 1;
}

- (int)maxPhone;
{
    return whichPhone;
}

- (NSString *)expressionString;
{
    NSMutableString *resultString;

    resultString = [NSMutableString string];
    [self expressionString:resultString];

    return resultString;
}

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
              [resultString appendFormat:@"%@%d", [symbol symbol], whichPhone+1];
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
    char *string;
    SymbolList *temp;

    NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    archivedVersion = [aDecoder versionForClassName:NSStringFromClass([self class])];
    NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

    temp = NXGetNamedObject(@"mainSymbolList", NSApp);

    switch (archivedVersion) {
      case 0:
          [aDecoder decodeValuesOfObjCTypes:"dii", &value, &whichPhone, &precedence];
          NSLog(@"value: %g, whichPhone: %d, precedence: %d", value, whichPhone, precedence);

          [aDecoder decodeValueOfObjCType:"*" at:&string];
          if (!strcmp(string, "No Symbol"))
              symbol = nil;
          else
              symbol = [temp findSymbol:string];

          free(string);
          break;
      default:
          NSLog(@"Unknown version %u", archivedVersion);
          NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);
          return nil;
    }

    NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);
    return self;
}

#ifdef PORTING
- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    const char *temp;

    [aCoder encodeValuesOfObjCTypes:"dii", &value, &whichPhone, &precedence];

    if (symbol)
    {
        temp = [symbol symbol];
        [aCoder encodeValueOfObjCType:"*" at:&temp];
    }
    else
    {
        temp = "No Symbol";
        [aCoder encodeValueOfObjCType:"*" at:&temp];
    }
}
#endif

#ifdef NeXT
- read:(NXTypedStream *)stream;
{
    char *string;
    SymbolList *temp;


    temp = NXGetNamedObject(@"mainSymbolList", NSApp);

    NXReadTypes(stream, "dii", &value, &whichPhone, &precedence);

    NXReadType(stream, "*", &string);
    if (!strcmp(string, "No Symbol"))
        symbol = nil;
    else
        symbol = [temp findSymbol:string];

    free(string);
    return self;
}
#endif

@end

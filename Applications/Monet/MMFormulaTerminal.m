#import "MMFormulaTerminal.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "MMPosture.h"
#import "PhoneList.h"
#import "MMSymbol.h"
#import "SymbolList.h"
#import "MMTarget.h"
#import "TargetList.h"

#import "MModel.h"
#import "MUnarchiver.h"

@implementation MMFormulaTerminal

- (id)init;
{
    if ([super init] == nil)
        return nil;

    symbol = nil;
    value = 0.0;
    whichPhone = -1;

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
// Methods overridden from MMFormulaNode
//

- (int)precedence;
{
    return 3;
}

- (double)evaluate:(double *)ruleSymbols phones:(PhoneList *)phones;
{
    double tempos[4] = {1.0, 1.0, 1.0, 1.0};

    return [self evaluate:ruleSymbols phones:phones tempos:tempos];
}

- (double)evaluate:(double *)ruleSymbols phones:(PhoneList *)phones tempos:(double *)tempos;
{
    MMTarget *symbolTarget;

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

    symbolTarget = [[phones objectAtIndex:whichPhone] targetForSymbol:symbol];
    if (symbolTarget == nil)
        return 0.0;

    /* Return the value */
    return [symbolTarget value];
}

- (int)maxPhone;
{
    return whichPhone;
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

@end

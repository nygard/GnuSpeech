//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright (c) 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMFormulaTerminal.h"

#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "MMPosture.h"
#import "MMSymbol.h"
#import "MMTarget.h"

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

- (NSInteger)whichPhone;
{
    return whichPhone;
}

- (void)setWhichPhone:(NSInteger)newValue;
{
    whichPhone = newValue;
}

//
// Methods overridden from MMFormulaNode
//

- (NSUInteger)precedence;
{
    return 3;
}

- (double)evaluate:(MMFRuleSymbols *)ruleSymbols postures:(NSArray *)postures tempos:(double *)tempos;
{
    MMTarget *symbolTarget;

    /* Duration of the rule itself */
    switch (whichPhone) {
      case RULEDURATION:
          return ruleSymbols->ruleDuration;
      case BEAT:
          return ruleSymbols->beat;
      case MARK1:
          return ruleSymbols->mark1;
      case MARK2:
          return ruleSymbols->mark2;
      case MARK3:
          return ruleSymbols->mark3;

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

    symbolTarget = [[postures objectAtIndex:whichPhone] targetForSymbol:symbol];
    if (symbolTarget == nil)
        return 0.0;

    /* Return the value */
    return [symbolTarget value];
}

- (NSInteger)maxPhone;
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
              [resultString appendFormat:@"%@%lu", [symbol name], whichPhone+1];
          }
          break;
    }
}

@end

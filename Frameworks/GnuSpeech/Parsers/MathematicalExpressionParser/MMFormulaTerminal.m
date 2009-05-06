////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
//  
//  Contributors: Steve Nygard
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
////////////////////////////////////////////////////////////////////////////////
//
//  MMFormulaTerminal.m
//  GnuSpeech
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.8
//
////////////////////////////////////////////////////////////////////////////////

#import "MMFormulaTerminal.h"

#import <Foundation/Foundation.h>
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
              [resultString appendFormat:@"%@%d", [symbol name], whichPhone+1];
          }
          break;
    }
}

@end

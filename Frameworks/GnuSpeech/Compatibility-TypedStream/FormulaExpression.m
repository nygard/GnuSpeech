////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
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
//  FormulaExpression.m
//  GnuSpeech
//
//  Created by Steve Nygard in 2004
//
//  Version: 0.8
//
////////////////////////////////////////////////////////////////////////////////

#import "FormulaExpression.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"

#import "MMFormulaSymbols.h"

@implementation FormulaExpression

- (id)init;
{
    if ([super init] == nil)
        return nil;

    operation = TK_F_END;
    expressions = [[NSMutableArray alloc] init];

    return self;
}

- (void)dealloc;
{
    [expressions release];

    [super dealloc];
}

- (int)operation;
{
    return operation;
}

- (void)setOperation:(int)newOp;
{
    operation = newOp;
}

- (void)addSubExpression:newExpression;
{
    [expressions addObject:newExpression];
}

- (id)operandOne;
{
    if ([expressions count] > 0)
        return [expressions objectAtIndex:0];

    return nil;
}

- (void)setOperandOne:(id)operand;
{
    if (operand == nil)
        return;

    if ([expressions count] == 0)
        [expressions addObject:operand];
    else
        [expressions replaceObjectAtIndex:0 withObject:operand];
}

- (id)operandTwo;
{
    if ([expressions count] > 1)
        return [expressions objectAtIndex:1];

    return nil;
}

- (void)setOperandTwo:(id)operand;
{
    switch ([expressions count]) {
      case 0:
          NSLog(@"Drat, there should be an operandOne in %s", _cmd);
          break;
      case 1:
          if (operand != nil)
              [expressions addObject:operand];
          break;
      default:
          [expressions replaceObjectAtIndex:1 withObject:operand];
          break;
    }
}

- (NSString *)opString;
{
    switch (operation) {
      default:
      case TK_F_END: return @"";
      case TK_F_ADD: return @" + ";
      case TK_F_SUB: return @" - ";
      case TK_F_MULT: return @" * ";
      case TK_F_DIV: return @" / ";
    }

    return @"";
}

//
// Methods common to "FormulaNode" -- for both FormulaExpression, FormulaTerminal
//

- (void)expressionString:(NSMutableString *)resultString;
{
    int count, index;
    NSString *opString;

    opString = [self opString];

    if (precedence == 3)
        [resultString appendString:@"("];

    count = [expressions count];
    for (index = 0; index < count; index++) {
        if (index != 0)
            [resultString appendString:opString];

        [[expressions objectAtIndex:index] expressionString:resultString];

    }

    if (precedence == 3)
        [resultString appendString:@")"];
}

//
// Archiving
//

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    unsigned archivedVersion;
    int index;
    int numExpressions, maxExpressions;

    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    //NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    archivedVersion = [aDecoder versionForClassName:NSStringFromClass([self class])];
    //NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

    [aDecoder decodeValuesOfObjCTypes:"iiii", &operation, &numExpressions, &maxExpressions, &precedence];
    if (numExpressions != 2)
        NSLog(@"operation: %d, numExpressions: %d, maxExpressions: %d, precedence: %d", operation, numExpressions, maxExpressions, precedence);
    expressions = [[NSMutableArray alloc] init];
    for (index = 0; index < numExpressions; index++)
        [self addSubExpression:[aDecoder decodeObject]];

    //NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);

    return self;
}

@end

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
//  MMFormulaNode.m
//  GnuSpeech
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.9
//
////////////////////////////////////////////////////////////////////////////////

#import "MMFormulaNode.h"

#import <Foundation/Foundation.h>

@implementation MMFormulaNode

- (int)precedence;
{
    // Implement in subclasses
    return 0;
}

- (double)evaluate:(MMFRuleSymbols *)ruleSymbols postures:(NSArray *)postures;
{
    double tempos[4] = {1.0, 1.0, 1.0, 1.0};

    return [self evaluate:ruleSymbols postures:postures tempos:tempos];
}

- (double)evaluate:(MMFRuleSymbols *)ruleSymbols postures:(NSArray *)postures tempos:(double *)tempos;
{
    // Implement in subclasses
    return 0;
}

- (int)maxPhone;
{
    // Implement in subclasses
    return 0;
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
    // Implement in subclasses
}

@end

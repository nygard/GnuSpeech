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
//  MMFormulaParser.h
//  GnuSpeech
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.9
//
////////////////////////////////////////////////////////////////////////////////

#import "GSParser.h"

@class MMFormulaTerminal, MMFormulaNode, MModel;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface MMFormulaParser : GSParser
{
    MModel *model;

    int lookahead;
}

+ (MMFormulaNode *)parsedExpressionFromString:(NSString *)aString model:(MModel *)aModel;
+ (NSString *)nameForToken:(int)aToken;

- (id)initWithModel:(MModel *)aModel;
- (void)dealloc;

- (MModel *)model;
- (void)setModel:(MModel *)newModel;

- (int)nextToken;
- (BOOL)scanNumber;


- (void)match:(int)token;
- (MMFormulaNode *)parseExpression;
- (MMFormulaNode *)parseTerm;
- (MMFormulaNode *)parseFactor;

- (MMFormulaTerminal *)parseNumber;
- (MMFormulaNode *)parseSymbol;

- (id)beginParseString;

@end

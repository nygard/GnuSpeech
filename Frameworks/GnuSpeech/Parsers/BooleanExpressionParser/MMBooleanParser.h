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
//  MMBooleanParser.h
//  GnuSpeech
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.8
//
////////////////////////////////////////////////////////////////////////////////

#import "GSParser.h"

@class MMBooleanNode, MMCategory, MModel;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================

	Object: BooleanParser
	Purpose: To parse a boolean expression string and build a boolean
		expression tree.

	Instance Variables:
		consumed: (int) currently not used.  May be used for look-
			ahead parsing.
		parseString: (const char *) The string being parsed.  NOTE
			that it is const and should not be modified.
		symbolString: (char[256]) Buffer for the current symbol.

		categoryList: In MONET, terminals for the boolean expression
			system are instances of the MMCategory class.
			The majority of those instances are stored in a
			named object which is of the "CategoryList" class.
			When a category symbol is to be resolved, this list
			is consulted.
		phoneList:  Not all MMCategorys are stored in the
			mainCategoryList.  Some are categories native to a
			specific phone.  If a category cannot be found in the
			main category list, the main phone list is consulted.

	"BooleanSymbols.h" for some TOKEN defines.
*/

@interface MMBooleanParser : GSParser
{
    MModel *model;
}

- (id)initWithModel:(MModel *)aModel;
- (void)dealloc;

- (MModel *)model;
- (void)setModel:(MModel *)newModel;

/* General purpose internal methods */
- (MMCategory *)categoryWithName:(NSString *)aName;
- (int)nextToken;

/* General Parse Methods */
- (id)beginParseString;
- (MMBooleanNode *)continueParse:(MMBooleanNode *)currentExpression;

/* Internal recursive descent methods */
- (MMBooleanNode *)notOperation;
- (MMBooleanNode *)andOperation:(MMBooleanNode *)operand;
- (MMBooleanNode *)orOperation:(MMBooleanNode *)operand;
- (MMBooleanNode *)xorOperation:(MMBooleanNode *)operand;

- (MMBooleanNode *)leftParen;

@end


#import <Foundation/NSObject.h>
#import "CategoryList.h"
#import "PhoneList.h"
#import "BooleanExpression.h"
#import "BooleanTerminal.h"
#import "BooleanSymbols.h"

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
		stringIndex: (int) current index into the string being
			parsed.
		lastStringIndex: (int) index of the first character of the
			current token being parsed.  Generally used to 
			indicate which token caused an error to occur.
		parseString: (const char *) The string being parsed.  NOTE
			that it is const and should not be modified.
		symbolString: (char[256]) Buffer for the current symbol.

		categoryList: In MONET, terminals for the boolean expression
			system are instances of the CategoryNode class.
			The majority of those instances are stored in a
			named object which is of the "CategoryList" class. 
			When a category symbol is to be resolved, this list
			is consulted.
		phoneList:  Not all CategoryNodes are stored in the 
			mainCategoryList.  Some are categories native to a 
			specific phone.  If a category cannot be found in the
			main category list, the main phone list is consulted.

		errorTextField:  Points to an instance of the "TextField" 
			class.  Parse errors are sent to this object.

	Import Files:

	"BooleanExpression.h", "BooleanTerminal.h", "CategoryList.h", and
		"PhoneList.h" for object definitions.

	"BooleanSymbols.h" for some TOKEN defines.
*/

@interface BooleanParser:NSObject
{
	int consumed;
	int stringIndex, lastStringIndex;
	const char *parseString;
	char symbolString[256];

	CategoryList *categoryList;
	PhoneList *phoneList;

	id	errorTextField;
}

- init;

/* Access to instance variables */
- (void)setCategoryList: (CategoryList *)aList;
- (CategoryList *)categoryList;
- (void)setPhoneList: (PhoneList *)aList;
- (PhoneList *)phoneList;
- (void)setErrorOutput:aTextObject;

/* Error reporting methods */
- (void)outputError:(const char *)errorText;
- (void)outputError:(const char *) errorText with: (const char *) symbol;

/* General purpose internal methods */
- (id)categorySymbol:(const char *)symbol;
- (int) nextToken;
- (void)consumeToken;

/* General Parse Methods */
- parseString:(const char *)string;
- beginParseString;
- continueParse:currentExpression;

/* Internal recursive descent methods */
- notOperation;
- andOperation:operand;
- orOperation:operand;
- xorOperation:operand;

- leftParen;

@end

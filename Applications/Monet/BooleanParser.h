#import <Foundation/NSObject.h>

@class NSScanner;
@class NSTextField; // Yuck!
@class BooleanExpression, CategoryNode, CategoryList, PhoneList;
#ifdef PORTING
#import "BooleanExpression.h"
#import "BooleanTerminal.h"
#import "BooleanSymbols.h"
#endif

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

@interface BooleanParser : NSObject
{
    BOOL consumed;
    //int stringIndex;
    //int lastStringIndex;
    NSString *nonretained_parseString;
    NSScanner *scanner;
    //char symbolString[256];
    NSString *symbolString;

    CategoryList *categoryList;
    PhoneList *phoneList;

    NSTextField *nonretained_errorTextField; // TODO (2004-03-01): Change this to an NSMutableString, and query it in the interface controller.
}

- (id)init;
- (void)dealloc;

/* Access to instance variables */
- (NSString *)symbolString;
- (void)setSymbolString:(NSString *)newString;

- (CategoryList *)categoryList;
- (void)setCategoryList:(CategoryList *)aList;

- (PhoneList *)phoneList;
- (void)setPhoneList: (PhoneList *)aList;

- (void)setErrorOutput:(NSTextField *)aTextField;

/* Error reporting methods */
- (void)outputError:(NSString *)errorText;
- (void)outputError:(NSString *)errorText with:(NSString *)symbol;

/* General purpose internal methods */
- (CategoryNode *)categorySymbol:(NSString *)symbol;
- (int)nextToken;
- (void)consumeToken;

/* General Parse Methods */
// BooleanExpression or maybe BooleanTerminal
- (id)parseString:(NSString *)aString;
- (id)beginParseString;
- (id)continueParse:(id)currentExpression;

/* Internal recursive descent methods */
- (id)notOperation;
- (id)andOperation:(id)operand;
- (id)orOperation:(id)operand;
- (id)xorOperation:(id)operand;

- (id)leftParen;

@end

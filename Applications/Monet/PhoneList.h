#import "MonetList.h"

@class Phone;
//#import <stdio.h>

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================

	Object: PhoneList
	Purpose: To provide special functionality specific to maintaining
		and accessing a list of phones.

	Import Files:
		"Phone.h":  The objects within this list will all be instances
			of the "Phone" class.


*/

@interface PhoneList : MonetList
{
}

- (Phone *) findPhone: (const char *) phone;
- binarySearchPhone:(const char *) searchPhone index:(int *) index;
- (void)addPhone:(const char *)phone;
- (void)addPhoneObject:(Phone *)phone;

- (void)readDegasFileFormat:(FILE *)fp;
- (void)printDataTo:(FILE *)fp;

/* BrowserManager List delegate Methods */
- (void)addNewValue:(const char *)newValue;
- findByName:(const char *)name;
- (void)changeSymbolOf:temp to:(const char *)name;


/* List maintenance Methods */
- (void)parameterDefaultChange:parameter to:(double)value;
- (void)symbolDefaultChange:parameter to:(double)value;

- (void)addParameter;
- (void)addMetaParameter;
- (void)addSymbol;

- (void)removeParameter:(int)index;
- (void)removeMetaParameter:(int)index;
- (void)removeSymbol:(int)index;

- (void)importTRMData:sender;
- makePhoneUniqueName:aPhone;

@end

#import "MonetList.h"
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class Parameter, Phone;

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

- (Phone *)findPhone:(NSString *)phone;
- (void)addPhone:(NSString *)phone;
- (void)addPhoneObject:(Phone *)phone;
- (Phone *)binarySearchPhone:(NSString *)searchPhone index:(int *)index;

/* BrowserManager List delegate Methods */
- (void)addNewValue:(NSString *)newValue;
- (Phone *)findByName:(NSString *)name;
- (void)changeSymbolOf:(Phone *)aPhone to:(NSString *)name;

//- (void)readDegasFileFormat:(FILE *)fp;
//- (void)printDataTo:(FILE *)fp;

/* List maintenance Methods */
- (void)parameterDefaultChange:(Parameter *)parameter to:(double)value;
- (void)symbolDefaultChange:(Parameter *)parameter to:(double)value;

- (void)addParameter;
- (void)removeParameter:(int)index;

- (void)addMetaParameter;
- (void)removeMetaParameter:(int)index;

- (void)addSymbol;
- (void)removeSymbol:(int)index;

- (IBAction)importTRMData:(id)sender;
- (Phone *)makePhoneUniqueName:(Phone *)aPhone;

@end

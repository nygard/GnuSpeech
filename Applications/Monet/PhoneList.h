#import "MonetList.h"
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class MMParameter, MMPosture;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================

	Object: PhoneList
	Purpose: To provide special functionality specific to maintaining
		and accessing a list of phones.

	Import Files:
		"MMPosture.h":  The objects within this list will all be instances
			of the "Phone" class.


*/

@interface PhoneList : MonetList
{
}

- (MMPosture *)findPhone:(NSString *)phone;
- (void)addPhone:(NSString *)phone;
- (void)addPhoneObject:(MMPosture *)phone;
- (MMPosture *)binarySearchPhone:(NSString *)searchPhone index:(int *)index;

/* BrowserManager List delegate Methods */
- (void)addNewValue:(NSString *)newValue;
- (id)findByName:(NSString *)name;
- (void)changeSymbolOf:(id)aPhone to:(NSString *)name;

- (void)readDegasFileFormat:(FILE *)fp;
- (void)printDataTo:(FILE *)fp;

/* List maintenance Methods */
- (void)parameterDefaultChange:(MMParameter *)parameter to:(double)value;
- (void)symbolDefaultChange:(MMParameter *)parameter to:(double)value;

- (void)addParameter;
- (void)removeParameterAtIndex:(int)index;

- (void)addMetaParameter;
- (void)removeMetaParameterAtIndex:(int)index;

- (void)addSymbol;
- (void)removeSymbol:(int)index;

- (IBAction)importTRMData:(id)sender;
- (MMPosture *)makePhoneUniqueName:(MMPosture *)aPhone;

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;

@end

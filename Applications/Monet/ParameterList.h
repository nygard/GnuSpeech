
#import "MonetList.h"
#import "Parameter.h"
#import <stdio.h>

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface ParameterList:MonetList
{
}

- (Parameter *) findParameter: (const char *) symbol;
- (int) findParameterIndex: (const char *) symbol;
- addParameter: (const char *) newSymbol min:(float) minValue max:(float) maxValue def:(float) defaultValue;
- (double) defaultValueFromIndex:(int) index;
- (double) minValueFromIndex:(int) index;
- (double) maxValueFromIndex:(int) index;
- (void)readDegasFileFormat:(FILE *)fp;
- (void)printDataTo:(FILE *)fp;


/* BrowserManager List delegate Methods */
- (void)addNewValue:(const char *)newValue;
- findByName:(const char *)name;
- (void)changeSymbolOf:temp to:(const char *)name;


@end

#import "MonetList.h"

@class Parameter;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface ParameterList : MonetList
{
}

- (Parameter *)findParameter:(NSString *)symbol;
- (int)findParameterIndex:(NSString *)symbol;
- (void)addParameter:(NSString *)newSymbol min:(float)minValue max:(float)maxValue def:(float)defaultValue;
- (double)defaultValueFromIndex:(int)index;
- (double)minValueFromIndex:(int)index;
- (double)maxValueFromIndex:(int)index;


/* BrowserManager List delegate Methods */
- (void)addNewValue:(NSString *)newValue;
- (Parameter *)findByName:(NSString *)name;
- (void)changeSymbolOf:(Parameter *)temp to:(NSString *)name;

//- (void)readDegasFileFormat:(FILE *)fp;
//- (void)printDataTo:(FILE *)fp;

@end

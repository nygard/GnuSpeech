/*
 *    Filename:	NiftyMatrixCat.m 
 *    Created :	Wed Jan  8 23:35:26 1992 
 *    Author  :	Vince DeMarco
 *		<vince@whatnxt.cuc.ab.ca>
 *
 * LastEditDate "Tue Apr  7 21:36:37 1992"
 *
 * _Log: NiftyMatrixCat.m,v $
 * Revision 1.2  2002/12/15 05:05:09  fedor
 * Port to Openstep and GNUstep
 *
 * Revision 1.1  2002/03/21 16:49:47  rao
 * Initial import.
 *
# Revision 2.0  1992/04/08  03:43:23  vince
# Initial-Release
#
 *
 */

#import "NiftyMatrixCat.h"
#import "NiftyMatrixCell.h"

#import <AppKit/NSCell.h>

@implementation NiftyMatrix(NiftyMatrixCat)

- (void)removeCellWithStringValue:(const char *)stringValue
{
NSArray *list = [self cells];
id cellAt;
int count;
int i = 0;
NSString *strValue = [NSString stringWithCString: stringValue];

	count = [list count];
	while (i < count)
	{
		cellAt = [list objectAtIndex:i];
		if ([strValue isEqual: [cellAt stringValue]])
		{
			[self removeRow:i];
			break;
		}
		i++;
	}
	[self sizeToCells]; 
}

- (void)removeAllCells
{
NSArray *list = [self cells];
int count;
int i = 0;

	count = [list count];
	while (i < count)
	{
		[self removeRow:0];
		i++;
	}
	[self sizeToCells]; 
}

- (void)removeUnlockedCells
{
NSArray *list = [self cells];
int count;
int i = 0;

	count = [list count];
	while (i < count)
	{
		if (![[list objectAtIndex:i] locked])
			[self removeRow:i];
		i++;
	}
	[self sizeToCells]; 
}

- (void)insertCellWithStringValue:(const char *)stringValue
{
id newCell = nil;
int rows, cols, count, i = 0;
id cellAt;
NSArray *list = [self cells];
BOOL found = NO;
//NXAtom strValue = NXUniqueString(stringValue);

	count = [list count];
	while (i < count)
	{
		cellAt = [list objectAtIndex:i++];
//		if (strValue == NXUniqueString([cellAt stringValue]))
		if ([[NSString stringWithCString:stringValue] isEqualToString:[cellAt stringValue]])
		{
			found = YES;
			break;
		}
	}

	if ((count == 0) || (found != YES))
	{
		[self getNumberOfRows:&rows columns:&cols];
		[self addRow];
		newCell = [self cellAtRow:rows column:0];
		[newCell setStringValue:[NSString stringWithCString:stringValue]];
		[self sizeToCells];
	}
	[self deselectAllCells]; 
}

- (void)insertCellWithStringValue:(const char *)stringValue withTag:(int)newTag
{
id newCell = nil;
int rows, cols, count, i = 0;
id cellAt;
NSArray *list = [self cells];
BOOL found = NO;
//NXAtom strValue = NXUniqueString(stringValue);

	count = [list count];
	while (i < count)
	{
		cellAt = [list objectAtIndex:i++];
//		if (strValue == NXUniqueString([cellAt stringValue]))
		if ([[NSString stringWithCString:stringValue] isEqualToString:[cellAt stringValue]])
		{
			found = YES;
			break;
		}
	}

	if ((count == 0) || (found != YES))
	{
		[self getNumberOfRows:&rows columns:&cols];
		[self addRow];
		newCell = [self cellAtRow:rows column:0];
		[newCell setStringValue:[NSString stringWithCString:stringValue]];
		[newCell setOrderTag:newTag];
		[self sizeToCells];
	}
	[self deselectAllCells]; 
}

- (void)toggleCellWithStringValue:(const char *)stringValue
{
NSArray *list = [self cells];
id cellAt;
int count;
int i = 0;
NSString *strValue = [NSString stringWithCString: stringValue];

	count = [list count];
	while (i < count)
	{
		cellAt = [list objectAtIndex:i++];
		if ([strValue isEqual: [cellAt stringValue]])
		{
			[cellAt toggle];
			break;
		}
	} 
}

- (void)grayAllCells
{
NSArray *list = [self cells];
id cellAt;
int count;
int i = 0;

	count = [list count];
	while (i < count)
	{
		cellAt = [list objectAtIndex:i++];
		[cellAt setToggleValue:0];
	} 
}

- (void)ungrayAllCells
{
NSArray *list = [self cells];
id cellAt;
int count;
int i = 0;

	count = [list count];
	while (i < count)
	{
		cellAt = [list objectAtIndex:i++];
		[cellAt setToggleValue:1];
	} 
}

- (void)unlockAllCells
{
NSArray *list = [self cells];

/*********
    id cellAt;
    int count;
    int i = 0;
  
    count = [list count];
    while (i < count) {
	cellAt = [list objectAt:i++];
	[cellAt unlock];
    }
********/
	[list makeObjectsPerform:@selector(unlock)]; 
}

- findCellNamed:(const char *)stringValue
{
NSArray *list = [self cells];
id cellAt = nil;
int count;
int i = 0;
NSString *strValue = [NSString stringWithCString: stringValue];

	count = [list count];
	while (i < count)
	{
		cellAt = [list objectAtIndex:i++];
		if ([strValue isEqual: [cellAt stringValue]])
		{
			break;
		}
		else
		{
			cellAt = nil;
		}
	}
	return cellAt;
}

@end

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

#import <AppKit/AppKit.h>
#import "NiftyMatrixCell.h"

@implementation NiftyMatrix (NiftyMatrixCat)

- (void)removeCellWithStringValue:(NSString *)stringValue;
{
    NSArray *cells = [self cells];
    NSCell *aCell;
    int count, index;

    count = [cells count];
    for (index = 0; index < count; index++) {
        aCell = [cells objectAtIndex:index];
        if ([stringValue isEqual:[aCell stringValue]]) {
            [self removeRow:index];
            break;
        }
    }

    [self sizeToCells];
}

- (void)removeAllCells;
{
    NSArray *cells = [self cells];
    int count, index;

    count = [cells count];
    for (index = 0; index < count; index++)
        [self removeRow:0];

    [self sizeToCells];
}

- (void)insertCellWithStringValue:(NSString *)stringValue;
{
    [self insertCellWithStringValue:stringValue withTag:0];
}

- (void)insertCellWithStringValue:(NSString *)stringValue withTag:(int)tag;
{
    if ([self findCellNamed:stringValue] == nil) {
        NiftyMatrixCell *newCell = nil;
        int rows, cols;

        [self getNumberOfRows:&rows columns:&cols];
        [self addRow];
        newCell = [self cellAtRow:rows column:0];
        [newCell setStringValue:stringValue];
        [newCell setOrderTag:tag];
        [self sizeToCells];
    }

    [self deselectAllCells];
}

- (void)grayAllCells;
{
    NSArray *cells = [self cells];
    NiftyMatrixCell *aCell;
    int count, index;

    count = [cells count];
    for (index = 0; index < count; index++) {
        aCell = [cells objectAtIndex:index];
        [aCell setToggleValue:NO];
    }
}

- (void)ungrayAllCells;
{
    NSArray *cells = [self cells];
    NiftyMatrixCell *aCell;
    int count, index;

    count = [cells count];
    for (index = 0; index < count; index++) {
        aCell = [cells objectAtIndex:index];
        [aCell setToggleValue:YES];
    }
}

- (NSCell *)findCellNamed:(NSString *)stringValue;
{
    NSArray *cells = [self cells];
    NSCell *aCell = nil;
    int count, index;

    count = [cells count];
    for (index = 0; index < count; index++) {
        aCell = [cells objectAtIndex:index];
        if ([stringValue isEqual:[aCell stringValue]])
            return aCell;
    }

    return nil;
}

@end

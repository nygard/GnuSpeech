#import "SymbolList.h"

#import <Foundation/Foundation.h>
#import "NSString-Extensions.h"

#import "GSXMLFunctions.h"
#import "MMSymbol.h"

/*===========================================================================

	This Class currently adds no functionality to the List class.
	However, it is planned that this object will provide sorting functions
	to the MMCategory class.

===========================================================================*/

@implementation SymbolList

- (MMSymbol *)findSymbol:(NSString *)searchSymbol;
{
    int count, index;

    count = [self count];
    for (index = 0; index < count; index++) {
        MMSymbol *aSymbol;

        aSymbol = [self objectAtIndex:index];
        if ([[aSymbol symbol] isEqual:searchSymbol] == YES)
            return aSymbol;
    }

    return nil;
}

- (int)findSymbolIndex:(NSString *)searchSymbol;
{
    int count, index;

    count = [self count];
    for (index = 0; index < count; index++) {
        MMSymbol *aSymbol;

        aSymbol = [self objectAtIndex:index];
        if ([[aSymbol symbol] isEqual:searchSymbol] == YES)
            return index;
    }

    return -1;
}

#define DEFAULT_VALUE 100.0
#define DEFAULT_MIN     0.0
#define DEFAULT_MAX     500.0

- (void)addSymbol:(NSString *)symbol withValue:(double)newValue;
{
    MMSymbol *newSymbol;

    newSymbol = [[MMSymbol alloc] initWithSymbol:symbol];
    [newSymbol setMinimumValue:DEFAULT_MIN];
    [newSymbol setMaximumValue:DEFAULT_MAX];
    [newSymbol setDefaultValue:DEFAULT_VALUE];

    [self addObject:newSymbol];

    [newSymbol release];
}

/* BrowserManager List delegate Methods */
- (void)addNewValue:(NSString *)newValue;
{
    [self addSymbol:newValue withValue:DEFAULT_VALUE];
}

- (id)findByName:(NSString *)name;
{
    return [self findSymbol:name];
}

- (void)changeSymbolOf:(id)aSymbol to:(NSString *)name;
{
    [aSymbol setSymbol:name];
}

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
{
    int count, index;

    count = [self count];
    if (count == 0)
        return;

    [resultString indentToLevel:level];
    [resultString appendString:@"<symbols>\n"];

    for (index = 0; index < count; index++) {
        MMSymbol *aSymbol;

        aSymbol = [self objectAtIndex:index];
        [aSymbol appendXMLToString:resultString level:level+1];
    }

    [resultString indentToLevel:level];
    [resultString appendString:@"</symbols>\n"];
}

@end


#import "SymbolList.h"


/*===========================================================================

	This Class currently adds no functionality to the List class.
	However, it is planned that this object will provide sorting functions
	to the CategoryNode class.

===========================================================================*/

@implementation SymbolList

- findSymbol:(const char *)searchSymbol
{
int i;
const char *temp;


	for (i = 0; i<[self count]; i++)
	{
		temp = [[self objectAtIndex: i] symbol];
		if (strcmp(temp, searchSymbol)==0)
		{
			return [self objectAtIndex: i];
		}
	}
	return nil;
}

-(int) findSymbolIndex:(const char *) searchSymbol
{
int i;
const char *temp;


	for (i = 0; i<[self count]; i++)
	{
		temp = [[self objectAtIndex: i] symbol];
		if (strcmp(temp, searchSymbol)==0)
		{
			return i;
		}
	}
	return (-1);
}

#define DEFAULT_VALUE 100.0
#define DEFAULT_MIN     0.0
#define DEFAULT_MAX     500.0

- addSymbol:(const char *) symbol withValue:(double) newValue
{
Symbol *temp;

	temp = [[Symbol alloc] initWithSymbol: symbol];
	[temp setMinimumValue:DEFAULT_MIN];
	[temp setMaximumValue:DEFAULT_MAX];
	[temp setDefaultValue:DEFAULT_VALUE];

	[self addObject:temp];
	return temp;
}

/* BrowserManager List delegate Methods */
- (void)addNewValue:(const char *)newValue
{
	[self addSymbol: newValue withValue: DEFAULT_VALUE]; 
}

- findByName:(const char *)name
{
	return [self findSymbol:name];
}

- (void)changeSymbolOf:temp to:(const char *)name
{
	[temp setSymbol:name]; 
}

- (void)printDataTo:(FILE *)fp
{
int i;
	fprintf(fp, "Symbols\n");
	for (i = 0; i<[self count]; i++)
	{
		fprintf(fp, "%s\n", [[self objectAtIndex: i] symbol]);
		fprintf(fp, "Min: %f  Max: %f  Default: %f\n", 
			[[self objectAtIndex: i] minimumValue], [[self objectAtIndex: i] maximumValue], [[self objectAtIndex: i] defaultValue]);
		if ([[self objectAtIndex: i] comment])
			fprintf(fp,"%s\n", [[self objectAtIndex: i] comment]);
		fprintf(fp, "\n");
	}
	fprintf(fp, "\n"); 
}

@end


#import "ParameterList.h"
#import <string.h>

#define DEFAULT_MIN	100.0
#define DEFAULT_MAX	1000.0

/*===========================================================================

	This Class currently adds no functionality to the List class.
	However, it is planned that this object will provide sorting functions
	to the Phone class.

===========================================================================*/

@implementation ParameterList

- (Parameter *) findParameter: (const char *) symbol
{
int i;
const char *temp;

	for (i = 0; i< [self count]; i++)
	{
		temp = [[self objectAtIndex: i] symbol];
		if (strcmp(temp, symbol)==0)
			return [self objectAtIndex: i];
	}
	return nil;

}

- (int) findParameterIndex: (const char *) symbol
{
int i;
const char *temp;

	for (i = 0; i< [self count]; i++)
	{
		temp = [[self objectAtIndex: i] symbol];
		if (strcmp(temp, symbol)==0)
			return i;
	}
	return (-1);

}

- addParameter: (const char *) newSymbol min:(float) minValue max:(float) maxValue def:(float) defaultValue
{
Parameter *tempParameter;

	tempParameter = [[Parameter alloc] initWithSymbol:newSymbol];
	[tempParameter setMinimumValue:minValue];
	[tempParameter setMaximumValue:maxValue];
	[tempParameter setDefaultValue:defaultValue];

	[self addObject: tempParameter];

	return self;
}

- (double) defaultValueFromIndex:(int) index
{
	return [[self objectAtIndex:index] defaultValue];
}

- (double) minValueFromIndex:(int) index
{
	return [[self objectAtIndex:index] minimumValue];
}

- (double) maxValueFromIndex:(int) index
{
	return [[self objectAtIndex:index] maximumValue];
}

/* BrowserManager List delegate Methods */
- (void)addNewValue:(const char *)newValue
{
	[self addParameter: newValue min: DEFAULT_MIN max: DEFAULT_MAX def: DEFAULT_MIN]; 
}

- findByName:(const char *)name
{
	return [self findParameter:name];
}

- (void)changeSymbolOf:temp to:(const char *)name
{
	[temp setSymbol:name]; 
}

#define SYMBOL_LENGTH_MAX 12
- (void)readDegasFileFormat:(FILE *)fp
{
int i, sampleSize, number_of_phones, number_of_parameters;
float tempMin, tempMax, tempDef;
char tempSymbol[SYMBOL_LENGTH_MAX + 1];

	/* READ SAMPLE SIZE FROM FILE  */
	fread((char *)&sampleSize, sizeof(sampleSize), 1, fp);

	/* READ PHONE SYMBOLS FROM FILE  */
	fread((char *)&number_of_phones, sizeof(number_of_phones), 1, fp);
	for (i = 0; i < number_of_phones; i++)
	{
		fread(tempSymbol, SYMBOL_LENGTH_MAX + 1, 1, fp);
	}

	/* READ PARAMETERS FROM FILE  */
	fread((char *)&number_of_parameters, sizeof(number_of_parameters), 1, fp);

	for (i = 0; i < number_of_parameters; i++)
	{
		bzero(tempSymbol, SYMBOL_LENGTH_MAX + 1);

		fread(tempSymbol, SYMBOL_LENGTH_MAX +1, 1, fp);

		fread(&tempMin, sizeof(float), 1, fp);
		fread(&tempMax, sizeof(float), 1, fp);
		fread(&tempDef, sizeof(float), 1, fp);

		[self addParameter:tempSymbol min: tempMin max: tempMax def:tempDef];

	} 
}

- (void)printDataTo:(FILE *)fp
{
int i;
	fprintf(fp, "Parameters\n");
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

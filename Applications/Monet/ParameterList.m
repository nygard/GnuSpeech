#import "ParameterList.h"

#import <Foundation/Foundation.h>
#import "NSString-Extensions.h"

#import <string.h>
#import "GSXMLFunctions.h"
#import "Parameter.h"

#define DEFAULT_MIN	100.0
#define DEFAULT_MAX	1000.0

/*===========================================================================

	This Class currently adds no functionality to the List class.
	However, it is planned that this object will provide sorting functions
	to the Phone class.

===========================================================================*/

@implementation ParameterList

- (Parameter *)findParameter:(NSString *)symbol;
{
    int count, index;
    Parameter *aParameter;

    count = [self count];
    for (index = 0; index < count; index++) {
        aParameter = [self objectAtIndex:index];
        if ([[aParameter symbol] isEqual:symbol] == YES)
            return aParameter;
    }

    return nil;
}

- (int)findParameterIndex:(NSString *)symbol;
{
    int count, index;
    Parameter *aParameter;

    count = [self count];
    for (index = 0; index < count; index++) {
        aParameter = [self objectAtIndex:index];
        if ([[aParameter symbol] isEqual:symbol] == YES)
            return index;
    }

    return -1;
}

- (void)addParameter:(NSString *)newSymbol min:(float)minValue max:(float)maxValue def:(float)defaultValue;
{
    Parameter *newParameter;

    newParameter = [[Parameter alloc] initWithSymbol:newSymbol];
    [newParameter setMinimumValue:minValue];
    [newParameter setMaximumValue:maxValue];
    [newParameter setDefaultValue:defaultValue];
    [self addObject:newParameter];
    [newParameter release];
}

- (double)defaultValueFromIndex:(int)index;
{
    return [[self objectAtIndex:index] defaultValue];
}

- (double)minValueFromIndex:(int)index;
{
    return [[self objectAtIndex:index] minimumValue];
}

- (double)maxValueFromIndex:(int)index;
{
    return [[self objectAtIndex:index] maximumValue];
}

/* BrowserManager List delegate Methods */
- (void)addNewValue:(NSString *)newValue;
{
    [self addParameter:newValue min:DEFAULT_MIN max:DEFAULT_MAX def:DEFAULT_MIN];
}

- (id)findByName:(NSString *)name;
{
    return [self findParameter:name];
}

- (void)changeSymbolOf:(id)temp to:(NSString *)name;
{
    [temp setSymbol:name];
}

#define SYMBOL_LENGTH_MAX 12
- (void)readDegasFileFormat:(FILE *)fp;
{
#warning Not yet ported
#ifdef PORTING
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

        [self addParameter:tempSymbol min:tempMin max:tempMax def:tempDef];

    }
#endif
}

- (void)printDataTo:(FILE *)fp;
{
#warning Not yet ported
#ifdef PORTING
    int i;

    fprintf(fp, "Parameters\n");
    for (i = 0; i < [self count]; i++)
    {
        fprintf(fp, "%s\n", [[self objectAtIndex:i] symbol]);
        fprintf(fp, "Min: %f  Max: %f  Default: %f\n",
                [[self objectAtIndex:i] minimumValue], [[self objectAtIndex:i] maximumValue], [[self objectAtIndex:i] defaultValue]);
        if ([[self objectAtIndex:i] comment])
            fprintf(fp,"%s\n", [[self objectAtIndex:i] comment]);
        fprintf(fp, "\n");
    }
    fprintf(fp, "\n");
#endif
}

- (void)appendXMLToString:(NSMutableString *)resultString elementName:(NSString *)elementName level:(int)level;
{
    int count, index;

    count = [self count];
    if (count == 0)
        return;

    [resultString indentToLevel:level];
    [resultString appendFormat:@"<%@>\n", elementName];

    for (index = 0; index < count; index++) {
        Parameter *aParameter;

        aParameter = [self objectAtIndex:index];
        [aParameter appendXMLToString:resultString level:level+1];
    }

    [resultString indentToLevel:level];
    [resultString appendFormat:@"</%@>\n", elementName];
}

@end

#import "PhoneList.h"

#import <Foundation/Foundation.h>
#import "NSString-Extensions.h"

#import "AppController.h" // To get NXGetNamedObject()
#import "CategoryNode.h"
#import "CategoryList.h"
#import "GSXMLFunctions.h"
#import "Parameter.h"
#import "ParameterList.h"
#import "Phone.h"
#import "Symbol.h"
#import "SymbolList.h"
#import "Target.h"
#import "TargetList.h"
#import "TRMData.h"

/*===========================================================================


===========================================================================*/

@implementation PhoneList

- (Phone *)findPhone:(NSString *)phone;
{
    int count, index;
    Phone *aPhone;

    count = [self count];
    for (index = 0; index < count; index++) {
        aPhone = [self objectAtIndex:index];
        if ([[aPhone symbol] isEqual:phone] == YES)
            return aPhone;
    }

    return nil;
}

- (void)addPhone:(NSString *)phone;
{
    Phone *aPhone;
    int index;
    SymbolList *symbols;
    ParameterList *parms, *metaParms;

    //printf("Phone List adding phone \n");
    if ([self binarySearchPhone:phone index:&index])
        return;

    // TODO (2004-03-01): Try having GSApp methods for these instead.
    symbols = NXGetNamedObject(@"mainSymbolList", NSApp);
    parms = NXGetNamedObject(@"mainParameterList", NSApp);
    metaParms = NXGetNamedObject(@"mainMetaParameterList", NSApp);

    aPhone = [[Phone alloc] initWithSymbol:phone parmeters:parms metaParameters:metaParms symbols:symbols];
    [[aPhone categoryList] addNativeCategory:phone];

    [self insertObject:aPhone atIndex:index];
    [aPhone release];
}

// TODO (2004-03-01): Rename above "addPhoneWithName:", and this to "addPhone"
- (void)addPhoneObject:(Phone *)phone;
{
    int index;

    if ([self binarySearchPhone:[phone symbol] index:&index])
        return;

    [self insertObject:phone atIndex:index];
}

// TODO (2004-03-01): Rename index to indexPtr

- (Phone *)binarySearchPhone:(NSString *)searchPhone index:(int *)index;
{
    int low, high, mid;
    NSComparisonResult test;

    assert(index != NULL);

    low = 0;
    high = [self count] - 1;
    *index = 0;
    if ([self count] == 0)	   /* Empty List */
        return nil;


#warning: TODO (2004-03-01): Check to see if strcmp() returns the same type of values (positive, negative) as NSComparisonResult.
    test = [searchPhone compare:[(Phone *)[self objectAtIndex:low] symbol]];

    if (test == 0)		  /* First word in List */
        return [self objectAtIndex:low];
    else
	if (test < 0)		     /* Belongs at the head of the list */
            return nil;

    *index = 1;

    if ([self count] == 1)	   /* Only 1 item to test */
        return nil;

    *index = [self count];

    test = [searchPhone compare:[(Phone *)[self objectAtIndex:high] symbol]];
    if (test == 0)		  /* Last word in List */
    {
        *index = high;
        return [self objectAtIndex:high];
    }
    else
	if (test > 0)		     /* Belongs at the end of the list */
            return nil;

    while (1)
    {
        if ( (low + 1) == high)
        {
            *index = high;
            break;
        }

        mid = (low + high) / 2;

        test = [searchPhone compare:[(Phone *)[self objectAtIndex:mid] symbol]];
        if (test == 0)
        {
            *index = mid;
            return [self objectAtIndex:mid];
        }
        else
            if (test > 0)
                low = mid;
            else
                high = mid;
    }

    return nil;
}

- (void)addNewValue:(NSString *)newValue;
{
    [self addPhone:newValue];
}

- (id)findByName:(NSString *)name;
{
    int dummy;

    if (name == NULL)
        return nil;

    return [self binarySearchPhone:name index:&dummy];
}

- (void)changeSymbolOf:(id)aPhone to:(NSString *)name;
{
    [aPhone retain];
    [self removeObject:aPhone];
    [aPhone setSymbol:name];
    [self addPhoneObject:aPhone];
    [aPhone release];
}

#define SYMBOL_LENGTH_MAX       12
- (void)readDegasFileFormat:(FILE *)fp;
{
    int i, j, symbolIndex;
    int phoneCount, targetCount, categoryCount;

    int tempDuration, tempType, tempFixed;
    float tempProp;

    int tempDefault;
    float tempValue;

    Phone *tempPhone;
    CategoryNode *tempCategory;
    CategoryList *categories;
    SymbolList *symbols;
    ParameterList *parms, *metaParms;
    Target *tempTarget;
    char tempSymbol[SYMBOL_LENGTH_MAX + 1];
    NSString *str;

    categories = NXGetNamedObject(@"mainCategoryList", NSApp);
    symbols = NXGetNamedObject(@"mainSymbolList", NSApp);
    parms = NXGetNamedObject(@"mainParameterList", NSApp);
    metaParms = NXGetNamedObject(@"mainMetaParameterList", NSApp);

    symbolIndex = [symbols findSymbolIndex:@"duration"];

    if (symbolIndex == -1) {
        [symbols addNewValue:@"duration"];
        symbolIndex = [symbols findSymbolIndex:@"duration"];
        [self addSymbol];
    }

    /* READ # OF PHONES AND TARGETS FROM FILE  */
    fread(&phoneCount, sizeof(int), 1, fp);
    fread(&targetCount, sizeof(int), 1, fp);

    /* READ PHONE DESCRIPTION FROM FILE  */
    for (i = 0; i < phoneCount; i++) {
        fread(tempSymbol, SYMBOL_LENGTH_MAX + 1, 1, fp);
        str = [NSString stringWithASCIICString:tempSymbol];

        tempPhone = [[Phone alloc] initWithSymbol:str parmeters:parms metaParameters:metaParms symbols:symbols];
        [self addPhoneObject:tempPhone];

        /* READ SYMBOL AND DURATIONS FROM FILE  */
        fread(&tempDuration, sizeof(int), 1, fp);
        fread(&tempType, sizeof(int), 1, fp);
        fread(&tempFixed, sizeof(int), 1, fp);
        fread(&tempProp, sizeof(int), 1, fp);

        tempTarget = [[tempPhone symbolList] objectAtIndex:symbolIndex];
        [tempTarget setValue:(double) tempDuration isDefault:NO];

        /* READ TARGETS IN FROM FILE  */
        for (j = 0; j < targetCount; j++) {
            tempTarget = [[tempPhone parameterList] objectAtIndex:j];

            /* READ IN DATA FROM FILE  */
            fread(&tempDefault, sizeof(int), 1, fp);
            fread(&tempValue, sizeof(float), 1, fp);

            [tempTarget setValue:tempValue];
            [tempTarget setDefault:tempDefault];
        }

        /* READ IN CATEGORIES FROM FILE  */
        fread(&categoryCount, sizeof(int), 1, fp);
        for (j = 0; j < categoryCount; j++) {
            /* READ IN DATA FROM FILE  */
            fread(tempSymbol, SYMBOL_LENGTH_MAX + 1, 1, fp);
            str = [NSString stringWithASCIICString:tempSymbol];

            tempCategory = [categories findSymbol:str];
            if (!tempCategory) {
                [[tempPhone categoryList] addNativeCategory:str];
            } else
                [[tempPhone categoryList] addObject:tempCategory];

        }
    }
}

- (void)printDataTo:(FILE *)fp;
{
    int i, j;
    SymbolList *mainSymbolList;
    ParameterList *mainParameterList, *mainMetaParameterList;

    mainSymbolList = NXGetNamedObject(@"mainSymbolList", NSApp);
    mainParameterList = NXGetNamedObject(@"mainParameterList", NSApp);
    mainMetaParameterList = NXGetNamedObject(@"mainMetaParameterList", NSApp);

    fprintf(fp, "Phones\n");
    for (i = 0; i < [self count]; i++) {
        Phone *aPhone;
        CategoryList *aCategoryList;
        TargetList *aParameterList, *aSymbolList;

        aPhone = [self objectAtIndex:i];
        fprintf(fp, "%s\n", [[aPhone symbol] UTF8String]);
        aCategoryList = [aPhone categoryList];
        for (j = 0; j < [aCategoryList count]; j++) {
            CategoryNode *aCategory;

            aCategory = [aCategoryList objectAtIndex:j];
            if ([aCategory isNative])
                fprintf(fp, "*%s ", [[aCategory symbol] UTF8String]);
            else
                fprintf(fp, "%s ", [[aCategory symbol] UTF8String]);
        }
        fprintf(fp, "\n\n");

        aParameterList = [aPhone parameterList];
        for (j = 0; j < [aParameterList count] / 2; j++) {
            Parameter *mainParameter;
            Target *aParameter;

            aParameter = [aParameterList objectAtIndex:j];
            mainParameter = [mainParameterList objectAtIndex:j];
            if ([aParameter isDefault])
                fprintf(fp, "\t%s: *%f\t\t", [[mainParameter symbol] UTF8String], [aParameter value]);
            else
                fprintf(fp, "\t%s: %f\t\t", [[mainParameter symbol] UTF8String], [aParameter value]);

            aParameter = [aParameterList objectAtIndex:j+8];
            mainParameter = [mainParameterList objectAtIndex:j+8];
            if ([aParameter isDefault])
                fprintf(fp, "%s: *%f\n", [[mainParameter symbol] UTF8String], [aParameter value]);
            else
                fprintf(fp, "%s: %f\n", [[mainParameter symbol] UTF8String], [aParameter value]);
        }
        fprintf(fp, "\n\n");

        aSymbolList = [aPhone symbolList];
        for (j = 0; j < [aSymbolList count]; j++) {
            Symbol *mainSymbol;
            Target *aSymbol;

            aSymbol = [aSymbolList objectAtIndex:j];
            mainSymbol = [mainSymbolList objectAtIndex:j];
            if ([aSymbol isDefault])
                fprintf(fp, "%s: *%f ", [[mainSymbol symbol] UTF8String], [aSymbol value]);
            else
                fprintf(fp, "%s: %f ", [[mainSymbol symbol] UTF8String], [aSymbol value]);
        }
        fprintf(fp, "\n\n");

        if ([aPhone comment])
            fprintf(fp,"%s\n", [[aPhone comment] UTF8String]);

        fprintf(fp, "\n");
    }
    fprintf(fp, "\n");
}

- (void)parameterDefaultChange:(Parameter *)parameter to:(double)value;
{
    int i, index;
    id temp;
    ParameterList *parms, *mainMetaParameterList; // TODO (2004-03-01): Not sure of types here.

    parms = NXGetNamedObject(@"mainParameterList", NSApp);
    index = [parms indexOfObject:parameter];
    if (index != NSNotFound) {
        for (i = 0; i < [self count]; i++) {
            temp = [[[self objectAtIndex:i] parameterList] objectAtIndex:index];
            if ([temp isDefault])
                [temp setValue:value];
        }
    } else {
        mainMetaParameterList = NXGetNamedObject(@"mainMetaParameterList", NSApp);
        index = [mainMetaParameterList indexOfObject:parameter];
        if (index != NSNotFound)
            for(i = 0; i < [self count]; i++) {
                temp = [[[self objectAtIndex:i] metaParameterList] objectAtIndex:index];
                if ([temp isDefault])
                    [temp setValue:value];
            }
    }
}

- (void)symbolDefaultChange:(Parameter *)parameter to:(double)value;
{
    int i, index;
    id temp;
    SymbolList *mainSymbolList;

    mainSymbolList = NXGetNamedObject(@"mainSymbolList", NSApp);
    index = [mainSymbolList indexOfObject:parameter];
    if (index != NSNotFound) {
        for (i = 0; i < [self count]; i++) {
            temp = [[[self objectAtIndex:i] symbolList] objectAtIndex:index];
            if ([temp isDefault])
                [temp setValue:value];
        }
    }
}

- (void)addParameter;
{
    int i;
    double value;
    id temp;

    value = [[NXGetNamedObject(@"mainParameterList", NSApp) lastObject] defaultValue];
    for (i = 0; i < [self count]; i++) {
        temp = [[self objectAtIndex:i] parameterList];
        [temp addDefaultTargetWithValue:value];
    }
}

- (void)removeParameter:(int)index;
{
    int i;
    id temp;

    for (i = 0; i < [self count]; i++) {
        temp = [[self objectAtIndex:i] parameterList];
        [temp removeObjectAtIndex:index];
    }
}

- (void)addMetaParameter;
{
    int i;
    double value;
    id temp;

    value = [[NXGetNamedObject(@"mainMetaParameterList", NSApp) lastObject] defaultValue];
    for (i = 0; i < [self count]; i++) {
        temp = [[self objectAtIndex:i] metaParameterList];
        [temp addDefaultTargetWithValue:value];
    }
}

- (void)removeMetaParameter:(int)index;
{
    int i;
    id temp;

    for (i = 0; i < [self count]; i++) {
        temp = [[self objectAtIndex:i] metaParameterList];
        [temp removeObjectAtIndex:index];
    }
}

- (void)addSymbol;
{
    int i;
    id temp;

    for (i = 0; i < [self count]; i++) {
        temp = [[self objectAtIndex:i] symbolList];
        [temp addDefaultTargetWithValue:(double)0.0];
    }
}

- (void)removeSymbol:(int)index;
{
    int i;
    id temp;

    for (i = 0; i < [self count]; i++) {
        temp = [[self objectAtIndex:i] symbolList];
        [temp removeObjectAtIndex:index];
    }
}

- (IBAction)importTRMData:(id)sender;
{
    SymbolList *mainSymbolList;
    ParameterList *parms, *mainMetaParameterList;
    NSArray *types;
    TRMData *myData;
    NSArray *fnames;
    TargetList *tempTargets;
    ParameterList *mainParameterList = NXGetNamedObject(@"mainParameterList", NSApp);
    double aValue;
    int count, index;

    mainSymbolList = NXGetNamedObject(@"mainSymbolList", NSApp);
    parms = NXGetNamedObject(@"mainParameterList", NSApp);
    mainMetaParameterList = NXGetNamedObject(@"mainMetaParameterList", NSApp);

    types = [NSArray arrayWithObject:@"dunno"]; // TODO (2004-03-02): I dunno what the extension should be.

    [[NSOpenPanel openPanel] setAllowsMultipleSelection:YES];
    if ([[NSOpenPanel openPanel] runModalForTypes:types] == NSCancelButton)
        return;

    fnames = [[NSOpenPanel openPanel] filenames];

    myData = [[TRMData alloc] init];

    count = [fnames count];
    for (index = 0; index < count; index++) {
        NSString *aFilename, *filename;
        NSString *str;
        Phone *aPhone;

        aFilename = [fnames objectAtIndex:index];
        filename = [[[NSOpenPanel openPanel] directory] stringByAppendingPathComponent:aFilename];
        str = [aFilename stringByDeletingPathExtension];

        aPhone = [[[Phone alloc] initWithSymbol:str parmeters:parms metaParameters:mainMetaParameterList symbols:mainSymbolList] autorelease];
        aPhone = [self makePhoneUniqueName:aPhone];
        [self addPhoneObject:aPhone];
        [[aPhone categoryList] addNativeCategory:str];

        /*  Read the file data and store it in the object  */
        if ([myData readFromFile:filename] == NO) {
            NSBeep();
            break;
        }

        tempTargets = [aPhone parameterList];

        /*  Get the values of the needed parameters  */
        aValue = [myData glotPitch];
        [[tempTargets objectAtIndex:0] setValue:aValue
                                       isDefault:([[mainParameterList objectAtIndex:0] defaultValue] == aValue)];
        aValue = [myData glotVol];
        [[tempTargets objectAtIndex:1] setValue:aValue
                                       isDefault:([[mainParameterList objectAtIndex:1] defaultValue] == aValue)];
        aValue = [myData aspVol];
        [[tempTargets objectAtIndex:2] setValue:aValue
                                       isDefault:([[mainParameterList objectAtIndex:2] defaultValue] == aValue)];
        aValue = [myData fricVol];
        [[tempTargets objectAtIndex:3] setValue:aValue
                                       isDefault:([[mainParameterList objectAtIndex:3] defaultValue] == aValue)];
        aValue = [myData fricPos];
        [[tempTargets objectAtIndex:4] setValue:aValue
                                       isDefault:([[mainParameterList objectAtIndex:4] defaultValue] == aValue)];
        aValue = [myData fricCF];
        [[tempTargets objectAtIndex:5] setValue:aValue
                                       isDefault:([[mainParameterList objectAtIndex:5] defaultValue] == aValue)];
        aValue = [myData fricBW];
        [[tempTargets objectAtIndex:6] setValue:aValue
                                       isDefault:([[mainParameterList objectAtIndex:6] defaultValue] == aValue)];
        aValue = [myData r1];
        [[tempTargets objectAtIndex:7] setValue:aValue
                                       isDefault:([[mainParameterList objectAtIndex:7] defaultValue] == aValue)];
        aValue = [myData r2];
        [[tempTargets objectAtIndex:8] setValue:aValue
                                       isDefault:([[mainParameterList objectAtIndex:8] defaultValue] == aValue)];
        aValue = [myData r3];
        [[tempTargets objectAtIndex:9] setValue:aValue
                                       isDefault:([[mainParameterList objectAtIndex:9] defaultValue] == aValue)];
        aValue = [myData r4];
        [[tempTargets objectAtIndex:10] setValue:aValue
                                        isDefault:([[mainParameterList objectAtIndex:10] defaultValue] == aValue)];
        aValue = [myData r5];
        [[tempTargets objectAtIndex:11] setValue:aValue
                                        isDefault:([[mainParameterList objectAtIndex:11] defaultValue] == aValue)];
        aValue = [myData r6];
        [[tempTargets objectAtIndex:12] setValue:aValue
                                        isDefault:([[mainParameterList objectAtIndex:12] defaultValue] == aValue)];
        aValue = [myData r7];
        [[tempTargets objectAtIndex:13] setValue:aValue
                                        isDefault:([[mainParameterList objectAtIndex:13] defaultValue] == aValue)];
        aValue = [myData r8];
        [[tempTargets objectAtIndex:14] setValue:aValue
                                        isDefault:([[mainParameterList objectAtIndex:14] defaultValue] == aValue)];
        aValue = [myData velum];
        [[tempTargets objectAtIndex:15] setValue:aValue
                                        isDefault:([[mainParameterList objectAtIndex:15] defaultValue] == aValue)];
    }

    [myData release];
}

// TODO (2004-03-01): Make return value void, since it just returns it's parameter.
- (Phone *)makePhoneUniqueName:(Phone *)aPhone;
{
    int dummy;
    char add1, add2;
    NSString *str;

    if ([self binarySearchPhone:[aPhone symbol] index:&dummy]) {
        for (add1 = 'A'; add1 < 'Z'; add1++) {
            // Okay, this isn't terribly efficient, but it's easy:
            str = [NSString stringWithFormat:@"%@%c", [aPhone symbol], add1];
            if ([self binarySearchPhone:str index:&dummy] == nil) {
                [aPhone setSymbol:str];
                return aPhone;
            }
        }

        for (add1 = 'A'; add1 < 'Z'; add1++) {
            for (add2 = 'A'; add2 < 'Z'; add2++) {
                str = [NSString stringWithFormat:@"%@%c%c", [aPhone symbol], add1, add2];
                if ([self binarySearchPhone:str index:&dummy] == nil) {
                    [aPhone setSymbol:str];
                    return aPhone;
                }
            }
        }
    }

    return aPhone;
}

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
{
    int count, index;

    count = [self count];
    if (count == 0)
        return;

    [resultString indentToLevel:level];
    [resultString appendString:@"<phones>\n"];

    for (index = 0; index < count; index++) {
        Phone *aPhone;

        aPhone = [self objectAtIndex:index];
        [aPhone appendXMLToString:resultString level:level+1];
    }

    [resultString indentToLevel:level];
    [resultString appendString:@"</phones>\n"];
}

@end

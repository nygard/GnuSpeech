#import "PhoneList.h"

#import <Foundation/Foundation.h>
#import "NSString-Extensions.h"

#import "AppController.h" // To get NXGetNamedObject()
#import "MMCategory.h"
#import "CategoryList.h"
#import "GSXMLFunctions.h"
#import "MMParameter.h"
#import "ParameterList.h"
#import "MMPosture.h"
#import "MMSymbol.h"
#import "SymbolList.h"
#import "MMTarget.h"
#import "TargetList.h"
#import "TRMData.h"

/*===========================================================================


===========================================================================*/

@implementation PhoneList

- (MMPosture *)findPhone:(NSString *)phone;
{
    int count, index;
    MMPosture *aPosture;

    count = [self count];
    for (index = 0; index < count; index++) {
        aPosture = [self objectAtIndex:index];
        if ([[aPosture symbol] isEqual:phone])
            return aPosture;
    }

    return nil;
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
        MMPosture *aPhone;
        CategoryList *aCategoryList;
        TargetList *aParameterList, *aSymbolList;

        aPhone = [self objectAtIndex:i];
        fprintf(fp, "%s\n", [[aPhone symbol] UTF8String]);
        aCategoryList = [aPhone categoryList];
        for (j = 0; j < [aCategoryList count]; j++) {
            MMCategory *aCategory;

            aCategory = [aCategoryList objectAtIndex:j];
            if ([aCategory isNative])
                fprintf(fp, "*%s ", [[aCategory symbol] UTF8String]);
            else
                fprintf(fp, "%s ", [[aCategory symbol] UTF8String]);
        }
        fprintf(fp, "\n\n");

        aParameterList = [aPhone parameterList];
        for (j = 0; j < [aParameterList count] / 2; j++) {
            MMParameter *mainParameter;
            MMTarget *aParameter;

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
            MMSymbol *mainSymbol;
            MMTarget *aSymbol;

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

- (void)parameterDefaultChange:(MMParameter *)parameter to:(double)value;
{
    int i, index;
    id temp;
    ParameterList *mainParameterList, *mainMetaParameterList;

    mainParameterList = NXGetNamedObject(@"mainParameterList", NSApp);
    index = [mainParameterList indexOfObject:parameter];
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

- (void)symbolDefaultChange:(MMParameter *)parameter to:(double)value;
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

- (void)removeParameterAtIndex:(int)index;
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

- (void)removeMetaParameterAtIndex:(int)index;
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
#ifdef PORTING
    SymbolList *mainSymbolList;
    ParameterList *mainParameterList, *mainMetaParameterList;
    NSArray *types;
    TRMData *myData;
    NSArray *fnames;
    TargetList *tempTargets;
    double aValue;
    int count, index;

    mainSymbolList = NXGetNamedObject(@"mainSymbolList", NSApp);
    mainParameterList = NXGetNamedObject(@"mainParameterList", NSApp);
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
        MMPosture *aPhone;

        aFilename = [fnames objectAtIndex:index];
        filename = [[[NSOpenPanel openPanel] directory] stringByAppendingPathComponent:aFilename];
        str = [aFilename stringByDeletingPathExtension];

        aPhone = [[[MMPosture alloc] initWithModel:nil] autorelease];
        [aPhone setSymbol:str];
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
#endif
}

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
{
    int count, index;

    count = [self count];
    if (count == 0)
        return;

    [resultString indentToLevel:level];
    [resultString appendString:@"<postures>\n"];

    for (index = 0; index < count; index++) {
        MMPosture *aPhone;

        aPhone = [self objectAtIndex:index];
        [aPhone appendXMLToString:resultString level:level+1];
    }

    [resultString indentToLevel:level];
    [resultString appendString:@"</postures>\n"];
}

@end

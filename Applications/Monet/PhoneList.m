#import "PhoneList.h"

#import <Foundation/Foundation.h>
#import "NSString-Extensions.h"

#import "AppController.h" // To get NXGetNamedObject()
#import "MMCategory.h"
#import "CategoryList.h"
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

// 2004-03-20: This assumes that the last parameter is the one we need.
- (void)addParameter;
{
    unsigned int count, index;
    double value;
    TargetList *aTargetList;

    value = [[NXGetNamedObject(@"mainParameterList", NSApp) lastObject] defaultValue];
    count = [self count];
    for (index = 0; index < count; index++) {
        MMTarget *newTarget;

        aTargetList = [[self objectAtIndex:index] parameterTargets];
        newTarget = [[MMTarget alloc] initWithValue:value isDefault:YES];
        [aTargetList addObject:newTarget];
        [newTarget release];
    }
}

- (void)removeParameterAtIndex:(int)index;
{
    int i;
    id temp;

    for (i = 0; i < [self count]; i++) {
        temp = [[self objectAtIndex:i] parameterTargets];
        [temp removeObjectAtIndex:index];
    }
}

- (void)addMetaParameter;
{
    unsigned int count, index;
    double value;
    TargetList *aTargetList;

    value = [[NXGetNamedObject(@"mainMetaParameterList", NSApp) lastObject] defaultValue];
    count = [self count];
    for (index = 0; index < count; index++) {
        MMTarget *newTarget;

        aTargetList = [[self objectAtIndex:index] metaParameterTargets];
        newTarget = [[MMTarget alloc] initWithValue:value isDefault:YES];
        [aTargetList addObject:newTarget];
        [newTarget release];
    }
}

- (void)removeMetaParameterAtIndex:(int)index;
{
    int i;
    id temp;

    for (i = 0; i < [self count]; i++) {
        temp = [[self objectAtIndex:i] metaParameterTargets];
        [temp removeObjectAtIndex:index];
    }
}

- (void)addSymbol;
{
    unsigned int count, index;
    TargetList *aTargetList;

    // TODO (2004-03-20): The original code didn't take the default value from the main symbol list.
    count = [self count];
    for (index = 0; index < count; index++) {
        MMTarget *newTarget;

        aTargetList = [[self objectAtIndex:index] symbolList];
        newTarget = [[MMTarget alloc] initWithValue:0 isDefault:YES];
        [aTargetList addObject:newTarget];
        [newTarget release];
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

@end

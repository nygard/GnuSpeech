//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MMPosture-Compatibility.h"

#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "CategoryList.h"
#import "MMCategory.h"
#import "MModel.h"
#import "MUnarchiver.h"
#import "TargetList.h"

@implementation MMPosture (Compatibility)

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    unsigned archivedVersion;
    int count, index;
    MMCategory *temp1;
    char *c_name, *c_comment, *c_str;
    MModel *model;

    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    model = [(MUnarchiver *)aDecoder userInfo];

    //NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    archivedVersion = [aDecoder versionForClassName:NSStringFromClass([self class])];
    //NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

    [aDecoder decodeValuesOfObjCTypes:"**", &c_name, &c_comment];
    //NSLog(@"c_name: %s, c_comment: %s", c_name, c_comment);

    name = [[NSString stringWithASCIICString:c_name] retain];
    comment = [[NSString stringWithASCIICString:c_comment] retain];
    free(c_name);
    free(c_comment);

    {
        TargetList *archivedParameters;

        archivedParameters = [aDecoder decodeObject];
        parameterTargets = [[NSMutableArray alloc] init];
        [parameterTargets addObjectsFromArray:[archivedParameters allObjects]];
    }
    {
        TargetList *archivedMetaParameters;

        archivedMetaParameters = [aDecoder decodeObject];
        metaParameterTargets = [[NSMutableArray alloc] init];
        [metaParameterTargets addObjectsFromArray:[archivedMetaParameters allObjects]];
    }
    {
        TargetList *archivedSymbols;

        archivedSymbols = [aDecoder decodeObject];
        symbolTargets = [[NSMutableArray alloc] init];
        [symbolTargets addObjectsFromArray:[archivedSymbols allObjects]];
    }

    assert(categories == nil);

    [aDecoder decodeValueOfObjCType:@encode(int) at:&count];
    //NSLog(@"TOTAL Categories for %@ = %d", name, count);

    categories = [[CategoryList alloc] initWithCapacity:count];

    nativeCategory = [[MMCategory alloc] init];
    [nativeCategory setName:[self name]];
    [nativeCategory setIsNative:YES];
    [categories addObject:nativeCategory];

    for (index = 0; index < count; index++) {
        NSString *str;

        [aDecoder decodeValueOfObjCType:@encode(char *) at:&c_str];
        //NSLog(@"%d: c_str: %s", index, c_str);
        str = [NSString stringWithASCIICString:c_str];
        free(c_str);

        temp1 = [model categoryWithName:str];
        if (temp1) {
            //NSLog(@"Read category: %@", str);
            [categories addObject:temp1];
        } else {
            //NSLog(@"Read NATIVE category: %@", str);
        }
    }

    //NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);
    return self;
}

@end

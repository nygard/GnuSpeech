//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MMBooleanTerminal-Compatibility.h"

#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "MMCategory.h"
#import "MModel.h"
#import "MMPosture.h"
#import "MUnarchiver.h"

@implementation MMBooleanTerminal (Compatibility)

- (id)initWithCoder:(NSCoder *)aDecoder
{
    unsigned archivedVersion;
    char *c_string;
    MMCategory *aCategory;
    NSString *str;
    MModel *model;
    int match;

    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    model = [(MUnarchiver *)aDecoder userInfo];

    //NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    archivedVersion = [aDecoder versionForClassName:NSStringFromClass([self class])];
    //NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

    [aDecoder decodeValueOfObjCType:@encode(int) at:&match]; // Can't decode an int into a BOOL
    //NSLog(@"match: %d", match);
    shouldMatchAll = match;

    [aDecoder decodeValueOfObjCType:@encode(char *) at:&c_string];
    //NSLog(@"c_string: %s", c_string);
    str = [NSString stringWithASCIICString:c_string];
    free(c_string);

    aCategory = [model categoryWithName:str];
    if (aCategory == nil) {
        category = [[[model postureWithName:str] nativeCategory] retain];
    } else {
        category = [aCategory retain];
    }

    //NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);
    return self;
}

@end

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MonetList-Compatibility.h"

#import "NSObject-Extensions.h"

@implementation MonetList (Compatibility)

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    unsigned archivedVersion;
    int count;

    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    // TODO (2004-03-05): On second thought I don't think these should call init -- also doing so in subclasses may cause problems, multiple-initialization
    ilist = [[NSMutableArray alloc] init];

    //NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    archivedVersion = [aDecoder versionForClassName:NSStringFromClass([self class])];
    //NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);
    //NSLog(@"aDecoder version for class %@ is: %u", @"List", archivedVersion);

    count = 0;
    [aDecoder decodeValueOfObjCType:@encode(int) at:&count];
    //NSLog(@"count: %d", count);

    if (count > 0) {
        id *array;

        array = malloc(count * sizeof(id *));
        if (array == NULL) {
            NSLog(@"malloc()'ing %d id *'s failed.", count);
        } else {
            int index;

            [aDecoder decodeArrayOfObjCType:@encode(id) count:count at:array];

            for (index = 0; index < count; index++)
                [self addObject:array[index]];

            free(array);
        }
    }

    //NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);
    return self;
}

@end

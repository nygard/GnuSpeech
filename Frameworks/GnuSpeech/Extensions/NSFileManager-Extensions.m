//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "NSFileManager-Extensions.h"

#import <Foundation/Foundation.h>

@implementation NSFileManager (Extensions)

- (BOOL)createDirectoryAtPath:(NSString *)path attributes:(NSDictionary *)attributes createIntermediateDirectories:(BOOL)shouldCreateIntermediateDirectories;
{
    NSArray *pathComponents;
    unsigned int count, index;

    if (shouldCreateIntermediateDirectories == NO)
        return [self createDirectoryAtPath:path attributes:attributes];

    pathComponents = [path pathComponents];
    count = [pathComponents count];
    for (index = 1; index <= count; index++) {
        NSString *aPath;

        aPath = [NSString pathWithComponents:[pathComponents subarrayWithRange:NSMakeRange(0, index)]];
        if ([self fileExistsAtPath:aPath]) {
            //NSLog(@"path exists, skipping: %@", aPath);
            continue;
        }

        if ([self createDirectoryAtPath:aPath attributes:attributes] == NO) {
            //NSLog(@"failed to create directory: %@", aPath);
            return NO;
        }
    }

    return YES;
}

@end

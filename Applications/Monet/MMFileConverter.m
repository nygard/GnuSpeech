//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MMFileConverter.h"

#import <Foundation/Foundation.h>

NSString *MMFileConverterUpgradeException = @"MMFileConverterUpgradeException";

static NSMutableArray *_fileConverters = nil;

@implementation MMFileConverter

+ (void)registerFileConverter:(Class)aConverter;
{
    if (_fileConverters == nil)
        _fileConverters = [[NSMutableArray alloc] init];

    [_fileConverters addObject:aConverter];
}

+ (Class)fileConverterFromVersion:(int)aVersion;
{
    unsigned int count, index;
    Class aConverterClass;

    count = [_fileConverters count];
    for (index = 0; index < count; index++) {
        aConverterClass = [_fileConverters objectAtIndex:index];
        if ([aConverterClass sourceVersion] == aVersion)
            return aConverterClass;
    }

    return nil;
}

+ (int)sourceVersion;
{
    return 0;
}

+ (int)targetVersion;
{
    return 1;
}

- (int)sourceVersion;
{
    return [[self class] sourceVersion];
}

- (int)targetVersion;
{
    return [[self class] targetVersion];
}

- (BOOL)upgradeDocument:(NSXMLDocument *)document;
{
    int documentVersion;
    NSXMLNode *versionAttribute;

    NSLog(@"Trying to upgrade from version %d to %d", [self sourceVersion], [self targetVersion]);

    versionAttribute = [[document rootElement] attributeForName:@"version"];
    documentVersion = [[versionAttribute stringValue] intValue];
    NSLog(@"documentVersion: %d", documentVersion);
    if (documentVersion != [self sourceVersion])
        return NO;

    [versionAttribute setObjectValue:[NSNumber numberWithInt:[self targetVersion]]];

    return YES;
}

@end

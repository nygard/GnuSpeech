//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>

extern NSString *MMFileConverterUpgradeException;

@interface MMFileConverter : NSObject
{
}

+ (void)registerFileConverter:(Class)aConverter;
+ (Class)fileConverterFromVersion:(int)aVersion;

+ (int)sourceVersion;
+ (int)targetVersion;

- (int)sourceVersion;
- (int)targetVersion;

- (BOOL)upgradeDocument:(NSXMLDocument *)document;

@end

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSFileManager.h>

@interface NSFileManager (Extensions)

- (BOOL)createDirectoryAtPath:(NSString *)path attributes:(NSDictionary *)attributes createIntermediateDirectories:(BOOL)shouldCreateIntermediateDirectories;

@end

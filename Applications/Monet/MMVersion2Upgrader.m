//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MMVersion2Upgrader.h"

@implementation MMVersion2Upgrader

+ (void)load;
{
    [self registerFileConverter:self];
}

+ (int)sourceVersion;
{
    return 1;
}

+ (int)targetVersion;
{
    return 2;
}

@end

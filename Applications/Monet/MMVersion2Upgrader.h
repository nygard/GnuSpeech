//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MMFileConverter.h"

@interface MMVersion2Upgrader : MMFileConverter
{
}

+ (void)load;

+ (int)sourceVersion;
+ (int)targetVersion;

@end

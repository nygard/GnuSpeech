//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MMSlopeRatio-Compatibility.h"

#import "NSObject-Extensions.h"
#import "MonetList.h"

@implementation MMSlopeRatio (Compatibility)

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    unsigned archivedVersion;

    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    //NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    archivedVersion = [aDecoder versionForClassName:NSStringFromClass([self class])];
    //NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

    {
        MonetList *archivedPoints;

        archivedPoints = [aDecoder decodeObject];
        points = [[NSMutableArray alloc] init];
        [points addObjectsFromArray:[archivedPoints allObjects]];
    }
    {
        MonetList *archivedSlopes;

        archivedSlopes = [aDecoder decodeObject];
        slopes = [[NSMutableArray alloc] init];
        [slopes addObjectsFromArray:[archivedSlopes allObjects]];
    }

    //NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);
    return self;
}

@end

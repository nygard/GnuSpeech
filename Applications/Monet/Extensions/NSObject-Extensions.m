//  This file is part of SNFoundation, a personal collection of Foundation extensions.
//  Copyright (C) 2004 Steve Nygard.  All rights reserved.

#import "NSObject-Extensions.h"

#import <Foundation/Foundation.h>

@implementation NSObject (Extensions)

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    // Implemented so that subclasses don't need to know what their superclass is to correctly implement this method.
    // They can always call [super initWithCoder:] without needing to know if they are a direct subclass of NSObject.
    return self;
}

- (NSString *)shortDescription;
{
    return [NSString stringWithFormat:@"<%@>[%p]", NSStringFromClass([self class]), self];
}

@end

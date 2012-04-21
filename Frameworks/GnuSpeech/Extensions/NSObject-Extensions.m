//  This file is part of SNFoundation, a personal collection of Foundation extensions.
//  Copyright (C) 2004-2012 Steve Nygard.  All rights reserved.

#import "NSObject-Extensions.h"

@implementation NSObject (Extensions)

+ (id)objectWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
{
    return [[[[self class] alloc] initWithXMLAttributes:attributes context:context] autorelease];
}

- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
{
    // This should be implemented by subclasses, and they shouldn't call this method
    NSLog(@"Warning: %s should be implemented by subclasses.", __PRETTY_FUNCTION__);
    [self release];

    return nil;
}

- (NSString *)shortDescription;
{
    return [NSString stringWithFormat:@"<%@>[%p]", NSStringFromClass([self class]), self];
}

@end

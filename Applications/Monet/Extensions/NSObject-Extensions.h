//  This file is part of SNFoundation, a personal collection of Foundation extensions.
//  Copyright (C) 2004 Steve Nygard.  All rights reserved.

#import <Foundation/NSObject.h>

@interface NSObject (Extensions)

+ (id)objectWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;

- (id)initWithCoder:(NSCoder *)aDecoder;

- (NSString *)shortDescription;

@end

@interface NSObject (Other)
- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
@end

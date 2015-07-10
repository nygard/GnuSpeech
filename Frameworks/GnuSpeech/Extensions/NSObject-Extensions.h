//  This file is part of SNFoundation, a personal collection of Foundation extensions.
//  Copyright (C) 2004-2012 Steve Nygard.  All rights reserved.

#import <Foundation/Foundation.h>

@interface NSObject (Extensions)

- (NSString *)shortDescription;

@end

@protocol GSXMLArchiving
- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;
@end

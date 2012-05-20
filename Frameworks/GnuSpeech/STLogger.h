//  This file is part of STFoundation, a personal collection of Foundation extensions.
//  Copyright (C) 2004-2012 Steve Nygard.  All rights reserved.

#import <Foundation/Foundation.h>

@interface STLogger : NSObject

- (id)initWithOutputToPath:(NSString *)path error:(NSError **)error;

- (void)log:(NSString *)format, ...;

- (void)pushIndentation:(NSString *)str;
- (void)popIndentation;

@end

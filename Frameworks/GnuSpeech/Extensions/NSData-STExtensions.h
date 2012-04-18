//  This file is part of STFoundation.
//  Copyright (C) 2008-2012 Steve Nygard.  All rights reserved.

#import <Foundation/Foundation.h>

@interface NSMutableData (STExtensions)

- (void)appendLittleInt16:(uint16_t)value;
- (void)appendLittleInt32:(uint32_t)value;

- (void)appendBigInt16:(uint16_t)value;
- (void)appendBigInt32:(uint32_t)value;

@end

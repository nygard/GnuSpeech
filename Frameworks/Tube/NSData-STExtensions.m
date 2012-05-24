//  This file is part of STFoundation.
//  Copyright (C) 2008-2012 Steve Nygard.  All rights reserved.

#import "NSData-STExtensions.h"

@implementation NSMutableData (STExtensions)

- (void)appendLittleInt16:(uint16_t)value;
{
    uint16_t bytes;

    OSWriteLittleInt16(&bytes, 0, value);
    [self appendBytes:&bytes length:sizeof(bytes)];
}

- (void)appendLittleInt32:(uint32_t)value;
{
    uint32_t bytes;

    OSWriteLittleInt32(&bytes, 0, value);
    [self appendBytes:&bytes length:sizeof(bytes)];
}

- (void)appendBigInt16:(uint16_t)value;
{
    uint16_t bytes;

    OSWriteBigInt16(&bytes, 0, value);
    [self appendBytes:&bytes length:sizeof(bytes)];
}

- (void)appendBigInt32:(uint32_t)value;
{
    uint32_t bytes;

    OSWriteBigInt32(&bytes, 0, value);
    [self appendBytes:&bytes length:sizeof(bytes)];
}

@end

//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "TRMRingBuffer.h"

#include <stdio.h>
#include <stdlib.h>

@interface TRMRingBuffer ()
@end

#pragma mark -

@implementation TRMRingBuffer
{
    double _buffer[TRMRingBufferSize];
    int32_t _padSize;
    int32_t _fillSize; // Derived from TRMRingBufferSize and padSize.  Remains constant.

    int32_t _fillPtr;
    int32_t _emptyPtr;
    int32_t _fillCounter;

    __weak id <TRMRingBufferDelegate> _delegate;
}

- (id)initWithPadSize:(int32_t)padSize;
{
    if ((self = [super init])) {
        for (int32_t index = 0; index < TRMRingBufferSize; index++)
            _buffer[index] = 0;
        
        _padSize = padSize;
        _fillSize = TRMRingBufferSize - (2 * _padSize);
        
        _fillPtr = _padSize;
        _emptyPtr = 0;
        _fillCounter = 0;

        _delegate = nil;
    }

    return self;
}

// Fills the ring buffer with a single sample, increments the counters and pointers, and empties the buffer when full.
- (void)dataFill:(double)data;
{
    _buffer[_fillPtr] = data;

    // Increment the fill pointer, module the buffer size
    [self increment];

    // Increment the counter, and empty the buffer if full
    if (++(_fillCounter) >= _fillSize) {
        [self dataEmpty];
        // Reset the fill counter
        _fillCounter = 0;
    }
}

- (void)dataEmpty;
{
    if (self.delegate == nil) {
        // Just empty the buffer.
        fprintf(stderr, "No delegate set, should just empty it...\n");
    } else {
        [self.delegate processDataFromRingBuffer:self];
    }
}

- (void)increment;
{
    if (++(_fillPtr) >= TRMRingBufferSize)
        _fillPtr -= TRMRingBufferSize;
}

- (void)decrement;
{
    if (--(_fillPtr) < 0)
        _fillPtr += TRMRingBufferSize;
}

// Pads the buffer with zero samples, and flushes it by converting the remaining samples.
- (void)flush;
{
    // Pad end of ring buffer with zeros.
    for (int32_t index = 0; index < (_padSize * 2); index++)
        [self dataFill:0.0];

    // Flush up to fill pointer - padsize;
    [self dataEmpty];
}

+ (void)incrementIndex:(int32_t *)index;
{
    if (++(*index) >= TRMRingBufferSize)
        (*index) -= TRMRingBufferSize;
}

+ (void)decrementIndex:(int32_t *)index;
{
    if (--(*index) < 0)
        (*index) += TRMRingBufferSize;
}

#pragma mark -

- (double *)buffer;
{
    return _buffer;
}

@end


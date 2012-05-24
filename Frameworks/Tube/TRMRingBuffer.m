//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "TRMRingBuffer.h"

#include <stdio.h>
#include <stdlib.h>

@interface TRMRingBuffer ()
- (void)dataEmpty;
- (void)increment;
- (void)decrement;
@end

#pragma mark -

@implementation TRMRingBuffer
{
    double m_buffer[TRMRingBufferSize];
    int32_t m_padSize;
    int32_t m_fillSize; // Derived from TRMRingBufferSize and padSize.  Remains constant.
    
    int32_t m_fillPtr;
    int32_t m_emptyPtr;
    int32_t m_fillCounter;

    __weak id <TRMRingBufferDelegate> nonretained_delegate;
}

- (id)initWithPadSize:(int32_t)padSize;
{
    if ((self = [super init])) {
        for (int32_t index = 0; index < TRMRingBufferSize; index++)
            m_buffer[index] = 0;
        
        m_padSize = padSize;
        m_fillSize = TRMRingBufferSize - (2 * m_padSize);
        
        m_fillPtr = m_padSize;
        m_emptyPtr = 0;
        m_fillCounter = 0;

        nonretained_delegate = nil;
    }

    return self;
}

// Fills the ring buffer with a single sample, increments the counters and pointers, and empties the buffer when full.
- (void)dataFill:(double)data;
{
    m_buffer[m_fillPtr] = data;

    // Increment the fill pointer, module the buffer size
    [self increment];

    // Increment the counter, and empty the buffer if full
    if (++(m_fillCounter) >= m_fillSize) {
        [self dataEmpty];
        // Reset the fill counter
        m_fillCounter = 0;
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
    if (++(m_fillPtr) >= TRMRingBufferSize)
        m_fillPtr -= TRMRingBufferSize;
}

- (void)decrement;
{
    if (--(m_fillPtr) < 0)
        m_fillPtr += TRMRingBufferSize;
}

// Pads the buffer with zero samples, and flushes it by converting the remaining samples.
- (void)flush;
{
    // Pad end of ring buffer with zeros.
    for (int32_t index = 0; index < (m_padSize * 2); index++)
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

@synthesize delegate = nonretained_delegate;
@synthesize padSize = m_padSize;
@synthesize fillPtr = m_fillPtr;
@synthesize emptyPtr = m_emptyPtr;

- (double *)buffer;
{
    return m_buffer;
}

@end


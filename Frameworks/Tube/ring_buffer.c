//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#include <stdio.h>
#include <stdlib.h>

#include "ring_buffer.h"

TRMRingBuffer *TRMRingBufferCreate(int aPadSize)
{
    TRMRingBuffer *newRingBuffer;
    int32_t index;

    newRingBuffer = (TRMRingBuffer *)malloc(sizeof(TRMRingBuffer));
    if (newRingBuffer == NULL) {
        fprintf(stderr, "Failed to malloc() space for ring buffer.\n");
        return NULL;
    }

    for (index = 0; index < BUFFER_SIZE; index++)
        newRingBuffer->buffer[index] = 0;

    newRingBuffer->padSize = aPadSize;
    newRingBuffer->fillSize = BUFFER_SIZE - (2 * newRingBuffer->padSize);

    newRingBuffer->fillPtr = newRingBuffer->padSize;
    newRingBuffer->emptyPtr = 0;
    newRingBuffer->fillCounter = 0;

    newRingBuffer->context = NULL;
    newRingBuffer->callbackFunction = NULL;

    return newRingBuffer;
}

void TRMRingBufferFree(TRMRingBuffer *ringBuffer)
{
    if (ringBuffer == NULL)
        return;

    free(ringBuffer);
}

// Fills the ring buffer with a single sample, increments the counters and pointers, and empties the buffer when full.
void dataFill(TRMRingBuffer *ringBuffer, double data)
{
    ringBuffer->buffer[ringBuffer->fillPtr] = data;

    // Increment the fill pointer, module the buffer size
    RBIncrement(ringBuffer);

    // Increment the counter, and empty the bufferif full
    if (++(ringBuffer->fillCounter) >= ringBuffer->fillSize) {
        dataEmpty(ringBuffer);
        // Reset the fill counter
        ringBuffer->fillCounter = 0;
    }
}

void dataEmpty(TRMRingBuffer *ringBuffer)
{
    if (ringBuffer->callbackFunction == NULL) {
        // Just empty the buffer.
        fprintf(stderr, "No callback function set, should just empty it...\n");
    } else {
        (*(ringBuffer->callbackFunction))(ringBuffer, ringBuffer->context);
    }
}

void RBIncrement(TRMRingBuffer *ringBuffer)
{
    if (++(ringBuffer->fillPtr) >= BUFFER_SIZE)
        ringBuffer->fillPtr -= BUFFER_SIZE;
}

void RBDecrement(TRMRingBuffer *ringBuffer)
{
    if (--(ringBuffer->fillPtr) < 0)
        ringBuffer->fillPtr += BUFFER_SIZE;
}

// Pads the buffer with zero samples, and flushes it by converting the remaining samples.
void flushBuffer(TRMRingBuffer *ringBuffer)
{
    int32_t index;

    /*  PAD END OF RING BUFFER WITH ZEROS  */
    for (index = 0; index < (ringBuffer->padSize * 2); index++)
        dataFill(ringBuffer, 0.0);

    /*  FLUSH UP TO FILL POINTER - PADSIZE  */
    dataEmpty(ringBuffer);
}

void RBIncrementIndex(int32_t *index)
{
    if (++(*index) >= BUFFER_SIZE)
        (*index) -= BUFFER_SIZE;
}

void RBDecrementIndex(int32_t *index)
{
    if (--(*index) < 0)
        (*index) += BUFFER_SIZE;
}

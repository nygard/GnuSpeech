#include <stdio.h>
#include <stdlib.h>

#include "ring_buffer.h"

TRMRingBuffer *TRMRingBufferCreate(int aPadSize)
{
    TRMRingBuffer *newRingBuffer;
    int index;

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

    printf("Ring buffer:\n");
    printf("\tpadSize:          %d\n", newRingBuffer->padSize);
    printf("\tfillSize:         %d\n", newRingBuffer->fillSize);
    printf("\tfillPtr:          %d\n", newRingBuffer->fillPtr);
    printf("\temptyPtr:         %d\n", newRingBuffer->emptyPtr);
    printf("\tfillCounter:      %d\n", newRingBuffer->fillCounter);
    printf("\tcontext:          %p\n", newRingBuffer->context);
    printf("\tcallbackFunction: %p\n", newRingBuffer->callbackFunction);

    return newRingBuffer;
}

void TRMRingBufferFree(TRMRingBuffer *ringBuffer)
{
    if (ringBuffer == NULL)
        return;

    free(ringBuffer);
}

// Fills the ring buffer with a single sample, increments
// the counters and pointers, and empties the buffer when
// full.
void dataFill(TRMRingBuffer *ringBuffer, double data)
{
    ringBuffer->buffer[ringBuffer->fillPtr] = data;

    // Increment the fill pointer, modulo the buffer size
    RBIncrement(ringBuffer);

    // Increment the counter, and empty the buffer if full
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
    int index;

    // Pad end of ring buffer with zeros
    for (index = 0; index < (ringBuffer->padSize * 2); index++)
        dataFill(ringBuffer, 0.0);

    // Flush up to fill pointer - padsize
    dataEmpty(ringBuffer);
}

void RBIncrementIndex(int *index)
{
    if (++(*index) >= BUFFER_SIZE)
        (*index) -= BUFFER_SIZE;
}

void RBDecrementIndex(int *index)
{
    if (--(*index) < 0)
        (*index) += BUFFER_SIZE;
}

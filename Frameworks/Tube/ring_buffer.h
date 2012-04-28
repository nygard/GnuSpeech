//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#ifndef __RING_BUFFER_H
#define __RING_BUFFER_H

#define BUFFER_SIZE 1024

typedef struct _TRMRingBuffer {
    double buffer[BUFFER_SIZE];
    int32_t padSize;
    int32_t fillSize; // Derived from BUFFER_SIZE and padSize.  Remains constant.

    int32_t fillPtr;
    int32_t emptyPtr;
    int32_t fillCounter;

    void *context;
    void (*callbackFunction)(struct _TRMRingBuffer *, void *);
} TRMRingBuffer;

TRMRingBuffer *TRMRingBufferCreate(int32_t aPadSize);
void TRMRingBufferFree(TRMRingBuffer *ringBuffer);

void dataFill(TRMRingBuffer *ringBuffer, double data);
void dataEmpty(TRMRingBuffer *ringBuffer);
void RBIncrement(TRMRingBuffer *ringBuffer);
void RBDecrement(TRMRingBuffer *ringBuffer);
void flushBuffer(TRMRingBuffer *ringBuffer);

void RBIncrementIndex(int32_t *index);
void RBDecrementIndex(int32_t *index);

#endif

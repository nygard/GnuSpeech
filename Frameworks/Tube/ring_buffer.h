//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#ifndef __RING_BUFFER_H
#define __RING_BUFFER_H

#define BUFFER_SIZE 1024

typedef struct _TRMRingBuffer {
    double buffer[BUFFER_SIZE];
    int padSize;
    int fillSize; // Derived from BUFFER_SIZE and padSize.  Remains constant.

    int fillPtr;
    int emptyPtr;
    int fillCounter;

    void *context;
    void (*callbackFunction)(struct _TRMRingBuffer *, void *);
} TRMRingBuffer;

extern TRMRingBuffer *TRMRingBufferCreate(int aPadSize);
extern void TRMRingBufferFree(TRMRingBuffer *ringBuffer);

extern void dataFill(TRMRingBuffer *ringBuffer, double data);
extern void dataEmpty(TRMRingBuffer *ringBuffer);
extern void RBIncrement(TRMRingBuffer *ringBuffer);
extern void RBDecrement(TRMRingBuffer *ringBuffer);
extern void flushBuffer(TRMRingBuffer *ringBuffer);

extern void RBIncrementIndex(int *index);
extern void RBDecrementIndex(int *index);

#endif

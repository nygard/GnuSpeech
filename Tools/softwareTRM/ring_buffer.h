#ifndef __RING_BUFFER_H
#define __RING_BUFFER_H

#define BUFFER_SIZE 1024

typedef struct _TRMRingBuffer {
    double buffer[BUFFER_SIZE];
    int padSize;
    int fillSize; // Derived from BUFFER_SIZE and padSize.  Remains constant.

    int fillPtr;
    int emptyPtr;
    int length;

    void *context;
    void (*callbackFunction)(struct _TRMRingBuffer *, void *);
} TRMRingBuffer;

TRMRingBuffer *TRMRingBufferCreate(int aPadSize);
void TRMRingBufferFree(TRMRingBuffer *ringBuffer);

void dataFill(TRMRingBuffer *ringBuffer, double data);
void dataEmpty(TRMRingBuffer *ringBuffer);
inline void RBIncrement(TRMRingBuffer *ringBuffer);
inline void RBDecrement(TRMRingBuffer *ringBuffer);
void flushBuffer(TRMRingBuffer *ringBuffer);

inline int RBIncrementIndex(int index);
inline int RBDecrementIndex(int index);

#endif

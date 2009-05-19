/*******************************************************************************
 *
 *  Copyright (c) 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
 *  
 *  Contributors: Steve Nygard
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *******************************************************************************
 *
 *  ring_buffer.h
 *  Tube
 *
 *  Version: 1.0.1
 *
 ******************************************************************************/

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

TRMRingBuffer *TRMRingBufferCreate(int aPadSize);
void TRMRingBufferFree(TRMRingBuffer *ringBuffer);

void dataFill(TRMRingBuffer *ringBuffer, double data);
void dataEmpty(TRMRingBuffer *ringBuffer);
void RBIncrement(TRMRingBuffer *ringBuffer);
void RBDecrement(TRMRingBuffer *ringBuffer);
void flushBuffer(TRMRingBuffer *ringBuffer);

void RBIncrementIndex(int *index);
void RBDecrementIndex(int *index);

#endif

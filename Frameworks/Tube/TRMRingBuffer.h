//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#include <stdlib.h>

#define BUFFER_SIZE 1024

@protocol TRMRingBufferDelegate;

@interface TRMRingBuffer : NSObject

- (id)initWithPadSize:(int32_t)padSize;

@property (weak) id <TRMRingBufferDelegate> delegate;

- (void)dataFill:(double)data;
- (void)dataEmpty;
- (void)increment;
- (void)decrement;
- (void)flush;

+ (void)incrementIndex:(int32_t *)index;
+ (void)decrementIndex:(int32_t *)index;

@property (assign) int32_t padSize;
@property (assign) int32_t fillPtr;
@property (assign) int32_t emptyPtr;
@property (nonatomic, readonly) double *buffer;

@end

@protocol TRMRingBufferDelegate <NSObject>
- (void)processDataFromRingBuffer:(TRMRingBuffer *)ringBuffer;
@end

#ifndef __SAMPLE_RATE_CONVERTER_H
#define __SAMPLE_RATE_CONVERTER_H

#include <stdio.h>
#include "ring_buffer.h"

// Sample rate conversion constants
#define ZERO_CROSSINGS            13                 // Source cutoff frq
#define LP_CUTOFF                 (11.0/13.0)        // (0.846 of Nyquist)

#define N_BITS                    16
#define L_BITS                    8
#define L_RANGE                   256                  // must be 2^L_BITS
#define M_BITS                    8
#define M_RANGE                   256                  // must be 2^M_BITS
#define FRACTION_BITS             (L_BITS + M_BITS)
#define FRACTION_RANGE            65536                // must be 2^FRACTION_BITS
#define FILTER_LENGTH             (ZERO_CROSSINGS * L_RANGE)
#define FILTER_LIMIT              (FILTER_LENGTH - 1)

typedef struct _TRMSampleRateConverter {
    double sampleRateRatio;
    double h[FILTER_LENGTH];
    double deltaH[FILTER_LENGTH];
    unsigned int timeRegisterIncrement, filterIncrement, phaseIncrement;
    unsigned int timeRegister;

    TRMRingBuffer *ringBuffer; // input ring buffer

    // Temporary sample storage values
    double maximumSampleValue;
    long int numberSamples;
    FILE *tempFilePtr;
} TRMSampleRateConverter;

//TRMSampleRateConverter *TRMSampleRateConverterCreate();
//void TRMSampleRateConverterFree(TRMSampleRateConverter *converter);

void initializeConversion(TRMSampleRateConverter *sampleRateConverter, double sampleRate, double outputRate);
//void initializeFilter(TRMSampleRateConverter *sampleRateConverter);
//void resampleBuffer(struct _TRMRingBuffer *aRingBuffer, void *context);

#endif

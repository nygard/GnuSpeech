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

// FILTER_LENGTH is 13 * 256 = 3328 with these settings.

typedef struct _TRMSampleRateConverter {
    double sampleRateRatio;
    double h[FILTER_LENGTH];
    double deltaH[FILTER_LENGTH];
    unsigned int timeRegisterIncrement;
    unsigned int filterIncrement, phaseIncrement;
    unsigned int timeRegister;

    TRMRingBuffer *ringBuffer; // input ring buffer

    // Temporary sample storage values
    double maximumSampleValue;
    long int numberSamples;

    void *context;
    void (*callbackFunction)(struct _TRMSampleRateConverter *, void *, double);
} TRMSampleRateConverter;

TRMSampleRateConverter *TRMSampleRateConverterCreate(int inputSampleRate, int outputSampleRate);
void TRMSampleRateConverterFree(TRMSampleRateConverter *converter);

#endif

#include "sample_rate_converter.h"

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "structs.h"
#include "util.h"

//
// This implements the resampling algorithm described in <http://www-ccrma.stanford.edu/~jos/resample/resample.html>.
// A PDF version is available at: <http://www-ccrma.stanford.edu/~jos/resample/resample.pdf>
//


#define N_MASK                    0xFFFF0000
#define L_MASK                    0x0000FF00
#define M_MASK                    0x000000FF
#define FRACTION_MASK             0x0000FFFF

#define nValue(x)                 (((x) & N_MASK) >> FRACTION_BITS)
#define lValue(x)                 (((x) & L_MASK) >> M_BITS)
#define mValue(x)                 ((x) & M_MASK)
#define fractionValue(x)          ((x) & FRACTION_MASK)

static void initializeFilter(TRMSampleRateConverter *sampleRateConverter);
static void resampleBuffer(TRMRingBuffer *aRingBuffer, void *context);

TRMSampleRateConverter *TRMSampleRateConverterCreate(int inputSampleRate, int outputSampleRate)
{
    TRMSampleRateConverter *newSampleRateConverter;
    double roundedSampleRateRatio;
    int padSize;

    newSampleRateConverter = (TRMSampleRateConverter *)malloc(sizeof(TRMSampleRateConverter));
    if (newSampleRateConverter == NULL) {
        fprintf(stderr, "Couldn't malloc() TRMSampleRateConverter.\n");
        return NULL;
    }

    newSampleRateConverter->timeRegister = 0;
    newSampleRateConverter->maximumSampleValue = 0.0;
    newSampleRateConverter->numberSamples = 0;

    // Initialize filter impulse response
    initializeFilter(newSampleRateConverter);

    // Calculate sample rate ratio
    newSampleRateConverter->sampleRateRatio = (double)outputSampleRate / (double)inputSampleRate;
    printf("input sample rate:  %d\n", inputSampleRate);
    printf("output sample rate: %d\n", outputSampleRate);
    printf("sampleRateRatio: %g (%s)\n", newSampleRateConverter->sampleRateRatio,
           (newSampleRateConverter->sampleRateRatio > 1.0) ? "Upsampling" : "downsampling");

    // Calculate time register increment
    newSampleRateConverter->timeRegisterIncrement = (int)rint(pow(2.0, FRACTION_BITS) / newSampleRateConverter->sampleRateRatio);

    // Calculate rounded sample rate ratio
    roundedSampleRateRatio = pow(2.0, FRACTION_BITS) / (double)newSampleRateConverter->timeRegisterIncrement;

    // Calculate phase or filter increment
    if (newSampleRateConverter->sampleRateRatio >= 1.0) {
        newSampleRateConverter->filterIncrement = L_RANGE;
        newSampleRateConverter->phaseIncrement = 0.0;
    } else {
        newSampleRateConverter->filterIncrement = 0.0;
        newSampleRateConverter->phaseIncrement = (unsigned int)rint(newSampleRateConverter->sampleRateRatio * (double)FRACTION_RANGE);
    }

    // Calculate pad size
    padSize = (newSampleRateConverter->sampleRateRatio >= 1.0) ? ZERO_CROSSINGS :
        (int)((float)ZERO_CROSSINGS / roundedSampleRateRatio) + 1;

    newSampleRateConverter->ringBuffer = TRMRingBufferCreate(padSize);
    newSampleRateConverter->ringBuffer->context = newSampleRateConverter;
    newSampleRateConverter->ringBuffer->callbackFunction = resampleBuffer;

    // Initialize the temporary output file
    newSampleRateConverter->tempFilePtr = tmpfile();
    rewind(newSampleRateConverter->tempFilePtr);

    return newSampleRateConverter;
}

void TRMSampleRateConverterFree(TRMSampleRateConverter *converter)
{
    if (converter == NULL)
        return;

    if (converter->ringBuffer != NULL) {
        TRMRingBufferFree(converter->ringBuffer);
        converter->ringBuffer = NULL;
    }

    fclose(converter->tempFilePtr);
    converter->tempFilePtr = NULL;

    free(converter);
}

// Initializes filter impulse response and impulse delta values.

static void initializeFilter(TRMSampleRateConverter *sampleRateConverter)
{
    double x, IBeta;
    int i;

    // Initialize the filter impulse response
    // This is probably a sinc() function.
    sampleRateConverter->h[0] = LP_CUTOFF;
    x = M_PI / (double)L_RANGE;
    for (i = 1; i < FILTER_LENGTH; i++) {
        double y = (double)i * x;
        sampleRateConverter->h[i] = sin(y * LP_CUTOFF) / y;
    }

    // Apply a Kaiser window to the impulse response
    // See <http://en.wikipedia.org/wiki/Kaiser_window>
    // ALPHA = 1.8
    // BETA = M_PI * ALPHA
    // Looks like this is intended to be the right lobe of a kaiser window.
    IBeta = 1.0 / Izero(BETA);
    for (i = 0; i < FILTER_LENGTH; i++) {
        double temp = (double)i / FILTER_LENGTH;
        //double temp = (double)i / (FILTER_LENGTH - 1);
        //double temp = 2.0 * (double)i / (FILTER_LENGTH - 1);
        sampleRateConverter->h[i] *= Izero(BETA * sqrt(1.0 - (temp * temp))) * IBeta;
    }

    // Initialize the filter impulse response delta values
    for (i = 0; i < FILTER_LIMIT; i++)
        sampleRateConverter->deltaH[i] = sampleRateConverter->h[i+1] - sampleRateConverter->h[i];
    sampleRateConverter->deltaH[FILTER_LIMIT] = 0.0 - sampleRateConverter->h[FILTER_LIMIT];
}

// Converts available portion of the input signal to the new sampling
// rate, and outputs the samples to the sound struct.

static void resampleBuffer(TRMRingBuffer *aRingBuffer, void *context)
{
    TRMSampleRateConverter *aConverter = (TRMSampleRateConverter *)context;
    int endPtr;

    // Calculate end pointer
    endPtr = aRingBuffer->fillPtr - aRingBuffer->padSize;

    // Adjust the end pointer, if less than zero
    if (endPtr < 0)
        endPtr += BUFFER_SIZE;

    // Adjust the endpoint, if less then the empty pointer
    if (endPtr < aRingBuffer->emptyPtr)
        endPtr += BUFFER_SIZE;

    // Upsample loop (slightly more efficient than downsampling)
    if (aConverter->sampleRateRatio >= 1.0) {
        //printf("Upsampling...\n");
        while (aRingBuffer->emptyPtr < endPtr) {
            int index;
            unsigned int filterIndex;
            double output, interpolation, absoluteSampleValue;

            // Reset accumulator to zero
            output = 0.0;

            // Calculate interpolation value (static when upsampling)
            interpolation = (double)mValue(aConverter->timeRegister) / (double)M_RANGE;

            // Compute the left side of the filter convolution
            index = aRingBuffer->emptyPtr;
            for (filterIndex = lValue(aConverter->timeRegister);
                 filterIndex < FILTER_LENGTH;
                 RBDecrementIndex(&index), filterIndex += aConverter->filterIncrement) {
                output += aRingBuffer->buffer[index] * (aConverter->h[filterIndex] + aConverter->deltaH[filterIndex] * interpolation);
            }

            // Adjust values for right side calculation
            aConverter->timeRegister = ~aConverter->timeRegister;
            interpolation = (double)mValue(aConverter->timeRegister) / (double)M_RANGE;

            // Compute the right side of the filter convolution
            index = aRingBuffer->emptyPtr;
            RBIncrementIndex(&index);
            for (filterIndex = lValue(aConverter->timeRegister);
                 filterIndex < FILTER_LENGTH;
                 RBIncrementIndex(&index), filterIndex += aConverter->filterIncrement) {
                output += aRingBuffer->buffer[index] * (aConverter->h[filterIndex] + aConverter->deltaH[filterIndex] * interpolation);
            }

            // Record maximum sample value
            absoluteSampleValue = fabs(output);
            if (absoluteSampleValue > aConverter->maximumSampleValue)
                aConverter->maximumSampleValue = absoluteSampleValue;

            // Increment sample number
            aConverter->numberSamples++;

            // Output the sample to the temporary file
            fwrite((char *)&output, sizeof(output), 1, aConverter->tempFilePtr);

            // Change time register back to original form
            aConverter->timeRegister = ~aConverter->timeRegister;

            // Increment the time register
            aConverter->timeRegister += aConverter->timeRegisterIncrement;

            // Increment the empty pointer, adjusting it and end pointer
            aRingBuffer->emptyPtr += nValue(aConverter->timeRegister);

            if (aRingBuffer->emptyPtr >= BUFFER_SIZE) {
                aRingBuffer->emptyPtr -= BUFFER_SIZE;
                endPtr -= BUFFER_SIZE;
            }

            // Clear N part of time register
            aConverter->timeRegister &= (~N_MASK);
        }
    } else {
        //printf("Downsampling...\n");
        // Downsampling conversion loop
        while (aRingBuffer->emptyPtr < endPtr) {
            int index;
            unsigned int phaseIndex, impulseIndex;
            double absoluteSampleValue, output, impulse;

            // Reset accumulator to zero
            output = 0.0;

            // Compute P prime
            phaseIndex = (unsigned int)rint( ((double)fractionValue(aConverter->timeRegister)) * aConverter->sampleRateRatio);

            // Compute the left side of the filter convolution
            index = aRingBuffer->emptyPtr;
            while ((impulseIndex = (phaseIndex >> M_BITS)) < FILTER_LENGTH) {
                impulse = aConverter->h[impulseIndex] + (aConverter->deltaH[impulseIndex] *
                                                                 (((double)mValue(phaseIndex)) / (double)M_RANGE));
                output += (aRingBuffer->buffer[index] * impulse);
                RBDecrementIndex(&index);
                phaseIndex += aConverter->phaseIncrement;
            }

            // Compute P prime, adjusted for right side
            phaseIndex = (unsigned int)rint( ((double)fractionValue(~aConverter->timeRegister)) * aConverter->sampleRateRatio);

            // Compute the right side of the filter convolution
            index = aRingBuffer->emptyPtr;
            RBIncrementIndex(&index);
            while ((impulseIndex = (phaseIndex>>M_BITS)) < FILTER_LENGTH) {
                impulse = aConverter->h[impulseIndex] + (aConverter->deltaH[impulseIndex] *
                                                                 (((double)mValue(phaseIndex)) / (double)M_RANGE));
                output += (aRingBuffer->buffer[index] * impulse);
                RBIncrementIndex(&index);
                phaseIndex += aConverter->phaseIncrement;
            }

            // Record maximum sample value
            absoluteSampleValue = fabs(output);
            if (absoluteSampleValue > aConverter->maximumSampleValue)
                aConverter->maximumSampleValue = absoluteSampleValue;

            // Increment sample number
            aConverter->numberSamples++;

            // Output the sample to the temporary file
            fwrite((char *)&output, sizeof(output), 1, aConverter->tempFilePtr);

            // Increment the time register
            aConverter->timeRegister += aConverter->timeRegisterIncrement;

            // Increment the empty pointer, adjusting it and end pointer
            aRingBuffer->emptyPtr += nValue(aConverter->timeRegister);
            if (aRingBuffer->emptyPtr >= BUFFER_SIZE) {
                aRingBuffer->emptyPtr -= BUFFER_SIZE;
                endPtr -= BUFFER_SIZE;
            }

            // Clear N part of time register
            aConverter->timeRegister &= (~N_MASK);
        }
    }
}

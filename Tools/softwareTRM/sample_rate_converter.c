#include "sample_rate_converter.h"

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "structs.h"
#include "util.h"

#define N_MASK                    0xFFFF0000
#define L_MASK                    0x0000FF00
#define M_MASK                    0x000000FF
#define FRACTION_MASK             0x0000FFFF

#define nValue(x)                 (((x) & N_MASK) >> FRACTION_BITS)
#define lValue(x)                 (((x) & L_MASK) >> M_BITS)
#define mValue(x)                 ((x) & M_MASK)
#define fractionValue(x)          ((x) & FRACTION_MASK)

static void initializeFilter(TRMSampleRateConverter *sampleRateConverter);
static void resampleBuffer(struct _TRMRingBuffer *aRingBuffer, void *context);

/******************************************************************************
*
*       function:       initializeConversion
*
*       purpose:        Initializes all the sample rate conversion functions.
*
******************************************************************************/

TRMSampleRateConverter *TRMSampleRateConverterCreate(double sampleRate, double outputRate)
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
    printf("initializeConversion(), newSampleRateConverter.maximumSampleValue: %g\n", newSampleRateConverter->maximumSampleValue);

    // Initialize filter impulse response
    initializeFilter(newSampleRateConverter);

    // Calculate sample rate ratio
    newSampleRateConverter->sampleRateRatio = outputRate / sampleRate;
    printf("sampleRateRatio: %g\n", newSampleRateConverter->sampleRateRatio);

    // Calculate time register increment
    newSampleRateConverter->timeRegisterIncrement = (int)rint(pow(2.0, FRACTION_BITS) / newSampleRateConverter->sampleRateRatio);

    // Calculate rounded sample rate ratio
    roundedSampleRateRatio = pow(2.0, FRACTION_BITS) / (double)newSampleRateConverter->timeRegisterIncrement;

    // Calculate phase or filter increment
    if (newSampleRateConverter->sampleRateRatio >= 1.0) {
        newSampleRateConverter->filterIncrement = L_RANGE;
    } else {
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

/******************************************************************************
*
*       function:       initializeFilter
*
*       purpose:        Initializes filter impulse response and impulse delta
*                       values.
*
******************************************************************************/

static void initializeFilter(TRMSampleRateConverter *sampleRateConverter)
{
    double x, IBeta;
    int i;


    /*  INITIALIZE THE FILTER IMPULSE RESPONSE  */
    // This is probably a sinc() function.
    sampleRateConverter->h[0] = LP_CUTOFF;
    x = M_PI / (double)L_RANGE;
    for (i = 1; i < FILTER_LENGTH; i++) {
        double y = (double)i * x;
        sampleRateConverter->h[i] = sin(y * LP_CUTOFF) / y;
    }

    /*  APPLY A KAISER WINDOW TO THE IMPULSE RESPONSE  */
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

    /*  INITIALIZE THE FILTER IMPULSE RESPONSE DELTA VALUES  */
    for (i = 0; i < FILTER_LIMIT; i++)
        sampleRateConverter->deltaH[i] = sampleRateConverter->h[i+1] - sampleRateConverter->h[i];
    sampleRateConverter->deltaH[FILTER_LIMIT] = 0.0 - sampleRateConverter->h[FILTER_LIMIT];
}



// Converts available portion of the input signal to the new sampling
// rate, and outputs the samples to the sound struct.

static void resampleBuffer(struct _TRMRingBuffer *aRingBuffer, void *context)
{
    TRMSampleRateConverter *aConverter = (TRMSampleRateConverter *)context;
    int endPtr;

    /*  CALCULATE END POINTER  */
    endPtr = aRingBuffer->fillPtr - aRingBuffer->padSize;

    /*  ADJUST THE END POINTER, IF LESS THAN ZERO  */
    if (endPtr < 0)
        endPtr += BUFFER_SIZE;

    /*  ADJUST THE ENDPOINT, IF LESS THEN THE EMPTY POINTER  */
    if (endPtr < aRingBuffer->emptyPtr)
        endPtr += BUFFER_SIZE;

    /*  UPSAMPLE LOOP (SLIGHTLY MORE EFFICIENT THAN DOWNSAMPLING)  */
    if (aConverter->sampleRateRatio >= 1.0) {
        //printf("Upsampling...\n");
        while (aRingBuffer->emptyPtr < endPtr) {
            int index;
            unsigned int filterIndex;
            double output, interpolation, absoluteSampleValue;

            /*  RESET ACCUMULATOR TO ZERO  */
            output = 0.0;

            /*  CALCULATE INTERPOLATION VALUE (STATIC WHEN UPSAMPLING)  */
            interpolation = (double)mValue(aConverter->timeRegister) / (double)M_RANGE;

            /*  COMPUTE THE LEFT SIDE OF THE FILTER CONVOLUTION  */
            index = aRingBuffer->emptyPtr;
            for (filterIndex = lValue(aConverter->timeRegister);
                 filterIndex < FILTER_LENGTH;
                 RBDecrementIndex(&index), filterIndex += aConverter->filterIncrement) {
                output += aRingBuffer->buffer[index] * (aConverter->h[filterIndex] + aConverter->deltaH[filterIndex] * interpolation);
            }

            /*  ADJUST VALUES FOR RIGHT SIDE CALCULATION  */
            aConverter->timeRegister = ~aConverter->timeRegister;
            interpolation = (double)mValue(aConverter->timeRegister) / (double)M_RANGE;

            /*  COMPUTE THE RIGHT SIDE OF THE FILTER CONVOLUTION  */
            index = aRingBuffer->emptyPtr;
            RBIncrementIndex(&index);
            for (filterIndex = lValue(aConverter->timeRegister);
                 filterIndex < FILTER_LENGTH;
                 RBIncrementIndex(&index), filterIndex += aConverter->filterIncrement) {
                output += aRingBuffer->buffer[index] * (aConverter->h[filterIndex] + aConverter->deltaH[filterIndex] * interpolation);
            }

            /*  RECORD MAXIMUM SAMPLE VALUE  */
            absoluteSampleValue = fabs(output);
            if (absoluteSampleValue > aConverter->maximumSampleValue)
                aConverter->maximumSampleValue = absoluteSampleValue;

            /*  INCREMENT SAMPLE NUMBER  */
            aConverter->numberSamples++;

            /*  OUTPUT THE SAMPLE TO THE TEMPORARY FILE  */
            fwrite((char *)&output, sizeof(output), 1, aConverter->tempFilePtr);

            /*  CHANGE TIME REGISTER BACK TO ORIGINAL FORM  */
            aConverter->timeRegister = ~aConverter->timeRegister;

            /*  INCREMENT THE TIME REGISTER  */
            aConverter->timeRegister += aConverter->timeRegisterIncrement;

            /*  INCREMENT THE EMPTY POINTER, ADJUSTING IT AND END POINTER  */
            aRingBuffer->emptyPtr += nValue(aConverter->timeRegister);

            if (aRingBuffer->emptyPtr >= BUFFER_SIZE) {
                aRingBuffer->emptyPtr -= BUFFER_SIZE;
                endPtr -= BUFFER_SIZE;
            }

            /*  CLEAR N PART OF TIME REGISTER  */
            aConverter->timeRegister &= (~N_MASK);
        }
    } else {
        //printf("Downsampling...\n");
        /*  DOWNSAMPLING CONVERSION LOOP  */
        while (aRingBuffer->emptyPtr < endPtr) {
            int index;
            unsigned int phaseIndex, impulseIndex;
            double absoluteSampleValue, output, impulse;

            /*  RESET ACCUMULATOR TO ZERO  */
            output = 0.0;

            /*  COMPUTE P PRIME  */
            phaseIndex = (unsigned int)rint( ((double)fractionValue(aConverter->timeRegister)) * aConverter->sampleRateRatio);

            /*  COMPUTE THE LEFT SIDE OF THE FILTER CONVOLUTION  */
            index = aRingBuffer->emptyPtr;
            while ((impulseIndex = (phaseIndex >> M_BITS)) < FILTER_LENGTH) {
                impulse = aConverter->h[impulseIndex] + (aConverter->deltaH[impulseIndex] *
                                                                 (((double)mValue(phaseIndex)) / (double)M_RANGE));
                output += (aRingBuffer->buffer[index] * impulse);
                RBDecrementIndex(&index);
                phaseIndex += aConverter->phaseIncrement;
            }

            /*  COMPUTE P PRIME, ADJUSTED FOR RIGHT SIDE  */
            phaseIndex = (unsigned int)rint( ((double)fractionValue(~aConverter->timeRegister)) * aConverter->sampleRateRatio);

            /*  COMPUTE THE RIGHT SIDE OF THE FILTER CONVOLUTION  */
            index = aRingBuffer->emptyPtr;
            RBIncrementIndex(&index);
            while ((impulseIndex = (phaseIndex>>M_BITS)) < FILTER_LENGTH) {
                impulse = aConverter->h[impulseIndex] + (aConverter->deltaH[impulseIndex] *
                                                                 (((double)mValue(phaseIndex)) / (double)M_RANGE));
                output += (aRingBuffer->buffer[index] * impulse);
                RBIncrementIndex(&index);
                phaseIndex += aConverter->phaseIncrement;
            }

            /*  RECORD MAXIMUM SAMPLE VALUE  */
            absoluteSampleValue = fabs(output);
            if (absoluteSampleValue > aConverter->maximumSampleValue)
                aConverter->maximumSampleValue = absoluteSampleValue;

            /*  INCREMENT SAMPLE NUMBER  */
            aConverter->numberSamples++;

            /*  OUTPUT THE SAMPLE TO THE TEMPORARY FILE  */
            fwrite((char *)&output, sizeof(output), 1, aConverter->tempFilePtr);

            /*  INCREMENT THE TIME REGISTER  */
            aConverter->timeRegister += aConverter->timeRegisterIncrement;

            /*  INCREMENT THE EMPTY POINTER, ADJUSTING IT AND END POINTER  */
            aRingBuffer->emptyPtr += nValue(aConverter->timeRegister);
            if (aRingBuffer->emptyPtr >= BUFFER_SIZE) {
                aRingBuffer->emptyPtr -= BUFFER_SIZE;
                endPtr -= BUFFER_SIZE;
            }

            /*  CLEAR N PART OF TIME REGISTER  */
            aConverter->timeRegister &= (~N_MASK);
        }
    }
}

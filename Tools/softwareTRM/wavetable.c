#include <stdlib.h>
#include <math.h>
#include "fir.h"
#include "tube.h"
#include "wavetable.h"

#define USE_VECLIB

#ifdef USE_VECLIB
#include <vecLib/vecLib.h>
#endif

// Compile with oversampling or plain oscillator
#define OVERSAMPLING_OSCILLATOR   1

// Oversampling FIR filter characteristics
#define FIR_BETA                  .2
#define FIR_GAMMA                 .1
#define FIR_CUTOFF                .00000001

//  Glottal source oscillator table variables
#define TABLE_LENGTH              512
#define TABLE_LENGTH_F            512.0

static double mod0(double value);
static void TRMWavetableIncrementPosition(TRMWavetable *wavetable, double frequency);

// Calculates the initial glottal pulse and stores it in the wavetable, for use in the oscillator.
TRMWavetable *TRMWavetableCreate(int waveform, double tp, double tnMin, double tnMax, double sampleRate)
{
    TRMWavetable *newWavetable;
    int i;

    //printf("TRMWavetableCreate(waveform=%d, tp=%f, tnMin=%f, tnMax=%f, sampleRate=%f\n", waveform, tp, tnMin, tnMax, sampleRate);

    newWavetable = (TRMWavetable *)malloc(sizeof(TRMWavetable));
    if (newWavetable == NULL) {
        fprintf(stderr, "Failed to allocate space for new TRMWavetable in TRMWavetableCreate.\n");
        return NULL;
    }

    //  Allocate memory for wavetable
    newWavetable->wavetable = (double *)calloc(TABLE_LENGTH, sizeof(double));
    if (newWavetable->wavetable == NULL) {
        fprintf(stderr, "Failed to allocate space for wavetable in TRMWavetableCreate.\n");
        free(newWavetable);
        return NULL;
    }

    newWavetable->basicIncrement = (double)TABLE_LENGTH / sampleRate;
    newWavetable->currentPosition = 0;

    newWavetable->FIRFilter = TRMFIRFilterCreate(FIR_BETA, FIR_GAMMA, FIR_CUTOFF);
    if (newWavetable->FIRFilter == NULL) {
        fprintf(stderr, "Failed to allocate FIRFilter in TRMWavetableCreate.\n");
        free(newWavetable->wavetable);
        free(newWavetable);
        return NULL;
    }

    newWavetable->waveform = waveform;

    newWavetable->riseTime = tp;
    newWavetable->minimumFallTime = tnMin;
    newWavetable->maximumFallTime = tnMax;

    newWavetable->squares = (double *)calloc(TABLE_LENGTH, sizeof(double));
    if (newWavetable->squares == NULL) {
        fprintf(stderr, "Failed to allocate space for squares in TRMWavetableCreate.\n");
        free(newWavetable->wavetable);
        TRMFIRFilterFree(newWavetable->FIRFilter);
        free(newWavetable);
        return NULL;
    }

    newWavetable->ones = (double *)calloc(TABLE_LENGTH, sizeof(double));
    if (newWavetable->ones == NULL) {
        fprintf(stderr, "Failed to allocate space for squares in TRMWavetableCreate.\n");
        free(newWavetable->wavetable);
        TRMFIRFilterFree(newWavetable->FIRFilter);
        free(newWavetable->squares);
        free(newWavetable);
        return NULL;
    }

    for (i = 0; i < TABLE_LENGTH; i++) {
        newWavetable->squares[i] = (double)(i * i);
        newWavetable->ones[i] = 1.0;
    }

    TRMWavetableCalculate(newWavetable);

    return newWavetable;
}

void TRMWavetableFree(TRMWavetable *wavetable)
{
    if (wavetable == NULL)
        return;

    if (FIRFilter != NULL) {
        TRMFIRFilterFree(wavetable->FIRFilter);
        wavetable->FIRFilter = NULL;
    }

    if (wavetable->wavetable != NULL) {
        free(wavetable->wavetable);
        wavetable->wavetable = NULL;
    }

    if (wavetable->squares != NULL) {
        free(wavetable->squares);
        wavetable->squares = NULL;
    }

    if (wavetable->ones != NULL) {
        free(wavetable->ones);
        wavetable->ones = NULL;
    }

    free(wavetable);
}

unsigned int TRMWavetableLength(TRMWavetable *wavetable)
{
    return TABLE_LENGTH;
}

void TRMWavetableSetWaveform(TRMWavetable *wavetable, TRMWaveformType newWaveform)
{
    wavetable->waveform = newWaveform;
    TRMWavetableCalculate(wavetable);
}

void TRMWavetableSetRiseTime(TRMWavetable *wavetable, double newRiseTime)
{
    wavetable->riseTime = newRiseTime;

    if (wavetable->waveform == TRMWaveformTypePulse)
        TRMWavetableCalculate(wavetable);
}

void TRMWavetableSetMinimumFallTime(TRMWavetable *wavetable, double newMinimumFallTime)
{
    wavetable->minimumFallTime = newMinimumFallTime;

    if (wavetable->waveform == TRMWaveformTypePulse)
        TRMWavetableCalculate(wavetable);
}

void TRMWavetableSetMaximumFallTime(TRMWavetable *wavetable, double newMaximumFallTime)
{
    wavetable->maximumFallTime = newMaximumFallTime;

    if (wavetable->waveform == TRMWaveformTypePulse)
        TRMWavetableCalculate(wavetable);
}

void TRMWavetableCalculate(TRMWavetable *wavetable)
{
    unsigned int i;

    //  Calculate wave table parameters
    wavetable->tableDiv1 = rint(TABLE_LENGTH * (wavetable->riseTime / 100.0));
    wavetable->tableDivMax = rint(TABLE_LENGTH * ((wavetable->riseTime + wavetable->maximumFallTime) / 100.0));
    wavetable->tnDelta = rint(TABLE_LENGTH * ((wavetable->maximumFallTime - wavetable->minimumFallTime) / 100.0));
    wavetable->tnLength = wavetable->tableDivMax - wavetable->tableDiv1; // Therefore defaults to maximum amplitude

    //  Initialize the wavetable with either a glottal pulse or sine tone
    if (wavetable->waveform == TRMWaveformTypePulse) {
        double j;

        //  Calculate rise portion of wave table
        for (i = 0; i < wavetable->tableDiv1; i++) {
            double x = (double)i / (double)wavetable->tableDiv1;
            double x2 = x * x;
            double x3 = x2 * x;
            wavetable->wavetable[i] = (3.0 * x2) - (2.0 * x3);
        }

        //  Calculate falling portion of wave table
        for (i = wavetable->tableDiv1, j = 0; i < wavetable->tableDivMax; i++, j++) {
            double x = j / wavetable->tnLength;
            wavetable->wavetable[i] = 1.0 - (x * x);
        }

        //  Set closed portion of wave table
        for (i = wavetable->tableDivMax; i < TABLE_LENGTH; i++)
            wavetable->wavetable[i] = 0.0;
    } else {
        //  Sine wave
        for (i = 0; i < TABLE_LENGTH; i++) {
            wavetable->wavetable[i] = sin( ((double)i / (double)TABLE_LENGTH) * 2.0 * M_PI);
        }
    }
}

// Rewrites the changeable part of the glottal pulse according to the amplitude.
void TRMWavetableUpdate(TRMWavetable *wavetable, double amplitude)
{
    int i;

    // Skip if it's not a pulse type, since it wouldn't make sense.  Handled in calling code.
    if (wavetable->waveform != TRMWaveformTypePulse)
        return;

    //printf("TRMWavetableUpdate(self=%p, amplitude=%f)\n", wavetable, amplitude);
    //  Calculate new closure point, based on amplitude
    double newDiv2 = wavetable->tableDivMax - rint(amplitude * wavetable->tnDelta);
    double newTnLength = newDiv2 - wavetable->tableDiv1;

    //  Recalculate the falling portion of the glottal pulse
#ifdef USE_VECLIB
    {
        double aj[TABLE_LENGTH];
        double scale = 1.0 / (newTnLength * newTnLength);
        int len;

        len = newTnLength;

        //printf("wavetable update, scale: %g, squares: %p, aj: %p, len: %d\n", scale, wavetable->squares, aj, len);
        vsmulD(wavetable->squares, 1, &scale, aj, 1, len);
        vsubD(aj, 1, wavetable->ones, 1, &wavetable->wavetable[wavetable->tableDiv1], 1, len); // The docs seem to be wrong about which one gets subtracted...
    }
#else
    {
        double j;

        for (i = wavetable->tableDiv1, j = 0.0; i < newDiv2; i++, j++) {
            double x = j / newTnLength;
            wavetable->wavetable[i] = 1.0 - (x * x);
        }
    }

#endif

    //  Fill in with closed portion of glottal pulse
#if 1
    for (i = newDiv2; i < wavetable->tableDivMax; i++)
        wavetable->wavetable[i] = 0.0;
#else
    i = newDiv2;
    if (wavetable->tableDivMax > i)
        memset(&wavetable[i], 0, (wavetable->tableDivMax - i) * sizeof(double)); // This seems to be crashy... possibly with 0 sizes?
#endif
}


#if OVERSAMPLING_OSCILLATOR
// A 2X oversampling interpolating wavetable oscillator.
double TRMWavetableOscillator(TRMWavetable *wavetable, double frequency)
{
    int i, lowerPosition, upperPosition;
    double interpolatedValue, output;
    double lowerValue, upperValue;

    for (i = 0; i < 2; i++) {
        //  First increment the table position, depending on frequency
        TRMWavetableIncrementPosition(wavetable, frequency / 2.0);

        //  Find surrounding integer table positions
        lowerPosition = (int)wavetable->currentPosition;
        upperPosition = (lowerPosition + 1) % TABLE_LENGTH;

        lowerValue = wavetable->wavetable[lowerPosition];
        upperValue = wavetable->wavetable[upperPosition];

        //  Calculate interpolated table value
        interpolatedValue = lowerValue + (wavetable->currentPosition - lowerPosition) * (upperValue - lowerValue);

        //  Put value through FIR filter
        output = FIRFilter(wavetable->FIRFilter, interpolatedValue, i);
    }

    //  Since we decimate, take only the second output value
    return output;
}
#else
// Plain oscillator
double TRMWavetableOscillator(TRMWavetable *wavetable, double frequency)
{
    int lowerPosition, upperPosition;
    double lowerValue, upperValue;

    //  First increment the table position, depending on frequency
    TRMWavetableIncrementPosition(wavetable, frequency);

    //  Find surrounding integer table positions
    lowerPosition = (int)wavetable->currentPosition;
    upperPosition = (lowerPosition + 1) % TABLE_LENGTH;

    lowerValue = wavetable->wavetable[lowerPosition];
    upperValue = wavetable->wavetable[upperPosition];

    //  Return interpolated table value
    return lowerValue + ((wavetable->currentPosition - lowerPosition) * (upperValue - lowerValue));
}
#endif

// Returns the modulus of 'value', keeping it in the range 0 <= value < TABLE_LENGTH.
static double mod0(double value)
{
    if (value >= TABLE_LENGTH_F)
        value -= TABLE_LENGTH_F;

    return value;
}

// Increments the position in the wavetable according to the desired frequency.
static void TRMWavetableIncrementPosition(TRMWavetable *wavetable, double frequency)
{
    wavetable->currentPosition = mod0(wavetable->currentPosition + (frequency * wavetable->basicIncrement));
}

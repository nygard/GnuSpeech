#include <stdlib.h>
#include <math.h>
#include "fir.h"
#include "tube.h"
#include "wavetable.h"

// Wavetable
double *wavetable;
int tableDiv1;
int tableDiv2;
double tnLength;
double tnDelta;

double basicIncrement;
double currentPosition;

double mod0(double value);
void incrementTablePosition(double frequency);

/******************************************************************************
*
*       function:       initializeWavetable
*
*       purpose:        Calculates the initial glottal pulse and stores it
*                       in the wavetable, for use in the oscillator.
*
*       arguments:      none
*
*       internal
*       functions:      none
*
*       library
*       functions:      calloc, rint
*
******************************************************************************/

void initializeWavetable(struct _TRMInputParameters *inputParameters)
{
    int i, j;


    /*  ALLOCATE MEMORY FOR WAVETABLE  */
    wavetable = (double *)calloc(TABLE_LENGTH, sizeof(double));

    /*  CALCULATE WAVE TABLE PARAMETERS  */
    tableDiv1 = rint(TABLE_LENGTH * (inputParameters->tp / 100.0));
    tableDiv2 = rint(TABLE_LENGTH * ((inputParameters->tp + inputParameters->tnMax) / 100.0));
    tnLength = tableDiv2 - tableDiv1;
    tnDelta = rint(TABLE_LENGTH * ((inputParameters->tnMax - inputParameters->tnMin) / 100.0));
    basicIncrement = (double)TABLE_LENGTH / (double)sampleRate;
    currentPosition = 0;

    /*  INITIALIZE THE WAVETABLE WITH EITHER A GLOTTAL PULSE OR SINE TONE  */
    if (inputParameters->waveform == PULSE) {
        /*  CALCULATE RISE PORTION OF WAVE TABLE  */
        for (i = 0; i < tableDiv1; i++) {
            double x = (double)i / (double)tableDiv1;
            double x2 = x * x;
            double x3 = x2 * x;
            wavetable[i] = (3.0 * x2) - (2.0 * x3);
        }

        /*  CALCULATE FALL PORTION OF WAVE TABLE  */
        for (i = tableDiv1, j = 0; i < tableDiv2; i++, j++) {
            double x = (double)j / tnLength;
            wavetable[i] = 1.0 - (x * x);
        }

        /*  SET CLOSED PORTION OF WAVE TABLE  */
        for (i = tableDiv2; i < TABLE_LENGTH; i++)
            wavetable[i] = 0.0;
    } else {
        /*  SINE WAVE  */
        for (i = 0; i < TABLE_LENGTH; i++) {
            wavetable[i] = sin( ((double)i/(double)TABLE_LENGTH) * 2.0 * PI );
        }
    }
}



/******************************************************************************
*
*       function:       updateWavetable
*
*       purpose:        Rewrites the changeable part of the glottal pulse
*                       according to the amplitude.
*
*       arguments:      amplitude
*
*       internal
*       functions:      none
*
*       library
*       functions:      rint
*
******************************************************************************/

void updateWavetable(double amplitude)
{
    int i, j;

    /*  CALCULATE NEW CLOSURE POINT, BASED ON AMPLITUDE  */
    double newDiv2 = tableDiv2 - rint(amplitude * tnDelta);
    double newTnLength = newDiv2 - tableDiv1;

    /*  RECALCULATE THE FALLING PORTION OF THE GLOTTAL PULSE  */
    for (i = tableDiv1, j = 0; i < newDiv2; i++, j++) {
        double x = (double)j / newTnLength;
        wavetable[i] = 1.0 - (x * x);
    }

    /*  FILL IN WITH CLOSED PORTION OF GLOTTAL PULSE  */
    for (i = newDiv2; i < tableDiv2; i++)
        wavetable[i] = 0.0;
}



/******************************************************************************
*
*       function:       mod0
*
*       purpose:        Returns the modulus of 'value', keeping it in the
*                       range 0 -> TABLE_MODULUS.
*
*       arguments:      value
*
*       internal
*       functions:      none
*
*       library
*       functions:      none
*
******************************************************************************/

double mod0(double value)
{
    if (value > TABLE_MODULUS)
        value -= TABLE_LENGTH;

    return value;
}



/******************************************************************************
*
*       function:       incrementTablePosition
*
*       purpose:        Increments the position in the wavetable according to
*                       the desired frequency.
*
*       arguments:      frequency
*
*       internal
*       functions:      mod0
*
*       library
*       functions:      none
*
******************************************************************************/

void incrementTablePosition(double frequency)
{
    currentPosition = mod0(currentPosition + (frequency * basicIncrement));
}



/******************************************************************************
*
*       function:       oscillator
*
*       purpose:        Is a 2X oversampling interpolating wavetable
*                       oscillator.
*
*       arguments:      frequency
*
*       internal
*       functions:      incrementTablePosition, mod0, FIRFilter
*
*       library
*       functions:      none
*
******************************************************************************/

#if OVERSAMPLING_OSCILLATOR
double oscillator(double frequency)  /*  2X OVERSAMPLING OSCILLATOR  */
{
    int i, lowerPosition, upperPosition;
    double interpolatedValue, output;


    for (i = 0; i < 2; i++) {
        /*  FIRST INCREMENT THE TABLE POSITION, DEPENDING ON FREQUENCY  */
        incrementTablePosition(frequency/2.0);

        /*  FIND SURROUNDING INTEGER TABLE POSITIONS  */
        lowerPosition = (int)currentPosition;
        upperPosition = mod0(lowerPosition + 1);

        /*  CALCULATE INTERPOLATED TABLE VALUE  */
        interpolatedValue = (wavetable[lowerPosition] +
                             ((currentPosition - lowerPosition) *
                              (wavetable[upperPosition] -
                               wavetable[lowerPosition])));

        /*  PUT VALUE THROUGH FIR FILTER  */
        output = FIRFilter(interpolatedValue, i);
    }

    /*  SINCE WE DECIMATE, TAKE ONLY THE SECOND OUTPUT VALUE  */
    return (output);
}
#else
double oscillator(double frequency)  /*  PLAIN OSCILLATOR  */
{
    int lowerPosition, upperPosition;


    /*  FIRST INCREMENT THE TABLE POSITION, DEPENDING ON FREQUENCY  */
    incrementTablePosition(frequency);

    /*  FIND SURROUNDING INTEGER TABLE POSITIONS  */
    lowerPosition = (int)currentPosition;
    upperPosition = mod0(lowerPosition + 1);

    /*  RETURN INTERPOLATED TABLE VALUE  */
    return (wavetable[lowerPosition] +
            ((currentPosition - lowerPosition) *
             (wavetable[upperPosition] - wavetable[lowerPosition])));
}
#endif

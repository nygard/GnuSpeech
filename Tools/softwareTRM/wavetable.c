#include <stdlib.h>
#include <math.h>
#include "fir.h"
#include "tube.h"
#include "wavetable.h"

//  Glottal source oscillator table variables
#define TABLE_LENGTH              512
#define TABLE_MODULUS             (TABLE_LENGTH-1)

double *wavetable;
int tableDiv1;
int tableDiv2;
double tnLength;
double tnDelta;

double basicIncrement;
double currentPosition;

static double mod0(double value);
static void incrementTablePosition(double frequency);

// Calculates the initial glottal pulse and stores it in the wavetable, for use in the oscillator.
void initializeWavetable(int waveform, double tp, double tnMin, double tnMax)
{
    int i, j;


    //  Allocate memory for wavetable
    wavetable = (double *)calloc(TABLE_LENGTH, sizeof(double));

    //  Calculate wave table parameters
    tableDiv1 = rint(TABLE_LENGTH * (tp / 100.0));
    tableDiv2 = rint(TABLE_LENGTH * ((tp + tnMax) / 100.0));
    tnLength = tableDiv2 - tableDiv1;
    tnDelta = rint(TABLE_LENGTH * ((tnMax - tnMin) / 100.0));
    basicIncrement = (double)TABLE_LENGTH / (double)sampleRate;
    currentPosition = 0;

    //  Initialize the wavetable with either a glottal pulse or sine tone
    if (waveform == PULSE) {
        //  Calculate rise portion of wave table
        for (i = 0; i < tableDiv1; i++) {
            double x = (double)i / (double)tableDiv1;
            double x2 = x * x;
            double x3 = x2 * x;
            wavetable[i] = (3.0 * x2) - (2.0 * x3);
        }

        //  Calculate fall portion of wave table
        for (i = tableDiv1, j = 0; i < tableDiv2; i++, j++) {
            double x = (double)j / tnLength;
            wavetable[i] = 1.0 - (x * x);
        }

        //  Set closed portion of wave table
        for (i = tableDiv2; i < TABLE_LENGTH; i++)
            wavetable[i] = 0.0;
    } else {
        //  Sine wave
        for (i = 0; i < TABLE_LENGTH; i++) {
            wavetable[i] = sin( ((double)i/(double)TABLE_LENGTH) * 2.0 * PI );
        }
    }
}



// Rewrites the changeable part of the glottal pulse according to the amplitude.
void updateWavetable(double amplitude)
{
    int i, j;

    //  Calculate new closure point, based on amplitude
    double newDiv2 = tableDiv2 - rint(amplitude * tnDelta);
    double newTnLength = newDiv2 - tableDiv1;

    //  Recalculate the falling portion of the glottal pulse
    for (i = tableDiv1, j = 0; i < newDiv2; i++, j++) {
        double x = (double)j / newTnLength;
        wavetable[i] = 1.0 - (x * x);
    }

    //  Fill in with closed portion of glottal pulse
    for (i = newDiv2; i < tableDiv2; i++)
        wavetable[i] = 0.0;
}



// Returns the modulus of 'value', keeping it in the range 0 -> TABLE_MODULUS.
double mod0(double value)
{
    if (value > TABLE_MODULUS)
        value -= TABLE_LENGTH;

    return value;
}



// Increments the position in the wavetable according to the desired frequency.
void incrementTablePosition(double frequency)
{
    currentPosition = mod0(currentPosition + (frequency * basicIncrement));
}



// Is a 2X oversampling interpolating wavetable oscillator.

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

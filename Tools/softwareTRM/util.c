#include <math.h>
#include "util.h"

// Range of all volume controls
#define VOL_MAX                   60

// Pitch variables
#define PITCH_BASE                220.0
#define PITCH_OFFSET              3.0           //  Middle C = 0
#define LOG_FACTOR                3.32193


/******************************************************************************
*
*       function:       speedOfSound
*
*       purpose:        Returns the speed of sound according to the value of
*                       the temperature (in Celsius degrees).
*
*       arguments:      temperature
*
*       internal
*       functions:      none
*
*       library
*       functions:      none
*
******************************************************************************/

double speedOfSound(double temperature)
{
    return 331.4 + (0.6 * temperature);
}

/******************************************************************************
*
*       function:       amplitude
*
*       purpose:        Converts dB value to amplitude value.  (Range of 0.0 - 1.0)
*
******************************************************************************/

double amplitude(double decibelLevel)
{
    // Convert 0-60 range to -60-0 range
    decibelLevel -= VOL_MAX;

    // If -60 or less, return amplitude of 0
    if (decibelLevel <= -VOL_MAX)
        return 0.0;

    // If 0 or greater, return amplitude of 1
    if (decibelLevel >= 0.0)
        return 1.0;

    // Return inverse log value
    return pow(10.0, (decibelLevel / 20.0));
}



/******************************************************************************
*
*       function:       frequency
*
*       purpose:        Converts a given pitch (0 = middle C) to the
*                       corresponding frequency.
*
*       internal
*       functions:      none
*
*       library
*       functions:      pow
*
******************************************************************************/

double frequency(double pitch)
{
    return PITCH_BASE * exp2((pitch + PITCH_OFFSET) / 12.0); // This is slightly faster than pow(2.0, )
    //return PITCH_BASE * pow(2.0, (pitch + PITCH_OFFSET) / 12.0);
}



/******************************************************************************
*
*       function:       Izero
*
*       purpose:        Returns the value for the modified Bessel function of
*                       the first kind, order 0, as a double.
*
*                       That is, it computes the sum of (A^k)/((k!)^2), where A = (1/4)x^2, k = 0, 1, 2, ...
*
*       reference:      <http://en.wikipedia.org/wiki/Bessel_function>
*                       <http://mathworld.wolfram.com/ModifiedBesselFunctionoftheFirstKind.html>
*
******************************************************************************/

#define IzeroEPSILON              1E-21

double Izero(double x)
{
    double sum, A, Ak, k, denominator, u;

    Ak = A = x * x / 4.0;
    k = 2.0;
    denominator = 1.0;

    sum = 1.0 + A; // The first two terms

    do {
        Ak *= A;
        denominator *= k * k;
        k += 1.0;
        u = Ak / denominator;
        sum += u;
    } while (u >= (IzeroEPSILON * sum));

    return sum;
}



/******************************************************************************
*
*       function:       noise
*
*       purpose:        Returns one value of a random sequence in the
*                       range of [-0.5, 0.5].
*
******************************************************************************/

// Constants for noise generator
#define FACTOR                    377.0
#define INITIAL_SEED              0.7892347

double noise(void)
{
    static double seed = INITIAL_SEED;
    double product;

    product = seed * FACTOR;
    seed = product - (int)product;

    return seed - 0.5;
}



/******************************************************************************
*
*       function:       noiseFilter
*
*       purpose:        One-zero lowpass filter.
*
* Difference equation:  y(n) = x(n) + x(n-1)
* "The Simplest Low-Pass filter" <http://ccrma.stanford.edu/~jos/filters/Definition_Simplest_Low_Pass.html>
*
******************************************************************************/

double noiseFilter(double input)
{
    static double previous = 0.0;
    double output;

    output = input + previous;
    previous = input;

    return output;
}

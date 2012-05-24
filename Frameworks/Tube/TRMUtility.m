//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#include "TRMUtility.h"

#include <math.h>

#define IzeroEPSILON              1E-21

// Range of all volume controls
#define VOL_MAX                   60

// Pitch variables
#define PITCH_BASE                220.0
#define PITCH_OFFSET              3           // Middle C = 0
#define LOG_FACTOR                3.32193

// Returns the speed of sound according to the value of the temperature (in Celsius degrees).
// <http://en.wikipedia.org/wiki/Speed_of_sound> shows 331.3 + (0.606 * temperatureCelsius).
double speedOfSound_mps(double temperatureCelsius)
{
    return 331.4 + (0.6 * temperatureCelsius);
}

// Converts dB value (0-60) to amplitude value (0-1)
double amplitude(double decibelLevel)
{
    // Convert 0-60 range to -60-0 range
    decibelLevel -= VOL_MAX;

    // If -60 or less, return amplitude of 0
    if (decibelLevel <= (-VOL_MAX))
        return 0.0;

    // If 0 or greater, return amplitude of 1
    if (decibelLevel >= 0.0)
        return 1.0;

    // otherwise return inverse log value
    return pow(10.0, (decibelLevel / 20.0));
}

// Converts a given pitch (0 = middle C) to the corresponding frequency.
double frequency(double pitch)
{
    return PITCH_BASE * pow(2.0, (((double)(pitch + PITCH_OFFSET)) / 12.0));
}

// Returns the value for the modified Bessel function of the first kind, order 0, as a double.
double Izero(double x)
{
    double sum   = 1;
    double u     = 1;
    double n     = 1;
    double halfx = x / 2.0;

    do {
        double temp = halfx / n;
        n += 1;
        temp *= temp;
        u *= temp;
        sum += u;
    } while (u >= (IzeroEPSILON * sum));

    return sum;
}

#pragma mark - Noise Generator

// Constants for noise generator
static const double kNoise_Factor = 377.0;
static const double kNoise_InitialSeed = 0.7892347;

void TRMNoiseGenerator_Init(TRMNoiseGenerator *generator)
{
    generator->seed = kNoise_InitialSeed;
}

// Returns one value of a random sequence.
double TRMNoiseGenerator_GetSample(TRMNoiseGenerator *generator)
{
    double product = generator->seed * kNoise_Factor;
    generator->seed = product - (int)product;
    return (generator->seed - 0.5);
}

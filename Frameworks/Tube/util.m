//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#include <math.h>
#include <stdint.h>
#include "util.h"

#define IzeroEPSILON              1E-21

// Range of all volume controls
#define VOL_MAX                   60

// Pitch variables
#define PITCH_BASE                220.0
#define PITCH_OFFSET              3           // Middle C = 0
#define LOG_FACTOR                3.32193

// Returns the speed of sound according to the value of the temperature (in Celsius degrees).
double speedOfSound(double temperature)
{
    return 331.4 + (0.6 * temperature);
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
    double sum, u, halfx, temp;
    int32_t n;


    sum = u = n = 1;
    halfx = x / 2.0;

    do {
        temp = halfx / (double)n;
        n += 1;
        temp *= temp;
        u *= temp;
        sum += u;
    } while (u >= (IzeroEPSILON * sum));

    return sum;
}

#pragma mark - Noise Generator

// Constants for noise generator
#define FACTOR                    377.0
#define INITIAL_SEED              0.7892347

// Returns one value of a random sequence.
double noise(void)
{
    static double seed = INITIAL_SEED;

    double product = seed * FACTOR;
    seed = product - (int)product;
    return (seed - 0.5);
}

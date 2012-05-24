//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#ifndef __UTIL_H
#define __UTIL_H

double speedOfSound_mps(double temperatureCelsius);
double amplitude(double decibelLevel);
double frequency(double pitch);
double Izero(double x);

typedef struct {
    double seed;
} TRMNoiseGenerator;

void TRMNoiseGenerator_Init(TRMNoiseGenerator *generator);
double TRMNoiseGenerator_GetSample(TRMNoiseGenerator *generator);

#endif

//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#ifndef __UTIL_H
#define __UTIL_H

#define BETA                      5.658        // Kaiser window parameters
#define IzeroEPSILON              1E-21

extern double speedOfSound(double temperature);
extern double amplitude(double decibelLevel);
extern double frequency(double pitch);
extern double Izero(double x);
extern double noise(void);
extern double noiseFilter(double input);

#endif

#ifndef __UTIL_H
#define __UTIL_H

#define BETA                      5.658        /*  kaiser window parameters  */
#define IzeroEPSILON              1E-21

double speedOfSound(double temperature);
double amplitude(double decibelLevel);
double frequency(double pitch);
double Izero(double x);
double noise(void);
double noiseFilter(double input);

#endif

#ifndef __TUBE_H
#define __TUBE_H

#include <stdio.h> // For FILE

/*  FUNCTION RETURN CONSTANTS  */
#define ERROR                     (-1)
#define SUCCESS                   0

/*  OROPHARYNX REGIONS  */
#define R1                        0      /*  S1  */
#define R2                        1      /*  S2  */
#define R3                        2      /*  S3  */
#define R4                        3      /*  S4 & S5  */
#define R5                        4      /*  S6 & S7  */
#define R6                        5      /*  S8  */
#define R7                        6      /*  S9  */
#define R8                        7      /*  S10  */
#define TOTAL_REGIONS             8

/*  NASAL TRACT SECTIONS  */
#define N1                        0
#define VELUM                     N1
#define N2                        1
#define N3                        2
#define N4                        3
#define N5                        4
#define N6                        5
#define TOTAL_NASAL_SECTIONS      6

/*  WAVEFORM TYPES  */
#define PULSE                     0
#define SINE                      1

extern double maximumSampleValue;

extern float outputRate;
extern float controlRate;

extern int waveform;
extern double tp;
extern double tnMin;
extern double tnMax;
extern double breathiness;

extern double length;
extern double temperature;
extern double lossFactor;

extern double apScale;
extern double mouthCoef;
extern double noseCoef;

extern double noseRadius[TOTAL_NASAL_SECTIONS];

extern double throatCutoff;
extern double throatVol;

extern int modulation;
extern double mixOffset;


extern int controlPeriod;
extern int sampleRate;
extern double actualTubeLength;





extern FILE  *tempFilePtr;
extern long int numberSamples;


int initializeSynthesizer(void);
void synthesize(void);
void flushBuffer(void);
double amplitude(double decibelLevel);



#endif

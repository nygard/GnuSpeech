#ifndef __STRUCTS_H
#define __STRUCTS_H

#include <stdio.h> // For FILE

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


/*  SAMPLE RATE CONVERSION CONSTANTS  */
#define ZERO_CROSSINGS            13                 /*  SRC CUTOFF FRQ      */
#define LP_CUTOFF                 (11.0/13.0)        /*  (0.846 OF NYQUIST)  */

#define N_BITS                    16
#define L_BITS                    8
#define L_RANGE                   256                  /*  must be 2^L_BITS  */
#define M_BITS                    8
#define M_RANGE                   256                  /*  must be 2^M_BITS  */
#define FRACTION_BITS             (L_BITS + M_BITS)
#define FRACTION_RANGE            65536         /*  must be 2^FRACTION_BITS  */
#define FILTER_LENGTH             (ZERO_CROSSINGS * L_RANGE)
#define FILTER_LIMIT              (FILTER_LENGTH - 1)

#define N_MASK                    0xFFFF0000
#define L_MASK                    0x0000FF00
#define M_MASK                    0x000000FF
#define FRACTION_MASK             0x0000FFFF

#define nValue(x)                 (((x) & N_MASK) >> FRACTION_BITS)
#define lValue(x)                 (((x) & L_MASK) >> M_BITS)
#define mValue(x)                 ((x) & M_MASK)
#define fractionValue(x)          ((x) & FRACTION_MASK)

#define OUTPUT_SRATE_LOW          22050.0
#define OUTPUT_SRATE_HIGH         44100.0

typedef struct _TRMParameters {
    double glotPitch;
    double glotVol;
    double aspVol;
    double fricVol;
    double fricPos;
    double fricCF;
    double fricBW;
    double radius[TOTAL_REGIONS];
    double velum;
} TRMParameters;

/*  VARIABLES FOR INPUT TABLES  */
typedef struct _INPUT {
    struct _INPUT *previous;
    struct _INPUT *next;

    TRMParameters parameters;
} INPUT;

typedef struct _TRMInputParameters {
    int    outputFileFormat;            /*  file format (0=AU, 1=AIFF, 2=WAVE)  */
    float  outputRate;                  /*  output sample rate (22.05, 44.1 KHz)  */
    float  controlRate;                 /*  1.0-1000.0 input tables/second (Hz)  */

    double volume;                      /*  master volume (0 - 60 dB)  */
    int    channels;                    /*  # of sound output channels (1, 2)  */
    double balance;                     /*  stereo balance (-1 to +1)  */

    int    waveform;                    /*  GS waveform type (0=PULSE, 1=SINE)  */
    double tp;                          /*  % glottal pulse rise time  */
    double tnMin;                       /*  % glottal pulse fall time minimum  */
    double tnMax;                       /*  % glottal pulse fall time maximum  */
    double breathiness;                 /*  % glottal source breathiness  */

    double length;                      /*  nominal tube length (10 - 20 cm)  */
    double temperature;                 /*  tube temperature (25 - 40 C)  */
    double lossFactor;                  /*  junction loss factor in (0 - 5 %)  */

    double apScale;                     /*  aperture scl. radius (3.05 - 12 cm)  */
    double mouthCoef;                   /*  mouth aperture coefficient  */
    double noseCoef;                    /*  nose aperture coefficient  */

    double noseRadius[TOTAL_NASAL_SECTIONS];  /*  fixed nose radii (0 - 3 cm)  */

    double throatCutoff;                /*  throat lp cutoff (50 - nyquist Hz)  */
    double throatVol;                   /*  throat volume (0 - 48 dB) */

    int    modulation;                  /*  pulse mod. of noise (0=OFF, 1=ON)  */
    double mixOffset;                   /*  noise crossmix offset (30 - 60 dB)  */
} TRMInputParameters;

typedef struct _TRMData {
    TRMInputParameters inputParameters;

    INPUT *inputHead;
    INPUT *inputTail;
} TRMData;

/*  VARIABLES FOR SAMPLE RATE CONVERSION  */
typedef struct _TRMSampleRateConverter {
    double sampleRateRatio;
    double h[FILTER_LENGTH], deltaH[FILTER_LENGTH];
    unsigned int timeRegisterIncrement, filterIncrement, phaseIncrement;
    unsigned int timeRegister;

    // Temporary sample storage values
    double maximumSampleValue;
    long int numberSamples;
    FILE *tempFilePtr;
} TRMSampleRateConverter;

#endif

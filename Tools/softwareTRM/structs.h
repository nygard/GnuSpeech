#ifndef __STRUCTS_H
#define __STRUCTS_H

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

#endif

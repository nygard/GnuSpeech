/*  REVISION INFORMATION  *****************************************************
 *
 * Revision 1.8  1995/04/17  19:51:21  len
 * Temporary fix to frication balance.
 *
 * Revision 1.7  1995/03/21  04:52:37  len
 * Now compiles FAT.  Also adjusted mono and stereo output volume to match
 * approximately the output volume of the DSP.
 *
 * Revision 1.6  1995/03/04  05:55:57  len
 * Changed controlRate parameter to a float.
 *
 * Revision 1.5  1995/03/02  04:33:04  len
 * Added amplitude scaling to input of vocal tract and throat, to keep the
 * software TRM in line with the DSP version.
 *
 * Revision 1.4  1994/11/24  05:24:12  len
 * Added Hi/Low output sample rate switch.
 *
 * Revision 1.3  1994/10/20  21:20:19  len
 * Changed nose and mouth aperture filter coefficients, so now specified as
 * Hz values (which scale appropriately as the tube length changes), rather
 * than arbitrary coefficient values (which don't scale).
 *
 * Revision 1.2  1994/08/05  03:12:52  len
 * Resectioned tube so that it more closely conforms the the DRM proportions.
 * Also changed frication injection so now allowed from S3 to S10.
 *
 * Revision 1.1.1.1  1994/07/07  03:48:52  len
 * Initial archived version.
 *

******************************************************************************/


/******************************************************************************
*
*     Program:       tube
*
*     Description:   Software (non-real-time) implementation of the Tube
*                    Resonance Model for speech production.
*
*     Author:        Leonard Manzara
*
*     Date:          July 5th, 1994
*
******************************************************************************/


/*  HEADER FILES  ************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <sys/param.h>
#include <math.h>
#include <string.h>
#include "main.h"
#include "tube.h"
#include "input.h"
#include "fir.h"
#include "util.h"
#include "structs.h"



/*  LOCAL DEFINES  ***********************************************************/

/*  COMPILE WITH OVERSAMPLING OR PLAIN OSCILLATOR  */
#define OVERSAMPLING_OSCILLATOR   1

/*  1 MEANS COMPILE SO THAT INTERPOLATION NOT DONE FOR
    SOME CONTROL RATE PARAMETERS  */
#define MATCH_DSP                 0


/*  OROPHARYNX SCATTERING JUNCTION COEFFICIENTS (BETWEEN EACH REGION)  */
#define C1                        R1     /*  R1-R2 (S1-S2)  */
#define C2                        R2     /*  R2-R3 (S2-S3)  */
#define C3                        R3     /*  R3-R4 (S3-S4)  */
#define C4                        R4     /*  R4-R5 (S5-S6)  */
#define C5                        R5     /*  R5-R6 (S7-S8)  */
#define C6                        R6     /*  R6-R7 (S8-S9)  */
#define C7                        R7     /*  R7-R8 (S9-S10)  */
#define C8                        R8     /*  R8-AIR (S10-AIR)  */
#define TOTAL_COEFFICIENTS        TOTAL_REGIONS

/*  OROPHARYNX SECTIONS  */
#define S1                        0      /*  R1  */
#define S2                        1      /*  R2  */
#define S3                        2      /*  R3  */
#define S4                        3      /*  R4  */
#define S5                        4      /*  R4  */
#define S6                        5      /*  R5  */
#define S7                        6      /*  R5  */
#define S8                        7      /*  R6  */
#define S9                        8      /*  R7  */
#define S10                       9      /*  R8  */
#define TOTAL_SECTIONS            10

/*  NASAL TRACT COEFFICIENTS  */
#define NC1                       N1     /*  N1-N2  */
#define NC2                       N2     /*  N2-N3  */
#define NC3                       N3     /*  N3-N4  */
#define NC4                       N4     /*  N4-N5  */
#define NC5                       N5     /*  N5-N6  */
#define NC6                       N6     /*  N6-AIR  */
#define TOTAL_NASAL_COEFFICIENTS  TOTAL_NASAL_SECTIONS

/*  THREE-WAY JUNCTION ALPHA COEFFICIENTS  */
#define LEFT                      0
#define RIGHT                     1
#define UPPER                     2
#define TOTAL_ALPHA_COEFFICIENTS  3

/*  FRICATION INJECTION COEFFICIENTS  */
#define FC1                       0      /*  S3  */
#define FC2                       1      /*  S4  */
#define FC3                       2      /*  S5  */
#define FC4                       3      /*  S6  */
#define FC5                       4      /*  S7  */
#define FC6                       5      /*  S8  */
#define FC7                       6      /*  S9  */
#define FC8                       7      /*  S10  */
#define TOTAL_FRIC_COEFFICIENTS   8


/*  GLOTTAL SOURCE OSCILLATOR TABLE VARIABLES  */
#define TABLE_LENGTH              512
#define TABLE_MODULUS             (TABLE_LENGTH-1)

/*  SCALING CONSTANT FOR INPUT TO VOCAL TRACT & THROAT (MATCHES DSP)  */
//#define VT_SCALE                  0.03125     /*  2^(-5)  */
// this is a temporary fix only, to try to match dsp synthesizer
#define VT_SCALE                  0.125     /*  2^(-3)  */

/*  BI-DIRECTIONAL TRANSMISSION LINE POINTERS  */
#define TOP                       0
#define BOTTOM                    1


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



/*  DERIVED VALUES  */
int    controlPeriod;
int    sampleRate;
double actualTubeLength;            /*  actual length in cm  */

double dampingFactor;               /*  calculated damping factor  */
double crossmixFactor;              /*  calculated crossmix factor  */

double *wavetable;
int    tableDiv1;
int    tableDiv2;
double tnLength;
double tnDelta;
double breathinessFactor;

double basicIncrement;
double currentPosition;


/*  REFLECTION AND RADIATION FILTER MEMORY  */
double a10, b11, a20, a21, b21;

/*  NASAL REFLECTION AND RADIATION FILTER MEMORY  */
double na10, nb11, na20, na21, nb21;

/*  THROAT LOWPASS FILTER MEMORY, GAIN  */
double tb1, ta0, throatGain;

/*  FRICATION BANDPASS FILTER MEMORY  */
double bpAlpha, bpBeta, bpGamma;

/*  TEMPORARY SAMPLE STORAGE VALUES  */
double maximumSampleValue = 0.0;
long int numberSamples = 0;
FILE *tempFilePtr;

/*  MEMORY FOR TUBE AND TUBE COEFFICIENTS  */
double oropharynx[TOTAL_SECTIONS][2][2];
double oropharynx_coeff[TOTAL_COEFFICIENTS];

double nasal[TOTAL_NASAL_SECTIONS][2][2];
double nasal_coeff[TOTAL_NASAL_COEFFICIENTS];

double alpha[TOTAL_ALPHA_COEFFICIENTS];
int current_ptr = 1;
int prev_ptr = 0;

/*  MEMORY FOR FRICATION TAPS  */
double fricationTap[TOTAL_FRIC_COEFFICIENTS];

/*  VARIABLES FOR INTERPOLATION  */
struct {
    struct _TRMParameters parameters;
    struct _TRMParameters delta;
} current;

/*  VARIABLES FOR SAMPLE RATE CONVERSION  */
double sampleRateRatio;
double h[FILTER_LENGTH], deltaH[FILTER_LENGTH];
unsigned int timeRegisterIncrement, filterIncrement, phaseIncrement;
unsigned int timeRegister = 0;


//
// Ring Buffer
//

#define BUFFER_SIZE               1024                 /*  ring buffer size  */

double buffer[BUFFER_SIZE];
int fillPtr, emptyPtr = 0, padSize, fillSize;


/*  GLOBAL FUNCTIONS (LOCAL TO THIS FILE)  ***********************************/

void initializeWavetable(struct _TRMInputParameters *inputParameters);
void updateWavetable(double amplitude);
void initializeMouthCoefficients(double coeff);
double reflectionFilter(double input);
double radiationFilter(double input);
void initializeNasalFilterCoefficients(double coeff);
double nasalReflectionFilter(double input);
double nasalRadiationFilter(double input);
void setControlRateParameters(INPUT *previousInput, INPUT *currentInput);
void sampleRateInterpolation(void);
void initializeNasalCavity(struct _TRMInputParameters *inputParameters);
void initializeThroat(struct _TRMInputParameters *inputParameters);
void calculateTubeCoefficients(struct _TRMInputParameters *inputParameters);
void setFricationTaps(void);
void calculateBandpassCoefficients(void);
double mod0(double value);
void incrementTablePosition(double frequency);
double oscillator(double frequency);
double vocalTract(double input, double frication);
double throat(double input);
double bandpassFilter(double input);
void initializeConversion(struct _TRMInputParameters *inputParameters);
void initializeFilter(void);
void initializeBuffer(void);
void dataFill(double data);
void dataEmpty(void);
void srIncrement(int *pointer, int modulus);
void srDecrement(int *pointer, int modulus);





/******************************************************************************
*
*       function:       initializeSynthesizer
*
*       purpose:        Initializes all variables so that the synthesis can
*                       be run.
*
*       arguments:      none
*
*       internal
*       functions:      speedOfSound, amplitude, initializeWavetable,
*                       initializeFIR, initializeNasalFilterCoefficients,
*                       initializeNasalCavity, initializeThroat,
*                       initializeConversion
*
*       library
*       functions:      rint, fprintf, tmpfile, rewind
*
******************************************************************************/

int initializeSynthesizer(struct _TRMData *data)
{
    double nyquist;

    /*  CALCULATE THE SAMPLE RATE, BASED ON NOMINAL
        TUBE LENGTH AND SPEED OF SOUND  */
    if (data->inputParameters.length > 0.0) {
        double c = speedOfSound(data->inputParameters.temperature);
        controlPeriod = rint((c * TOTAL_SECTIONS * 100.0) / (data->inputParameters.length * data->inputParameters.controlRate));
        sampleRate = data->inputParameters.controlRate * controlPeriod;
        actualTubeLength = (c * TOTAL_SECTIONS * 100.0) / sampleRate;
        nyquist = (double)sampleRate / 2.0;
    } else {
        fprintf(stderr, "Illegal tube length.\n");
        return ERROR;
    }

    /*  CALCULATE THE BREATHINESS FACTOR  */
    breathinessFactor = data->inputParameters.breathiness / 100.0;

    /*  CALCULATE CROSSMIX FACTOR  */
    crossmixFactor = 1.0 / amplitude(data->inputParameters.mixOffset);

    /*  CALCULATE THE DAMPING FACTOR  */
    dampingFactor = (1.0 - (data->inputParameters.lossFactor / 100.0));

    /*  INITIALIZE THE WAVE TABLE  */
    initializeWavetable(&(data->inputParameters));

    /*  INITIALIZE THE FIR FILTER  */
    initializeFIR(FIR_BETA, FIR_GAMMA, FIR_CUTOFF);

    /*  INITIALIZE REFLECTION AND RADIATION FILTER COEFFICIENTS FOR MOUTH  */
    initializeMouthCoefficients((nyquist - data->inputParameters.mouthCoef) / nyquist);

    /*  INITIALIZE REFLECTION AND RADIATION FILTER COEFFICIENTS FOR NOSE  */
    initializeNasalFilterCoefficients((nyquist - data->inputParameters.noseCoef) / nyquist);

    /*  INITIALIZE NASAL CAVITY FIXED SCATTERING COEFFICIENTS  */
    initializeNasalCavity(&(data->inputParameters));

    /*  INITIALIZE THE THROAT LOWPASS FILTER  */
    initializeThroat(&(data->inputParameters));

    /*  INITIALIZE THE SAMPLE RATE CONVERSION ROUTINES  */
    initializeConversion(&(data->inputParameters));

    /*  INITIALIZE THE TEMPORARY OUTPUT FILE  */
    tempFilePtr = tmpfile();
    rewind(tempFilePtr);

    /*  RETURN SUCCESS  */
    return SUCCESS;
}


/******************************************************************************
*
*       function:       initializeWavetable
*
*       purpose:        Calculates the initial glottal pulse and stores it
*                       in the wavetable, for use in the oscillator.
*
*       arguments:      none
*
*       internal
*       functions:      none
*
*       library
*       functions:      calloc, rint
*
******************************************************************************/

void initializeWavetable(struct _TRMInputParameters *inputParameters)
{
    int i, j;


    /*  ALLOCATE MEMORY FOR WAVETABLE  */
    wavetable = (double *)calloc(TABLE_LENGTH, sizeof(double));

    /*  CALCULATE WAVE TABLE PARAMETERS  */
    tableDiv1 = rint(TABLE_LENGTH * (inputParameters->tp / 100.0));
    tableDiv2 = rint(TABLE_LENGTH * ((inputParameters->tp + inputParameters->tnMax) / 100.0));
    tnLength = tableDiv2 - tableDiv1;
    tnDelta = rint(TABLE_LENGTH * ((inputParameters->tnMax - inputParameters->tnMin) / 100.0));
    basicIncrement = (double)TABLE_LENGTH / (double)sampleRate;
    currentPosition = 0;

    /*  INITIALIZE THE WAVETABLE WITH EITHER A GLOTTAL PULSE OR SINE TONE  */
    if (inputParameters->waveform == PULSE) {
        /*  CALCULATE RISE PORTION OF WAVE TABLE  */
        for (i = 0; i < tableDiv1; i++) {
            double x = (double)i / (double)tableDiv1;
            double x2 = x * x;
            double x3 = x2 * x;
            wavetable[i] = (3.0 * x2) - (2.0 * x3);
        }

        /*  CALCULATE FALL PORTION OF WAVE TABLE  */
        for (i = tableDiv1, j = 0; i < tableDiv2; i++, j++) {
            double x = (double)j / tnLength;
            wavetable[i] = 1.0 - (x * x);
        }

        /*  SET CLOSED PORTION OF WAVE TABLE  */
        for (i = tableDiv2; i < TABLE_LENGTH; i++)
            wavetable[i] = 0.0;
    } else {
        /*  SINE WAVE  */
        for (i = 0; i < TABLE_LENGTH; i++) {
            wavetable[i] = sin( ((double)i/(double)TABLE_LENGTH) * 2.0 * PI );
        }
    }
}



/******************************************************************************
*
*       function:       updateWavetable
*
*       purpose:        Rewrites the changeable part of the glottal pulse
*                       according to the amplitude.
*
*       arguments:      amplitude
*
*       internal
*       functions:      none
*
*       library
*       functions:      rint
*
******************************************************************************/

void updateWavetable(double amplitude)
{
    int i, j;

    /*  CALCULATE NEW CLOSURE POINT, BASED ON AMPLITUDE  */
    double newDiv2 = tableDiv2 - rint(amplitude * tnDelta);
    double newTnLength = newDiv2 - tableDiv1;

    /*  RECALCULATE THE FALLING PORTION OF THE GLOTTAL PULSE  */
    for (i = tableDiv1, j = 0; i < newDiv2; i++, j++) {
        double x = (double)j / newTnLength;
        wavetable[i] = 1.0 - (x * x);
    }

    /*  FILL IN WITH CLOSED PORTION OF GLOTTAL PULSE  */
    for (i = newDiv2; i < tableDiv2; i++)
        wavetable[i] = 0.0;
}



/******************************************************************************
*
*       function:       initializeMouthCoefficients
*
*       purpose:        Calculates the reflection/radiation filter coefficients
*                       for the mouth, according to the mouth aperture
*                       coefficient.
*
*       arguments:      coeff - mouth aperture coefficient
*
*       internal
*       functions:      none
*
*       library
*       functions:      fabs
*
******************************************************************************/

void initializeMouthCoefficients(double coeff)
{
    b11 = -coeff;
    a10 = 1.0 - fabs(b11);

    a20 = coeff;
    a21 = b21 = -a20;
}



/******************************************************************************
*
*       function:       reflectionFilter
*
*       purpose:        Is a variable, one-pole lowpass filter, whose cutoff
*                       is determined by the mouth aperture coefficient.
*
*       arguments:      input
*
*       internal
*       functions:      none
*
*       library
*       functions:      none
*
******************************************************************************/

double reflectionFilter(double input)
{
    static double reflectionY = 0.0;

    double output = (a10 * input) - (b11 * reflectionY);
    reflectionY = output;
    return output;
}



/******************************************************************************
*
*       function:       radiationFilter
*
*       purpose:        Is a variable, one-zero, one-pole, highpass filter,
*                       whose cutoff point is determined by the mouth aperture
*                       coefficient.
*
*       arguments:      input
*
*       internal
*       functions:      none
*
*       library
*       functions:      none
*
******************************************************************************/

double radiationFilter(double input)
{
    static double radiationX = 0.0, radiationY = 0.0;

    double output = (a20 * input) + (a21 * radiationX) - (b21 * radiationY);
    radiationX = input;
    radiationY = output;
    return output;
}



/******************************************************************************
*
*       function:       initializeNasalFilterCoefficients
*
*       purpose:        Calculates the fixed coefficients for the nasal
*                       reflection/radiation filter pair, according to the
*                       nose aperture coefficient.
*
*       arguments:      coeff - nose aperture coefficient
*
*       internal
*       functions:      none
*
*       library
*       functions:      fabs
*
******************************************************************************/

void initializeNasalFilterCoefficients(double coeff)
{
    nb11 = -coeff;
    na10 = 1.0 - fabs(nb11);

    na20 = coeff;
    na21 = nb21 = -na20;
}



/******************************************************************************
*
*       function:       nasalReflectionFilter
*
*       purpose:        Is a one-pole lowpass filter, used for terminating
*                       the end of the nasal cavity.
*
*       arguments:      input
*
*       internal
*       functions:      none
*
*       library
*       functions:      none
*
******************************************************************************/

double nasalReflectionFilter(double input)
{
    static double nasalReflectionY = 0.0;

    double output = (na10 * input) - (nb11 * nasalReflectionY);
    nasalReflectionY = output;
    return output;
}



/******************************************************************************
*
*       function:       nasalRadiationFilter
*
*       purpose:        Is a one-zero, one-pole highpass filter, used for the
*                       radiation characteristic from the nasal cavity.
*
*       arguments:      input
*
*       internal
*       functions:      none
*
*       library
*       functions:      none
*
******************************************************************************/

double nasalRadiationFilter(double input)
{
    static double nasalRadiationX = 0.0, nasalRadiationY = 0.0;

    double output = (na20 * input) + (na21 * nasalRadiationX) - (nb21 * nasalRadiationY);
    nasalRadiationX = input;
    nasalRadiationY = output;
    return output;
}

/******************************************************************************
*
*       function:       synthesize
*
*       purpose:        Performs the actual synthesis of sound samples.
*
*       arguments:      none
*
*       internal
*       functions:      setControlRateParameters, frequency, amplitude,
*                       calculateTubeCoefficients, noise, noiseFilter,
*                       updateWavetable, oscillator, vocalTract, throat,
*                       dataFill, sampleRateInterpolation
*
*       library
*       functions:      none
*
******************************************************************************/

void synthesize(TRMData *data)
{
    int j;
    double f0, ax, ah1, pulse, lp_noise, pulsed_noise, signal, crossmix;
    INPUT *previousInput, *currentInput;



    /*  CONTROL RATE LOOP  */

    previousInput = data->inputHead;
    currentInput = data->inputHead->next;

    while (currentInput != NULL) {
        /*  SET CONTROL RATE PARAMETERS FROM INPUT TABLES  */
        setControlRateParameters(previousInput, currentInput);


        /*  SAMPLE RATE LOOP  */
        for (j = 0; j < controlPeriod; j++) {

            /*  CONVERT PARAMETERS HERE  */
            f0 = frequency(current.parameters.glotPitch);
            ax = amplitude(current.parameters.glotVol);
            ah1 = amplitude(current.parameters.aspVol);
            calculateTubeCoefficients(&(data->inputParameters));
            setFricationTaps();
            calculateBandpassCoefficients();


            /*  DO SYNTHESIS HERE  */
            /*  CREATE LOW-PASS FILTERED NOISE  */
            lp_noise = noiseFilter(noise());

            /*  UPDATE THE SHAPE OF THE GLOTTAL PULSE, IF NECESSARY  */
            if (data->inputParameters.waveform == PULSE)
                updateWavetable(ax);

            /*  CREATE GLOTTAL PULSE (OR SINE TONE)  */
            pulse = oscillator(f0);

            /*  CREATE PULSED NOISE  */
            pulsed_noise = lp_noise * pulse;

            /*  CREATE NOISY GLOTTAL PULSE  */
            pulse = ax * ((pulse * (1.0 - breathinessFactor)) + (pulsed_noise * breathinessFactor));

            /*  CROSS-MIX PURE NOISE WITH PULSED NOISE  */
            if (data->inputParameters.modulation) {
                crossmix = ax * crossmixFactor;
                crossmix = (crossmix < 1.0) ? crossmix : 1.0;
                signal = (pulsed_noise * crossmix) + (lp_noise * (1.0 - crossmix));
                if (verbose) {
                    printf("\nSignal = %e", signal);
                    fflush(stdout);
                }


            } else
                signal = lp_noise;

            /*  PUT SIGNAL THROUGH VOCAL TRACT  */
            signal = vocalTract(((pulse + (ah1 * signal)) * VT_SCALE),
                                bandpassFilter(signal));


            /*  PUT PULSE THROUGH THROAT  */
            signal += throat(pulse * VT_SCALE);
            if (verbose)
                printf("\nDone throat\n");

            /*  OUTPUT SAMPLE HERE  */
            dataFill(signal);
            if (verbose)
                printf("\nDone datafil\n");

            /*  DO SAMPLE RATE INTERPOLATION OF CONTROL PARAMETERS  */
            sampleRateInterpolation();
            if (verbose)
                printf("\nDone sample rate interp\n");

        }

        previousInput = currentInput;
        currentInput = currentInput->next;
    }

    /*  BE SURE TO FLUSH SRC BUFFER  */
    flushBuffer();
}


/******************************************************************************
*
*       function:       setControlRateParameters
*
*       purpose:        Calculates the current table values, and their
*                       associated sample-to-sample delta values.
*
*       arguments:      pos
*
*       internal
*       functions:      glotPitchAt, glotVolAt, aspVolAt, fricVolAt, fricPosAt,
*                       fricCFAt, fricBWAt, radiusAtRegion, velumAt,
*
*       library
*       functions:      none
*
******************************************************************************/

void setControlRateParameters(INPUT *previousInput, INPUT *currentInput)
{
    int i;

    /*  GLOTTAL PITCH  */
    current.parameters.glotPitch = glotPitchAt(previousInput);
    current.delta.glotPitch = (glotPitchAt(currentInput) - current.parameters.glotPitch) / (double)controlPeriod;

    /*  GLOTTAL VOLUME  */
    current.parameters.glotVol = glotVolAt(previousInput);
    current.delta.glotVol = (glotVolAt(currentInput) - current.parameters.glotVol) / (double)controlPeriod;

    /*  ASPIRATION VOLUME  */
    current.parameters.aspVol = aspVolAt(previousInput);
#if MATCH_DSP
    current.delta.aspVol = 0.0;
#else
    current.delta.aspVol = (aspVolAt(currentInput) - current.parameters.aspVol) / (double)controlPeriod;
#endif

    /*  FRICATION VOLUME  */
    current.parameters.fricVol = fricVolAt(previousInput);
#if MATCH_DSP
    current.delta.fricVol = 0.0;
#else
    current.delta.fricVol = (fricVolAt(currentInput) - current.parameters.fricVol) / (double)controlPeriod;
#endif

    /*  FRICATION POSITION  */
    current.parameters.fricPos = fricPosAt(previousInput);
#if MATCH_DSP
    current.delta.fricPos = 0.0;
#else
    current.delta.fricPos = (fricPosAt(currentInput) - current.parameters.fricPos) / (double)controlPeriod;
#endif

    /*  FRICATION CENTER FREQUENCY  */
    current.parameters.fricCF = fricCFAt(previousInput);
#if MATCH_DSP
    current.delta.fricCF = 0.0;
#else
    current.delta.fricCF = (fricCFAt(currentInput) - current.parameters.fricCF) / (double)controlPeriod;
#endif

    /*  FRICATION BANDWIDTH  */
    current.parameters.fricBW = fricBWAt(previousInput);
#if MATCH_DSP
    current.delta.fricBW = 0.0;
#else
    current.delta.fricBW = (fricBWAt(currentInput) - current.parameters.fricBW) / (double)controlPeriod;
#endif

    /*  TUBE REGION RADII  */
    for (i = 0; i < TOTAL_REGIONS; i++) {
        current.parameters.radius[i] = radiusAtRegion(previousInput, i);
        current.delta.radius[i] = (radiusAtRegion(currentInput,i) - current.parameters.radius[i]) / (double)controlPeriod;
    }

    /*  VELUM RADIUS  */
    current.parameters.velum = velumAt(previousInput);
    current.delta.velum = (velumAt(currentInput) - current.parameters.velum) / (double)controlPeriod;
}



/******************************************************************************
*
*       function:       sampleRateInterpolation
*
*       purpose:        Interpolates table values at the sample rate.
*
*       arguments:      none
*
*       internal
*       functions:      none
*
*       library
*       functions:      none
*
******************************************************************************/

void sampleRateInterpolation(void)
{
    int i;

    current.parameters.glotPitch += current.delta.glotPitch;
    current.parameters.glotVol += current.delta.glotVol;
    current.parameters.aspVol += current.delta.aspVol;
    current.parameters.fricVol += current.delta.fricVol;
    current.parameters.fricPos += current.delta.fricPos;
    current.parameters.fricCF += current.delta.fricCF;
    current.parameters.fricBW += current.delta.fricBW;
    for (i = 0; i < TOTAL_REGIONS; i++)
        current.parameters.radius[i] += current.delta.radius[i];
    current.parameters.velum += current.delta.velum;
}



/******************************************************************************
*
*       function:       initializeNasalCavity
*
*       purpose:        Calculates the scattering coefficients for the fixed
*                       sections of the nasal cavity.
*
*       arguments:      none
*
*       internal
*       functions:      none
*
*       library
*       functions:      none
*
******************************************************************************/

void initializeNasalCavity(struct _TRMInputParameters *inputParameters)
{
    int i, j;
    double radA2, radB2;


    /*  CALCULATE COEFFICIENTS FOR INTERNAL FIXED SECTIONS OF NASAL CAVITY  */
    for (i = N2, j = NC2; i < N6; i++, j++) {
        radA2 = inputParameters->noseRadius[i] * inputParameters->noseRadius[i];
        radB2 = inputParameters->noseRadius[i+1] * inputParameters->noseRadius[i+1];
        nasal_coeff[j] = (radA2 - radB2) / (radA2 + radB2);
    }

    /*  CALCULATE THE FIXED COEFFICIENT FOR THE NOSE APERTURE  */
    radA2 = inputParameters->noseRadius[N6] * inputParameters->noseRadius[N6];
    radB2 = inputParameters->apScale * inputParameters->apScale;
    nasal_coeff[NC6] = (radA2 - radB2) / (radA2 + radB2);
}



/******************************************************************************
*
*       function:       initializeThroat
*
*       purpose:        Initializes the throat lowpass filter coefficients
*                       according to the throatCutoff value, and also the
*                       throatGain, according to the throatVol value.
*
*       arguments:      none
*
*       internal
*       functions:      none
*
*       library
*       functions:      fabs
*
******************************************************************************/

void initializeThroat(struct _TRMInputParameters *inputParameters)
{
    ta0 = (inputParameters->throatCutoff * 2.0) / sampleRate;
    tb1 = 1.0 - ta0;

    throatGain = amplitude(inputParameters->throatVol);
}



/******************************************************************************
*
*       function:       calculateTubeCoefficients
*
*       purpose:        Calculates the scattering coefficients for the vocal
*                       tract according to the current radii.  Also calculates
*                       the coefficients for the reflection/radiation filter
*                       pair for the mouth and nose.
*
*       arguments:      none
*
*       internal
*       functions:      none
*
*       library
*       functions:      none
*
******************************************************************************/

void calculateTubeCoefficients(struct _TRMInputParameters *inputParameters)
{
    int i;
    double radA2, radB2, r0_2, r1_2, r2_2, sum;


    /*  CALCULATE COEFFICIENTS FOR THE OROPHARYNX  */
    for (i = 0; i < (TOTAL_REGIONS-1); i++) {
        radA2 = current.parameters.radius[i] * current.parameters.radius[i];
        radB2 = current.parameters.radius[i+1] * current.parameters.radius[i+1];
        oropharynx_coeff[i] = (radA2 - radB2) / (radA2 + radB2);
    }

    /*  CALCULATE THE COEFFICIENT FOR THE MOUTH APERTURE  */
    radA2 = current.parameters.radius[R8] * current.parameters.radius[R8];
    radB2 = inputParameters->apScale * inputParameters->apScale;
    oropharynx_coeff[C8] = (radA2 - radB2) / (radA2 + radB2);

    /*  CALCULATE ALPHA COEFFICIENTS FOR 3-WAY JUNCTION  */
    /*  NOTE:  SINCE JUNCTION IS IN MIDDLE OF REGION 4, r0_2 = r1_2  */
    r0_2 = r1_2 = current.parameters.radius[R4] * current.parameters.radius[R4];
    r2_2 = current.parameters.velum * current.parameters.velum;
    sum = 2.0 / (r0_2 + r1_2 + r2_2);
    alpha[LEFT] = sum * r0_2;
    alpha[RIGHT] = sum * r1_2;
    alpha[UPPER] = sum * r2_2;

    /*  AND 1ST NASAL PASSAGE COEFFICIENT  */
    radA2 = current.parameters.velum * current.parameters.velum;
    radB2 = inputParameters->noseRadius[N2] * inputParameters->noseRadius[N2];
    nasal_coeff[NC1] = (radA2 - radB2) / (radA2 + radB2);
}



/******************************************************************************
*
*       function:       setFricationTaps
*
*       purpose:        Sets the frication taps according to the current
*                       position and amplitude of frication.
*
*       arguments:      none
*
*       internal
*       functions:      none
*
*       library
*       functions:      none
*
******************************************************************************/

void setFricationTaps(void)
{
    int i, integerPart;
    double complement, remainder;
    double fricationAmplitude = amplitude(current.parameters.fricVol);


    /*  CALCULATE POSITION REMAINDER AND COMPLEMENT  */
    integerPart = (int)current.parameters.fricPos;
    complement = current.parameters.fricPos - (double)integerPart;
    remainder = 1.0 - complement;

    /*  SET THE FRICATION TAPS  */
    for (i = FC1; i < TOTAL_FRIC_COEFFICIENTS; i++) {
        if (i == integerPart) {
            fricationTap[i] = remainder * fricationAmplitude;
            if ((i+1) < TOTAL_FRIC_COEFFICIENTS)
                fricationTap[++i] = complement * fricationAmplitude;
        } else
            fricationTap[i] = 0.0;
    }

#if DEBUG
    /*  PRINT OUT  */
    printf("fricationTaps:  ");
    for (i = FC1; i < TOTAL_FRIC_COEFFICIENTS; i++)
        printf("%.6f  ", fricationTap[i]);
    printf("\n");
#endif
}



/******************************************************************************
*
*       function:       calculateBandpassCoefficients
*
*       purpose:        Sets the frication bandpass filter coefficients
*                       according to the current center frequency and
*                       bandwidth.
*
*       arguments:      none
*
*       internal
*       functions:      none
*
*       library
*       functions:      tan, cos
*
******************************************************************************/

void calculateBandpassCoefficients(void)
{
    double tanValue, cosValue;


    tanValue = tan((PI * current.parameters.fricBW) / sampleRate);
    cosValue = cos((2.0 * PI * current.parameters.fricCF) / sampleRate);

    bpBeta = (1.0 - tanValue) / (2.0 * (1.0 + tanValue));
    bpGamma = (0.5 + bpBeta) * cosValue;
    bpAlpha = (0.5 - bpBeta) / 2.0;
}



/******************************************************************************
*
*       function:       mod0
*
*       purpose:        Returns the modulus of 'value', keeping it in the
*                       range 0 -> TABLE_MODULUS.
*
*       arguments:      value
*
*       internal
*       functions:      none
*
*       library
*       functions:      none
*
******************************************************************************/

double mod0(double value)
{
    if (value > TABLE_MODULUS)
        value -= TABLE_LENGTH;

    return value;
}



/******************************************************************************
*
*       function:       incrementTablePosition
*
*       purpose:        Increments the position in the wavetable according to
*                       the desired frequency.
*
*       arguments:      frequency
*
*       internal
*       functions:      mod0
*
*       library
*       functions:      none
*
******************************************************************************/

void incrementTablePosition(double frequency)
{
    currentPosition = mod0(currentPosition + (frequency * basicIncrement));
}



/******************************************************************************
*
*       function:       oscillator
*
*       purpose:        Is a 2X oversampling interpolating wavetable
*                       oscillator.
*
*       arguments:      frequency
*
*       internal
*       functions:      incrementTablePosition, mod0, FIRFilter
*
*       library
*       functions:      none
*
******************************************************************************/

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



/******************************************************************************
*
*       function:       vocalTract
*
*       purpose:        Updates the pressure wave throughout the vocal tract,
*                       and returns the summed output of the oral and nasal
*                       cavities.  Also injects frication appropriately.
*
*       arguments:      input, frication
*
*       internal
*       functions:      reflectionFilter, radiationFilter,
*                       nasalReflectionFilter, nasalRadiationFilter
*
*       library
*       functions:      none
*
******************************************************************************/

double vocalTract(double input, double frication)
{
    int i, j, k;
    double delta, output, junctionPressure;


    /*  INCREMENT CURRENT AND PREVIOUS POINTERS  */
    if (++current_ptr > 1)
        current_ptr = 0;
    if (++prev_ptr > 1)
        prev_ptr = 0;

    /*  UPDATE OROPHARYNX  */
    /*  INPUT TO TOP OF TUBE  */

    oropharynx[S1][TOP][current_ptr] = (oropharynx[S1][BOTTOM][prev_ptr] * dampingFactor) + input;

    /*  CALCULATE THE SCATTERING JUNCTIONS FOR S1-S2  */

    delta = oropharynx_coeff[C1] * (oropharynx[S1][TOP][prev_ptr] - oropharynx[S2][BOTTOM][prev_ptr]);
    oropharynx[S2][TOP][current_ptr] = (oropharynx[S1][TOP][prev_ptr] + delta) * dampingFactor;
    oropharynx[S1][BOTTOM][current_ptr] = (oropharynx[S2][BOTTOM][prev_ptr] + delta) * dampingFactor;

    /*  CALCULATE THE SCATTERING JUNCTIONS FOR S2-S3 AND S3-S4  */
    if (verbose)
        printf("\nCalc scattering\n");
    for (i = S2, j = C2, k = FC1; i < S4; i++, j++, k++) {
        delta = oropharynx_coeff[j] * (oropharynx[i][TOP][prev_ptr] - oropharynx[i+1][BOTTOM][prev_ptr]);
        oropharynx[i+1][TOP][current_ptr] =
            ((oropharynx[i][TOP][prev_ptr] + delta) * dampingFactor) +
                (fricationTap[k] * frication);
        oropharynx[i][BOTTOM][current_ptr] = (oropharynx[i+1][BOTTOM][prev_ptr] + delta) * dampingFactor;
    }

    /*  UPDATE 3-WAY JUNCTION BETWEEN THE MIDDLE OF R4 AND NASAL CAVITY  */
    junctionPressure = (alpha[LEFT] * oropharynx[S4][TOP][prev_ptr])+
        (alpha[RIGHT] * oropharynx[S5][BOTTOM][prev_ptr]) +
        (alpha[UPPER] * nasal[VELUM][BOTTOM][prev_ptr]);
    oropharynx[S4][BOTTOM][current_ptr] = (junctionPressure - oropharynx[S4][TOP][prev_ptr]) * dampingFactor;
    oropharynx[S5][TOP][current_ptr] =
        ((junctionPressure - oropharynx[S5][BOTTOM][prev_ptr]) * dampingFactor)
            + (fricationTap[FC3] * frication);
    nasal[VELUM][TOP][current_ptr] = (junctionPressure - nasal[VELUM][BOTTOM][prev_ptr]) * dampingFactor;

    /*  CALCULATE JUNCTION BETWEEN R4 AND R5 (S5-S6)  */
    delta = oropharynx_coeff[C4] * (oropharynx[S5][TOP][prev_ptr] - oropharynx[S6][BOTTOM][prev_ptr]);
    oropharynx[S6][TOP][current_ptr] =
        ((oropharynx[S5][TOP][prev_ptr] + delta) * dampingFactor) +
            (fricationTap[FC4] * frication);
    oropharynx[S5][BOTTOM][current_ptr] = (oropharynx[S6][BOTTOM][prev_ptr] + delta) * dampingFactor;

    /*  CALCULATE JUNCTION INSIDE R5 (S6-S7) (PURE DELAY WITH DAMPING)  */
    oropharynx[S7][TOP][current_ptr] =
        (oropharynx[S6][TOP][prev_ptr] * dampingFactor) +
            (fricationTap[FC5] * frication);
    oropharynx[S6][BOTTOM][current_ptr] = oropharynx[S7][BOTTOM][prev_ptr] * dampingFactor;

    /*  CALCULATE LAST 3 INTERNAL JUNCTIONS (S7-S8, S8-S9, S9-S10)  */
    for (i = S7, j = C5, k = FC6; i < S10; i++, j++, k++) {
        delta = oropharynx_coeff[j] * (oropharynx[i][TOP][prev_ptr] - oropharynx[i+1][BOTTOM][prev_ptr]);
        oropharynx[i+1][TOP][current_ptr] =
            ((oropharynx[i][TOP][prev_ptr] + delta) * dampingFactor) +
                (fricationTap[k] * frication);
        oropharynx[i][BOTTOM][current_ptr] = (oropharynx[i+1][BOTTOM][prev_ptr] + delta) * dampingFactor;
    }

    /*  REFLECTED SIGNAL AT MOUTH GOES THROUGH A LOWPASS FILTER  */
    oropharynx[S10][BOTTOM][current_ptr] =  dampingFactor *
        reflectionFilter(oropharynx_coeff[C8] * oropharynx[S10][TOP][prev_ptr]);

    /*  OUTPUT FROM MOUTH GOES THROUGH A HIGHPASS FILTER  */
    output = radiationFilter((1.0 + oropharynx_coeff[C8]) * oropharynx[S10][TOP][prev_ptr]);


    /*  UPDATE NASAL CAVITY  */
    for (i = VELUM, j = NC1; i < N6; i++, j++) {
        delta = nasal_coeff[j] * (nasal[i][TOP][prev_ptr] - nasal[i+1][BOTTOM][prev_ptr]);
        nasal[i+1][TOP][current_ptr] = (nasal[i][TOP][prev_ptr] + delta) * dampingFactor;
        nasal[i][BOTTOM][current_ptr] = (nasal[i+1][BOTTOM][prev_ptr] + delta) * dampingFactor;
    }

    /*  REFLECTED SIGNAL AT NOSE GOES THROUGH A LOWPASS FILTER  */
    nasal[N6][BOTTOM][current_ptr] = dampingFactor * nasalReflectionFilter(nasal_coeff[NC6] * nasal[N6][TOP][prev_ptr]);

    /*  OUTPUT FROM NOSE GOES THROUGH A HIGHPASS FILTER  */
    output += nasalRadiationFilter((1.0 + nasal_coeff[NC6]) * nasal[N6][TOP][prev_ptr]);

    /*  RETURN SUMMED OUTPUT FROM MOUTH AND NOSE  */
    return(output);
}



/******************************************************************************
*
*       function:       throat
*
*       purpose:        Simulates the radiation of sound through the walls
*                       of the throat.  Note that this form of the filter
*                       uses addition instead of subtraction for the
*                       second term, since tb1 has reversed sign.
*
*       arguments:      input
*
*       internal
*       functions:      none
*
*       library
*       functions:      none
*
******************************************************************************/

double throat(double input)
{
    static double throatY = 0.0;

    double output = (ta0 * input) + (tb1 * throatY);
    throatY = output;
    return (output * throatGain);
}



/******************************************************************************
*
*       function:       bandpassFilter
*
*       purpose:        Frication bandpass filter, with variable center
*                       frequency and bandwidth.
*
*       arguments:      input
*
*       internal
*       functions:      none
*
*       library
*       functions:      none
*
******************************************************************************/

double bandpassFilter(double input)
{
    static double xn1 = 0.0, xn2 = 0.0, yn1 = 0.0, yn2 = 0.0;
    double output;


    output = 2.0 * ((bpAlpha * (input - xn2)) + (bpGamma * yn1) - (bpBeta * yn2));

    xn2 = xn1;
    xn1 = input;
    yn2 = yn1;
    yn1 = output;

    return output;
}



/******************************************************************************
*
*       function:       initializeConversion
*
*       purpose:        Initializes all the sample rate conversion functions.
*
*       arguments:      none
*
*       internal
*       functions:      initializeFilter, initializeBuffer
*
*       library
*       functions:      rint, pow
*
******************************************************************************/

void initializeConversion(struct _TRMInputParameters *inputParameters)
{
    double roundedSampleRateRatio;


    /*  INITIALIZE FILTER IMPULSE RESPONSE  */
    initializeFilter();

    /*  CALCULATE SAMPLE RATE RATIO  */
    sampleRateRatio = (double)inputParameters->outputRate / (double)sampleRate;

    /*  CALCULATE TIME REGISTER INCREMENT  */
    timeRegisterIncrement = (int)rint(pow(2.0, FRACTION_BITS) / sampleRateRatio);

    /*  CALCULATE ROUNDED SAMPLE RATE RATIO  */
    roundedSampleRateRatio = pow(2.0, FRACTION_BITS) / (double)timeRegisterIncrement;

    /*  CALCULATE PHASE OR FILTER INCREMENT  */
    if (sampleRateRatio >= 1.0) {
        filterIncrement = L_RANGE;
    } else {
        phaseIncrement = (unsigned int)rint(sampleRateRatio * (double)FRACTION_RANGE);
    }

    /*  CALCULATE PAD SIZE  */
    padSize = (sampleRateRatio >= 1.0) ? ZERO_CROSSINGS :
        (int)((float)ZERO_CROSSINGS / roundedSampleRateRatio) + 1;

    /*  INITIALIZE THE RING BUFFER  */
    initializeBuffer();
}



/******************************************************************************
*
*       function:       initializeFilter
*
*       purpose:        Initializes filter impulse response and impulse delta
*                       values.
*
*       arguments:      none
*
*       internal
*       functions:      none
*
*       library
*       functions:      sin, cos
*
******************************************************************************/

void initializeFilter(void)
{
    double x, IBeta;
    int i;


    /*  INITIALIZE THE FILTER IMPULSE RESPONSE  */
    h[0] = LP_CUTOFF;
    x = PI / (double)L_RANGE;
    for (i = 1; i < FILTER_LENGTH; i++) {
        double y = (double)i * x;
        h[i] = sin(y * LP_CUTOFF) / y;
    }

    /*  APPLY A KAISER WINDOW TO THE IMPULSE RESPONSE  */
    IBeta = 1.0 / Izero(BETA);
    for (i = 0; i < FILTER_LENGTH; i++) {
        double temp = (double)i / FILTER_LENGTH;
        h[i] *= Izero(BETA * sqrt(1.0 - (temp * temp))) * IBeta;
    }

    /*  INITIALIZE THE FILTER IMPULSE RESPONSE DELTA VALUES  */
    for (i = 0; i < FILTER_LIMIT; i++)
        deltaH[i] = h[i+1] - h[i];
    deltaH[FILTER_LIMIT] = 0.0 - h[FILTER_LIMIT];
}



/******************************************************************************
*
*       function:       initializeBuffer
*
*       purpose:        Initializes the ring buffer used for sample rate
*                       conversion.
*
*       arguments:      none
*
*       internal
*       functions:      none
*
*       library
*       functions:      none
*
******************************************************************************/

void initializeBuffer(void)
{
    int i;

    printf("initializeBuffer(), padSize: %d\n", padSize);

    /*  FILL THE RING BUFFER WITH ALL ZEROS  */
    for (i = 0; i < BUFFER_SIZE; i++)
        buffer[i] = 0.0;

    /*  INITIALIZE FILL POINTER  */
    fillPtr = padSize;

    /*  CALCULATE FILL SIZE  */
    fillSize = BUFFER_SIZE - (2 * padSize);

    printf("initializeBuffer(), padSize: %d, fillPtr: %d, fillSize: %d\n", padSize, fillPtr, fillSize);
}



/******************************************************************************
*
*       function:       dataFill
*
*       purpose:        Fills the ring buffer with a single sample, increments
*                       the counters and pointers, and empties the buffer when
*                       full.
*
*       arguments:      data
*
*       internal
*       functions:      srIncrement, dataEmpty
*
*       library
*       functions:      none
*
******************************************************************************/

void dataFill(double data)
{
    static int fillCounter = 0;


    /*  PUT THE DATA INTO THE RING BUFFER  */
    buffer[fillPtr] = data;

    /*  INCREMENT THE FILL POINTER, MODULO THE BUFFER SIZE  */
    srIncrement(&fillPtr, BUFFER_SIZE);

    /*  INCREMENT THE COUNTER, AND EMPTY THE BUFFER IF FULL  */
    if (++fillCounter >= fillSize) {
        dataEmpty();
        /* RESET THE FILL COUNTER  */
        fillCounter = 0;
    }
}



/******************************************************************************
*
*       function:       dataEmpty
*
*       purpose:        Converts available portion of the input signal to the
*                       new sampling rate, and outputs the samples to the
*                       sound struct.
*
*       arguments:      none
*
*       internal
*       functions:      srDecrement, srIncrement
*
*       library
*       functions:      rint, fabs, fwrite
*
******************************************************************************/

void dataEmpty(void)
{
    int endPtr;

    printf(" > dataEmpty()\n");
    printf("buffer size: %d\n", BUFFER_SIZE);
    printf("numberSamples before: %ld\n", numberSamples);
    printf("fillPtr: %d, padSize: %d\n", fillPtr, padSize);

    /*  CALCULATE END POINTER  */
    endPtr = fillPtr - padSize;
    printf("endPtr: %d\n", endPtr);
    printf("emptyPtr: %d\n", emptyPtr);

    /*  ADJUST THE END POINTER, IF LESS THAN ZERO  */
    if (endPtr < 0)
        endPtr += BUFFER_SIZE;

    /*  ADJUST THE ENDPOINT, IF LESS THEN THE EMPTY POINTER  */
    if (endPtr < emptyPtr)
        endPtr += BUFFER_SIZE;

    /*  UPSAMPLE LOOP (SLIGHTLY MORE EFFICIENT THAN DOWNSAMPLING)  */
    printf("sampleRateRatio: %g\n", sampleRateRatio);
    if (sampleRateRatio >= 1.0) {
        printf("Upsampling...\n");
        while (emptyPtr < endPtr) {
            int index;
            unsigned int filterIndex;
            double output, interpolation, absoluteSampleValue;

            /*  RESET ACCUMULATOR TO ZERO  */
            output = 0.0;

            /*  CALCULATE INTERPOLATION VALUE (STATIC WHEN UPSAMPLING)  */
            interpolation = (double)mValue(timeRegister) / (double)M_RANGE;

            /*  COMPUTE THE LEFT SIDE OF THE FILTER CONVOLUTION  */
            index = emptyPtr;
            for (filterIndex = lValue(timeRegister);
                 filterIndex < FILTER_LENGTH;
                 srDecrement(&index, BUFFER_SIZE), filterIndex += filterIncrement) {
                output += buffer[index] * (h[filterIndex] + deltaH[filterIndex] * interpolation);
            }

            /*  ADJUST VALUES FOR RIGHT SIDE CALCULATION  */
            timeRegister = ~timeRegister;
            interpolation = (double)mValue(timeRegister) / (double)M_RANGE;

            /*  COMPUTE THE RIGHT SIDE OF THE FILTER CONVOLUTION  */
            index = emptyPtr;
            srIncrement(&index, BUFFER_SIZE);
            for (filterIndex = lValue(timeRegister);
                 filterIndex < FILTER_LENGTH;
                 srIncrement(&index, BUFFER_SIZE), filterIndex += filterIncrement) {
                output += buffer[index] * (h[filterIndex] + deltaH[filterIndex] * interpolation);
            }

            /*  RECORD MAXIMUM SAMPLE VALUE  */
            absoluteSampleValue = fabs(output);
            if (absoluteSampleValue > maximumSampleValue)
                maximumSampleValue = absoluteSampleValue;

            /*  INCREMENT SAMPLE NUMBER  */
            numberSamples++;

            /*  OUTPUT THE SAMPLE TO THE TEMPORARY FILE  */
            fwrite((char *)&output, sizeof(output), 1, tempFilePtr);

            /*  CHANGE TIME REGISTER BACK TO ORIGINAL FORM  */
            timeRegister = ~timeRegister;

            /*  INCREMENT THE TIME REGISTER  */
            timeRegister += timeRegisterIncrement;

            /*  INCREMENT THE EMPTY POINTER, ADJUSTING IT AND END POINTER  */
            emptyPtr += nValue(timeRegister);

            if (emptyPtr >= BUFFER_SIZE) {
                emptyPtr -= BUFFER_SIZE;
                endPtr -= BUFFER_SIZE;
            }

            /*  CLEAR N PART OF TIME REGISTER  */
            timeRegister &= (~N_MASK);
        }
    } else {
        printf("Downsampling...\n");
        /*  DOWNSAMPLING CONVERSION LOOP  */
        while (emptyPtr < endPtr) {
            int index;
            unsigned int phaseIndex, impulseIndex;
            double absoluteSampleValue, output, impulse;

            /*  RESET ACCUMULATOR TO ZERO  */
            output = 0.0;

            /*  COMPUTE P PRIME  */
            phaseIndex = (unsigned int)rint( ((double)fractionValue(timeRegister)) * sampleRateRatio);

            /*  COMPUTE THE LEFT SIDE OF THE FILTER CONVOLUTION  */
            index = emptyPtr;
            while ((impulseIndex = (phaseIndex>>M_BITS)) < FILTER_LENGTH) {
                impulse = h[impulseIndex] + (deltaH[impulseIndex] *
                    (((double)mValue(phaseIndex)) / (double)M_RANGE));
                output += (buffer[index] * impulse);
                srDecrement(&index, BUFFER_SIZE);
                phaseIndex += phaseIncrement;
            }

            /*  COMPUTE P PRIME, ADJUSTED FOR RIGHT SIDE  */
            phaseIndex = (unsigned int)rint( ((double)fractionValue(~timeRegister)) * sampleRateRatio);

            /*  COMPUTE THE RIGHT SIDE OF THE FILTER CONVOLUTION  */
            index = emptyPtr;
            srIncrement(&index, BUFFER_SIZE);
            while ((impulseIndex = (phaseIndex>>M_BITS)) < FILTER_LENGTH) {
                impulse = h[impulseIndex] + (deltaH[impulseIndex] *
                    (((double)mValue(phaseIndex)) / (double)M_RANGE));
                output += (buffer[index] * impulse);
                srIncrement(&index, BUFFER_SIZE);
                phaseIndex += phaseIncrement;
            }

            /*  RECORD MAXIMUM SAMPLE VALUE  */
            absoluteSampleValue = fabs(output);
            if (absoluteSampleValue > maximumSampleValue)
                maximumSampleValue = absoluteSampleValue;

            /*  INCREMENT SAMPLE NUMBER  */
            numberSamples++;

            /*  OUTPUT THE SAMPLE TO THE TEMPORARY FILE  */
            fwrite((char *)&output, sizeof(output), 1, tempFilePtr);

            /*  INCREMENT THE TIME REGISTER  */
            timeRegister += timeRegisterIncrement;

            /*  INCREMENT THE EMPTY POINTER, ADJUSTING IT AND END POINTER  */
            emptyPtr += nValue(timeRegister);
            if (emptyPtr >= BUFFER_SIZE) {
                emptyPtr -= BUFFER_SIZE;
                endPtr -= BUFFER_SIZE;
            }

            /*  CLEAR N PART OF TIME REGISTER  */
            timeRegister &= (~N_MASK);
        }
    }
    printf("numberSamples after: %ld\n", numberSamples);
    printf("<  dataEmpty()\n");
}



/******************************************************************************
*
*       function:       flushBuffer
*
*       purpose:        Pads the buffer with zero samples, and flushes it by
*                       converting the remaining samples.
*
*       arguments:      none
*
*       internal
*       functions:      dataFill, dataEmpty
*
*       library
*       functions:      none
*
******************************************************************************/

void flushBuffer(void)
{
    int i;


    /*  PAD END OF RING BUFFER WITH ZEROS  */
    for (i = 0; i < (padSize * 2); i++)
        dataFill(0.0);

    /*  FLUSH UP TO FILL POINTER - PADSIZE  */
    dataEmpty();
}



/******************************************************************************
*
*       function:       srIncrement
*
*       purpose:        Increments the pointer, keeping it within the range
*                       0 to (modulus-1).
*
*       arguments:      pointer, modulus
*
*       internal
*       functions:      none
*
*       library
*       functions:      none
*
******************************************************************************/

void srIncrement(int *pointer, int modulus)
{
    if ( ++(*pointer) >= modulus)
        (*pointer) -= modulus;
}



/******************************************************************************
*
*       function:       srDecrement
*
*       purpose:        Decrements the pointer, keeping it within the range
*                       0 to (modulus-1).
*
*       arguments:      pointer, modulus
*
*       internal
*       functions:      none
*
*       library
*       functions:      none
*
******************************************************************************/

void srDecrement(int *pointer, int modulus)
{
    if ( --(*pointer) < 0)
        (*pointer) += modulus;
}

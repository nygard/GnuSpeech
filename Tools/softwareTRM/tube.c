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
#include "util.h"
#include "structs.h"
#include "ring_buffer.h"
#include "wavetable.h"
#include "sample_rate_converter.h"


/*  GLOBAL FUNCTIONS (LOCAL TO THIS FILE)  ***********************************/

void initializeMouthCoefficients(TRMTubeModel *tubeModel, double coeff);
double reflectionFilter(TRMTubeModel *tubeModel, double input);
double radiationFilter(TRMTubeModel *tubeModel, double input);

void initializeNasalFilterCoefficients(TRMTubeModel *tubeModel, double coeff);
double nasalReflectionFilter(TRMTubeModel *tubeModel, double input);
double nasalRadiationFilter(TRMTubeModel *tubeModel, double input);

void setControlRateParameters(TRMTubeModel *tubeModel, INPUT *previousInput, INPUT *currentInput);
void sampleRateInterpolation(TRMTubeModel *tubeModel);
void initializeNasalCavity(TRMTubeModel *tubeModel, struct _TRMInputParameters *inputParameters);
void initializeThroat(TRMTubeModel *tubeModel, struct _TRMInputParameters *inputParameters);
void calculateTubeCoefficients(TRMTubeModel *tubeModel, struct _TRMInputParameters *inputParameters);
void setFricationTaps(TRMTubeModel *tubeModel);
void calculateBandpassCoefficients(TRMTubeModel *tubeModel, double fricCF, double fricBW, int sampleRate);
double vocalTract(TRMTubeModel *tubeModel, double input, double frication);
double throat(TRMTubeModel *tubeModel, double input);
double bandpassFilter(TRMTubeModel *tubeModel, double input);

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
******************************************************************************/

void initializeMouthCoefficients(TRMTubeModel *tubeModel, double coeff)
{
    tubeModel->b11 = -coeff;
    tubeModel->a10 = 1.0 - fabs(tubeModel->b11);

    tubeModel->a20 = coeff;
    tubeModel->a21 = tubeModel->b21 = -(tubeModel->a20);
}



/******************************************************************************
*
*       function:       reflectionFilter
*
*       purpose:        Is a variable, one-pole lowpass filter, whose cutoff
*                       is determined by the mouth aperture coefficient.
*
******************************************************************************/

double reflectionFilter(TRMTubeModel *tubeModel, double input)
{
    static double reflectionY = 0.0;

    double output = (tubeModel->a10 * input) - (tubeModel->b11 * reflectionY);
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
******************************************************************************/

double radiationFilter(TRMTubeModel *tubeModel, double input)
{
    static double radiationX = 0.0, radiationY = 0.0;

    double output = (tubeModel->a20 * input) + (tubeModel->a21 * radiationX) - (tubeModel->b21 * radiationY);
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
******************************************************************************/

void initializeNasalFilterCoefficients(TRMTubeModel *tubeModel, double coeff)
{
    tubeModel->nb11 = -coeff;
    tubeModel->na10 = 1.0 - fabs(tubeModel->nb11);

    tubeModel->na20 = coeff;
    tubeModel->na21 = tubeModel->nb21 = -(tubeModel->na20);
}



/******************************************************************************
*
*       function:       nasalReflectionFilter
*
*       purpose:        Is a one-pole lowpass filter, used for terminating
*                       the end of the nasal cavity.
*
******************************************************************************/

double nasalReflectionFilter(TRMTubeModel *tubeModel, double input)
{
    static double nasalReflectionY = 0.0;

    double output = (tubeModel->na10 * input) - (tubeModel->nb11 * nasalReflectionY);
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
******************************************************************************/

double nasalRadiationFilter(TRMTubeModel *tubeModel, double input)
{
    static double nasalRadiationX = 0.0, nasalRadiationY = 0.0; // This has got to go!

    double output = (tubeModel->na20 * input) + (tubeModel->na21 * nasalRadiationX) - (tubeModel->nb21 * nasalRadiationY);
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
******************************************************************************/

void TRMTubeModelSynthesize(TRMTubeModel *tubeModel, TRMData *data)
{
    int j;
    double f0, ax, ah1, pulse, lp_noise, pulsed_noise, signal, crossmix;
    INPUT *previousInput, *currentInput;

    /*  CONTROL RATE LOOP  */

    if (data->inputHead == NULL) {
        // No data
        return;
    }

    previousInput = data->inputHead;
    currentInput = data->inputHead->next;

    while (currentInput != NULL) {
        /*  SET CONTROL RATE PARAMETERS FROM INPUT TABLES  */
        setControlRateParameters(tubeModel, previousInput, currentInput);


        /*  SAMPLE RATE LOOP  */
        for (j = 0; j < tubeModel->controlPeriod; j++) {

            /*  CONVERT PARAMETERS HERE  */
            f0 = frequency(tubeModel->current.parameters.glotPitch);
            ax = amplitude(tubeModel->current.parameters.glotVol);
            ah1 = amplitude(tubeModel->current.parameters.aspVol);

            calculateTubeCoefficients(tubeModel, &data->inputParameters);
            setFricationTaps(tubeModel);
            calculateBandpassCoefficients(tubeModel, tubeModel->current.parameters.fricCF, tubeModel->current.parameters.fricBW, tubeModel->sampleRate);


            /*  DO SYNTHESIS HERE  */
            /*  CREATE LOW-PASS FILTERED NOISE  */
            lp_noise = noiseFilter(noise());

            /*  UPDATE THE SHAPE OF THE GLOTTAL PULSE, IF NECESSARY  */
            TRMWavetableUpdate(tubeModel->wavetable, ax);

            /*  CREATE GLOTTAL PULSE (OR SINE TONE)  */
            pulse = TRMWavetableOscillator(tubeModel->wavetable, f0);

            /*  CREATE PULSED NOISE  */
            pulsed_noise = lp_noise * pulse;

            /*  CREATE NOISY GLOTTAL PULSE  */
            pulse = ax * ((pulse * (1.0 - tubeModel->breathinessFactor)) + (pulsed_noise * tubeModel->breathinessFactor));

            /*  CROSS-MIX PURE NOISE WITH PULSED NOISE  */
            if (data->inputParameters.modulation) {
                crossmix = ax * tubeModel->crossmixFactor;
                crossmix = (crossmix < 1.0) ? crossmix : 1.0;
                signal = (pulsed_noise * crossmix) + (lp_noise * (1.0 - crossmix));
                if (verbose > 1) {
                    printf("\nSignal = %e", signal);
                    fflush(stdout);
                }
            } else
                signal = lp_noise;

            /*  PUT SIGNAL THROUGH VOCAL TRACT  */
            signal = vocalTract(tubeModel, ((pulse + (ah1 * signal)) * VT_SCALE), bandpassFilter(tubeModel, signal));


            /*  PUT PULSE THROUGH THROAT  */
            signal += throat(tubeModel, pulse * VT_SCALE);
            if (verbose > 1)
                printf("\nDone throat\n");

            /*  OUTPUT SAMPLE HERE  */
            dataFill(tubeModel->sampleRateConverter->ringBuffer, signal);
            if (verbose > 1)
                printf("\nDone datafil\n");

            /*  DO SAMPLE RATE INTERPOLATION OF CONTROL PARAMETERS  */
            sampleRateInterpolation(tubeModel);
            if (verbose > 1)
                printf("\nDone sample rate interp\n");

        }

        previousInput = currentInput;
        currentInput = currentInput->next;
    }

    /*  BE SURE TO FLUSH SRC BUFFER  */
    flushBuffer(tubeModel->sampleRateConverter->ringBuffer);
}


/******************************************************************************
*
*       function:       setControlRateParameters
*
*       purpose:        Calculates the current table values, and their
*                       associated sample-to-sample delta values.
*
******************************************************************************/

void setControlRateParameters(TRMTubeModel *tubeModel, INPUT *previousInput, INPUT *currentInput)
{
    int i;

    /*  GLOTTAL PITCH  */
    tubeModel->current.parameters.glotPitch = glotPitchAt(previousInput);
    tubeModel->current.delta.glotPitch = (glotPitchAt(currentInput) - tubeModel->current.parameters.glotPitch) / (double)tubeModel->controlPeriod;

    /*  GLOTTAL VOLUME  */
    tubeModel->current.parameters.glotVol = glotVolAt(previousInput);
    tubeModel->current.delta.glotVol = (glotVolAt(currentInput) - tubeModel->current.parameters.glotVol) / (double)tubeModel->controlPeriod;

    /*  ASPIRATION VOLUME  */
    tubeModel->current.parameters.aspVol = aspVolAt(previousInput);
    tubeModel->current.delta.aspVol = (aspVolAt(currentInput) - tubeModel->current.parameters.aspVol) / (double)tubeModel->controlPeriod;

    /*  FRICATION VOLUME  */
    tubeModel->current.parameters.fricVol = fricVolAt(previousInput);
    tubeModel->current.delta.fricVol = (fricVolAt(currentInput) - tubeModel->current.parameters.fricVol) / (double)tubeModel->controlPeriod;

    /*  FRICATION POSITION  */
    tubeModel->current.parameters.fricPos = fricPosAt(previousInput);
    tubeModel->current.delta.fricPos = (fricPosAt(currentInput) - tubeModel->current.parameters.fricPos) / (double)tubeModel->controlPeriod;

    /*  FRICATION CENTER FREQUENCY  */
    tubeModel->current.parameters.fricCF = fricCFAt(previousInput);
    tubeModel->current.delta.fricCF = (fricCFAt(currentInput) - tubeModel->current.parameters.fricCF) / (double)tubeModel->controlPeriod;

    /*  FRICATION BANDWIDTH  */
    tubeModel->current.parameters.fricBW = fricBWAt(previousInput);
    tubeModel->current.delta.fricBW = (fricBWAt(currentInput) - tubeModel->current.parameters.fricBW) / (double)tubeModel->controlPeriod;

    /*  TUBE REGION RADII  */
    for (i = 0; i < TOTAL_REGIONS; i++) {
        tubeModel->current.parameters.radius[i] = radiusAtRegion(previousInput, i);
        tubeModel->current.delta.radius[i] = (radiusAtRegion(currentInput,i) - tubeModel->current.parameters.radius[i]) / (double)tubeModel->controlPeriod;
    }

    /*  VELUM RADIUS  */
    tubeModel->current.parameters.velum = velumAt(previousInput);
    tubeModel->current.delta.velum = (velumAt(currentInput) - tubeModel->current.parameters.velum) / (double)tubeModel->controlPeriod;
}



/******************************************************************************
*
*       function:       sampleRateInterpolation
*
*       purpose:        Interpolates table values at the sample rate.
*
******************************************************************************/

void sampleRateInterpolation(TRMTubeModel *tubeModel)
{
    int i;

    tubeModel->current.parameters.glotPitch += tubeModel->current.delta.glotPitch;
    tubeModel->current.parameters.glotVol += tubeModel->current.delta.glotVol;
    tubeModel->current.parameters.aspVol += tubeModel->current.delta.aspVol;
    tubeModel->current.parameters.fricVol += tubeModel->current.delta.fricVol;
    tubeModel->current.parameters.fricPos += tubeModel->current.delta.fricPos;
    tubeModel->current.parameters.fricCF += tubeModel->current.delta.fricCF;
    tubeModel->current.parameters.fricBW += tubeModel->current.delta.fricBW;
    for (i = 0; i < TOTAL_REGIONS; i++)
        tubeModel->current.parameters.radius[i] += tubeModel->current.delta.radius[i];
    tubeModel->current.parameters.velum += tubeModel->current.delta.velum;
}



/******************************************************************************
*
*       function:       initializeNasalCavity
*
*       purpose:        Calculates the scattering coefficients for the fixed
*                       sections of the nasal cavity.
*
******************************************************************************/

void initializeNasalCavity(TRMTubeModel *tubeModel, struct _TRMInputParameters *inputParameters)
{
    int i, j;
    double radA2, radB2;


    /*  CALCULATE COEFFICIENTS FOR INTERNAL FIXED SECTIONS OF NASAL CAVITY  */
    for (i = TRM_N2, j = NC2; i < TRM_N6; i++, j++) {
        radA2 = inputParameters->noseRadius[i] * inputParameters->noseRadius[i];
        radB2 = inputParameters->noseRadius[i+1] * inputParameters->noseRadius[i+1];
        tubeModel->nasal_coeff[j] = (radA2 - radB2) / (radA2 + radB2);
    }

    /*  CALCULATE THE FIXED COEFFICIENT FOR THE NOSE APERTURE  */
    radA2 = inputParameters->noseRadius[TRM_N6] * inputParameters->noseRadius[TRM_N6];
    radB2 = inputParameters->apScale * inputParameters->apScale;
    tubeModel->nasal_coeff[NC6] = (radA2 - radB2) / (radA2 + radB2);
}



/******************************************************************************
*
*       function:       initializeThroat
*
*       purpose:        Initializes the throat lowpass filter coefficients
*                       according to the throatCutoff value, and also the
*                       throatGain, according to the throatVol value.
*
******************************************************************************/

void initializeThroat(TRMTubeModel *tubeModel, struct _TRMInputParameters *inputParameters)
{
    tubeModel->ta0 = (inputParameters->throatCutoff * 2.0) / tubeModel->sampleRate;
    tubeModel->tb1 = 1.0 - tubeModel->ta0;

    tubeModel->throatGain = amplitude(inputParameters->throatVol);
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
******************************************************************************/

void calculateTubeCoefficients(TRMTubeModel *tubeModel, struct _TRMInputParameters *inputParameters)
{
    int i;
    double radA, radB;
    double radA2, radB2; // squared values
    double r0_2, r1_2, r2_2, sum;

    // Calculate coefficients for the oropharynx
    for (i = 0; i < TOTAL_REGIONS - 1; i++) {
        radA = tubeModel->current.parameters.radius[i];
        radB = tubeModel->current.parameters.radius[i+1];
        radA2 = radA * radA;
        radB2 = radB * radB;
        tubeModel->oropharynx_coeff[i] = (radA2 - radB2) / (radA2 + radB2);
    }

    // Calculate the coefficient for the mouth aperture
    radA = tubeModel->current.parameters.radius[TRM_R8];
    radB = inputParameters->apScale;
    radA2 = radA * radA;
    radB2 = radB * radB;
    tubeModel->oropharynx_coeff[C8] = (radA2 - radB2) / (radA2 + radB2);

    // Calculate alpha coefficients for 3-way junction
    // NOTE:  Since junction is in middle of region 4, r0_2 = r1_2
    radA = tubeModel->current.parameters.radius[TRM_R4];
    radB = tubeModel->current.parameters.velum;
    r0_2 = r1_2 = radA * radA;
    r2_2 = radB * radB;
    sum = 2.0 / (r0_2 + r1_2 + r2_2);
    tubeModel->alpha[LEFT] = sum * r0_2;
    tubeModel->alpha[RIGHT] = sum * r1_2;
    tubeModel->alpha[UPPER] = sum * r2_2;

    // And 1st nasal passage coefficient
    radA = tubeModel->current.parameters.velum;
    radB = inputParameters->noseRadius[TRM_N2];
    radA2 = radA * radA;
    radB2 = radB * radB;
    tubeModel->nasal_coeff[NC1] = (radA2 - radB2) / (radA2 + radB2);
}



/******************************************************************************
*
*       function:       setFricationTaps
*
*       purpose:        Sets the frication taps according to the current
*                       position and amplitude of frication.
*
******************************************************************************/

void setFricationTaps(TRMTubeModel *tubeModel)
{
    int i, integerPart;
    double complement, remainder;
    double fricationAmplitude = amplitude(tubeModel->current.parameters.fricVol);


    /*  CALCULATE POSITION REMAINDER AND COMPLEMENT  */
    integerPart = (int)tubeModel->current.parameters.fricPos;
    complement = tubeModel->current.parameters.fricPos - (double)integerPart;
    remainder = 1.0 - complement;

    /*  SET THE FRICATION TAPS  */
    for (i = FC1; i < TOTAL_FRIC_COEFFICIENTS; i++) {
        if (i == integerPart) {
            tubeModel->fricationTap[i] = remainder * fricationAmplitude;
            if ((i+1) < TOTAL_FRIC_COEFFICIENTS)
                tubeModel->fricationTap[++i] = complement * fricationAmplitude;
        } else
            tubeModel->fricationTap[i] = 0.0;
    }

#if DEBUG
    /*  PRINT OUT  */
    printf("fricationTaps:  ");
    for (i = FC1; i < TOTAL_FRIC_COEFFICIENTS; i++)
        printf("%.6f  ", tubeModel->fricationTap[i]);
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
******************************************************************************/

// TODO (2004-05-13): I imagine passing this a bandpass filter object (which won't have the sample rate) and the sample rate in the future.
void calculateBandpassCoefficients(TRMTubeModel *tubeModel, double fricCF, double fricBW, int sampleRate)
{
    double tanValue, cosValue;

    tanValue = tan((M_PI * fricBW) / sampleRate);
    cosValue = cos((2.0 * M_PI * fricCF) / sampleRate);

    tubeModel->bpBeta = (1.0 - tanValue) / (2.0 * (1.0 + tanValue));
    tubeModel->bpGamma = (0.5 + tubeModel->bpBeta) * cosValue;
    tubeModel->bpAlpha = (0.5 - tubeModel->bpBeta) / 2.0;
}



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
******************************************************************************/

double vocalTract(TRMTubeModel *tubeModel, double input, double frication)
{
    int i, j, k;
    double delta, output, junctionPressure;

    // copies to shorten code
    int current_ptr, prev_ptr;
    double dampingFactor;


    /*  INCREMENT CURRENT AND PREVIOUS POINTERS  */
    if (++(tubeModel->current_ptr) > 1)
        tubeModel->current_ptr = 0;
    if (++(tubeModel->prev_ptr) > 1)
        tubeModel->prev_ptr = 0;

    current_ptr = tubeModel->current_ptr;
    prev_ptr = tubeModel->prev_ptr;
    dampingFactor = tubeModel->dampingFactor;

    /*  UPDATE OROPHARYNX  */
    /*  INPUT TO TOP OF TUBE  */

    tubeModel->oropharynx[S1][TOP][current_ptr] = (tubeModel->oropharynx[S1][BOTTOM][prev_ptr] * dampingFactor) + input;

    /*  CALCULATE THE SCATTERING JUNCTIONS FOR S1-S2  */

    delta = tubeModel->oropharynx_coeff[C1] * (tubeModel->oropharynx[S1][TOP][prev_ptr] - tubeModel->oropharynx[S2][BOTTOM][prev_ptr]);
    tubeModel->oropharynx[S2][TOP][current_ptr] = (tubeModel->oropharynx[S1][TOP][prev_ptr] + delta) * dampingFactor;
    tubeModel->oropharynx[S1][BOTTOM][current_ptr] = (tubeModel->oropharynx[S2][BOTTOM][prev_ptr] + delta) * dampingFactor;

    /*  CALCULATE THE SCATTERING JUNCTIONS FOR S2-S3 AND S3-S4  */
    if (verbose > 1)
        printf("\nCalc scattering\n");
    for (i = S2, j = C2, k = FC1; i < S4; i++, j++, k++) {
        delta = tubeModel->oropharynx_coeff[j] * (tubeModel->oropharynx[i][TOP][prev_ptr] - tubeModel->oropharynx[i+1][BOTTOM][prev_ptr]);
        tubeModel->oropharynx[i+1][TOP][current_ptr] =
            ((tubeModel->oropharynx[i][TOP][prev_ptr] + delta) * dampingFactor) +
                (tubeModel->fricationTap[k] * frication);
        tubeModel->oropharynx[i][BOTTOM][current_ptr] = (tubeModel->oropharynx[i+1][BOTTOM][prev_ptr] + delta) * dampingFactor;
    }

    /*  UPDATE 3-WAY JUNCTION BETWEEN THE MIDDLE OF R4 AND NASAL CAVITY  */
    junctionPressure = (tubeModel->alpha[LEFT] * tubeModel->oropharynx[S4][TOP][prev_ptr])+
        (tubeModel->alpha[RIGHT] * tubeModel->oropharynx[S5][BOTTOM][prev_ptr]) +
        (tubeModel->alpha[UPPER] * tubeModel->nasal[TRM_VELUM][BOTTOM][prev_ptr]);
    tubeModel->oropharynx[S4][BOTTOM][current_ptr] = (junctionPressure - tubeModel->oropharynx[S4][TOP][prev_ptr]) * dampingFactor;
    tubeModel->oropharynx[S5][TOP][current_ptr] =
        ((junctionPressure - tubeModel->oropharynx[S5][BOTTOM][prev_ptr]) * dampingFactor)
            + (tubeModel->fricationTap[FC3] * frication);
    tubeModel->nasal[TRM_VELUM][TOP][current_ptr] = (junctionPressure - tubeModel->nasal[TRM_VELUM][BOTTOM][prev_ptr]) * dampingFactor;

    /*  CALCULATE JUNCTION BETWEEN R4 AND R5 (S5-S6)  */
    delta = tubeModel->oropharynx_coeff[C4] * (tubeModel->oropharynx[S5][TOP][prev_ptr] - tubeModel->oropharynx[S6][BOTTOM][prev_ptr]);
    tubeModel->oropharynx[S6][TOP][current_ptr] =
        ((tubeModel->oropharynx[S5][TOP][prev_ptr] + delta) * dampingFactor) +
            (tubeModel->fricationTap[FC4] * frication);
    tubeModel->oropharynx[S5][BOTTOM][current_ptr] = (tubeModel->oropharynx[S6][BOTTOM][prev_ptr] + delta) * dampingFactor;

    /*  CALCULATE JUNCTION INSIDE R5 (S6-S7) (PURE DELAY WITH DAMPING)  */
    tubeModel->oropharynx[S7][TOP][current_ptr] =
        (tubeModel->oropharynx[S6][TOP][prev_ptr] * dampingFactor) +
            (tubeModel->fricationTap[FC5] * frication);
    tubeModel->oropharynx[S6][BOTTOM][current_ptr] = tubeModel->oropharynx[S7][BOTTOM][prev_ptr] * dampingFactor;

    /*  CALCULATE LAST 3 INTERNAL JUNCTIONS (S7-S8, S8-S9, S9-S10)  */
    for (i = S7, j = C5, k = FC6; i < S10; i++, j++, k++) {
        delta = tubeModel->oropharynx_coeff[j] * (tubeModel->oropharynx[i][TOP][prev_ptr] - tubeModel->oropharynx[i+1][BOTTOM][prev_ptr]);
        tubeModel->oropharynx[i+1][TOP][current_ptr] =
            ((tubeModel->oropharynx[i][TOP][prev_ptr] + delta) * dampingFactor) +
                (tubeModel->fricationTap[k] * frication);
        tubeModel->oropharynx[i][BOTTOM][current_ptr] = (tubeModel->oropharynx[i+1][BOTTOM][prev_ptr] + delta) * dampingFactor;
    }

    /*  REFLECTED SIGNAL AT MOUTH GOES THROUGH A LOWPASS FILTER  */
    tubeModel->oropharynx[S10][BOTTOM][current_ptr] =  dampingFactor *
        reflectionFilter(tubeModel, tubeModel->oropharynx_coeff[C8] * tubeModel->oropharynx[S10][TOP][prev_ptr]);

    /*  OUTPUT FROM MOUTH GOES THROUGH A HIGHPASS FILTER  */
    output = radiationFilter(tubeModel, (1.0 + tubeModel->oropharynx_coeff[C8]) * tubeModel->oropharynx[S10][TOP][prev_ptr]);


    /*  UPDATE NASAL CAVITY  */
    for (i = TRM_VELUM, j = NC1; i < TRM_N6; i++, j++) {
        delta = tubeModel->nasal_coeff[j] * (tubeModel->nasal[i][TOP][prev_ptr] - tubeModel->nasal[i+1][BOTTOM][prev_ptr]);
        tubeModel->nasal[i+1][TOP][current_ptr] = (tubeModel->nasal[i][TOP][prev_ptr] + delta) * dampingFactor;
        tubeModel->nasal[i][BOTTOM][current_ptr] = (tubeModel->nasal[i+1][BOTTOM][prev_ptr] + delta) * dampingFactor;
    }

    /*  REFLECTED SIGNAL AT NOSE GOES THROUGH A LOWPASS FILTER  */
    tubeModel->nasal[TRM_N6][BOTTOM][current_ptr] = dampingFactor * nasalReflectionFilter(tubeModel, tubeModel->nasal_coeff[NC6] * tubeModel->nasal[TRM_N6][TOP][prev_ptr]);

    /*  OUTPUT FROM NOSE GOES THROUGH A HIGHPASS FILTER  */
    output += nasalRadiationFilter(tubeModel, (1.0 + tubeModel->nasal_coeff[NC6]) * tubeModel->nasal[TRM_N6][TOP][prev_ptr]);

    /*  RETURN SUMMED OUTPUT FROM MOUTH AND NOSE  */
    return output;
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
******************************************************************************/

double throat(TRMTubeModel *tubeModel, double input)
{
    static double throatY = 0.0;

    double output = (tubeModel->ta0 * input) + (tubeModel->tb1 * throatY);
    throatY = output;
    return (output * tubeModel->throatGain);
}



/******************************************************************************
*
*       function:       bandpassFilter
*
*       purpose:        Frication bandpass filter, with variable center
*                       frequency and bandwidth.
*
******************************************************************************/

double bandpassFilter(TRMTubeModel *tubeModel, double input)
{
    static double xn1 = 0.0, xn2 = 0.0, yn1 = 0.0, yn2 = 0.0;
    double output;


    output = 2.0 * ((tubeModel->bpAlpha * (input - xn2)) + (tubeModel->bpGamma * yn1) - (tubeModel->bpBeta * yn2));

    xn2 = xn1;
    xn1 = input;
    yn2 = yn1;
    yn1 = output;

    return output;
}


TRMTubeModel *TRMTubeModelCreate(TRMInputParameters *inputParameters)
{
    TRMTubeModel *newTubeModel;
    double nyquist;

    newTubeModel = (TRMTubeModel *)malloc(sizeof(TRMTubeModel));
    if (newTubeModel == NULL) {
        fprintf(stderr, "Failed to malloc() space for tube model.\n");
        return NULL;
    }

    memset(newTubeModel, 0, sizeof(TRMTubeModel));

    // Calculate the sample rate, based on nominal tube length and speed of sound
    if (inputParameters->length > 0.0) {
        double c = speedOfSound(inputParameters->temperature);

        newTubeModel->controlPeriod = rint((c * TOTAL_SECTIONS * 100.0) / (inputParameters->length * inputParameters->controlRate));
        newTubeModel->sampleRate = inputParameters->controlRate * newTubeModel->controlPeriod;
        newTubeModel->actualTubeLength = (c * TOTAL_SECTIONS * 100.0) / newTubeModel->sampleRate;
        nyquist = (double)newTubeModel->sampleRate / 2.0;
    } else {
        fprintf(stderr, "Illegal tube length: %g\n", inputParameters->length);
        free(newTubeModel);
        return NULL;
    }

    newTubeModel->breathinessFactor = inputParameters->breathiness / 100.0;
    newTubeModel->crossmixFactor = 1.0 / amplitude(inputParameters->mixOffset);
    newTubeModel->dampingFactor = (1.0 - (inputParameters->lossFactor / 100.0));

    // Initialize the wave table
    newTubeModel->wavetable = TRMWavetableCreate(inputParameters->waveform, inputParameters->tp, inputParameters->tnMin, inputParameters->tnMax, newTubeModel->sampleRate);

    /*  INITIALIZE REFLECTION AND RADIATION FILTER COEFFICIENTS FOR MOUTH  */
    initializeMouthCoefficients(newTubeModel, (nyquist - inputParameters->mouthCoef) / nyquist);

    /*  INITIALIZE REFLECTION AND RADIATION FILTER COEFFICIENTS FOR NOSE  */
    initializeNasalFilterCoefficients(newTubeModel, (nyquist - inputParameters->noseCoef) / nyquist);

    /*  INITIALIZE NASAL CAVITY FIXED SCATTERING COEFFICIENTS  */
    initializeNasalCavity(newTubeModel, inputParameters);

    // TODO (2004-05-07): nasal?

    /*  INITIALIZE THE THROAT LOWPASS FILTER  */
    initializeThroat(newTubeModel, inputParameters);

    /*  INITIALIZE THE SAMPLE RATE CONVERSION ROUTINES  */
    newTubeModel->sampleRateConverter = TRMSampleRateConverterCreate(newTubeModel->sampleRate, inputParameters->outputRate);

    // These get calculated each time through the synthesize() loop:
    //newTubeModel->bpAlpha = 0.0;
    //newTubeModel->bpBeta = 0.0;
    //newTubeModel->bpGamma = 0.0;

    // TODO (2004-05-07): oropharynx
    // TODO (2004-05-07): alpha

    newTubeModel->current_ptr = 1;
    newTubeModel->prev_ptr = 0;

    // TODO (2004-05-07): fricationTap

    return newTubeModel;
}

void TRMTubeModelFree(TRMTubeModel *tubeModel)
{
    if (tubeModel == NULL)
        return;

    if (tubeModel->sampleRateConverter != NULL) {
        TRMSampleRateConverterFree(tubeModel->sampleRateConverter);
        tubeModel->sampleRateConverter = NULL;
    }

    if (tubeModel->wavetable != NULL) {
        TRMWavetableFree(tubeModel->wavetable);
        tubeModel->wavetable = NULL;
    }

    free(tubeModel);
}

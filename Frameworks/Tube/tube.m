//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

// Software (non-real-time) implementation of the Tube Resonance Model for speech production.

#include <stdio.h>
#include <stdlib.h>
#include <sys/param.h>
#include <math.h>
#include <string.h>
#include "tube.h"
#include "fir.h"
#include "util.h"
#include "structs.h"
#include "ring_buffer.h"
#include "wavetable.h"

#import "TRMInputParameters.h"
#import "TRMParameters.h"
#import "TRMDataList.h"

BOOL verbose = NO;


#pragma mark - Local defines

// 1 means to compile so that interpolation not done for some control rate parameters
#define MATCH_DSP 0


#pragma mark - Local funcations

static void initializeMouthCoefficients(TRMTubeModel *tubeModel, double coeff);
static double reflectionFilter(TRMTubeModel *tubeModel, double input);
static double radiationFilter(TRMTubeModel *tubeModel, double input);

static void initializeNasalFilterCoefficients(TRMTubeModel *tubeModel, double coeff);
static double nasalReflectionFilter(TRMTubeModel *tubeModel, double input);
static double nasalRadiationFilter(TRMTubeModel *tubeModel, double input);

static void setControlRateParameters(TRMTubeModel *tubeModel, TRMParameters *previous, TRMParameters *current);
static void sampleRateInterpolation(TRMTubeModel *tubeModel);
static void initializeNasalCavity(TRMTubeModel *tubeModel, TRMInputParameters *inputParameters);
static void initializeThroat(TRMTubeModel *tubeModel, TRMInputParameters *inputParameters);
static void calculateTubeCoefficients(TRMTubeModel *tubeModel, TRMInputParameters *inputParameters);
static void setFricationTaps(TRMTubeModel *tubeModel);
static void calculateBandpassCoefficients(TRMTubeModel *tubeModel, int32_t sampleRate);
static double vocalTract(TRMTubeModel *tubeModel, double input, double frication);
static double throat(TRMTubeModel *tubeModel, double input);
static double bandpassFilter(TRMTubeModel *tubeModel, double input);

static void initializeConversion(TRMTubeModel *tubeModel, TRMInputParameters *inputParameters);
static void resampleBuffer(struct _TRMRingBuffer *aRingBuffer, void *context);
static void initializeFilter(TRMSampleRateConverter *sampleRateConverter);


// Calculates the reflection/radiation filter coefficients for the mouth, according to the mouth aperture coefficient.
// coeff - mouth aperture coefficient

void initializeMouthCoefficients(TRMTubeModel *tubeModel, double coeff)
{
    tubeModel->b11 = -coeff;
    tubeModel->a10 = 1.0 - fabs(tubeModel->b11);

    tubeModel->a20 = coeff;
    tubeModel->a21 = tubeModel->b21 = -(tubeModel->a20);
}


// Is a variable, one-pole lowpass filter, whose cutoff is determined by the mouth aperture coefficient.

double reflectionFilter(TRMTubeModel *tubeModel, double input)
{
    static double reflectionY = 0.0;

    double output = (tubeModel->a10 * input) - (tubeModel->b11 * reflectionY);
    reflectionY = output;
    return output;
}

// Is a variable, one-zero, one-pole, highpass filter, whose cutoff point is determined by the mouth aperture coefficient.

double radiationFilter(TRMTubeModel *tubeModel, double input)
{
    static double radiationX = 0.0, radiationY = 0.0;

    double output = (tubeModel->a20 * input) + (tubeModel->a21 * radiationX) - (tubeModel->b21 * radiationY);
    radiationX = input;
    radiationY = output;
    return output;
}

// Calculates the fixed coefficients for the nasal reflection/radiation filter pair, according to the nose aperture coefficient.
// coeff - nose aperture coefficient

void initializeNasalFilterCoefficients(TRMTubeModel *tubeModel, double coeff)
{
    tubeModel->nb11 = -coeff;
    tubeModel->na10 = 1.0 - fabs(tubeModel->nb11);

    tubeModel->na20 = coeff;
    tubeModel->na21 = tubeModel->nb21 = -(tubeModel->na20);
}


// Is a one-pole lowpass filter, used for terminating the end of the nasal cavity.

double nasalReflectionFilter(TRMTubeModel *tubeModel, double input)
{
    static double nasalReflectionY = 0.0;

    double output = (tubeModel->na10 * input) - (tubeModel->nb11 * nasalReflectionY);
    nasalReflectionY = output;
    return output;
}


// Is a one-zero, one-pole highpass filter, used for the radiation characteristic from the nasal cavity.

double nasalRadiationFilter(TRMTubeModel *tubeModel, double input)
{
    static double nasalRadiationX = 0.0, nasalRadiationY = 0.0;

    double output = (tubeModel->na20 * input) + (tubeModel->na21 * nasalRadiationX) - (tubeModel->nb21 * nasalRadiationY);
    nasalRadiationX = input;
    nasalRadiationY = output;
    return output;
}

// Performs the actual synthesis of sound samples.

void synthesize(TRMTubeModel *tubeModel, TRMDataList *data)
{
    int32_t j;
    double f0, ax, ah1, pulse, lp_noise, pulsed_noise, signal, crossmix;

    if ([data.values count] == 0) {
        // No data
        return;
    }
    
    // Control rate loop
    TRMParameters *previous = nil;

    for (TRMParameters *parameters in data.values) {
        if (previous == nil) {
            previous = parameters;
            continue;
        }
        
        // Set control rate parameters from input tables
        setControlRateParameters(tubeModel, previous, parameters);


        // Sample rate loop
        for (j = 0; j < tubeModel->controlPeriod; j++) {

            // Convert parameters here
            f0 = frequency(tubeModel->current.parameters.glotPitch);
            ax = amplitude(tubeModel->current.parameters.glotVol);
            ah1 = amplitude(tubeModel->current.parameters.aspVol);
            calculateTubeCoefficients(tubeModel, data.inputParameters);
            setFricationTaps(tubeModel);
            calculateBandpassCoefficients(tubeModel, tubeModel->sampleRate);


            // Do synthesis here
            // Create low-pass filtered noise
            lp_noise = noiseFilter(noise());

            // Update the shape of the glottal pulse, if necessary
            if (data.inputParameters.waveform == PULSE)
                TRMWavetableUpdate(tubeModel->wavetable, ax);

            // Create glottal pulse (or sine tone)
            pulse = TRMWavetableOscillator(tubeModel->wavetable, f0);

            // Create pulsed noise
            pulsed_noise = lp_noise * pulse;

            // Create noisy glottal pulse
            pulse = ax * ((pulse * (1.0 - tubeModel->breathinessFactor)) + (pulsed_noise * tubeModel->breathinessFactor));

            // Cross-mix pure noise with pulsed noise
            if (data.inputParameters.modulation) {
                crossmix = ax * tubeModel->crossmixFactor;
                crossmix = (crossmix < 1.0) ? crossmix : 1.0;
                signal = (pulsed_noise * crossmix) + (lp_noise * (1.0 - crossmix));
                if (verbose) {
                    printf("\nSignal = %e", signal);
                    fflush(stdout);
                }
            } else
                signal = lp_noise;

            // Put signal through vocal tract
            signal = vocalTract(tubeModel, ((pulse + (ah1 * signal)) * VT_SCALE), bandpassFilter(tubeModel, signal));


            // Put pulse through throat
            signal += throat(tubeModel, pulse * VT_SCALE);
            if (verbose)
                printf("\nDone throat\n");

            // Output sample
            dataFill(tubeModel->ringBuffer, signal);
            if (verbose)
                printf("\nDone datafil\n");

            // Do sample rate interpolation of control parameters
            sampleRateInterpolation(tubeModel);
            if (verbose)
                printf("\nDone sample rate interp\n");
        }
        
        previous = parameters;
    }

    // Be sure to flush source buffer
    flushBuffer(tubeModel->ringBuffer);
}

// Calculates the current table values, and their associated sample-to-sample delta values.

void setControlRateParameters(TRMTubeModel *tubeModel, TRMParameters *previousInput, TRMParameters *currentInput)
{
    int32_t i;

    // Glottal pitch
    tubeModel->current.parameters.glotPitch = previousInput.glotPitch;
    tubeModel->current.delta.glotPitch = (currentInput.glotPitch - tubeModel->current.parameters.glotPitch) / (double)tubeModel->controlPeriod;

    // Glottal volume
    tubeModel->current.parameters.glotVol = previousInput.glotVol;
    tubeModel->current.delta.glotVol = (currentInput.glotVol - tubeModel->current.parameters.glotVol) / (double)tubeModel->controlPeriod;

    // Aspiration volume
    tubeModel->current.parameters.aspVol = previousInput.aspVol;
#if MATCH_DSP
    tubeModel->current.delta.aspVol = 0.0;
#else
    tubeModel->current.delta.aspVol = (currentInput.aspVol - tubeModel->current.parameters.aspVol) / (double)tubeModel->controlPeriod;
#endif

    // Frication volume
    tubeModel->current.parameters.fricVol = previousInput.fricVol;
#if MATCH_DSP
    tubeModel->current.delta.fricVol = 0.0;
#else
    tubeModel->current.delta.fricVol = (currentInput.fricVol - tubeModel->current.parameters.fricVol) / (double)tubeModel->controlPeriod;
#endif

    // Frication position
    tubeModel->current.parameters.fricPos = previousInput.fricPos;
#if MATCH_DSP
    tubeModel->current.delta.fricPos = 0.0;
#else
    tubeModel->current.delta.fricPos = (currentInput.fricPos - tubeModel->current.parameters.fricPos) / (double)tubeModel->controlPeriod;
#endif

    // Frication center frequency
    tubeModel->current.parameters.fricCF = previousInput.fricCF;
#if MATCH_DSP
    tubeModel->current.delta.fricCF = 0.0;
#else
    tubeModel->current.delta.fricCF = (currentInput.fricCF - tubeModel->current.parameters.fricCF) / (double)tubeModel->controlPeriod;
#endif

    // Frication bandwidth
    tubeModel->current.parameters.fricBW = previousInput.fricBW;
#if MATCH_DSP
    tubeModel->current.delta.fricBW = 0.0;
#else
    tubeModel->current.delta.fricBW = (currentInput.fricBW - tubeModel->current.parameters.fricBW) / (double)tubeModel->controlPeriod;
#endif

    // Tube region radii
    for (i = 0; i < TOTAL_REGIONS; i++) {
        tubeModel->current.parameters.radius[i] = previousInput.radius[i];
        tubeModel->current.delta.radius[i] = (currentInput.radius[i] - tubeModel->current.parameters.radius[i]) / (double)tubeModel->controlPeriod;
    }

    // Velum radius
    tubeModel->current.parameters.velum = previousInput.velum;
    tubeModel->current.delta.velum = (currentInput.velum - tubeModel->current.parameters.velum) / (double)tubeModel->controlPeriod;
}


// Interpolates table values at the sample rate.

void sampleRateInterpolation(TRMTubeModel *tubeModel)
{
    int32_t i;

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


// Calculates the scattering coefficients for the fixed sections of the nasal cavity.

void initializeNasalCavity(TRMTubeModel *tubeModel, TRMInputParameters *inputParameters)
{
    int32_t i, j;
    double radA2, radB2;


    // Calculate coefficients for internal fixed sections of nasal cavity
    for (i = TRM_N2, j = NC2; i < TRM_N6; i++, j++) {
        radA2 = inputParameters.noseRadius[i] * inputParameters.noseRadius[i];
        radB2 = inputParameters.noseRadius[i+1] * inputParameters.noseRadius[i+1];
        tubeModel->nasal_coeff[j] = (radA2 - radB2) / (radA2 + radB2);
    }

    // Calculate the fixed coefficient for the nose aperture
    radA2 = inputParameters.noseRadius[TRM_N6] * inputParameters.noseRadius[TRM_N6];
    radB2 = inputParameters.apScale * inputParameters.apScale;
    tubeModel->nasal_coeff[NC6] = (radA2 - radB2) / (radA2 + radB2);
}


// Initializes the throat lowpass filter coefficients according to the throatCutoff value, and also the throatGain, according to the throatVol value.

void initializeThroat(TRMTubeModel *tubeModel, TRMInputParameters *inputParameters)
{
    tubeModel->ta0 = (inputParameters.throatCutoff * 2.0) / tubeModel->sampleRate;
    tubeModel->tb1 = 1.0 - tubeModel->ta0;

    tubeModel->throatGain = amplitude(inputParameters.throatVol);
}


// Calculates the scattering coefficients for the vocal tract according to the current radii.  Also calculates
// the coefficients for the reflection/radiation filter pair for the mouth and nose.

void calculateTubeCoefficients(TRMTubeModel *tubeModel, TRMInputParameters *inputParameters)
{
    int32_t i;
    double radA2, radB2, r0_2, r1_2, r2_2, sum;


    // Calcualte coefficients for the oropharynx
    for (i = 0; i < (TOTAL_REGIONS-1); i++) {
        radA2 = tubeModel->current.parameters.radius[i] * tubeModel->current.parameters.radius[i];
        radB2 = tubeModel->current.parameters.radius[i+1] * tubeModel->current.parameters.radius[i+1];
        tubeModel->oropharynx_coeff[i] = (radA2 - radB2) / (radA2 + radB2);
    }

    // Calculate the coefficient for the mouth aperture
    radA2 = tubeModel->current.parameters.radius[TRM_R8] * tubeModel->current.parameters.radius[TRM_R8];
    radB2 = inputParameters.apScale * inputParameters.apScale;
    tubeModel->oropharynx_coeff[C8] = (radA2 - radB2) / (radA2 + radB2);

    // Calculate alpha coefficients for 3-way junction
    // Note: Since junction is in middle of region 4, r0_2 = r1_2
    r0_2 = r1_2 = tubeModel->current.parameters.radius[TRM_R4] * tubeModel->current.parameters.radius[TRM_R4];
    r2_2 = tubeModel->current.parameters.velum * tubeModel->current.parameters.velum;
    sum = 2.0 / (r0_2 + r1_2 + r2_2);
    tubeModel->alpha[LEFT] = sum * r0_2;
    tubeModel->alpha[RIGHT] = sum * r1_2;
    tubeModel->alpha[UPPER] = sum * r2_2;

    // And first nasal passage coefficient
    radA2 = tubeModel->current.parameters.velum * tubeModel->current.parameters.velum;
    radB2 = inputParameters.noseRadius[TRM_N2] * inputParameters.noseRadius[TRM_N2];
    tubeModel->nasal_coeff[NC1] = (radA2 - radB2) / (radA2 + radB2);
}


// Sets the frication taps according to the current position and amplitude of frication.

void setFricationTaps(TRMTubeModel *tubeModel)
{
    int32_t i, integerPart;
    double complement, remainder;
    double fricationAmplitude = amplitude(tubeModel->current.parameters.fricVol);


    // Calculate position remainder and complement
    integerPart = (int)tubeModel->current.parameters.fricPos;
    complement = tubeModel->current.parameters.fricPos - (double)integerPart;
    remainder = 1.0 - complement;

    // Set the frication taps
    for (i = FC1; i < TOTAL_FRIC_COEFFICIENTS; i++) {
        if (i == integerPart) {
            tubeModel->fricationTap[i] = remainder * fricationAmplitude;
            if ((i+1) < TOTAL_FRIC_COEFFICIENTS)
                tubeModel->fricationTap[++i] = complement * fricationAmplitude;
        } else
            tubeModel->fricationTap[i] = 0.0;
    }

#if DEBUG
    printf("fricationTaps:  ");
    for (i = FC1; i < TOTAL_FRIC_COEFFICIENTS; i++)
        printf("%.6f  ", tubeModel->fricationTap[i]);
    printf("\n");
#endif
}

// Sets the frication bandpass filter coefficients according to the current center frequency and bandwidth.

// TODO (2004-05-13): I imagine passing this a bandpass filter object (which won't have the sample rate) and the sample rate in the future.
void calculateBandpassCoefficients(TRMTubeModel *tubeModel, int sampleRate)
{
    double tanValue, cosValue;


    tanValue = tan((PI * tubeModel->current.parameters.fricBW) / sampleRate);
    cosValue = cos((2.0 * PI * tubeModel->current.parameters.fricCF) / sampleRate);

    tubeModel->bpBeta = (1.0 - tanValue) / (2.0 * (1.0 + tanValue));
    tubeModel->bpGamma = (0.5 + tubeModel->bpBeta) * cosValue;
    tubeModel->bpAlpha = (0.5 - tubeModel->bpBeta) / 2.0;
}


// Updates the pressure wave throughout the vocal tract, and returns the summed output of the oral and nasal
// cavities.  Also injects frication appropriately.

double vocalTract(TRMTubeModel *tubeModel, double input, double frication)
{
    int32_t i, j, k;
    double delta, output, junctionPressure;

    // copies to shorten code
    int current_ptr, prev_ptr;
    double dampingFactor;


    // Increment current and previous pointers
    if (++(tubeModel->current_ptr) > 1)
        tubeModel->current_ptr = 0;
    if (++(tubeModel->prev_ptr) > 1)
        tubeModel->prev_ptr = 0;

    current_ptr = tubeModel->current_ptr;
    prev_ptr = tubeModel->prev_ptr;
    dampingFactor = tubeModel->dampingFactor;

    // Upate oropharynx
    // Input to top of tube

    tubeModel->oropharynx[S1][TOP][current_ptr] = (tubeModel->oropharynx[S1][BOTTOM][prev_ptr] * dampingFactor) + input;

    // Calculate the scattering junctions for S1-S2

    delta = tubeModel->oropharynx_coeff[C1] * (tubeModel->oropharynx[S1][TOP][prev_ptr] - tubeModel->oropharynx[S2][BOTTOM][prev_ptr]);
    tubeModel->oropharynx[S2][TOP][current_ptr] = (tubeModel->oropharynx[S1][TOP][prev_ptr] + delta) * dampingFactor;
    tubeModel->oropharynx[S1][BOTTOM][current_ptr] = (tubeModel->oropharynx[S2][BOTTOM][prev_ptr] + delta) * dampingFactor;

    // Calculate the scattering junctions for S2-S3 and S3-S4
    if (verbose)
        printf("\nCalc scattering\n");
    for (i = S2, j = C2, k = FC1; i < S4; i++, j++, k++) {
        delta = tubeModel->oropharynx_coeff[j] * (tubeModel->oropharynx[i][TOP][prev_ptr] - tubeModel->oropharynx[i+1][BOTTOM][prev_ptr]);
        tubeModel->oropharynx[i+1][TOP][current_ptr] =
            ((tubeModel->oropharynx[i][TOP][prev_ptr] + delta) * dampingFactor) +
                (tubeModel->fricationTap[k] * frication);
        tubeModel->oropharynx[i][BOTTOM][current_ptr] = (tubeModel->oropharynx[i+1][BOTTOM][prev_ptr] + delta) * dampingFactor;
    }

    // Update 3-way junction between the middle of R4 and nasal cavity
    junctionPressure = (tubeModel->alpha[LEFT] * tubeModel->oropharynx[S4][TOP][prev_ptr])+
        (tubeModel->alpha[RIGHT] * tubeModel->oropharynx[S5][BOTTOM][prev_ptr]) +
        (tubeModel->alpha[UPPER] * tubeModel->nasal[TRM_VELUM][BOTTOM][prev_ptr]);
    tubeModel->oropharynx[S4][BOTTOM][current_ptr] = (junctionPressure - tubeModel->oropharynx[S4][TOP][prev_ptr]) * dampingFactor;
    tubeModel->oropharynx[S5][TOP][current_ptr] =
        ((junctionPressure - tubeModel->oropharynx[S5][BOTTOM][prev_ptr]) * dampingFactor)
            + (tubeModel->fricationTap[FC3] * frication);
    tubeModel->nasal[TRM_VELUM][TOP][current_ptr] = (junctionPressure - tubeModel->nasal[TRM_VELUM][BOTTOM][prev_ptr]) * dampingFactor;

    // Calculate junction between R4 and R5 (S5-S6)
    delta = tubeModel->oropharynx_coeff[C4] * (tubeModel->oropharynx[S5][TOP][prev_ptr] - tubeModel->oropharynx[S6][BOTTOM][prev_ptr]);
    tubeModel->oropharynx[S6][TOP][current_ptr] =
        ((tubeModel->oropharynx[S5][TOP][prev_ptr] + delta) * dampingFactor) +
            (tubeModel->fricationTap[FC4] * frication);
    tubeModel->oropharynx[S5][BOTTOM][current_ptr] = (tubeModel->oropharynx[S6][BOTTOM][prev_ptr] + delta) * dampingFactor;

    // Calculate junction inside R5 (S6-S7) (pure delay with damping)
    tubeModel->oropharynx[S7][TOP][current_ptr] =
        (tubeModel->oropharynx[S6][TOP][prev_ptr] * dampingFactor) +
            (tubeModel->fricationTap[FC5] * frication);
    tubeModel->oropharynx[S6][BOTTOM][current_ptr] = tubeModel->oropharynx[S7][BOTTOM][prev_ptr] * dampingFactor;

    // Calculate last 3 internal junctions (S7-S8, S8-S9, S9-S10
    for (i = S7, j = C5, k = FC6; i < S10; i++, j++, k++) {
        delta = tubeModel->oropharynx_coeff[j] * (tubeModel->oropharynx[i][TOP][prev_ptr] - tubeModel->oropharynx[i+1][BOTTOM][prev_ptr]);
        tubeModel->oropharynx[i+1][TOP][current_ptr] =
            ((tubeModel->oropharynx[i][TOP][prev_ptr] + delta) * dampingFactor) +
                (tubeModel->fricationTap[k] * frication);
        tubeModel->oropharynx[i][BOTTOM][current_ptr] = (tubeModel->oropharynx[i+1][BOTTOM][prev_ptr] + delta) * dampingFactor;
    }

    // Reflected signal at mouth goes through a lowpass filter
    tubeModel->oropharynx[S10][BOTTOM][current_ptr] =  dampingFactor *
        reflectionFilter(tubeModel, tubeModel->oropharynx_coeff[C8] * tubeModel->oropharynx[S10][TOP][prev_ptr]);

    // Output from mouth goes through a highpass filter
    output = radiationFilter(tubeModel, (1.0 + tubeModel->oropharynx_coeff[C8]) * tubeModel->oropharynx[S10][TOP][prev_ptr]);


    // Update nasal cavity
    for (i = TRM_VELUM, j = NC1; i < TRM_N6; i++, j++) {
        delta = tubeModel->nasal_coeff[j] * (tubeModel->nasal[i][TOP][prev_ptr] - tubeModel->nasal[i+1][BOTTOM][prev_ptr]);
        tubeModel->nasal[i+1][TOP][current_ptr] = (tubeModel->nasal[i][TOP][prev_ptr] + delta) * dampingFactor;
        tubeModel->nasal[i][BOTTOM][current_ptr] = (tubeModel->nasal[i+1][BOTTOM][prev_ptr] + delta) * dampingFactor;
    }

    // Reflected signal at nose goes through a lowpass filter
    tubeModel->nasal[TRM_N6][BOTTOM][current_ptr] = dampingFactor * nasalReflectionFilter(tubeModel, tubeModel->nasal_coeff[NC6] * tubeModel->nasal[TRM_N6][TOP][prev_ptr]);

    // Outpout from nose goes through a highpass filter
    output += nasalRadiationFilter(tubeModel, (1.0 + tubeModel->nasal_coeff[NC6]) * tubeModel->nasal[TRM_N6][TOP][prev_ptr]);

    // Return summed output from mouth and nose
    return output;
}


// Simulates the radiation of sound through the walls of the throat.  Note that this form of the filter
// uses addition instead of subtraction for the second term, since tb1 has reversed sign.

double throat(TRMTubeModel *tubeModel, double input)
{
    static double throatY = 0.0;

    double output = (tubeModel->ta0 * input) + (tubeModel->tb1 * throatY);
    throatY = output;
    return (output * tubeModel->throatGain);
}


// Frication bandpass filter, with variable center frequency and bandwidth.

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


// Initializes all the sample rate conversion functions.

void initializeConversion(TRMTubeModel *tubeModel, TRMInputParameters *inputParameters)
{
    double roundedSampleRateRatio;
    int32_t padSize;

    tubeModel->sampleRateConverter.timeRegister = 0;
    tubeModel->sampleRateConverter.maximumSampleValue = 0.0;
    tubeModel->sampleRateConverter.numberSamples = 0;
    printf("initializeConversion(), sampleRateConverter.maximumSampleValue: %g\n", tubeModel->sampleRateConverter.maximumSampleValue);

    // Initialize filter impulse response
    initializeFilter(&(tubeModel->sampleRateConverter));

    // Calculate sample rate ratio
    tubeModel->sampleRateConverter.sampleRateRatio = (double)inputParameters.outputRate / (double)tubeModel->sampleRate;

    // Calculate time register increment
    tubeModel->sampleRateConverter.timeRegisterIncrement = (int)rint(pow(2.0, FRACTION_BITS) / tubeModel->sampleRateConverter.sampleRateRatio);

    // Calculate rounded sample rate ratio
    roundedSampleRateRatio = pow(2.0, FRACTION_BITS) / (double)tubeModel->sampleRateConverter.timeRegisterIncrement;

    // Calculate phase or filter increment
    if (tubeModel->sampleRateConverter.sampleRateRatio >= 1.0) {
        tubeModel->sampleRateConverter.filterIncrement = L_RANGE;
    } else {
        tubeModel->sampleRateConverter.phaseIncrement = (unsigned int)rint(tubeModel->sampleRateConverter.sampleRateRatio * (double)FRACTION_RANGE);
    }

    // Calculate pad size
    padSize = (tubeModel->sampleRateConverter.sampleRateRatio >= 1.0) ? ZERO_CROSSINGS :
        (int)((float)ZERO_CROSSINGS / roundedSampleRateRatio) + 1;

    tubeModel->ringBuffer = TRMRingBufferCreate(padSize);

    tubeModel->ringBuffer->context = &(tubeModel->sampleRateConverter);
    tubeModel->ringBuffer->callbackFunction = resampleBuffer;

    /*  INITIALIZE THE TEMPORARY OUTPUT FILE  */
    tubeModel->sampleRateConverter.tempFilePtr = tmpfile();
    rewind(tubeModel->sampleRateConverter.tempFilePtr);
}

// Initializes filter impulse response and impulse delta values.

void initializeFilter(TRMSampleRateConverter *sampleRateConverter)
{
    double x, IBeta;
    int32_t i;


    // Initialize the filter impulse response
    sampleRateConverter->h[0] = LP_CUTOFF;
    x = PI / (double)L_RANGE;
    for (i = 1; i < FILTER_LENGTH; i++) {
        double y = (double)i * x;
        sampleRateConverter->h[i] = sin(y * LP_CUTOFF) / y;
    }

    // Apply a Kaiser window to the impulse response
    IBeta = 1.0 / Izero(BETA);
    for (i = 0; i < FILTER_LENGTH; i++) {
        double temp = (double)i / FILTER_LENGTH;
        sampleRateConverter->h[i] *= Izero(BETA * sqrt(1.0 - (temp * temp))) * IBeta;
    }

    // Initialize the filter impulse response delta values
    for (i = 0; i < FILTER_LIMIT; i++)
        sampleRateConverter->deltaH[i] = sampleRateConverter->h[i+1] - sampleRateConverter->h[i];
    sampleRateConverter->deltaH[FILTER_LIMIT] = 0.0 - sampleRateConverter->h[FILTER_LIMIT];
}



// Converts available portion of the input signal to the new sampling
// rate, and outputs the samples to the sound struct.

void resampleBuffer(struct _TRMRingBuffer *aRingBuffer, void *context)
{
    TRMSampleRateConverter *aConverter = (TRMSampleRateConverter *)context;
    int32_t endPtr;

    // Calculate end pointer
    endPtr = aRingBuffer->fillPtr - aRingBuffer->padSize;

    // Adjust the end pointer, if less than zero
    if (endPtr < 0)
        endPtr += BUFFER_SIZE;

    // Adjust the endpoint, if less then the empty pointer
    if (endPtr < aRingBuffer->emptyPtr)
        endPtr += BUFFER_SIZE;

    // Upsample loop (slightly more efficient than downsampling)
    if (aConverter->sampleRateRatio >= 1.0) {
        //printf("Upsampling...\n");
        while (aRingBuffer->emptyPtr < endPtr) {
            int32_t index;
            uint32_t filterIndex;
            double output, interpolation, absoluteSampleValue;

            // Reset accumulator to zero
            output = 0.0;

            // Calculate interpolation value (static when upsampling)
            interpolation = (double)mValue(aConverter->timeRegister) / (double)M_RANGE;

            // Compute the left side of the filter convolution
            index = aRingBuffer->emptyPtr;
            for (filterIndex = lValue(aConverter->timeRegister);
                 filterIndex < FILTER_LENGTH;
                 RBDecrementIndex(&index), filterIndex += aConverter->filterIncrement) {
                output += aRingBuffer->buffer[index] * (aConverter->h[filterIndex] + aConverter->deltaH[filterIndex] * interpolation);
            }

            // Adjust values for right side calculation
            aConverter->timeRegister = ~aConverter->timeRegister;
            interpolation = (double)mValue(aConverter->timeRegister) / (double)M_RANGE;

            // Compute the right side of the filter convolution
            index = aRingBuffer->emptyPtr;
            RBIncrementIndex(&index);
            for (filterIndex = lValue(aConverter->timeRegister);
                 filterIndex < FILTER_LENGTH;
                 RBIncrementIndex(&index), filterIndex += aConverter->filterIncrement) {
                output += aRingBuffer->buffer[index] * (aConverter->h[filterIndex] + aConverter->deltaH[filterIndex] * interpolation);
            }

            // Record maximum sample value
            absoluteSampleValue = fabs(output);
            if (absoluteSampleValue > aConverter->maximumSampleValue)
                aConverter->maximumSampleValue = absoluteSampleValue;

            // Increment sample number
            aConverter->numberSamples++;

            // Output the sample to the temporary file
            fwrite((char *)&output, sizeof(output), 1, aConverter->tempFilePtr);

            // Change time register back to original form
            aConverter->timeRegister = ~aConverter->timeRegister;

            // Increment the time register
            aConverter->timeRegister += aConverter->timeRegisterIncrement;

            // Increment the empty pointer, adjusting it and end pointer
            aRingBuffer->emptyPtr += nValue(aConverter->timeRegister);

            if (aRingBuffer->emptyPtr >= BUFFER_SIZE) {
                aRingBuffer->emptyPtr -= BUFFER_SIZE;
                endPtr -= BUFFER_SIZE;
            }

            // Clear N part of time register
            aConverter->timeRegister &= (~N_MASK);
        }
    } else {
        //printf("Downsampling...\n");
        // Downsampling conversion loop
        while (aRingBuffer->emptyPtr < endPtr) {
            int32_t index;
            uint32_t phaseIndex, impulseIndex;
            double absoluteSampleValue, output, impulse;

            // Reset accumulator to zero
            output = 0.0;

            // Compute P prime
            phaseIndex = (unsigned int)rint( ((double)fractionValue(aConverter->timeRegister)) * aConverter->sampleRateRatio);

            // Compute the left side of the filter convolution
            index = aRingBuffer->emptyPtr;
            while ((impulseIndex = (phaseIndex >> M_BITS)) < FILTER_LENGTH) {
                impulse = aConverter->h[impulseIndex] + (aConverter->deltaH[impulseIndex] *
                                                                 (((double)mValue(phaseIndex)) / (double)M_RANGE));
                output += (aRingBuffer->buffer[index] * impulse);
                RBDecrementIndex(&index);
                phaseIndex += aConverter->phaseIncrement;
            }

            // Compute P prime, adjusted for right side
            phaseIndex = (unsigned int)rint( ((double)fractionValue(~aConverter->timeRegister)) * aConverter->sampleRateRatio);

            // Compute the right side of the filter convolution
            index = aRingBuffer->emptyPtr;
            RBIncrementIndex(&index);
            while ((impulseIndex = (phaseIndex>>M_BITS)) < FILTER_LENGTH) {
                impulse = aConverter->h[impulseIndex] + (aConverter->deltaH[impulseIndex] *
                                                                 (((double)mValue(phaseIndex)) / (double)M_RANGE));
                output += (aRingBuffer->buffer[index] * impulse);
                RBIncrementIndex(&index);
                phaseIndex += aConverter->phaseIncrement;
            }

            // Record maximum sample value
            absoluteSampleValue = fabs(output);
            if (absoluteSampleValue > aConverter->maximumSampleValue)
                aConverter->maximumSampleValue = absoluteSampleValue;

            // Increment sample number
            aConverter->numberSamples++;

            // Output the sample to the temporary file
            fwrite((char *)&output, sizeof(output), 1, aConverter->tempFilePtr);

            // Increment the time register
            aConverter->timeRegister += aConverter->timeRegisterIncrement;

            // Increment the empty pointer, adjusting it and end pointer
            aRingBuffer->emptyPtr += nValue(aConverter->timeRegister);
            if (aRingBuffer->emptyPtr >= BUFFER_SIZE) {
                aRingBuffer->emptyPtr -= BUFFER_SIZE;
                endPtr -= BUFFER_SIZE;
            }

            // Clear N part of time register
            aConverter->timeRegister &= (~N_MASK);
        }
    }
}

TRMTubeModel *TRMTubeModelCreate(TRMInputParameters *inputParameters)
{
    double nyquist;

    TRMTubeModel *newTubeModel = (TRMTubeModel *)malloc(sizeof(TRMTubeModel));
    if (newTubeModel == NULL) {
        fprintf(stderr, "Failed to malloc() space for tube model.\n");
        return NULL;
    }

    memset(newTubeModel, 0, sizeof(TRMTubeModel));

    newTubeModel->current.parameters = [[TRMParameters alloc] init];
    newTubeModel->current.delta = [[TRMParameters alloc] init];

    // Calculate the sample rate, based on nominal tube length and speed of sound
    if (inputParameters.length > 0.0) {
        double c = speedOfSound(inputParameters.temperature);

        newTubeModel->controlPeriod = rint((c * TOTAL_SECTIONS * 100.0) / (inputParameters.length * inputParameters.controlRate));
        newTubeModel->sampleRate = inputParameters.controlRate * newTubeModel->controlPeriod;
        newTubeModel->actualTubeLength = (c * TOTAL_SECTIONS * 100.0) / newTubeModel->sampleRate;
        nyquist = (double)newTubeModel->sampleRate / 2.0;
    } else {
        fprintf(stderr, "Illegal tube length: %g\n", inputParameters.length);
        free(newTubeModel);
        return NULL;
    }

    // Calculate the breathiness factor
    newTubeModel->breathinessFactor = inputParameters.breathiness / 100.0;

    // Calculate crossmix factor
    newTubeModel->crossmixFactor = 1.0 / amplitude(inputParameters.mixOffset);

    // Calculate the damping factor
    newTubeModel->dampingFactor = (1.0 - (inputParameters.lossFactor / 100.0));

    // Initialize the wave table
    newTubeModel->wavetable = TRMWavetableCreate(inputParameters.waveform, inputParameters.tp, inputParameters.tnMin, inputParameters.tnMax, newTubeModel->sampleRate);

    // Initialize reflection and radiation filter coefficients for mouth
    initializeMouthCoefficients(newTubeModel, (nyquist - inputParameters.mouthCoef) / nyquist);

    // Initialize reflection and radiation filter coefficients for nose
    initializeNasalFilterCoefficients(newTubeModel, (nyquist - inputParameters.noseCoef) / nyquist);

    // Initialize nasal cavity fixed scattering coefficients
    initializeNasalCavity(newTubeModel, inputParameters);

    // TODO (2004-05-07): nasal?

    // Initialize the throat lowpass filter
    initializeThroat(newTubeModel, inputParameters);

    // Initialize the sample rate conversion routines
    initializeConversion(newTubeModel, inputParameters);

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

    if (tubeModel->ringBuffer != NULL) {
        TRMRingBufferFree(tubeModel->ringBuffer);
        tubeModel->ringBuffer = NULL;
    }

    if (tubeModel->wavetable != NULL) {
        TRMWavetableFree(tubeModel->wavetable);
        tubeModel->wavetable = NULL;
    }

    [tubeModel->current.parameters release];
    [tubeModel->current.delta release];

    free(tubeModel);
}

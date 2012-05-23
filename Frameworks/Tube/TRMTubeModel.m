//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "TRMTubeModel.h"

#import "TRMParameters.h"
#import "TRMDataList.h"
#import "TRMInputParameters.h"
#import "util.h"
#import "TRMSampleRateConverter.h"
#include "TRMWavetable.h"

// Oropharynx scattering junction coefficients (between each region)
#define C1                        TRM_R1     // R1-R2 (S1-S2)
#define C2                        TRM_R2     // R2-R3 (S2-S3)
#define C3                        TRM_R3     // R3-R4 (S3-S4)
#define C4                        TRM_R4     // R4-R5 (S5-S6)
#define C5                        TRM_R5     // R5-R6 (S7-S8)
#define C6                        TRM_R6     // R6-R7 (S8-S9)
#define C7                        TRM_R7     // R7-R8 (S9-S10)
#define C8                        TRM_R8     // R8-AIR (S10-AIR)
#define TOTAL_COEFFICIENTS        TOTAL_REGIONS

// Oropharynx sections
#define S1                        0      // R1
#define S2                        1      // R2
#define S3                        2      // R3
#define S4                        3      // R4
#define S5                        4      // R4
#define S6                        5      // R5
#define S7                        6      // R5
#define S8                        7      // R6
#define S9                        8      // R7
#define S10                       9      // R8
#define TOTAL_SECTIONS            10

// Nasal tract coefficients
#define NC1                       TRM_N1     // N1-N2
#define NC2                       TRM_N2     // N2-N3
#define NC3                       TRM_N3     // N3-N4
#define NC4                       TRM_N4     // N4-N5
#define NC5                       TRM_N5     // N5-N6
#define NC6                       TRM_N6     // N6-AIR
#define TOTAL_NASAL_COEFFICIENTS  TOTAL_NASAL_SECTIONS

// Three-way junction alpha coefficients
#define LEFT                      0
#define RIGHT                     1
#define UPPER                     2
#define TOTAL_ALPHA_COEFFICIENTS  3

// Frication injection coefficients
#define FC1                       0      // S3
#define FC2                       1      // S4
#define FC3                       2      // S5
#define FC4                       3      // S6
#define FC5                       4      // S7
#define FC6                       5      // S8
#define FC7                       6      // S9
#define FC8                       7      // S10
#define TOTAL_FRIC_COEFFICIENTS   8


// Scaling constant for input to vocal tract and throat (matches DSP)
//#define VT_SCALE                  0.03125       // 2^(-5)

// this is a temporary fix only, to try to match dsp synthesizer
#define VT_SCALE                  0.125         // 2^(-3)

// Bi-directional transmission line pointers
#define TOP                       0
#define BOTTOM                    1

// 1 means to compile so that interpolation not done for some control rate parameters
#define MATCH_DSP 0

@interface TRMTubeModel ()
@property (readonly) TRMInputParameters *inputParameters;

- (void)initializeMouthCoefficients:(double)coeff;
- (double)reflectionFilter:(double)input;
- (double)radiationFilter:(double)input;

- (void)initializeNasalFilterCoefficients:(double)coeff;
- (double)nasalReflectionFilter:(double)input;
- (double)nasalRadiationFilter:(double)input;

- (void)setControlRateParameters:(TRMParameters *)previous :(TRMParameters *)current;
- (void)sampleRateInterpolation;
- (void)initializeNasalCavity:(TRMInputParameters *)inputParameters;
- (void)initializeThroat:(TRMInputParameters *)inputParameters;
- (void)calculateTubeCoefficients:(TRMInputParameters *)inputParameters;
- (void)setFricationTaps;
- (void)calculateBandpassCoefficients:(int32_t)sampleRate;
- (double)vocalTract:(double)input :(double)frication;
- (double)throat:(double)input;
- (double)bandpassFilter:(double)input;

@end

#pragma mark -

@implementation TRMTubeModel
{
    // Derived values
    int32_t controlPeriod;
    int32_t sampleRate;
    double actualTubeLength;            // actual length in cm
    
    double m_dampingFactor;               // calculated damping factor
    double crossmixFactor;              // calculated crossmix factor
    
    double breathinessFactor;
    
    // Reflection and radiation filter memory
    double a10, b11, a20, a21, b21;
    
    // Nasal reflection and radiation filter memory
    double na10, nb11, na20, na21, nb21;
    
    // Throad lowpass filter memory, gain
    double tb1, ta0, throatGain;
    
    // Frication bandpass filter memory
    double bpAlpha, bpBeta, bpGamma;
    
    // Memory for tue and tube coefficients
    double oropharynx[TOTAL_SECTIONS][2][2];
    double oropharynx_coeff[TOTAL_COEFFICIENTS];
    
    double nasal[TOTAL_NASAL_SECTIONS][2][2];
    double nasal_coeff[TOTAL_NASAL_COEFFICIENTS];
    
    double alpha[TOTAL_ALPHA_COEFFICIENTS];
    int32_t m_current_ptr;
    int32_t m_prev_ptr;
    
    // Memory for frication taps
    double fricationTap[TOTAL_FRIC_COEFFICIENTS];
    
    // Variables for interpolation
    struct {
        TRMParameters *parameters;
        TRMParameters *delta;
    } m_current;
    
    TRMSampleRateConverter *m_sampleRateConverter;
    TRMWavetable *wavetable;


    BOOL verbose;
    TRMInputParameters *m_inputParameters;
}

- (id)initWithInputParameters:(TRMInputParameters *)inputParameters;
{
    if ((self = [super init])) {
        m_inputParameters = [inputParameters retain];

        double nyquist;

        //memset(newTubeModel, 0, sizeof(TRMTubeModel));
        
        m_current.parameters = [[TRMParameters alloc] init];
        m_current.delta = [[TRMParameters alloc] init];
        
        // Calculate the sample rate, based on nominal tube length and speed of sound
        if (inputParameters.length > 0.0) {
            double c = speedOfSound(inputParameters.temperature);
            
            controlPeriod = rint((c * TOTAL_SECTIONS * 100.0) / (inputParameters.length * inputParameters.controlRate));
            sampleRate = inputParameters.controlRate * controlPeriod;
            actualTubeLength = (c * TOTAL_SECTIONS * 100.0) / sampleRate;
            nyquist = (double)sampleRate / 2.0;
        } else {
            fprintf(stderr, "Illegal tube length: %g\n", inputParameters.length);
            [self release];
            return nil;
        }
        
        // Calculate the breathiness factor
        breathinessFactor = inputParameters.breathiness / 100.0;
        
        // Calculate crossmix factor
        crossmixFactor = 1.0 / amplitude(inputParameters.mixOffset);
        
        // Calculate the damping factor
        m_dampingFactor = (1.0 - (inputParameters.lossFactor / 100.0));
        
        // Initialize the wave table
        wavetable = [[TRMWavetable alloc] initWithWaveform:inputParameters.waveform throttlePulse:inputParameters.tp tnMin:inputParameters.tnMin tnMax:inputParameters.tnMax sampleRate:sampleRate];
        
        // Initialize reflection and radiation filter coefficients for mouth
        [self initializeMouthCoefficients:(nyquist - inputParameters.mouthCoef) / nyquist];
        
        // Initialize reflection and radiation filter coefficients for nose
        [self initializeNasalFilterCoefficients:(nyquist - inputParameters.noseCoef) / nyquist];
        
        // Initialize nasal cavity fixed scattering coefficients
        [self initializeNasalCavity:inputParameters];
        
        // TODO (2004-05-07): nasal?
        
        // Initialize the throat lowpass filter
        [self initializeThroat:inputParameters];
        
        m_sampleRateConverter = [[TRMSampleRateConverter alloc] initWithInputRate:sampleRate outputRate:inputParameters.outputRate];
        
        // These get calculated each time through the synthesize() loop:
        //newTubeModel->bpAlpha = 0.0;
        //newTubeModel->bpBeta = 0.0;
        //newTubeModel->bpGamma = 0.0;
        
        // TODO (2004-05-07): oropharynx
        // TODO (2004-05-07): alpha
        
        m_current_ptr = 1;
        m_prev_ptr = 0;
        
        // TODO (2004-05-07): fricationTap
    }

    return self;
}

- (void)dealloc;
{
    [m_inputParameters release];

    [wavetable release];

    [m_current.parameters release];
    [m_current.delta release];

    [m_sampleRateConverter release];

    [super dealloc];
}

#pragma mark -

@synthesize inputParameters = m_inputParameters;

#pragma mark -

// Performs the actual synthesis of sound samples.
- (void)synthesizeFromDataList:(TRMDataList *)data;
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
        [self setControlRateParameters:previous :parameters];
        
        
        // Sample rate loop
        for (j = 0; j < controlPeriod; j++) {
            
            // Convert parameters here
            f0 = frequency(m_current.parameters.glotPitch);
            ax = amplitude(m_current.parameters.glotVol);
            ah1 = amplitude(m_current.parameters.aspVol);
            [self calculateTubeCoefficients:data.inputParameters];
            [self setFricationTaps];
            [self calculateBandpassCoefficients:sampleRate];
            
            
            // Do synthesis here
            // Create low-pass filtered noise
            lp_noise = noiseFilter(noise());
            
            // Update the shape of the glottal pulse, if necessary
            if (data.inputParameters.waveform == TRMWaveFormType_Pulse)
                [wavetable update:ax];
            
            // Create glottal pulse (or sine tone)
            pulse = [wavetable oscillator:f0];
            
            // Create pulsed noise
            pulsed_noise = lp_noise * pulse;
            
            // Create noisy glottal pulse
            pulse = ax * ((pulse * (1.0 - breathinessFactor)) + (pulsed_noise * breathinessFactor));
            
            // Cross-mix pure noise with pulsed noise
            if (data.inputParameters.modulation) {
                crossmix = ax * crossmixFactor;
                crossmix = (crossmix < 1.0) ? crossmix : 1.0;
                signal = (pulsed_noise * crossmix) + (lp_noise * (1.0 - crossmix));
                if (verbose) {
                    printf("\nSignal = %e", signal);
                    fflush(stdout);
                }
            } else
                signal = lp_noise;
            
            // Put signal through vocal tract
            signal = [self vocalTract:((pulse + (ah1 * signal)) * VT_SCALE) :[self bandpassFilter:signal]];
            
            
            // Put pulse through throat
            signal += [self throat:pulse * VT_SCALE];
            if (verbose)
                printf("\nDone throat\n");
            
            // Output sample
            [self.sampleRateConverter dataFill:signal];
            if (verbose)
                printf("\nDone datafil\n");
            
            // Do sample rate interpolation of control parameters
            [self sampleRateInterpolation];
            if (verbose)
                printf("\nDone sample rate interp\n");
        }
        
        previous = parameters;
    }
    
    // Be sure to flush source buffer
    [self.sampleRateConverter flush];
}

#pragma mark -

@synthesize sampleRateConverter = m_sampleRateConverter;

#pragma mark -

// Calculates the reflection/radiation filter coefficients for the mouth, according to the mouth aperture coefficient.
// coeff - mouth aperture coefficient

- (void)initializeMouthCoefficients:(double)coeff;
{
    b11 = -coeff;
    a10 = 1.0 - fabs(b11);
    
    a20 = coeff;
    a21 = b21 = -(a20);
}

// Is a variable, one-pole lowpass filter, whose cutoff is determined by the mouth aperture coefficient.

- (double)reflectionFilter:(double)input;
{
    static double reflectionY = 0.0; // TODO: Remove static!
    
    double output = (a10 * input) - (b11 * reflectionY);
    reflectionY = output;
    return output;
}

// Is a variable, one-zero, one-pole, highpass filter, whose cutoff point is determined by the mouth aperture coefficient.

- (double)radiationFilter:(double)input;
{
    static double radiationX = 0.0, radiationY = 0.0;
    
    double output = (a20 * input) + (a21 * radiationX) - (b21 * radiationY);
    radiationX = input;
    radiationY = output;
    return output;
}

// Calculates the fixed coefficients for the nasal reflection/radiation filter pair, according to the nose aperture coefficient.
// coeff - nose aperture coefficient

- (void)initializeNasalFilterCoefficients:(double)coeff;
{
    nb11 = -coeff;
    na10 = 1.0 - fabs(nb11);
    
    na20 = coeff;
    na21 = nb21 = -(na20);
}

// Is a one-pole lowpass filter, used for terminating the end of the nasal cavity.

- (double)nasalReflectionFilter:(double)input;
{
    static double nasalReflectionY = 0.0;
    
    double output = (na10 * input) - (nb11 * nasalReflectionY);
    nasalReflectionY = output;
    return output;
}

// Is a one-zero, one-pole highpass filter, used for the radiation characteristic from the nasal cavity.

- (double)nasalRadiationFilter:(double)input;
{
    static double nasalRadiationX = 0.0, nasalRadiationY = 0.0;
    
    double output = (na20 * input) + (na21 * nasalRadiationX) - (nb21 * nasalRadiationY);
    nasalRadiationX = input;
    nasalRadiationY = output;
    return output;
}

// Calculates the current table values, and their associated sample-to-sample delta values.

- (void)setControlRateParameters:(TRMParameters *)previousInput :(TRMParameters *)currentInput;
{
    int32_t i;
    
    // Glottal pitch
    m_current.parameters.glotPitch = previousInput.glotPitch;
    m_current.delta.glotPitch = (currentInput.glotPitch - m_current.parameters.glotPitch) / (double)controlPeriod;
    
    // Glottal volume
    m_current.parameters.glotVol = previousInput.glotVol;
    m_current.delta.glotVol = (currentInput.glotVol - m_current.parameters.glotVol) / (double)controlPeriod;
    
    // Aspiration volume
    m_current.parameters.aspVol = previousInput.aspVol;
#if MATCH_DSP
    m_current.delta.aspVol = 0.0;
#else
    m_current.delta.aspVol = (currentInput.aspVol - m_current.parameters.aspVol) / (double)controlPeriod;
#endif
    
    // Frication volume
    m_current.parameters.fricVol = previousInput.fricVol;
#if MATCH_DSP
    current.delta.fricVol = 0.0;
#else
    m_current.delta.fricVol = (currentInput.fricVol - m_current.parameters.fricVol) / (double)controlPeriod;
#endif
    
    // Frication position
    m_current.parameters.fricPos = previousInput.fricPos;
#if MATCH_DSP
    current.delta.fricPos = 0.0;
#else
    m_current.delta.fricPos = (currentInput.fricPos - m_current.parameters.fricPos) / (double)controlPeriod;
#endif
    
    // Frication center frequency
    m_current.parameters.fricCF = previousInput.fricCF;
#if MATCH_DSP
    m_current.delta.fricCF = 0.0;
#else
    m_current.delta.fricCF = (currentInput.fricCF - m_current.parameters.fricCF) / (double)controlPeriod;
#endif
    
    // Frication bandwidth
    m_current.parameters.fricBW = previousInput.fricBW;
#if MATCH_DSP
    m_current.delta.fricBW = 0.0;
#else
    m_current.delta.fricBW = (currentInput.fricBW - m_current.parameters.fricBW) / (double)controlPeriod;
#endif
    
    // Tube region radii
    for (i = 0; i < TOTAL_REGIONS; i++) {
        m_current.parameters.radius[i] = previousInput.radius[i];
        m_current.delta.radius[i] = (currentInput.radius[i] - m_current.parameters.radius[i]) / (double)controlPeriod;
    }
    
    // Velum radius
    m_current.parameters.velum = previousInput.velum;
    m_current.delta.velum = (currentInput.velum - m_current.parameters.velum) / (double)controlPeriod;
}

// Interpolates table values at the sample rate.

- (void)sampleRateInterpolation;
{
    int32_t i;
    
    m_current.parameters.glotPitch += m_current.delta.glotPitch;
    m_current.parameters.glotVol += m_current.delta.glotVol;
    m_current.parameters.aspVol += m_current.delta.aspVol;
    m_current.parameters.fricVol += m_current.delta.fricVol;
    m_current.parameters.fricPos += m_current.delta.fricPos;
    m_current.parameters.fricCF += m_current.delta.fricCF;
    m_current.parameters.fricBW += m_current.delta.fricBW;
    for (i = 0; i < TOTAL_REGIONS; i++)
        m_current.parameters.radius[i] += m_current.delta.radius[i];
    m_current.parameters.velum += m_current.delta.velum;
}

// Calculates the scattering coefficients for the fixed sections of the nasal cavity.

- (void)initializeNasalCavity:(TRMInputParameters *)inputParameters;
{
    int32_t i, j;
    double radA2, radB2;
    
    
    // Calculate coefficients for internal fixed sections of nasal cavity
    for (i = TRM_N2, j = NC2; i < TRM_N6; i++, j++) {
        radA2 = inputParameters.noseRadius[i] * inputParameters.noseRadius[i];
        radB2 = inputParameters.noseRadius[i+1] * inputParameters.noseRadius[i+1];
        nasal_coeff[j] = (radA2 - radB2) / (radA2 + radB2);
    }
    
    // Calculate the fixed coefficient for the nose aperture
    radA2 = inputParameters.noseRadius[TRM_N6] * inputParameters.noseRadius[TRM_N6];
    radB2 = inputParameters.apScale * inputParameters.apScale;
    nasal_coeff[NC6] = (radA2 - radB2) / (radA2 + radB2);
}

// Initializes the throat lowpass filter coefficients according to the throatCutoff value, and also the throatGain, according to the throatVol value.

- (void)initializeThroat:(TRMInputParameters *)inputParameters;
{
    ta0 = (inputParameters.throatCutoff * 2.0) / sampleRate;
    tb1 = 1.0 - ta0;
    
    throatGain = amplitude(inputParameters.throatVol);
}

// Calculates the scattering coefficients for the vocal tract according to the current radii.  Also calculates
// the coefficients for the reflection/radiation filter pair for the mouth and nose.

- (void)calculateTubeCoefficients:(TRMInputParameters *)inputParameters;
{
    int32_t i;
    double radA2, radB2, r0_2, r1_2, r2_2, sum;
    
    
    // Calcualte coefficients for the oropharynx
    for (i = 0; i < (TOTAL_REGIONS-1); i++) {
        radA2 = m_current.parameters.radius[i] * m_current.parameters.radius[i];
        radB2 = m_current.parameters.radius[i+1] * m_current.parameters.radius[i+1];
        oropharynx_coeff[i] = (radA2 - radB2) / (radA2 + radB2);
    }
    
    // Calculate the coefficient for the mouth aperture
    radA2 = m_current.parameters.radius[TRM_R8] * m_current.parameters.radius[TRM_R8];
    radB2 = inputParameters.apScale * inputParameters.apScale;
    oropharynx_coeff[C8] = (radA2 - radB2) / (radA2 + radB2);
    
    // Calculate alpha coefficients for 3-way junction
    // Note: Since junction is in middle of region 4, r0_2 = r1_2
    r0_2 = r1_2 = m_current.parameters.radius[TRM_R4] * m_current.parameters.radius[TRM_R4];
    r2_2 = m_current.parameters.velum * m_current.parameters.velum;
    sum = 2.0 / (r0_2 + r1_2 + r2_2);
    alpha[LEFT] = sum * r0_2;
    alpha[RIGHT] = sum * r1_2;
    alpha[UPPER] = sum * r2_2;
    
    // And first nasal passage coefficient
    radA2 = m_current.parameters.velum * m_current.parameters.velum;
    radB2 = inputParameters.noseRadius[TRM_N2] * inputParameters.noseRadius[TRM_N2];
    nasal_coeff[NC1] = (radA2 - radB2) / (radA2 + radB2);
}

// Sets the frication taps according to the current position and amplitude of frication.

- (void)setFricationTaps;
{
    int32_t i, integerPart;
    double complement, remainder;
    double fricationAmplitude = amplitude(m_current.parameters.fricVol);
    
    
    // Calculate position remainder and complement
    integerPart = (int)m_current.parameters.fricPos;
    complement = m_current.parameters.fricPos - (double)integerPart;
    remainder = 1.0 - complement;
    
    // Set the frication taps
    for (i = FC1; i < TOTAL_FRIC_COEFFICIENTS; i++) {
        if (i == integerPart) {
            fricationTap[i] = remainder * fricationAmplitude;
            if ((i+1) < TOTAL_FRIC_COEFFICIENTS)
                fricationTap[++i] = complement * fricationAmplitude;
        } else
            fricationTap[i] = 0.0;
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
- (void)calculateBandpassCoefficients:(int32_t)localSampleRate;
{
    double tanValue, cosValue;
    
    
    tanValue = tan((M_PI * m_current.parameters.fricBW) / localSampleRate);
    cosValue = cos((2.0 * M_PI * m_current.parameters.fricCF) / localSampleRate);
    
    bpBeta = (1.0 - tanValue) / (2.0 * (1.0 + tanValue));
    bpGamma = (0.5 + bpBeta) * cosValue;
    bpAlpha = (0.5 - bpBeta) / 2.0;
}

// Updates the pressure wave throughout the vocal tract, and returns the summed output of the oral and nasal
// cavities.  Also injects frication appropriately.

- (double)vocalTract:(double)input :(double)frication;
{
    int32_t i, j, k;
    double delta, output, junctionPressure;
    
    // copies to shorten code
    int current_ptr, prev_ptr;
    double dampingFactor;
    
    
    // Increment current and previous pointers
    if (++(m_current_ptr) > 1)
        m_current_ptr = 0;
    if (++(m_prev_ptr) > 1)
        m_prev_ptr = 0;
    
    current_ptr = m_current_ptr;
    prev_ptr = m_prev_ptr;
    dampingFactor = m_dampingFactor;
    
    // Upate oropharynx
    // Input to top of tube
    
   oropharynx[S1][TOP][current_ptr] = (oropharynx[S1][BOTTOM][prev_ptr] * dampingFactor) + input;
    
    // Calculate the scattering junctions for S1-S2
    
    delta = oropharynx_coeff[C1] * (oropharynx[S1][TOP][prev_ptr] - oropharynx[S2][BOTTOM][prev_ptr]);
    oropharynx[S2][TOP][current_ptr] = (oropharynx[S1][TOP][prev_ptr] + delta) * dampingFactor;
    oropharynx[S1][BOTTOM][current_ptr] = (oropharynx[S2][BOTTOM][prev_ptr] + delta) * dampingFactor;
    
    // Calculate the scattering junctions for S2-S3 and S3-S4
    if (verbose)
        printf("\nCalc scattering\n");
    for (i = S2, j = C2, k = FC1; i < S4; i++, j++, k++) {
        delta = oropharynx_coeff[j] * (oropharynx[i][TOP][prev_ptr] - oropharynx[i+1][BOTTOM][prev_ptr]);
        oropharynx[i+1][TOP][current_ptr] =
        ((oropharynx[i][TOP][prev_ptr] + delta) * dampingFactor) +
        (fricationTap[k] * frication);
        oropharynx[i][BOTTOM][current_ptr] = (oropharynx[i+1][BOTTOM][prev_ptr] + delta) * dampingFactor;
    }
    
    // Update 3-way junction between the middle of R4 and nasal cavity
    junctionPressure = (alpha[LEFT] * oropharynx[S4][TOP][prev_ptr])+
    (alpha[RIGHT] * oropharynx[S5][BOTTOM][prev_ptr]) +
    (alpha[UPPER] * nasal[TRM_VELUM][BOTTOM][prev_ptr]);
    oropharynx[S4][BOTTOM][current_ptr] = (junctionPressure - oropharynx[S4][TOP][prev_ptr]) * dampingFactor;
    oropharynx[S5][TOP][current_ptr] =
    ((junctionPressure - oropharynx[S5][BOTTOM][prev_ptr]) * dampingFactor)
    + (fricationTap[FC3] * frication);
    nasal[TRM_VELUM][TOP][current_ptr] = (junctionPressure - nasal[TRM_VELUM][BOTTOM][prev_ptr]) * dampingFactor;
    
    // Calculate junction between R4 and R5 (S5-S6)
    delta = oropharynx_coeff[C4] * (oropharynx[S5][TOP][prev_ptr] - oropharynx[S6][BOTTOM][prev_ptr]);
    oropharynx[S6][TOP][current_ptr] =
    ((oropharynx[S5][TOP][prev_ptr] + delta) * dampingFactor) +
    (fricationTap[FC4] * frication);
    oropharynx[S5][BOTTOM][current_ptr] = (oropharynx[S6][BOTTOM][prev_ptr] + delta) * dampingFactor;
    
    // Calculate junction inside R5 (S6-S7) (pure delay with damping)
    oropharynx[S7][TOP][current_ptr] =
    (oropharynx[S6][TOP][prev_ptr] * dampingFactor) +
    (fricationTap[FC5] * frication);
    oropharynx[S6][BOTTOM][current_ptr] = oropharynx[S7][BOTTOM][prev_ptr] * dampingFactor;
    
    // Calculate last 3 internal junctions (S7-S8, S8-S9, S9-S10
    for (i = S7, j = C5, k = FC6; i < S10; i++, j++, k++) {
        delta = oropharynx_coeff[j] * (oropharynx[i][TOP][prev_ptr] - oropharynx[i+1][BOTTOM][prev_ptr]);
        oropharynx[i+1][TOP][current_ptr] =
        ((oropharynx[i][TOP][prev_ptr] + delta) * dampingFactor) +
        (fricationTap[k] * frication);
        oropharynx[i][BOTTOM][current_ptr] = (oropharynx[i+1][BOTTOM][prev_ptr] + delta) * dampingFactor;
    }
    
    // Reflected signal at mouth goes through a lowpass filter
    oropharynx[S10][BOTTOM][current_ptr] =  dampingFactor *
    [self reflectionFilter:oropharynx_coeff[C8] * oropharynx[S10][TOP][prev_ptr]];
    
    // Output from mouth goes through a highpass filter
    output = [self radiationFilter:(1.0 + oropharynx_coeff[C8]) * oropharynx[S10][TOP][prev_ptr]];
    
    
    // Update nasal cavity
    for (i = TRM_VELUM, j = NC1; i < TRM_N6; i++, j++) {
        delta = nasal_coeff[j] * (nasal[i][TOP][prev_ptr] - nasal[i+1][BOTTOM][prev_ptr]);
        nasal[i+1][TOP][current_ptr] = (nasal[i][TOP][prev_ptr] + delta) * dampingFactor;
        nasal[i][BOTTOM][current_ptr] = (nasal[i+1][BOTTOM][prev_ptr] + delta) * dampingFactor;
    }
    
    // Reflected signal at nose goes through a lowpass filter
    nasal[TRM_N6][BOTTOM][current_ptr] = dampingFactor * [self nasalReflectionFilter:nasal_coeff[NC6] * nasal[TRM_N6][TOP][prev_ptr]];
    
    // Outpout from nose goes through a highpass filter
    output += [self nasalRadiationFilter:(1.0 + nasal_coeff[NC6]) * nasal[TRM_N6][TOP][prev_ptr]];
    
    // Return summed output from mouth and nose
    return output;
}

// Simulates the radiation of sound through the walls of the throat.  Note that this form of the filter
// uses addition instead of subtraction for the second term, since tb1 has reversed sign.

- (double)throat:(double)input;
{
    static double throatY = 0.0;
    
    double output = (ta0 * input) + (tb1 * throatY);
    throatY = output;
    return (output * throatGain);
}

// Frication bandpass filter, with variable center frequency and bandwidth.

- (double)bandpassFilter:(double)input;
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

@end

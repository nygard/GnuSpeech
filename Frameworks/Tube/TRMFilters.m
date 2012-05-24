//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "TRMFilters.h"

#import "util.h"

#pragma mark - Band Pass Filter

// Sets the frication bandpass filter coefficients according to the current center frequency and bandwidth.
void TRMBandPassFilter_CalculateCoefficients(TRMBandPassFilter *filter, int32_t sampleRate, double centerFrequency, double bandwidth)
{
    double tanValue = tan((      M_PI * bandwidth)       / sampleRate);
    double cosValue = cos((2.0 * M_PI * centerFrequency) / sampleRate);
    
    filter->bpBeta  = (1.0 - tanValue) / (2.0 * (1.0 + tanValue));
    filter->bpGamma = (0.5 + filter->bpBeta) * cosValue;
    filter->bpAlpha = (0.5 - filter->bpBeta) / 2.0;
}

double TRMBandPassFilter_FilterInput(TRMBandPassFilter *filter, double input)
{
    double output = 2.0 * ((filter->bpAlpha * (input - filter->xn2)) + (filter->bpGamma * filter->yn1) - (filter->bpBeta * filter->yn2));
    
    filter->xn2 = filter->xn1;
    filter->xn1 = input;
    filter->yn2 = filter->yn1;
    filter->yn1 = output;
    
    return output;
}

#pragma mark - Mouth, Nasal filter pairs

// Calculates the fixed coefficients for the reflection/radiation filter pair, according to the aperture coefficient.
void TRMRadiationReflectionFilter_InitWithCoefficient(TRMRadiationReflectionFilter *filter, double coeff)
{
    filter->b11 = -coeff;
    filter->a10 = 1.0 - fabs(filter->b11);
    
    filter->a20 = coeff;
    filter->a21 = filter->b21 = -(filter->a20);

    filter->reflectionY = 0;
    filter->radiationX = 0;
    filter->radiationY = 0;
}

double TRMRadiationReflectionFilter_ReflectionFilterInput(TRMRadiationReflectionFilter *filter, double input)
{
    double output = (filter->a10 * input) - (filter->b11 * filter->reflectionY);
    filter->reflectionY = output;
    return output;
}

double TRMRadiationReflectionFilter_RadiationFilterInput(TRMRadiationReflectionFilter *filter, double input)
{
    double output = (filter->a20 * input) + (filter->a21 * filter->radiationX) - (filter->b21 * filter->radiationY);
    filter->radiationX = input;
    filter->radiationY = output;
    return output;
}

#pragma mark - Throat filter

void TRMLowPassFilter_CalculateCoefficients(TRMLowPassFilter *filter, int32_t sampleRate, double cutoff)
{
    filter->ta0 = (cutoff * 2.0) / sampleRate;
    filter->tb1 = 1.0 - filter->ta0;
}

// Note that this form of the filter uses addition instead of subtraction for the second term, since tb1 has reversed sign.

double TRMLowPassFilter_FilterInput(TRMLowPassFilter *filter, double input)
{
    double output = (filter->ta0 * input) + (filter->tb1 * filter->y);
    filter->y = output;
    return output;
}

#pragma mark - Noise filter

double TRMLowPassFilter2_FilterInput(TRMLowPassFilter2 *filter, double input)
{
    double output = input + filter->x;
    filter->x = input;
    return output;
}


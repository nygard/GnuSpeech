//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "TRMParameters.h"

#import "TRMTubeModel.h"

@implementation TRMParameters
{
    double m_glottalPitch;
    double m_glottalVolume;
    double m_aspirationVolume;
    double m_fricationVolume;
    double m_fricationPosition;
    double m_fricationCenterFrequency;
    double m_fricationBandwidth;
    double m_radius[TOTAL_REGIONS];
    double m_velum;
}

@synthesize glottalPitch = m_glottalPitch;
@synthesize glottalVolume = m_glottalVolume;
@synthesize aspirationVolume = m_aspirationVolume;
@synthesize fricationVolume = m_fricationVolume;
@synthesize fricationPosition = m_fricationPosition;
@synthesize fricationCenterFrequency = m_fricationCenterFrequency;
@synthesize fricationBandwidth = m_fricationBandwidth;
@synthesize velum = m_velum;

- (double *)radius;
{
    return m_radius;
}

@end

//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

/*
 * Needed to split off "current" and "originalDefaults" declarations
 */

#include <sys/param.h>

static struct _postureRateParameters
{
    double glotPitch;
    double glotPitchDelta;
    double glotVol;
    double glotVolDelta;
    double aspVol;
    double aspVolDelta;
    double fricVol;
    double fricVolDelta;
    double fricPos;
    double fricPosDelta;
    double fricCF;
    double fricCFDelta;
    double fricBW;
    double fricBWDelta;
    double radius[TOTAL_REGIONS];
    double radiusDelta[TOTAL_REGIONS];
    double velum;
    double velumDelta;
} current;

static struct _postureRateParameters originalDefaults;

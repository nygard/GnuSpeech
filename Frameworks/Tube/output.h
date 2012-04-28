//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#ifndef __OUTPUT_H
#define __OUTPUT_H

#include <stdint.h> // For uint8_t, uint32_t, etc.
#include "structs.h" // For TRMDataList

// Output file format constants
enum {
    TRMSoundFileFormat_AU   = 0,
    TRMSoundFileFormat_AIFF = 1,
    TRMSoundFileFormat_WAVE = 2,
};
typedef NSUInteger TRMSoundFileFormat;

// Maximum sample value
#define TRMSampleValue_Maximum    32767.0

// Size in bits per output sample
#define TRMBitsPerSample          16


void writeOutputToFile(TRMSampleRateConverter *sampleRateConverter, TRMDataList *data, const char *fileName);

#endif

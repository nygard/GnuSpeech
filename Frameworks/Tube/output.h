//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#ifndef __OUTPUT_H
#define __OUTPUT_H

#import "TRMInputParameters.h"

@class TRMSampleRateConverter;

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

void writeAuFileHeader(int32_t channels, int32_t numberSamples, float outputRate, FILE *outputFile);
void writeAiffFileHeader(int32_t channels, int32_t numberSamples, float outputRate, FILE *outputFile);
void writeWaveFileHeader(int32_t channels, int32_t numberSamples, float outputRate, FILE *outputFile);
void writeSamplesMonoMsb(NSInputStream *inputStream, int32_t numberSamples, double scale, FILE *outputFile);
void writeSamplesMonoLsb(NSInputStream *inputStream, int32_t numberSamples, double scale, FILE *outputFile);
void writeSamplesStereoMsb(NSInputStream *inputStream, int32_t numberSamples, double leftScale, double rightScale, FILE *outputFile);
void writeSamplesStereoLsb(NSInputStream *inputStream, int32_t numberSamples, double leftScale, double rightScale, FILE *outputFile);

#endif

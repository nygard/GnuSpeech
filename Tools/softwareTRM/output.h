#ifndef __OUTPUT_H
#define __OUTPUT_H

#include "structs.h" // For TRMData

/*  OUTPUT FILE FORMAT CONSTANTS  */
#define AU_FILE_FORMAT            0
#define AIFF_FILE_FORMAT          1
#define WAVE_FILE_FORMAT          2

/*  FINAL OUTPUT SCALING, SO THAT .SND FILES APPROX. MATCH DSP OUTPUT  */
//#define OUTPUT_SCALE              0.25
#define OUTPUT_SCALE              1.0

/*  MAXIMUM SAMPLE VALUE  */
#define RANGE_MAX                 32767.0

// This is the max for the 'oooiiii' sample sound.  It appears to be a bit less for speech.
#define MAX_SAMPLE 0.0034

/*  SIZE IN BITS PER OUTPUT SAMPLE  */
#define BITS_PER_SAMPLE           16


void writeOutputToFile(TRMSampleRateConverter *sampleRateConverter, TRMData *data, const char *fileName);

void writeAuFileHeader(int channels, long int numberSamples, float outputRate, FILE *outputFile);
size_t fwriteShortMsb(int data, FILE *stream);

#endif

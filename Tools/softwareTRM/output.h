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

typedef struct _OutputCallbackContext {
    double scale;
    double leftScale;
    double rightScale;
    int sampleCount;
    void *userInfo;
} OutputCallbackContext;

void writeAuFileHeader(int channels, long int numberSamples, float outputRate, FILE *outputFile);
void writeAiffFileHeader(int channels, long int numberSamples, float outputRate, FILE *outputFile);
void writeWaveFileHeader(int channels, long int numberSamples, float outputRate, FILE *outputFile);

void writeSampleMonoMsb(TRMSampleRateConverter *aConverter, void *context, double value);
void writeSampleStereoMsb(TRMSampleRateConverter *aConverter, void *context, double value);
void writeSampleMonoLsb(TRMSampleRateConverter *aConverter, void *context, double value);
void writeSampleStereoLsb(TRMSampleRateConverter *aConverter, void *context, double value);

void TRMConfigureOutputContext(OutputCallbackContext *context, double volume, int channels, double balance);
void TRMSynthesizeToFile(TRMTubeModel *tube, TRMData *inputData, const char *filename);

#endif

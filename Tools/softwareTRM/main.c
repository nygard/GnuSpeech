#include <stdio.h>
#include <stdlib.h>
#include <sys/param.h>
#include <libgen.h> // for basename
#include <math.h>
#include <string.h>
#include <unistd.h>

#include "tube.h"
#include "input.h"
#include "output.h"
#include "structs.h"
#include "util.h"

// Command line argument variables
int verbose = 0;

void printInfo(struct _TRMData *data, char *inputFile, TRMTubeModel *tube);

void printInfo(struct _TRMData *data, char *inputFile, TRMTubeModel *tube)
// Prints pertinent variables to standard output.
{
    int i;

    printf("----------------------------------------------------------------------\n");
    printf("input file:\t\t%s\n\n", inputFile);

    // Print input parameters
    printf("outputFileFormat:\t");
    if (data->inputParameters.outputFileFormat == AU_FILE_FORMAT)
        printf("AU\n");
    else if (data->inputParameters.outputFileFormat == AIFF_FILE_FORMAT)
        printf("AIFF\n");
    else if (data->inputParameters.outputFileFormat == WAVE_FILE_FORMAT)
        printf("WAVE\n");

    printf("outputRate:\t\t%.1f Hz\n", data->inputParameters.outputRate);
    printf("controlRate:\t\t%.2f Hz\n\n", data->inputParameters.controlRate);

    printf("volume:\t\t\t%.2f dB\n", data->inputParameters.volume);
    printf("channels:\t\t%-d\n", data->inputParameters.channels);
    printf("balance:\t\t%+1.2f\n\n", data->inputParameters.balance);

    printf("waveform:\t\t");
    if (data->inputParameters.waveform == TRMWaveformTypePulse)
        printf("pulse\n");
    else if (data->inputParameters.waveform == TRMWaveformTypeSine)
        printf("sine\n");
    else
        printf("unknown\n");

    printf("tp:\t\t\t%.2f%%\n", data->inputParameters.tp);
    printf("tnMin:\t\t\t%.2f%%\n", data->inputParameters.tnMin);
    printf("tnMax:\t\t\t%.2f%%\n", data->inputParameters.tnMax);
    printf("breathiness:\t\t%.2f%%\n\n", data->inputParameters.breathiness);

    printf("nominal tube length:\t%.2f cm\n", data->inputParameters.length);
    printf("temperature:\t\t%.2f degrees C\n", data->inputParameters.temperature);
    printf("lossFactor:\t\t%.2f%%\n\n", data->inputParameters.lossFactor);

    printf("apScale:\t\t%.2f cm\n", data->inputParameters.apScale);
    printf("mouthCoef:\t\t%.1f Hz\n", data->inputParameters.mouthCoef);
    printf("noseCoef:\t\t%.1f Hz\n\n", data->inputParameters.noseCoef);

    for (i = 1; i < TOTAL_NASAL_SECTIONS; i++)
        printf("n%-d:\t\t\t%.2f cm\n", i, data->inputParameters.noseRadius[i]);

    printf("\nthroatCutoff:\t\t%.1f Hz\n", data->inputParameters.throatCutoff);
    printf("throatVol:\t\t%.2f dB\n\n", data->inputParameters.throatVol);

    printf("modulation:\t\t");
    if (data->inputParameters.modulation)
        printf("on\n");
    else
        printf("off\n");
    printf("mixOffset:\t\t%.2f dB\n\n", data->inputParameters.mixOffset);

    // Print out derived values
    printf("\nactual tube length:\t%.4f cm\n", tube->actualTubeLength);
    printf("internal sample rate:\t%-d Hz\n", tube->sampleRate);
    printf("control period:\t\t%-d samples (%.4f seconds)\n\n", tube->controlPeriod, (float)tube->controlPeriod/(float)tube->sampleRate);

#if DEBUG
    /*  PRINT OUT WAVE TABLE VALUES  */
    printf("\n");
    for (i = 0; i < TABLE_LENGTH; i++)
        printf("table[%-d] = %.4f\n", i, wavetable[i]);
#endif

    //printControlRateInputTable(data);
    printf("----------------------------------------------------------------------\n");
}

void usage(char *name)
{
    fprintf(stderr, "Usage:  %s [-v] inputFile outputFile\n", basename(name));
    exit(-1);
}

int main(int argc, char *argv[])
{
    char *inputFilename, *outputFilename;
    TRMData *inputData;
    TRMTubeModel *tube;
    int ch;

    // Parse the command line
    while ( (ch = getopt(argc, argv, "v")) != -1) {
        switch (ch) {
          case 'v':
              verbose++;
              break;

          default:
              usage(argv[0]);
        }
    }

    argc -= optind;
    if (argc != 2)
        usage(argv[0]);

    argv += optind;
    inputFilename = argv[0];
    outputFilename = argv[1];

    // Parse the input file for input parameters
    inputData = parseInputFile(inputFilename);
    if (inputData == NULL) {
        fprintf(stderr, "Aborting...\n");
        exit(-1);
    }

    // Initialize the synthesizer
    tube = TRMTubeModelCreate(&inputData->inputParameters);
    if (tube == NULL) {
        fprintf(stderr, "Aborting...\n");
        exit(-1);
    }

    // Print out parameter information
    if (verbose)
        printInfo(inputData, inputFilename, tube);

    // Calculate scaling, write header, and set up callback function
    TRMSynthesizeToFile(tube, inputData, outputFilename);

    if (verbose)
        printf("\nWrote scaled samples to file:  %s\n", outputFilename);

    TRMTubeModelFree(tube);

    return 0;
}

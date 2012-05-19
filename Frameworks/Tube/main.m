#include <stdio.h>
#include <stdlib.h>
#include <sys/param.h>
#include <math.h>
#include <string.h>

#include "tube.h"
#include "output.h"
#include "structs.h"

void printInputParameters(TRMDataList *data, const char *inputFile);

void printInputParameters(TRMDataList *data, const char *inputFile)
{
#if 0
    printf("input file:\t\t%s\n\n", inputFile);
    
    /*  ECHO INPUT PARAMETERS  */
    printf("outputFileFormat:\t");
    if (data->inputParameters.outputFileFormat == TRMSoundFileFormat_AU)
        printf("AU\n");
    else if (data->inputParameters.outputFileFormat == TRMSoundFileFormat_AIFF)
        printf("AIFF\n");
    else if (data->inputParameters.outputFileFormat == TRMSoundFileFormat_WAVE)
        printf("WAVE\n");
    
    printf("outputRate:\t\t%.1f Hz\n", data->inputParameters.outputRate);
    printf("controlRate:\t\t%.2f Hz\n\n", data->inputParameters.controlRate);
    
    printf("volume:\t\t\t%.2f dB\n", data->inputParameters.volume);
    printf("channels:\t\t%-d\n", data->inputParameters.channels);
    printf("balance:\t\t%+1.2f\n\n", data->inputParameters.balance);
    
    printf("waveform:\t\t");
    if (data->inputParameters.waveform == PULSE)
        printf("pulse\n");
    else if (data->inputParameters.waveform == SINE)
        printf("sine\n");
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
    
    for (NSUInteger index = 1; index < TOTAL_NASAL_SECTIONS; index++)
        printf("n%-d:\t\t\t%.2f cm\n", index, data->inputParameters.noseRadius[index]);
    
    printf("\nthroatCutoff:\t\t%.1f Hz\n", data->inputParameters.throatCutoff);
    printf("throatVol:\t\t%.2f dB\n\n", data->inputParameters.throatVol);
    
    printf("modulation:\t\t");
    if (data->inputParameters.modulation)
        printf("on\n");
    else
        printf("off\n");
    printf("mixOffset:\t\t%.2f dB\n\n", data->inputParameters.mixOffset);
    
    /*  PRINT OUT DERIVED VALUES  */
    printf("\nactual tube length:\t%.4f cm\n", actualTubeLength);
    printf("internal sample rate:\t%-d Hz\n", sampleRate);
    printf("control period:\t\t%-d samples (%.4f seconds)\n\n",
           controlPeriod, (float)controlPeriod/(float)sampleRate);
    
#if DEBUG
    /*  PRINT OUT WAVE TABLE VALUES  */
    printf("\n");
    for (NSUInteger index = 0; index < TABLE_LENGTH; i++)
        printf("table[%-d] = %.4f\n", index, wavetable[index]);
#endif
    
    [data printControlRateInputTable];
#endif
}

int main(int argc, char *argv[])
{
    @autoreleasepool {
        NSString *inputFile = nil;
        NSString *outputFile = nil;;
        
        if (argc == 3) {
            inputFile = [[[NSString alloc] initWithUTF8String:argv[1]] autorelease];
            outputFile = [[[NSString alloc] initWithUTF8String:argv[2]] autorelease];
        } else if ((argc == 4) && (!strcmp("-v", argv[1]))) {
            verbose = YES;
            inputFile = [[[NSString alloc] initWithUTF8String:argv[2]] autorelease];
            outputFile = [[[NSString alloc] initWithUTF8String:argv[3]] autorelease];
        } else {
            fprintf(stderr, "Usage:  %s [-v] inputFile outputFile\n", argv[0]);
            exit(-1);
        }
        
        TRMDataList *inputData = [[TRMDataList alloc] initWithContentsOfFile:inputFile error:NULL];
        if (inputData == NULL) {
            fprintf(stderr, "Aborting...\n");
            exit(-1);
        }
        
        // Initialize the synthesizer
        TRMTubeModel *tube = TRMTubeModelCreate(inputData.inputParameters);
        if (tube == NULL) {
            fprintf(stderr, "Aborting...\n");
            exit(-1);
        }
        
        // Print out parameter information
        if (verbose)
            printInputParameters(inputData, [inputFile UTF8String]);
        
        if (verbose) {
            printf("\nCalculating floating point samples...");
            fflush(stdout);
        }
        
        if (verbose) {
            printf("\nStarting synthesis\n");
            fflush(stdout);
        }
        synthesize(tube, inputData);
        
        if (verbose)
            printf("done.\n");
        
        writeOutputToFile(&(tube->sampleRateConverter), inputData, [outputFile UTF8String]);
        
        if (verbose)
            printf("\nWrote scaled samples to file:  %s\n", [outputFile UTF8String]);
        
        TRMTubeModelFree(tube);
    }
        
    return 0;
}

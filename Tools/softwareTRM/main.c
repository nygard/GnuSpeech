#include <stdio.h>
#include <stdlib.h>
#include <sys/param.h>
#include <math.h>
#include <string.h>

#include "tube.h"
#include "input.h"
#include "output.h"


//#define SHARK

/*  BOOLEAN CONSTANTS  */
#define FALSE                     0
#define TRUE                      1

/*  COMMAND LINE ARGUMENT VARIABLES  */
int verbose = FALSE;

void printInfo(char *inputFile);

/******************************************************************************
*
*	function:	printInfo
*
*	purpose:	Prints pertinent variables to standard output.
*
*       arguments:      none
*
*	internal
*	functions:	glotPitchAt, glotVolAt, aspVolAt, fricVolAt,
*                       fricPosAt, fricCFAt, fricBWAt, radiusAtRegion,
*                       velumAt
*
*	library
*	functions:	printf
*
******************************************************************************/

void printInfo(char *inputFile)
{
    int i;
    INPUT *ptr;

    /*  PRINT INPUT FILE NAME  */
    printf("input file:\t\t%s\n\n", inputFile);

    /*  ECHO INPUT PARAMETERS  */
    printf("outputFileFormat:\t");
    if (outputFileFormat == AU_FILE_FORMAT)
        printf("AU\n");
    else if (outputFileFormat == AIFF_FILE_FORMAT)
        printf("AIFF\n");
    else if (outputFileFormat == WAVE_FILE_FORMAT)
        printf("WAVE\n");

    printf("outputRate:\t\t%.1f Hz\n", outputRate);
    printf("controlRate:\t\t%.2f Hz\n\n", controlRate);

    printf("volume:\t\t\t%.2f dB\n", volume);
    printf("channels:\t\t%-d\n", channels);
    printf("balance:\t\t%+1.2f\n\n", balance);

    printf("waveform:\t\t");
    if (waveform == PULSE)
	printf("pulse\n");
    else if (waveform == SINE)
	printf("sine\n");
    printf("tp:\t\t\t%.2f%%\n", tp);
    printf("tnMin:\t\t\t%.2f%%\n", tnMin);
    printf("tnMax:\t\t\t%.2f%%\n", tnMax);
    printf("breathiness:\t\t%.2f%%\n\n", breathiness);

    printf("nominal tube length:\t%.2f cm\n", length);
    printf("temperature:\t\t%.2f degrees C\n", temperature);
    printf("lossFactor:\t\t%.2f%%\n\n", lossFactor);

    printf("apScale:\t\t%.2f cm\n", apScale);
    printf("mouthCoef:\t\t%.1f Hz\n", mouthCoef);
    printf("noseCoef:\t\t%.1f Hz\n\n", noseCoef);

    for (i = 1; i < TOTAL_NASAL_SECTIONS; i++)
	printf("n%-d:\t\t\t%.2f cm\n", i, noseRadius[i]);

    printf("\nthroatCutoff:\t\t%.1f Hz\n", throatCutoff);
    printf("throatVol:\t\t%.2f dB\n\n", throatVol);

    printf("modulation:\t\t");
    if (modulation)
	printf("on\n");
    else
	printf("off\n");
    printf("mixOffset:\t\t%.2f dB\n\n", mixOffset);

    /*  PRINT OUT DERIVED VALUES  */
    printf("\nactual tube length:\t%.4f cm\n", actualTubeLength);
    printf("internal sample rate:\t%-d Hz\n", sampleRate);
    printf("control period:\t\t%-d samples (%.4f seconds)\n\n",
	   controlPeriod, (float)controlPeriod/(float)sampleRate);

#if DEBUG
    /*  PRINT OUT WAVE TABLE VALUES  */
    printf("\n");
    for (i = 0; i < TABLE_LENGTH; i++)
	printf("table[%-d] = %.4f\n", i, wavetable[i]);
#endif

    /*  ECHO TABLE VALUES  */
    printf("\n%-d control rate input tables:\n\n", numberInputTables - 1);

    /*  HEADER  */
    printf("glPitch");
    printf("\tglotVol");
    printf("\taspVol");
    printf("\tfricVol");
    printf("\tfricPos");
    printf("\tfricCF");
    printf("\tfricBW");
    for (i = 1; i <= TOTAL_REGIONS; i++)
	printf("\tr%-d", i);
    printf("\tvelum\n");

    /*  ACTUAL VALUES  */
    ptr = inputHead;
    for (i = 0; i < numberInputTables-1; i++) {
	int j;

	printf("%.2f", glotPitchAt(ptr));
	printf("\t%.2f", glotVolAt(ptr));
	printf("\t%.2f", aspVolAt(ptr));
	printf("\t%.2f", fricVolAt(ptr));
	printf("\t%.2f", fricPosAt(ptr));
	printf("\t%.2f", fricCFAt(ptr));
	printf("\t%.2f", fricBWAt(ptr));
	for (j = 0; j < TOTAL_REGIONS; j++)
	    printf("\t%.2f", radiusAtRegion(ptr, j));
	printf("\t%.2f\n", velumAt(ptr));
        ptr = ptr->next;
    }
    printf("\n");
}

/******************************************************************************
*
*	function:	main
*
*	purpose:	Controls overall execution.
*
*       arguments:      inputFile, outputFile
*
*	internal
*	functions:	parseInputFile, initializeSynthesizer, printInfo,
*                       synthesize, flushBuffer, writeOutputToFile
*
*	library
*	functions:	strcpy, fprintf, exit, printf, fflush
*
******************************************************************************/

int main(int argc, char *argv[])
{
    char inputFile[MAXPATHLEN + 1];
    char outputFile[MAXPATHLEN + 1];

    /*  PARSE THE COMMAND LINE  */
    if (argc == 3) {
	strcpy(inputFile, argv[1]);
	strcpy(outputFile, argv[2]);
    } else if ((argc == 4) && (!strcmp("-v", argv[1]))) {
	verbose = TRUE;
	strcpy(inputFile, argv[2]);
	strcpy(outputFile, argv[3]);
    } else {
	fprintf(stderr, "Usage:  %s [-v] inputFile outputFile\n", argv[0]);
	exit(-1);
    }

#ifdef SHARK
    {
        char buf[100];
        printf("Waiting to start...\n");
        gets(buf);
    }
#endif

    /*  PARSE THE INPUT FILE FOR INPUT INFORMATION  */
    if (parseInputFile(inputFile) == ERROR) {
	fprintf(stderr, "Aborting...\n");
	exit(-1);
    }

    /*  INITIALIZE THE SYNTHESIZER  */
    if (initializeSynthesizer() == ERROR) {
	fprintf(stderr, "Aborting...\n");
	exit(-1);
    }

    /*  PRINT OUT PARAMETER INFORMATION  */
    if (verbose)
	printInfo(inputFile);

    /*  PRINT OUT CALCULATING MESSAGE  */
    if (verbose) {
	printf("\nCalculating floating point samples...");
	fflush(stdout);
    }

    /*  SYNTHESIZE THE SPEECH  */
    if (verbose) {
	printf("\nStarting synthesis\n");
	fflush(stdout);
    }
    synthesize();

    /*  BE SURE TO FLUSH SRC BUFFER  */
    flushBuffer();

    /*  PRINT OUT DONE MESSAGE  */
    if (verbose)
	printf("done.\n");

    /*  OUTPUT SAMPLES TO OUTPUT FILE  */
    writeOutputToFile(outputFile);

    /*  PRINT OUT FINISHED MESSAGE  */
    if (verbose)
	printf("\nWrote scaled samples to file:  %s\n", outputFile);

#ifdef SHARK
    {
        char buf[100];
        printf("Done, waiting...\n");
        gets(buf);
    }
#endif

    return 0;
}

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
char inputFile[MAXPATHLEN + 1];
char outputFile[MAXPATHLEN + 1];

int parseInputFile(const char *inputFile);
void printInfo(void);



/******************************************************************************
*
*	function:	parseInputFile
*
*	purpose:	Parses the input file and assigns values to global
*                       variables.
*
*       arguments:      inputFile
*
*	internal
*	functions:	addInput, glotPitchAt, glotVolAt, aspVolAt, fricVolAt,
*                       fricPosAt, fricCFAt, fricBWAt, radiiAt, velumAt
*
*	library
*	functions:	fopen, fprintf, fgets, strtol, strod, fclose
*
******************************************************************************/

int parseInputFile(const char *inputFile)
{
    int i;
    FILE *fopen(), *fp;
    char line[128];


    /*  OPEN THE INPUT FILE  */
    if ((fp = fopen(inputFile, "r")) == NULL) {
	fprintf(stderr, "Can't open input file \"%s\".\n", inputFile);
	return ERROR;
    }


    /*  GET THE OUTPUT FILE FORMAT  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read output file format.\n");
	return ERROR;
    } else
	outputFileFormat = strtol(line, NULL, 10);

    /*  GET THE OUTPUT SAMPLE RATE  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read output sample rate.\n");
	return ERROR;
    } else
	outputRate = strtod(line, NULL);

    /*  GET THE INPUT CONTROL RATE  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read input control rate.\n");
	return ERROR;
    } else
	controlRate = strtod(line, NULL);


    /*  GET THE MASTER VOLUME  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read master volume.\n");
	return ERROR;
    } else
	volume = strtod(line, NULL);

    /*  GET THE NUMBER OF SOUND OUTPUT CHANNELS  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read number of sound output channels.\n");
	return ERROR;
    } else
	channels = strtol(line, NULL, 10);

    /*  GET THE STEREO BALANCE  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read stereo balance.\n");
	return ERROR;
    } else
	balance = strtod(line, NULL);


    /*  GET THE GLOTTAL SOURCE WAVEFORM TYPE  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read glottal source waveform type.\n");
	return ERROR;
    } else
	waveform = strtol(line, NULL, 10);

    /*  GET THE GLOTTAL PULSE RISE TIME (tp)  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read glottal pulse rise time (tp).\n");
	return ERROR;
    } else
	tp = strtod(line, NULL);

    /*  GET THE GLOTTAL PULSE FALL TIME MINIMUM (tnMin)  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read glottal pulse fall time minimum (tnMin).\n");
	return ERROR;
    } else
	tnMin = strtod(line, NULL);

    /*  GET THE GLOTTAL PULSE FALL TIME MAXIMUM (tnMax)  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read glottal pulse fall time maximum (tnMax).\n");
	return ERROR;
    } else
	tnMax = strtod(line, NULL);

    /*  GET THE GLOTTAL SOURCE BREATHINESS  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read glottal source breathiness.\n");
	return ERROR;
    } else
	breathiness = strtod(line, NULL);


    /*  GET THE NOMINAL TUBE LENGTH  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read nominal tube length.\n");
	return ERROR;
    } else
	length = strtod(line, NULL);

    /*  GET THE TUBE TEMPERATURE  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read tube temperature.\n");
	return ERROR;
    } else
	temperature = strtod(line, NULL);

    /*  GET THE JUNCTION LOSS FACTOR  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read junction loss factor.\n");
	return ERROR;
    } else
	lossFactor = strtod(line, NULL);


    /*  GET THE APERTURE SCALING RADIUS  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read aperture scaling radius.\n");
	return ERROR;
    } else
	apScale = strtod(line, NULL);

    /*  GET THE MOUTH APERTURE COEFFICIENT  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read mouth aperture coefficient\n");
	return ERROR;
    } else
	mouthCoef = strtod(line, NULL);

    /*  GET THE NOSE APERTURE COEFFICIENT  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read nose aperture coefficient\n");
	return ERROR;
    } else
	noseCoef = strtod(line, NULL);


    /*  GET THE NOSE RADII  */
    for (i = 1; i < TOTAL_NASAL_SECTIONS; i++) {
	if (fgets(line, 128, fp) == NULL) {
	    fprintf(stderr, "Can't read nose radius %-d.\n", i);
	    return ERROR;
	} else
	    noseRadius[i] = strtod(line, NULL);
    }


    /*  GET THE THROAT LOWPASS FREQUENCY CUTOFF  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read throat lowpass filter cutoff.\n");
	return ERROR;
    } else
	throatCutoff = strtod(line, NULL);

    /*  GET THE THROAT VOLUME  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read throat volume.\n");
	return ERROR;
    } else
	throatVol = strtod(line, NULL);


    /*  GET THE PULSE MODULATION OF NOISE FLAG  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read pulse modulation of noise flag.\n");
	return ERROR;
    } else
	modulation = strtol(line, NULL, 10);

    /*  GET THE NOISE CROSSMIX OFFSET  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read noise crossmix offset.\n");
	return ERROR;
    } else
	mixOffset = strtod(line, NULL);


    /*  GET THE INPUT TABLE VALUES  */
    while (fgets(line, 128, fp)) {
	double glotPitch, glotVol, radius[TOTAL_REGIONS], velum, aspVol;
	double fricVol, fricPos, fricCF, fricBW;
	char *ptr = line;

	/*  GET EACH PARAMETER  */
	glotPitch = strtod(ptr, &ptr);
	glotVol = strtod(ptr, &ptr);
	aspVol = strtod(ptr, &ptr);
	fricVol = strtod(ptr, &ptr);
	fricPos = strtod(ptr, &ptr);
	fricCF = strtod(ptr, &ptr);
	fricBW = strtod(ptr, &ptr);
	for (i = 0; i < TOTAL_REGIONS; i++)
	    radius[i] = strtod(ptr, &ptr);
	velum = strtod(ptr, &ptr);

	/*  ADD THE PARAMETERS TO THE INPUT LIST  */
	addInput(glotPitch, glotVol, aspVol, fricVol, fricPos, fricCF,
		 fricBW, radius, velum);
    }

    /*  DOUBLE UP THE LAST INPUT TABLE, TO HELP INTERPOLATION CALCULATIONS  */
    if (numberInputTables > 0) {
	addInput(glotPitchAt(inputTail), glotVolAt(inputTail),
		 aspVolAt(inputTail), fricVolAt(inputTail),
		 fricPosAt(inputTail), fricCFAt(inputTail),
		 fricBWAt(inputTail), radiiAt(inputTail),
		 velumAt(inputTail));
    }

    /*  CLOSE THE INPUT FILE  */
    fclose(fp);

    /*  RETURN SUCCESS  */
    return SUCCESS;
}

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

void printInfo(void)
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
	printInfo();

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

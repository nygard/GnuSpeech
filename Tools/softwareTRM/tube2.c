/*  REVISION INFORMATION  *****************************************************

_Author: rao $
_Date: 2002/03/21 16:49:54 $
_Revision: 1.1 $
_Source: /cvsroot/gnuspeech/gnuspeech/trillium/src/softwareTRM/tube.c,v $
_State: Exp $


_Log: tube.c,v $
Revision 1.1  2002/03/21 16:49:54  rao
Initial import.

 * Revision 1.8  1995/04/17  19:51:21  len
 * Temporary fix to frication balance.
 *
 * Revision 1.7  1995/03/21  04:52:37  len
 * Now compiles FAT.  Also adjusted mono and stereo output volume to match
 * approximately the output volume of the DSP.
 *
 * Revision 1.6  1995/03/04  05:55:57  len
 * Changed controlRate parameter to a float.
 *
 * Revision 1.5  1995/03/02  04:33:04  len
 * Added amplitude scaling to input of vocal tract and throat, to keep the
 * software TRM in line with the DSP version.
 *
 * Revision 1.4  1994/11/24  05:24:12  len
 * Added Hi/Low output sample rate switch.
 *
 * Revision 1.3  1994/10/20  21:20:19  len
 * Changed nose and mouth aperture filter coefficients, so now specified as
 * Hz values (which scale appropriately as the tube length changes), rather
 * than arbitrary coefficient values (which don't scale).
 *
 * Revision 1.2  1994/08/05  03:12:52  len
 * Resectioned tube so that it more closely conforms the the DRM proportions.
 * Also changed frication injection so now allowed from S3 to S10.
 *
 * Revision 1.1.1.1  1994/07/07  03:48:52  len
 * Initial archived version.
 *

******************************************************************************/


/******************************************************************************
*
*     Program:       tube
*
*     Description:   Software (non-real-time) implementation of the Tube
*                    Resonance Model for speech production.
*
*     Author:        Leonard Manzara
*
*     Date:          July 5th, 1994
*
******************************************************************************/


/*  HEADER FILES  ************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <sys/param.h>
#include <math.h>
#include <string.h>



/*  LOCAL DEFINES  ***********************************************************/

/*  COMPILE WITH OVERSAMPLING OR PLAIN OSCILLATOR  */
#define OVERSAMPLING_OSCILLATOR   1

/*  1 MEANS COMPILE SO THAT INTERPOLATION NOT DONE FOR
    SOME CONTROL RATE PARAMETERS  */
#define MATCH_DSP                 0


/*  OROPHARYNX REGIONS  */
#define R1                        0      /*  S1  */
#define R2                        1      /*  S2  */
#define R3                        2      /*  S3  */
#define R4                        3      /*  S4 & S5  */
#define R5                        4      /*  S6 & S7  */
#define R6                        5      /*  S8  */
#define R7                        6      /*  S9  */
#define R8                        7      /*  S10  */
#define TOTAL_REGIONS             8

/*  OROPHARYNX SCATTERING JUNCTION COEFFICIENTS (BETWEEN EACH REGION)  */
#define C1                        R1     /*  R1-R2 (S1-S2)  */
#define C2                        R2     /*  R2-R3 (S2-S3)  */
#define C3                        R3     /*  R3-R4 (S3-S4)  */
#define C4                        R4     /*  R4-R5 (S5-S6)  */
#define C5                        R5     /*  R5-R6 (S7-S8)  */
#define C6                        R6     /*  R6-R7 (S8-S9)  */
#define C7                        R7     /*  R7-R8 (S9-S10)  */
#define C8                        R8     /*  R8-AIR (S10-AIR)  */
#define TOTAL_COEFFICIENTS        TOTAL_REGIONS

/*  OROPHARYNX SECTIONS  */
#define S1                        0      /*  R1  */
#define S2                        1      /*  R2  */
#define S3                        2      /*  R3  */
#define S4                        3      /*  R4  */
#define S5                        4      /*  R4  */
#define S6                        5      /*  R5  */
#define S7                        6      /*  R5  */
#define S8                        7      /*  R6  */
#define S9                        8      /*  R7  */
#define S10                       9      /*  R8  */
#define TOTAL_SECTIONS            10

/*  NASAL TRACT SECTIONS  */
#define N1                        0
#define VELUM                     N1
#define N2                        1
#define N3                        2
#define N4                        3
#define N5                        4
#define N6                        5
#define TOTAL_NASAL_SECTIONS      6

/*  NASAL TRACT COEFFICIENTS  */
#define NC1                       N1     /*  N1-N2  */
#define NC2                       N2     /*  N2-N3  */
#define NC3                       N3     /*  N3-N4  */
#define NC4                       N4     /*  N4-N5  */
#define NC5                       N5     /*  N5-N6  */
#define NC6                       N6     /*  N6-AIR  */
#define TOTAL_NASAL_COEFFICIENTS  TOTAL_NASAL_SECTIONS

/*  THREE-WAY JUNCTION ALPHA COEFFICIENTS  */
#define LEFT                      0
#define RIGHT                     1
#define UPPER                     2
#define TOTAL_ALPHA_COEFFICIENTS  3

/*  FRICATION INJECTION COEFFICIENTS  */
#define FC1                       0      /*  S3  */
#define FC2                       1      /*  S4  */
#define FC3                       2      /*  S5  */
#define FC4                       3      /*  S6  */
#define FC5                       4      /*  S7  */
#define FC6                       5      /*  S8  */
#define FC7                       6      /*  S9  */
#define FC8                       7      /*  S10  */
#define TOTAL_FRIC_COEFFICIENTS   8


/*  GLOTTAL SOURCE OSCILLATOR TABLE VARIABLES  */
#define TABLE_LENGTH              512
#define TABLE_MODULUS             (TABLE_LENGTH-1)

/*  WAVEFORM TYPES  */
#define PULSE                     0
#define SINE                      1

/*  OVERSAMPLING FIR FILTER CHARACTERISTICS  */
#define FIR_BETA                  .2
#define FIR_GAMMA                 .1
#define FIR_CUTOFF                .00000001

/*  PITCH VARIABLES  */
#define PITCH_BASE                220.0
#define PITCH_OFFSET              3           /*  MIDDLE C = 0  */
#define LOG_FACTOR                3.32193

/*  RANGE OF ALL VOLUME CONTROLS  */
#define VOL_MAX                   60

/*  SCALING CONSTANT FOR INPUT TO VOCAL TRACT & THROAT (MATCHES DSP)  */
//#define VT_SCALE                  0.03125     /*  2^(-5)  */
// this is a temporary fix only, to try to match dsp synthesizer
#define VT_SCALE                  0.125     /*  2^(-3)  */

/*  FINAL OUTPUT SCALING, SO THAT .SND FILES APPROX. MATCH DSP OUTPUT  */
#define OUTPUT_SCALE              0.25

/*  CONSTANTS FOR THE FIR FILTER  */
#define LIMIT                     200
#define BETA_OUT_OF_RANGE         1
#define GAMMA_OUT_OF_RANGE        2
#define GAMMA_TOO_SMALL           3

/*  CONSTANTS FOR NOISE GENERATOR  */
#define FACTOR                    377.0
#define INITIAL_SEED              0.7892347

/*  MAXIMUM SAMPLE VALUE  */
#define RANGE_MAX                 32767.0

/*  MATH CONSTANTS  */
#define PI                        3.14159265358979
#define TWO_PI                    (2.0 * PI)

/*  FUNCTION RETURN CONSTANTS  */
#define ERROR                     (-1)
#define SUCCESS                   0

/*  BI-DIRECTIONAL TRANSMISSION LINE POINTERS  */
#define TOP                       0
#define BOTTOM                    1


/*  SAMPLE RATE CONVERSION CONSTANTS  */
#define ZERO_CROSSINGS            13                 /*  SRC CUTOFF FRQ      */
#define LP_CUTOFF                 (11.0/13.0)        /*  (0.846 OF NYQUIST)  */

#define N_BITS                    16
#define L_BITS                    8
#define L_RANGE                   256                  /*  must be 2^L_BITS  */
#define M_BITS                    8
#define M_RANGE                   256.0                  /*  must be 2^M_BITS  */
#define FRACTION_BITS             (L_BITS + M_BITS)
#define FRACTION_RANGE            65536         /*  must be 2^FRACTION_BITS  */
#define FILTER_LENGTH             (ZERO_CROSSINGS * L_RANGE)
#define FILTER_LIMIT              (FILTER_LENGTH - 1)

#define N_MASK                    0xFFFF0000
#define L_MASK                    0x0000FF00
#define M_MASK                    0x000000FF
#define FRACTION_MASK             0x0000FFFF

#define nValue(x)                 (((x) & N_MASK) >> FRACTION_BITS)
#define lValue(x)                 (((x) & L_MASK) >> M_BITS)
#define mValue(x)                 ((x) & M_MASK)
#define fractionValue(x)          ((x) & FRACTION_MASK)

#define BETA                      5.658        /*  kaiser window parameters  */
#define IzeroEPSILON              1E-21

#define OUTPUT_SRATE_LOW          22050.0
#define OUTPUT_SRATE_HIGH         44100.0
#define BUFFER_SIZE               1024                 /*  ring buffer size  */

/*  OUTPUT FILE FORMAT CONSTANTS  */
#define AU_FILE_FORMAT            0
#define AIFF_FILE_FORMAT          1
#define WAVE_FILE_FORMAT          2

/*  SIZE IN BITS PER OUTPUT SAMPLE  */
#define BITS_PER_SAMPLE           16

/*  BOOLEAN CONSTANTS  */
#define FALSE                     0
#define TRUE                      1


//#define SHARK


/*  DATA TYPES  **************************************************************/

/*  VARIABLES FOR INPUT TABLES  */
typedef struct _INPUT {
    struct _INPUT *previous;
    struct _INPUT *next;

    double glotPitch;
    double glotVol;
    double aspVol;
    double fricVol;
    double fricPos;
    double fricCF;
    double fricBW;
    double radius[TOTAL_REGIONS];
    double velum;
} INPUT;



/*  GLOBAL VARIABLES *********************************************************/

/*  COMMAND LINE ARGUMENT VARIABLES  */
int verbose = FALSE;
char inputFile[MAXPATHLEN+1];
char outputFile[MAXPATHLEN+1];

/*  INPUT VARIABLES  */
int    outputFileFormat;            /*  file format (0=AU, 1=AIFF, 2=WAVE)  */
float  outputRate;                  /*  output sample rate (22.05, 44.1 KHz)  */
float  controlRate;                 /*  1.0-1000.0 input tables/second (Hz)  */

double volume;                      /*  master volume (0 - 60 dB)  */
int    channels;                    /*  # of sound output channels (1, 2)  */
double balance;                     /*  stereo balance (-1 to +1)  */

int    waveform;                    /*  GS waveform type (0=PULSE, 1=SINE  */
double tp;                          /*  % glottal pulse rise time  */
double tnMin;                       /*  % glottal pulse fall time minimum  */
double tnMax;                       /*  % glottal pulse fall time maximum  */
double breathiness;                 /*  % glottal source breathiness  */

double length;                      /*  nominal tube length (10 - 20 cm)  */
double temperature;                 /*  tube temperature (25 - 40 C)  */
double lossFactor;                  /*  junction loss factor in (0 - 5 %)  */

double apScale;                     /*  aperture scl. radius (3.05 - 12 cm)  */
double mouthCoef;                   /*  mouth aperture coefficient  */
double noseCoef;                    /*  nose aperture coefficient  */

double noseRadius[TOTAL_NASAL_SECTIONS];  /*  fixed nose radii (0 - 3 cm)  */

double throatCutoff;                /*  throat lp cutoff (50 - nyquist Hz)  */
double throatVol;                   /*  throat volume (0 - 48 dB) */

int    modulation;                  /*  pulse mod. of noise (0=OFF, 1=ON)  */
double mixOffset;                   /*  noise crossmix offset (30 - 60 dB)  */


/*  DERIVED VALUES  */
int    controlPeriod;
int    sampleRate;
double actualTubeLength;            /*  actual length in cm  */

double dampingFactor;               /*  calculated damping factor  */
double crossmixFactor;              /*  calculated crossmix factor  */

double *wavetable;
int    tableDiv1;
int    tableDiv2;
double tnLength;
double tnDelta;
double breathinessFactor;

double basicIncrement;
double currentPosition;


/*  REFLECTION AND RADIATION FILTER MEMORY  */
double a10, b11, a20, a21, b21;

/*  NASAL REFLECTION AND RADIATION FILTER MEMORY  */
double na10, nb11, na20, na21, nb21;

/*  THROAT LOWPASS FILTER MEMORY, GAIN  */
double tb1, ta0, throatGain;

/*  FRICATION BANDPASS FILTER MEMORY  */
double bpAlpha, bpBeta, bpGamma;

/*  TEMPORARY SAMPLE STORAGE VALUES  */
double maximumSampleValue = 0.0;
long int numberSamples = 0;
FILE  *tempFilePtr;

/*  MEMORY FOR TUBE AND TUBE COEFFICIENTS  */
double oropharynx[TOTAL_SECTIONS][2][2];
double oropharynx_coeff[TOTAL_COEFFICIENTS];

double nasal[TOTAL_NASAL_SECTIONS][2][2];
double nasal_coeff[TOTAL_NASAL_COEFFICIENTS];

double alpha[TOTAL_ALPHA_COEFFICIENTS];
int current_ptr = 1;
int prev_ptr = 0;

/*  MEMORY FOR FRICATION TAPS  */
double fricationTap[TOTAL_FRIC_COEFFICIENTS];

/*  VARIABLES FOR INPUT TABLE STORAGE  */
INPUT *inputHead = NULL;
INPUT *inputTail = NULL;
int numberInputTables = 0;

/*  VARIABLES FOR INTERPOLATION  */
struct {
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

/*  VARIABLES FOR FIR LOWPASS FILTER  */
double *FIRData, *FIRCoef;
int FIRPtr, numberTaps;

/*  VARIABLES FOR SAMPLE RATE CONVERSION  */
double sampleRateRatio;
double h[FILTER_LENGTH], deltaH[FILTER_LENGTH], buffer[BUFFER_SIZE];
int fillPtr, emptyPtr = 0, padSize, fillSize;
unsigned int timeRegisterIncrement, filterIncrement, phaseIncrement;
unsigned int timeRegister = 0;



/*  GLOBAL FUNCTIONS (LOCAL TO THIS FILE)  ***********************************/
void printInfo(void);
int parseInputFile(const char *inputFile);
int initializeSynthesizer(void);

void initializeWavetable(void);
double speedOfSound(double temperature);
void updateWavetable(double amplitude);
void initializeFIR(double beta, double gamma, double cutoff);
double noise(void);
double noiseFilter(double input);
void initializeMouthCoefficients(double coeff);
double reflectionFilter(double input);
double radiationFilter(double input);
void initializeNasalFilterCoefficients(double coeff);
double nasalReflectionFilter(double input);
double nasalRadiationFilter(double input);
void addInput(double glotPitch, double glotVol, double aspVol, double fricVol,
	      double fricPos, double fricCF, double fricBW, double *radius,
	      double velum);
INPUT *newInputTable(void);
double glotPitchAt(INPUT *ptr);
double glotVolAt(INPUT *ptr);
double *radiiAt(INPUT *ptr);
double radiusAtRegion(INPUT *ptr, int region);
double velumAt(INPUT *ptr);
double aspVolAt(INPUT *ptr);
double fricVolAt(INPUT *ptr);
double fricPosAt(INPUT *ptr);
double fricCFAt(INPUT *ptr);
double fricBWAt(INPUT *ptr);
//INPUT *inputAt(int position);
void synthesize(void);
void setControlRateParameters(INPUT *previousInput, INPUT *currentInput);
void sampleRateInterpolation(void);
void initializeNasalCavity(void);
void initializeThroat(void);
void calculateTubeCoefficients(void);
void setFricationTaps(void);
void calculateBandpassCoefficients(void);
double mod0(double value);
void incrementTablePosition(double frequency);
double oscillator(double frequency);
double vocalTract(double input, double frication);
double throat(double input);
double bandpassFilter(double input);
void writeOutputToFile(char *fileName);
void writeAuFileHeader(int channels, long int numberSamples,
		       float outputRate, FILE *outputFile);
void writeAiffFileHeader(int channels, long int numberSamples,
			 float outputRate, FILE *outputFile);
void writeWaveFileHeader(int channels, long int numberSamples,
			 float outputRate, FILE *outputFile);
void writeSamplesMonoMsb(FILE *tempFile, long int numberSamples,
			 double scale, FILE *outputFile);
void writeSamplesMonoLsb(FILE *tempFile, long int numberSamples,
			 double scale, FILE *outputFile);
void writeSamplesStereoMsb(FILE *tempFile, long int numberSamples,
			   double leftScale, double rightScale,
			   FILE *outputFile);
void writeSamplesStereoLsb(FILE *tempFile, long int numberSamples,
			   double leftScale, double rightScale,
			   FILE *outputFile);
size_t fwriteIntMsb(int data, FILE *stream);
size_t fwriteIntLsb(int data, FILE *stream);
size_t fwriteShortMsb(int data, FILE *stream);
size_t fwriteShortLsb(int data, FILE *stream);
void convertIntToFloat80(unsigned int value, unsigned char buffer[10]);
double amplitude(double decibelLevel);
double frequency(double pitch);
int maximallyFlat(double beta, double gamma, int *np, double *coefficient);
void trim(double cutoff, int *numberCoefficients, double *coefficient);
void rationalApproximation(double number, int *order, int *numerator,
			   int *denominator);
double FIRFilter(double input, int needOutput);
int increment(int pointer, int modulus);
int decrement(int pointer, int modulus);
void initializeConversion(void);
void initializeFilter(void);
double Izero(double x);
void initializeBuffer(void);
void dataFill(double data);
void dataEmpty(void);
void flushBuffer(void);
void srIncrement(int *pointer, int modulus);
void srDecrement(int *pointer, int modulus);




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
	strcpy(inputFile,argv[1]);
	strcpy(outputFile,argv[2]);
    }
    else if ((argc == 4) && (!strcmp("-v", argv[1]))) {
	verbose = TRUE;
	strcpy(inputFile,argv[2]);
	strcpy(outputFile,argv[3]);
    }
    else {
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
    printf("\n%-d control rate input tables:\n\n", numberInputTables-1);

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
	return (ERROR);
    }


    /*  GET THE OUTPUT FILE FORMAT  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read output file format.\n");
	return(ERROR);
    }
    else
	outputFileFormat = strtol(line, NULL, 10);

    /*  GET THE OUTPUT SAMPLE RATE  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read output sample rate.\n");
	return(ERROR);
    }
    else
	outputRate = strtod(line, NULL);

    /*  GET THE INPUT CONTROL RATE  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read input control rate.\n");
	return(ERROR);
    }
    else
	controlRate = strtod(line, NULL);


    /*  GET THE MASTER VOLUME  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read master volume.\n");
	return(ERROR);
    }
    else
	volume = strtod(line, NULL);

    /*  GET THE NUMBER OF SOUND OUTPUT CHANNELS  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read number of sound output channels.\n");
	return(ERROR);
    }
    else
	channels = strtol(line, NULL, 10);

    /*  GET THE STEREO BALANCE  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read stereo balance.\n");
	return(ERROR);
    }
    else
	balance = strtod(line, NULL);


    /*  GET THE GLOTTAL SOURCE WAVEFORM TYPE  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read glottal source waveform type.\n");
	return(ERROR);
    }
    else
	waveform = strtol(line, NULL, 10);

    /*  GET THE GLOTTAL PULSE RISE TIME (tp)  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read glottal pulse rise time (tp).\n");
	return(ERROR);
    }
    else
	tp = strtod(line, NULL);

    /*  GET THE GLOTTAL PULSE FALL TIME MINIMUM (tnMin)  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr,
		"Can't read glottal pulse fall time minimum (tnMin).\n");
	return(ERROR);
    }
    else
	tnMin = strtod(line, NULL);

    /*  GET THE GLOTTAL PULSE FALL TIME MAXIMUM (tnMax)  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr,
		"Can't read glottal pulse fall time maximum (tnMax).\n");
	return(ERROR);
    }
    else
	tnMax = strtod(line, NULL);

    /*  GET THE GLOTTAL SOURCE BREATHINESS  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read glottal source breathiness.\n");
	return(ERROR);
    }
    else
	breathiness = strtod(line, NULL);


    /*  GET THE NOMINAL TUBE LENGTH  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read nominal tube length.\n");
	return(ERROR);
    }
    else
	length = strtod(line, NULL);

    /*  GET THE TUBE TEMPERATURE  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read tube temperature.\n");
	return(ERROR);
    }
    else
	temperature = strtod(line, NULL);

    /*  GET THE JUNCTION LOSS FACTOR  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read junction loss factor.\n");
	return(ERROR);
    }
    else
	lossFactor = strtod(line, NULL);


    /*  GET THE APERTURE SCALING RADIUS  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read aperture scaling radius.\n");
	return(ERROR);
    }
    else
	apScale = strtod(line, NULL);

    /*  GET THE MOUTH APERTURE COEFFICIENT  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read mouth aperture coefficient\n");
	return(ERROR);
    }
    else
	mouthCoef = strtod(line, NULL);

    /*  GET THE NOSE APERTURE COEFFICIENT  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read nose aperture coefficient\n");
	return(ERROR);
    }
    else
	noseCoef = strtod(line, NULL);


    /*  GET THE NOSE RADII  */
    for (i = 1; i < TOTAL_NASAL_SECTIONS; i++) {
	if (fgets(line, 128, fp) == NULL) {
	    fprintf(stderr, "Can't read nose radius %-d.\n", i);
	    return(ERROR);
	}
	else
	    noseRadius[i] = strtod(line, NULL);
    }


    /*  GET THE THROAT LOWPASS FREQUENCY CUTOFF  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read throat lowpass filter cutoff.\n");
	return(ERROR);
    }
    else
	throatCutoff = strtod(line, NULL);

    /*  GET THE THROAT VOLUME  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read throat volume.\n");
	return(ERROR);
    }
    else
	throatVol = strtod(line, NULL);


    /*  GET THE PULSE MODULATION OF NOISE FLAG  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read pulse modulation of noise flag.\n");
	return(ERROR);
    }
    else
	modulation = strtol(line, NULL, 10);

    /*  GET THE NOISE CROSSMIX OFFSET  */
    if (fgets(line, 128, fp) == NULL) {
	fprintf(stderr, "Can't read noise crossmix offset.\n");
	return(ERROR);
    }
    else
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
    return (SUCCESS);
}



/******************************************************************************
*
*	function:	speedOfSound
*
*	purpose:	Returns the speed of sound according to the value of
*                       the temperature (in Celsius degrees).
*
*       arguments:      temperature
*
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

double speedOfSound(double temperature)
{
    return (331.4 + (0.6 * temperature));
}



/******************************************************************************
*
*	function:	initializeSynthesizer
*
*	purpose:	Initializes all variables so that the synthesis can
*                       be run.
*
*       arguments:      none
*
*	internal
*	functions:	speedOfSound, amplitude, initializeWavetable,
*                       initializeFIR, initializeNasalFilterCoefficients,
*                       initializeNasalCavity, initializeThroat,
*                       initializeConversion
*
*	library
*	functions:	rint, fprintf, tmpfile, rewind
*
******************************************************************************/

int initializeSynthesizer(void)
{
    double nyquist;

    /*  CALCULATE THE SAMPLE RATE, BASED ON NOMINAL
	TUBE LENGTH AND SPEED OF SOUND  */
    if (length > 0.0) {
	double c = speedOfSound(temperature);
	controlPeriod =
	    rint((c * TOTAL_SECTIONS * 100.0) /(length * controlRate));
	sampleRate = controlRate * controlPeriod;
	actualTubeLength = (c * TOTAL_SECTIONS * 100.0) / sampleRate;
	nyquist = (double)sampleRate / 2.0;
    }
    else {
	fprintf(stderr, "Illegal tube length.\n");
	return (ERROR);
    }

    /*  CALCULATE THE BREATHINESS FACTOR  */
    breathinessFactor = breathiness / 100.0;

    /*  CALCULATE CROSSMIX FACTOR  */
    crossmixFactor = 1.0 / amplitude(mixOffset);

    /*  CALCULATE THE DAMPING FACTOR  */
    dampingFactor = (1.0 - (lossFactor / 100.0));

    /*  INITIALIZE THE WAVE TABLE  */
    initializeWavetable();

    /*  INITIALIZE THE FIR FILTER  */
    initializeFIR(FIR_BETA, FIR_GAMMA, FIR_CUTOFF);

    /*  INITIALIZE REFLECTION AND RADIATION FILTER COEFFICIENTS FOR MOUTH  */
    initializeMouthCoefficients((nyquist - mouthCoef) / nyquist);

    /*  INITIALIZE REFLECTION AND RADIATION FILTER COEFFICIENTS FOR NOSE  */
    initializeNasalFilterCoefficients((nyquist - noseCoef) / nyquist);

    /*  INITIALIZE NASAL CAVITY FIXED SCATTERING COEFFICIENTS  */
    initializeNasalCavity();

    /*  INITIALIZE THE THROAT LOWPASS FILTER  */
    initializeThroat();

    /*  INITIALIZE THE SAMPLE RATE CONVERSION ROUTINES  */
    initializeConversion();

    /*  INITIALIZE THE TEMPORARY OUTPUT FILE  */
    tempFilePtr = tmpfile();
    rewind(tempFilePtr);

    /*  RETURN SUCCESS  */
    return (SUCCESS);
}



/******************************************************************************
*
*	function:	initializeWavetable
*
*	purpose:	Calculates the initial glottal pulse and stores it
*                       in the wavetable, for use in the oscillator.
*
*       arguments:      none
*
*	internal
*	functions:	none
*
*	library
*	functions:	calloc, rint
*
******************************************************************************/

void initializeWavetable(void)
{
    int i, j;


    /*  ALLOCATE MEMORY FOR WAVETABLE  */
    wavetable = (double *)calloc(TABLE_LENGTH, sizeof(double));

    /*  CALCULATE WAVE TABLE PARAMETERS  */
    tableDiv1 = rint(TABLE_LENGTH * (tp / 100.0));
    tableDiv2 = rint(TABLE_LENGTH * ((tp + tnMax) / 100.0));
    tnLength = tableDiv2 - tableDiv1;
    tnDelta = rint(TABLE_LENGTH * ((tnMax - tnMin) / 100.0));
    basicIncrement = (double)TABLE_LENGTH / (double)sampleRate;
    currentPosition = 0;

    /*  INITIALIZE THE WAVETABLE WITH EITHER A GLOTTAL PULSE OR SINE TONE  */
    if (waveform == PULSE) {
	/*  CALCULATE RISE PORTION OF WAVE TABLE  */
	for (i = 0; i < tableDiv1; i++) {
	    double x = (double)i / (double)tableDiv1;
	    double x2 = x * x;
	    double x3 = x2 * x;
	    wavetable[i] = (3.0 * x2) - (2.0 * x3);
	}

	/*  CALCULATE FALL PORTION OF WAVE TABLE  */
	for (i = tableDiv1, j = 0; i < tableDiv2; i++, j++) {
	    double x = (double)j / tnLength;
	    wavetable[i] = 1.0 - (x * x);
	}

	/*  SET CLOSED PORTION OF WAVE TABLE  */
	for (i = tableDiv2; i < TABLE_LENGTH; i++)
	    wavetable[i] = 0.0;
    }
    else {
	/*  SINE WAVE  */
	for (i = 0; i < TABLE_LENGTH; i++) {
	    wavetable[i] = sin( ((double)i/(double)TABLE_LENGTH) * 2.0 * PI );
	}
    }
}



/******************************************************************************
*
*	function:	updateWavetable
*
*	purpose:	Rewrites the changeable part of the glottal pulse
*                       according to the amplitude.
*
*       arguments:      amplitude
*
*	internal
*	functions:	none
*
*	library
*	functions:	rint
*
******************************************************************************/

void updateWavetable(double amplitude)
{
    int i, j;


    /*  CALCULATE NEW CLOSURE POINT, BASED ON AMPLITUDE  */
    double newDiv2 = tableDiv2 - rint(amplitude * tnDelta);
    double newTnLength = newDiv2 - tableDiv1;
    //double x;
    double oneOver_newTnLength_squared;
    double x1, x2, x3, x4;
    int newDiv2_int, limit;
    int remainder;
    //int j_2;

    /*  RECALCULATE THE FALLING PORTION OF THE GLOTTAL PULSE  */
    newDiv2_int = newDiv2;
    oneOver_newTnLength_squared = 1 / (newTnLength * newTnLength);
    i = tableDiv1;
    j = 0;

    remainder = newDiv2_int % 4;
    limit = newDiv2_int - remainder;
    //printf("newDiv2_int: %d\n", newDiv2_int);
    //while (i < limit) {
    for (;i < limit;) {
#if 1
	x1 = j * j * oneOver_newTnLength_squared;
	x2 = (j + 1) * (j + 1) * oneOver_newTnLength_squared;
	x3 = (j + 2) * (j + 2) * oneOver_newTnLength_squared;
	x4 = (j + 3) * (j + 3) * oneOver_newTnLength_squared;
#else
        j_2 = j * j;
	x1 = j_2 * oneOver_newTnLength_squared;
	x2 = (j_2 + 2 * j + 1) * oneOver_newTnLength_squared;
	x3 = (j_2 + 4 * j + 4) * oneOver_newTnLength_squared;
	x4 = (j_2 + 6 * j + 9) * oneOver_newTnLength_squared;
#endif
        j += 4;
	wavetable[i] = 1.0 - x1;
        wavetable[i + 1] = 1.0 - x2;
        wavetable[i + 2] = 1.0 - x3;
        wavetable[i + 3] = 1.0 - x4;

        i += 4;
    }

    if (remainder > 1) {
	x2 = (j + 1) * (j + 1) * oneOver_newTnLength_squared;
        wavetable[i + 1] = 1.0 - x2;
    }
    if (remainder > 2) {
	x3 = (j + 2) * (j + 2) * oneOver_newTnLength_squared;
        wavetable[i + 2] = 1.0 - x3;
    }
    if (remainder > 3) {
	x4 = (j + 3) * (j + 3) * oneOver_newTnLength_squared;
        wavetable[i + 3] = 1.0 - x4;
    }

    /*  FILL IN WITH CLOSED PORTION OF GLOTTAL PULSE  */
    for (i = newDiv2_int; i < tableDiv2; i++)
	wavetable[i] = 0.0;
}



/******************************************************************************
*
*	function:	initializeFIR
*
*	purpose:	Allocates memory and initializes the coefficients
*                       for the FIR filter used in the oversampling oscillator.
*
*       arguments:      beta, gamma, cutoff
*
*	internal
*	functions:	maximallyFlat, trim
*
*	library
*	functions:	calloc
*
******************************************************************************/

void initializeFIR(double beta, double gamma, double cutoff)
{
    int i, pointer, increment, numberCoefficients;
    double coefficient[LIMIT+1];


    /*  DETERMINE IDEAL LOW PASS FILTER COEFFICIENTS  */
    maximallyFlat(beta, gamma, &numberCoefficients, coefficient);

    /*  TRIM LOW-VALUE COEFFICIENTS  */
    trim(cutoff, &numberCoefficients, coefficient);

    /*  DETERMINE THE NUMBER OF TAPS IN THE FILTER  */
    numberTaps = (numberCoefficients * 2) - 1;

    /*  ALLOCATE MEMORY FOR DATA AND COEFFICIENTS  */
    FIRData = (double *)calloc(numberTaps, sizeof(double));
    FIRCoef = (double *)calloc(numberTaps, sizeof(double));

    /*  INITIALIZE THE COEFFICIENTS  */
    increment = (-1);
    pointer = numberCoefficients;
    for (i = 0; i < numberTaps; i++) {
	FIRCoef[i] = coefficient[pointer];
	pointer += increment;
	if (pointer <= 0) {
	    pointer = 2;
	    increment = 1;
	}
    }

    /*  SET POINTER TO FIRST ELEMENT  */
    FIRPtr = 0;

#if DEBUG
    /*  PRINT OUT  */
    printf("\n");
    for (i = 0; i < numberTaps; i++)
	printf("FIRCoef[%-d] = %11.8f\n", i, FIRCoef[i]);
#endif
}



/******************************************************************************
*
*	function:	noise
*
*	purpose:	Returns one value of a random sequence.
*
*       arguments:      none
*
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

double noise(void)
{
    static double seed = INITIAL_SEED;

    double product = seed * FACTOR;
    seed = product - (int)product;
    return (seed - 0.5);
}



/******************************************************************************
*
*	function:	noiseFilter
*
*	purpose:	One-zero lowpass filter.
*
*       arguments:      input
*
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

double noiseFilter(double input)
{
    static double noiseX = 0.0;

    double output = input + noiseX;
    noiseX = input;
    return (output);
}



/******************************************************************************
*
*	function:	initializeMouthCoefficients
*
*	purpose:	Calculates the reflection/radiation filter coefficients
*                       for the mouth, according to the mouth aperture
*                       coefficient.
*
*       arguments:      coeff - mouth aperture coefficient
*
*	internal
*	functions:	none
*
*	library
*	functions:	fabs
*
******************************************************************************/

void initializeMouthCoefficients(double coeff)
{
    b11 = -coeff;
    a10 = 1.0 - fabs(b11);

    a20 = coeff;
    a21 = b21 = -a20;
}



/******************************************************************************
*
*	function:	reflectionFilter
*
*	purpose:	Is a variable, one-pole lowpass filter, whose cutoff
*                       is determined by the mouth aperture coefficient.
*
*       arguments:      input
*
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

double reflectionFilter(double input)
{
    static double reflectionY = 0.0;

    double output = (a10 * input) - (b11 * reflectionY);
    reflectionY = output;
    return (output);
}



/******************************************************************************
*
*	function:	radiationFilter
*
*	purpose:	Is a variable, one-zero, one-pole, highpass filter,
*                       whose cutoff point is determined by the mouth aperture
*                       coefficient.
*
*       arguments:      input
*
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

double radiationFilter(double input)
{
    static double radiationX = 0.0, radiationY = 0.0;

    double output = (a20 * input) + (a21 * radiationX) - (b21 * radiationY);
    radiationX = input;
    radiationY = output;
    return (output);
}



/******************************************************************************
*
*	function:	initializeNasalFilterCoefficients
*
*	purpose:	Calculates the fixed coefficients for the nasal
*                       reflection/radiation filter pair, according to the
*                       nose aperture coefficient.
*
*       arguments:      coeff - nose aperture coefficient
*
*	internal
*	functions:	none
*
*	library
*	functions:	fabs
*
******************************************************************************/

void initializeNasalFilterCoefficients(double coeff)
{
    nb11 = -coeff;
    na10 = 1.0 - fabs(nb11);

    na20 = coeff;
    na21 = nb21 = -na20;
}



/******************************************************************************
*
*	function:	nasalReflectionFilter
*
*	purpose:	Is a one-pole lowpass filter, used for terminating
*                       the end of the nasal cavity.
*
*       arguments:      input
*
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

double nasalReflectionFilter(double input)
{
    static double nasalReflectionY = 0.0;

    double output = (na10 * input) - (nb11 * nasalReflectionY);
    nasalReflectionY = output;
    return (output);
}



/******************************************************************************
*
*	function:	nasalRadiationFilter
*
*	purpose:	Is a one-zero, one-pole highpass filter, used for the
*                       radiation characteristic from the nasal cavity.
*
*       arguments:      input
*
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

double nasalRadiationFilter(double input)
{
    static double nasalRadiationX = 0.0, nasalRadiationY = 0.0;

    double output = (na20 * input) + (na21 * nasalRadiationX) -
	(nb21 * nasalRadiationY);
    nasalRadiationX = input;
    nasalRadiationY = output;
    return (output);
}



/******************************************************************************
*
*	function:	addInput
*
*	purpose:	Adds table control data to the end of a linked list.
*
*       arguments:      glotPitch, glotVol, radius, velum, aspVol,
*                       fricVol, fricPos,
*                       fricCF, fricBW
*
*	internal
*	functions:	newInputTable
*
*	library
*	functions:	none
*
******************************************************************************/

void addInput(double glotPitch, double glotVol, double aspVol, double fricVol,
	      double fricPos, double fricCF, double fricBW, double *radius,
	      double velum)
{
    int i;
    INPUT *tempPtr;


    if (inputHead == NULL) {
	inputTail = inputHead = newInputTable();
	inputTail->previous = NULL;
    }
    else {
	tempPtr = inputTail;
	inputTail = tempPtr->next = newInputTable();
	inputTail->previous = tempPtr;
    }

    /*  SET NULL POINTER TO NEXT, SINCE END OF LIST  */
    inputTail->next = NULL;

    /*  ADD GLOTTAL PITCH AND VOLUME  */
    inputTail->glotPitch = glotPitch;
    inputTail->glotVol = glotVol;

    /*  ADD ASPIRATION  */
    inputTail->aspVol = aspVol;

    /*  ADD FRICATION PARAMETERS  */
    inputTail->fricVol = fricVol;
    inputTail->fricPos = fricPos;
    inputTail->fricCF = fricCF;
    inputTail->fricBW = fricBW;

    /*  ADD TUBE REGION RADII  */
    for (i = 0; i < TOTAL_REGIONS; i++)
	inputTail->radius[i] = radius[i];

    /*  ADD VELUM RADIUS  */
    inputTail->velum = velum;

    /*  INCREMENT NUMBER OF TABLES  */
    numberInputTables++;
}



/******************************************************************************
*
*	function:	newInputTable
*
*	purpose:	Allocates memory for a new input table.
*
*       arguments:      none
*
*	internal
*	functions:	none
*
*	library
*	functions:	malloc
*
******************************************************************************/

INPUT *newInputTable(void)
{
    return ((INPUT *)malloc(sizeof(INPUT)));
}



/******************************************************************************
*
*	function:	glotPitchAt
*
*	purpose:	Returns the pitch stored in the table at 'position'.
*
*       arguments:      position
*
*	internal
*	functions:	none
*
*	library
*	functions:	inputAt
*
******************************************************************************/

double glotPitchAt(INPUT *ptr)
{
    if (ptr)
	return (ptr->glotPitch);
    else
	return (0.0);
}



/******************************************************************************
*
*	function:	glotVolAt
*
*	purpose:	Returns the glotVol stored in the table at 'position'.
*
*       arguments:      position
*
*	internal
*	functions:	none
*
*	library
*	functions:	inputAt
*
******************************************************************************/

double glotVolAt(INPUT *ptr)
{
    if (ptr)
	return (ptr->glotVol);
    else
	return (0.0);
}



/******************************************************************************
*
*	function:	radiiAt
*
*	purpose:	Returns the variable tube radii stored in the table at
*                       'position'.
*
*       arguments:      position
*
*	internal
*	functions:	none
*
*	library
*	functions:	inputAt
*
******************************************************************************/

double *radiiAt(INPUT *ptr)
{
    if (ptr)
	return (ptr->radius);
    else
	return (NULL);
}



/******************************************************************************
*
*	function:	radiusAtRegion
*
*	purpose:	Returns the radius for 'region', from the table at
*                       'position'.
*
*       arguments:      position, region
*
*	internal
*	functions:	inputAt
*
*	library
*	functions:	none
*
******************************************************************************/

double radiusAtRegion(INPUT *ptr, int region)
{
    if (ptr)
	return (ptr->radius[region]);
    else
	return (0.0);
}



/******************************************************************************
*
*	function:	velumAt
*
*	purpose:	Returns the velum radius from the table at 'position'.
*
*       arguments:      position
*
*	internal
*	functions:	inputAt
*
*	library
*	functions:	none
*
******************************************************************************/

double velumAt(INPUT *ptr)
{
    if (ptr)
	return (ptr->velum);
    else
	return (0.0);
}



/******************************************************************************
*
*	function:	aspVolAt
*
*	purpose:	Returns the aspiration factor from the table at
*                       'position'.
*
*       arguments:      position
*
*	internal
*	functions:	inputAt
*
*	library
*	functions:	none
*
******************************************************************************/

double aspVolAt(INPUT *ptr)
{
    if (ptr)
	return (ptr->aspVol);
    else
	return (0.0);
}



/******************************************************************************
*
*	function:	fricVolAt
*
*	purpose:	Returns the frication volume from the table at
*                       'position'.
*
*       arguments:      position
*
*	internal
*	functions:	inputAt
*
*	library
*	functions:	none
*
******************************************************************************/

double fricVolAt(INPUT *ptr)
{
    if (ptr)
	return (ptr->fricVol);
    else
	return (0.0);
}



/******************************************************************************
*
*	function:	fricPosAt
*
*	purpose:	Returns the frication position from the table at
*                       'position'.
*
*       arguments:      position
*
*	internal
*	functions:	inputAt
*
*	library
*	functions:	none
*
******************************************************************************/

double fricPosAt(INPUT *ptr)
{
    if (ptr)
	return (ptr->fricPos);
    else
	return (0.0);
}



/******************************************************************************
*
*	function:	fricCFAt
*
*	purpose:	Returns the frication center frequency from the table
*                       at 'position'.
*
*       arguments:      position
*
*	internal
*	functions:	inputAt
*
*	library
*	functions:	none
*
******************************************************************************/

double fricCFAt(INPUT *ptr)
{
    if (ptr)
	return (ptr->fricCF);
    else
	return (0.0);
}



/******************************************************************************
*
*	function:	fricBWAt
*
*	purpose:	Returns the frication bandwidth from the table
*                       at 'position'.
*
*       arguments:      position
*
*	internal
*	functions:	inputAt
*
*	library
*	functions:	none
*
******************************************************************************/

double fricBWAt(INPUT *ptr)
{
    if (ptr)
	return (ptr->fricBW);
    else
	return (0.0);
}


#if 0
/******************************************************************************
*
*	function:	inputAt
*
*	purpose:	Returns a pointer to the table specified by 'position'.
*
*       arguments:      position
*
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

INPUT *inputAt(int position)
{
    int i;
    INPUT *tempPtr = inputHead;

    if ((position < 0) || (position >= numberInputTables))
	return (NULL);

    /*  LOOP THROUGH TO PROPER POSITION IN LIST  */
    for (i = 0; i < position; i++)
	tempPtr = tempPtr->next;

    return (tempPtr);
}
#endif


/******************************************************************************
*
*	function:	synthesize
*
*	purpose:	Performs the actual synthesis of sound samples.
*
*       arguments:      none
*
*	internal
*	functions:	setControlRateParameters, frequency, amplitude,
*                       calculateTubeCoefficients, noise, noiseFilter,
*                       updateWavetable, oscillator, vocalTract, throat,
*                       dataFill, sampleRateInterpolation
*
*	library
*	functions:	none
*
******************************************************************************/

void synthesize(void)
{

    int i, j;
    double f0, ax, ah1, pulse, lp_noise, pulsed_noise, signal, crossmix;
    INPUT *previousInput, *currentInput;



    /*  CONTROL RATE LOOP  */

    previousInput = inputHead;
    currentInput = inputHead->next;

    for (i = 1; i < numberInputTables; i++) {

	/*  SET CONTROL RATE PARAMETERS FROM INPUT TABLES  */
	setControlRateParameters(previousInput, currentInput);


	/*  SAMPLE RATE LOOP  */
	for (j = 0; j < controlPeriod; j++) {

	    /*  CONVERT PARAMETERS HERE  */
	    f0 = frequency(current.glotPitch);
	    ax = amplitude(current.glotVol);
	    ah1 = amplitude(current.aspVol);
	    calculateTubeCoefficients();
	    setFricationTaps();
	    calculateBandpassCoefficients();


	    /*  DO SYNTHESIS HERE  */
	    /*  CREATE LOW-PASS FILTERED NOISE  */
	    lp_noise = noiseFilter(noise());

	    /*  UPDATE THE SHAPE OF THE GLOTTAL PULSE, IF NECESSARY  */
	    if (waveform == PULSE)
		updateWavetable(ax);

	    /*  CREATE GLOTTAL PULSE (OR SINE TONE)  */
	    pulse = oscillator(f0);

	    /*  CREATE PULSED NOISE  */
	    pulsed_noise = lp_noise * pulse;

	    /*  CREATE NOISY GLOTTAL PULSE  */
	    pulse = ax * ((pulse * (1.0 - breathinessFactor)) +
			  (pulsed_noise * breathinessFactor));

	    /*  CROSS-MIX PURE NOISE WITH PULSED NOISE  */
	    if (modulation) {
		crossmix = ax * crossmixFactor;
		crossmix = (crossmix < 1.0) ? crossmix : 1.0;
		signal = (pulsed_noise * crossmix) +
		    (lp_noise * (1.0 - crossmix));
                if (verbose) {
                    printf("\nSignal = %e", signal);
                    fflush(stdout);
                }


	    }
	    else
		signal = lp_noise;

	    /*  PUT SIGNAL THROUGH VOCAL TRACT  */
	    signal = vocalTract(((pulse + (ah1 * signal)) * VT_SCALE),
				bandpassFilter(signal));


	    /*  PUT PULSE THROUGH THROAT  */
	    signal += throat(pulse * VT_SCALE);
            if (verbose)
                printf("\nDone throat\n");

	    /*  OUTPUT SAMPLE HERE  */
	    dataFill(signal);
            if (verbose)
                printf("\nDone datafil\n");

	    /*  DO SAMPLE RATE INTERPOLATION OF CONTROL PARAMETERS  */
	    sampleRateInterpolation();
            if (verbose)
                printf("\nDone sample rate interp\n");

	}

        previousInput = currentInput;
        currentInput = currentInput->next;
    }
}



/******************************************************************************
*
*	function:	setControlRateParameters
*
*	purpose:	Calculates the current table values, and their
*                       associated sample-to-sample delta values.
*
*       arguments:      pos
*
*	internal
*	functions:	glotPitchAt, glotVolAt, aspVolAt, fricVolAt, fricPosAt,
*                       fricCFAt, fricBWAt, radiusAtRegion, velumAt,
*
*	library
*	functions:	none
*
******************************************************************************/

void setControlRateParameters(INPUT *previousInput, INPUT *currentInput)
{
    int i;

    /*  GLOTTAL PITCH  */
    current.glotPitch = glotPitchAt(previousInput);
    current.glotPitchDelta =
	(glotPitchAt(currentInput) - current.glotPitch) / (double)controlPeriod;

    /*  GLOTTAL VOLUME  */
    current.glotVol = glotVolAt(previousInput);
    current.glotVolDelta =
	(glotVolAt(currentInput) - current.glotVol) / (double)controlPeriod;

    /*  ASPIRATION VOLUME  */
    current.aspVol = aspVolAt(previousInput);
#if MATCH_DSP
    current.aspVolDelta = 0.0;
#else
    current.aspVolDelta =
	(aspVolAt(currentInput) - current.aspVol) / (double)controlPeriod;
#endif

    /*  FRICATION VOLUME  */
    current.fricVol = fricVolAt(previousInput);
#if MATCH_DSP
    current.fricVolDelta = 0.0;
#else
    current.fricVolDelta =
	(fricVolAt(currentInput) - current.fricVol) / (double)controlPeriod;
#endif

    /*  FRICATION POSITION  */
    current.fricPos = fricPosAt(previousInput);
#if MATCH_DSP
    current.fricPosDelta = 0.0;
#else
    current.fricPosDelta =
	(fricPosAt(currentInput) - current.fricPos) / (double)controlPeriod;
#endif

    /*  FRICATION CENTER FREQUENCY  */
    current.fricCF = fricCFAt(previousInput);
#if MATCH_DSP
    current.fricCFDelta = 0.0;
#else
    current.fricCFDelta =
	(fricCFAt(currentInput) - current.fricCF) / (double)controlPeriod;
#endif

    /*  FRICATION BANDWIDTH  */
    current.fricBW = fricBWAt(previousInput);
#if MATCH_DSP
    current.fricBWDelta = 0.0;
#else
    current.fricBWDelta =
	(fricBWAt(currentInput) - current.fricBW) / (double)controlPeriod;
#endif

    /*  TUBE REGION RADII  */
    for (i = 0; i < TOTAL_REGIONS; i++) {
	current.radius[i] = radiusAtRegion(previousInput, i);
	current.radiusDelta[i] =
	    (radiusAtRegion(currentInput,i) - current.radius[i]) /
		(double)controlPeriod;
    }

    /*  VELUM RADIUS  */
    current.velum = velumAt(previousInput);
    current.velumDelta =
	(velumAt(currentInput) - current.velum) / (double)controlPeriod;
}



/******************************************************************************
*
*	function:	sampleRateInterpolation
*
*	purpose:	Interpolates table values at the sample rate.
*
*       arguments:      none
*
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

void sampleRateInterpolation(void)
{
    int i;

    current.glotPitch += current.glotPitchDelta;
    current.glotVol += current.glotVolDelta;
    current.aspVol += current.aspVolDelta;
    current.fricVol += current.fricVolDelta;
    current.fricPos += current.fricPosDelta;
    current.fricCF += current.fricCFDelta;
    current.fricBW += current.fricBWDelta;
    for (i = 0; i < TOTAL_REGIONS; i++)
	current.radius[i] += current.radiusDelta[i];
    current.velum += current.velumDelta;
}



/******************************************************************************
*
*	function:	initializeNasalCavity
*
*	purpose:	Calculates the scattering coefficients for the fixed
*                       sections of the nasal cavity.
*
*       arguments:      none
*
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

void initializeNasalCavity(void)
{
    int i, j;
    double radA2, radB2;


    /*  CALCULATE COEFFICIENTS FOR INTERNAL FIXED SECTIONS OF NASAL CAVITY  */
    for (i = N2, j = NC2; i < N6; i++, j++) {
	radA2 = noseRadius[i] * noseRadius[i];
	radB2 = noseRadius[i+1] * noseRadius[i+1];
	nasal_coeff[j] = (radA2 - radB2) / (radA2 + radB2);
    }

    /*  CALCULATE THE FIXED COEFFICIENT FOR THE NOSE APERTURE  */
    radA2 = noseRadius[N6] * noseRadius[N6];
    radB2 = apScale * apScale;
    nasal_coeff[NC6] = (radA2 - radB2) / (radA2 + radB2);
}



/******************************************************************************
*
*	function:	initializeThroat
*
*	purpose:	Initializes the throat lowpass filter coefficients
*                       according to the throatCutoff value, and also the
*                       throatGain, according to the throatVol value.
*
*       arguments:      none
*
*	internal
*	functions:	none
*
*	library
*	functions:	fabs
*
******************************************************************************/

void initializeThroat(void)
{
    ta0 = (throatCutoff * 2.0)/sampleRate;
    tb1 = 1.0 - ta0;

    throatGain = amplitude(throatVol);
}



/******************************************************************************
*
*	function:	calculateTubeCoefficients
*
*	purpose:	Calculates the scattering coefficients for the vocal
*                       tract according to the current radii.  Also calculates
*                       the coefficients for the reflection/radiation filter
*                       pair for the mouth and nose.
*
*       arguments:      none
*
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

void calculateTubeCoefficients(void)
{
    int i;
    double radA2, radB2, r0_2, r1_2, r2_2, sum;


    /*  CALCULATE COEFFICIENTS FOR THE OROPHARYNX  */
    for (i = 0; i < (TOTAL_REGIONS-1); i++) {
	radA2 = current.radius[i] * current.radius[i];
	radB2 = current.radius[i+1] * current.radius[i+1];
	oropharynx_coeff[i] = (radA2 - radB2) / (radA2 + radB2);
    }

    /*  CALCULATE THE COEFFICIENT FOR THE MOUTH APERTURE  */
    radA2 = current.radius[R8] * current.radius[R8];
    radB2 = apScale * apScale;
    oropharynx_coeff[C8] = (radA2 - radB2) / (radA2 + radB2);

    /*  CALCULATE ALPHA COEFFICIENTS FOR 3-WAY JUNCTION  */
    /*  NOTE:  SINCE JUNCTION IS IN MIDDLE OF REGION 4, r0_2 = r1_2  */
    r0_2 = r1_2 = current.radius[R4] * current.radius[R4];
    r2_2 = current.velum * current.velum;
    sum = 2.0 / (r0_2 + r1_2 + r2_2);
    alpha[LEFT] = sum * r0_2;
    alpha[RIGHT] = sum * r1_2;
    alpha[UPPER] = sum * r2_2;

    /*  AND 1ST NASAL PASSAGE COEFFICIENT  */
    radA2 = current.velum * current.velum;
    radB2 = noseRadius[N2] * noseRadius[N2];
    nasal_coeff[NC1] = (radA2 - radB2) / (radA2 + radB2);
}



/******************************************************************************
*
*	function:	setFricationTaps
*
*	purpose:	Sets the frication taps according to the current
*                       position and amplitude of frication.
*
*       arguments:      none
*
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

void setFricationTaps(void)
{
    int i, integerPart;
    double complement, remainder;
    double fricationAmplitude = amplitude(current.fricVol);


    /*  CALCULATE POSITION REMAINDER AND COMPLEMENT  */
    integerPart = (int)current.fricPos;
    complement = current.fricPos - (double)integerPart;
    remainder = 1.0 - complement;

    /*  SET THE FRICATION TAPS  */
    for (i = FC1; i < TOTAL_FRIC_COEFFICIENTS; i++) {
	if (i == integerPart) {
	    fricationTap[i] = remainder * fricationAmplitude;
	    if ((i+1) < TOTAL_FRIC_COEFFICIENTS)
		fricationTap[++i] = complement * fricationAmplitude;
	}
	else
	    fricationTap[i] = 0.0;
    }

#if DEBUG
    /*  PRINT OUT  */
    printf("fricationTaps:  ");
    for (i = FC1; i < TOTAL_FRIC_COEFFICIENTS; i++)
	printf("%.6f  ", fricationTap[i]);
    printf("\n");
#endif
}



/******************************************************************************
*
*	function:	calculateBandpassCoefficients
*
*	purpose:	Sets the frication bandpass filter coefficients
*                       according to the current center frequency and
*                       bandwidth.
*
*       arguments:      none
*
*	internal
*	functions:	none
*
*	library
*	functions:	tan, cos
*
******************************************************************************/

void calculateBandpassCoefficients(void)
{
    double tanValue, cosValue;


    tanValue = tan((PI * current.fricBW) / sampleRate);
    cosValue = cos((2.0 * PI * current.fricCF) / sampleRate);

    bpBeta = (1.0 - tanValue) / (2.0 * (1.0 + tanValue));
    bpGamma = (0.5 + bpBeta) * cosValue;
    bpAlpha = (0.5 - bpBeta) / 2.0;
}



/******************************************************************************
*
*	function:	mod0
*
*	purpose:	Returns the modulus of 'value', keeping it in the
*                       range 0 -> TABLE_MODULUS.
*
*       arguments:      value
*
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

double mod0(double value)
{
    if (value > TABLE_MODULUS)
	value -= TABLE_LENGTH;

    return (value);
}



/******************************************************************************
*
*	function:	incrementTablePosition
*
*	purpose:	Increments the position in the wavetable according to
*                       the desired frequency.
*
*       arguments:      frequency
*
*	internal
*	functions:	mod0
*
*	library
*	functions:	none
*
******************************************************************************/

void incrementTablePosition(double frequency)
{
    currentPosition = mod0(currentPosition + (frequency * basicIncrement));
}



/******************************************************************************
*
*	function:	oscillator
*
*	purpose:	Is a 2X oversampling interpolating wavetable
*                       oscillator.
*
*       arguments:      frequency
*
*	internal
*	functions:	incrementTablePosition, mod0, FIRFilter
*
*	library
*	functions:	none
*
******************************************************************************/

#if OVERSAMPLING_OSCILLATOR
double oscillator(double frequency)  /*  2X OVERSAMPLING OSCILLATOR  */
{
    int i, lowerPosition, upperPosition;
    double interpolatedValue, output;


    for (i = 0; i < 2; i++) {
	/*  FIRST INCREMENT THE TABLE POSITION, DEPENDING ON FREQUENCY  */
	incrementTablePosition(frequency/2.0);

	/*  FIND SURROUNDING INTEGER TABLE POSITIONS  */
	lowerPosition = (int)currentPosition;
	upperPosition = mod0(lowerPosition + 1);

	/*  CALCULATE INTERPOLATED TABLE VALUE  */
	interpolatedValue = (wavetable[lowerPosition] +
			     ((currentPosition - lowerPosition) *
			      (wavetable[upperPosition] -
			       wavetable[lowerPosition])));

	/*  PUT VALUE THROUGH FIR FILTER  */
	output = FIRFilter(interpolatedValue, i);
    }

    /*  SINCE WE DECIMATE, TAKE ONLY THE SECOND OUTPUT VALUE  */
    return (output);
}
#else
double oscillator(double frequency)  /*  PLAIN OSCILLATOR  */
{
    int lowerPosition, upperPosition;


    /*  FIRST INCREMENT THE TABLE POSITION, DEPENDING ON FREQUENCY  */
    incrementTablePosition(frequency);

    /*  FIND SURROUNDING INTEGER TABLE POSITIONS  */
    lowerPosition = (int)currentPosition;
    upperPosition = mod0(lowerPosition + 1);

    /*  RETURN INTERPOLATED TABLE VALUE  */
    return (wavetable[lowerPosition] +
	    ((currentPosition - lowerPosition) *
	     (wavetable[upperPosition] - wavetable[lowerPosition])));
}
#endif



/******************************************************************************
*
*	function:	vocalTract
*
*	purpose:	Updates the pressure wave throughout the vocal tract,
*                       and returns the summed output of the oral and nasal
*                       cavities.  Also injects frication appropriately.
*
*       arguments:      input, frication
*
*	internal
*	functions:	reflectionFilter, radiationFilter,
*                       nasalReflectionFilter, nasalRadiationFilter
*
*	library
*	functions:	none
*
******************************************************************************/

double vocalTract(double input, double frication)
{
    int i, j, k;
    double delta, output, junctionPressure;


    /*  INCREMENT CURRENT AND PREVIOUS POINTERS  */
    if (++current_ptr > 1)
	current_ptr = 0;
    if (++prev_ptr > 1)
	prev_ptr = 0;

    /*  UPDATE OROPHARYNX  */
    /*  INPUT TO TOP OF TUBE  */

    oropharynx[S1][TOP][current_ptr] =
	(oropharynx[S1][BOTTOM][prev_ptr] * dampingFactor) + input;

    /*  CALCULATE THE SCATTERING JUNCTIONS FOR S1-S2  */

    delta = oropharynx_coeff[C1] *
	(oropharynx[S1][TOP][prev_ptr] - oropharynx[S2][BOTTOM][prev_ptr]);
    oropharynx[S2][TOP][current_ptr] =
	(oropharynx[S1][TOP][prev_ptr] + delta) * dampingFactor;
    oropharynx[S1][BOTTOM][current_ptr] =
	(oropharynx[S2][BOTTOM][prev_ptr] + delta) * dampingFactor;

    /*  CALCULATE THE SCATTERING JUNCTIONS FOR S2-S3 AND S3-S4  */
    if (verbose)
        printf("\nCalc scattering\n");
    for (i = S2, j = C2, k = FC1; i < S4; i++, j++, k++) {
	delta = oropharynx_coeff[j] *
	    (oropharynx[i][TOP][prev_ptr] - oropharynx[i+1][BOTTOM][prev_ptr]);
	oropharynx[i+1][TOP][current_ptr] =
	    ((oropharynx[i][TOP][prev_ptr] + delta) * dampingFactor) +
		(fricationTap[k] * frication);
	oropharynx[i][BOTTOM][current_ptr] =
	    (oropharynx[i+1][BOTTOM][prev_ptr] + delta) * dampingFactor;
    }

    /*  UPDATE 3-WAY JUNCTION BETWEEN THE MIDDLE OF R4 AND NASAL CAVITY  */
    junctionPressure = (alpha[LEFT] * oropharynx[S4][TOP][prev_ptr])+
	(alpha[RIGHT] * oropharynx[S5][BOTTOM][prev_ptr]) +
	(alpha[UPPER] * nasal[VELUM][BOTTOM][prev_ptr]);
    oropharynx[S4][BOTTOM][current_ptr] =
	(junctionPressure - oropharynx[S4][TOP][prev_ptr]) * dampingFactor;
    oropharynx[S5][TOP][current_ptr] =
	((junctionPressure - oropharynx[S5][BOTTOM][prev_ptr]) * dampingFactor)
	    + (fricationTap[FC3] * frication);
    nasal[VELUM][TOP][current_ptr] =
	(junctionPressure - nasal[VELUM][BOTTOM][prev_ptr]) * dampingFactor;

    /*  CALCULATE JUNCTION BETWEEN R4 AND R5 (S5-S6)  */
    delta = oropharynx_coeff[C4] *
	(oropharynx[S5][TOP][prev_ptr] - oropharynx[S6][BOTTOM][prev_ptr]);
    oropharynx[S6][TOP][current_ptr] =
	((oropharynx[S5][TOP][prev_ptr] + delta) * dampingFactor) +
	    (fricationTap[FC4] * frication);
    oropharynx[S5][BOTTOM][current_ptr] =
	(oropharynx[S6][BOTTOM][prev_ptr] + delta) * dampingFactor;

    /*  CALCULATE JUNCTION INSIDE R5 (S6-S7) (PURE DELAY WITH DAMPING)  */
    oropharynx[S7][TOP][current_ptr] =
	(oropharynx[S6][TOP][prev_ptr] * dampingFactor) +
	    (fricationTap[FC5] * frication);
    oropharynx[S6][BOTTOM][current_ptr] =
	oropharynx[S7][BOTTOM][prev_ptr] * dampingFactor;

    /*  CALCULATE LAST 3 INTERNAL JUNCTIONS (S7-S8, S8-S9, S9-S10)  */
    for (i = S7, j = C5, k = FC6; i < S10; i++, j++, k++) {
	delta = oropharynx_coeff[j] *
	    (oropharynx[i][TOP][prev_ptr] - oropharynx[i+1][BOTTOM][prev_ptr]);
	oropharynx[i+1][TOP][current_ptr] =
	    ((oropharynx[i][TOP][prev_ptr] + delta) * dampingFactor) +
		(fricationTap[k] * frication);
	oropharynx[i][BOTTOM][current_ptr] =
	    (oropharynx[i+1][BOTTOM][prev_ptr] + delta) * dampingFactor;
    }

    /*  REFLECTED SIGNAL AT MOUTH GOES THROUGH A LOWPASS FILTER  */
    oropharynx[S10][BOTTOM][current_ptr] =  dampingFactor *
	reflectionFilter(oropharynx_coeff[C8] *
			 oropharynx[S10][TOP][prev_ptr]);

    /*  OUTPUT FROM MOUTH GOES THROUGH A HIGHPASS FILTER  */
    output = radiationFilter((1.0 + oropharynx_coeff[C8]) *
			     oropharynx[S10][TOP][prev_ptr]);


    /*  UPDATE NASAL CAVITY  */
    for (i = VELUM, j = NC1; i < N6; i++, j++) {
	delta = nasal_coeff[j] *
	    (nasal[i][TOP][prev_ptr] - nasal[i+1][BOTTOM][prev_ptr]);
	nasal[i+1][TOP][current_ptr] =
	    (nasal[i][TOP][prev_ptr] + delta) * dampingFactor;
	nasal[i][BOTTOM][current_ptr] =
	    (nasal[i+1][BOTTOM][prev_ptr] + delta) * dampingFactor;
    }

    /*  REFLECTED SIGNAL AT NOSE GOES THROUGH A LOWPASS FILTER  */
    nasal[N6][BOTTOM][current_ptr] = dampingFactor *
	nasalReflectionFilter(nasal_coeff[NC6] * nasal[N6][TOP][prev_ptr]);

    /*  OUTPUT FROM NOSE GOES THROUGH A HIGHPASS FILTER  */
    output += nasalRadiationFilter((1.0 + nasal_coeff[NC6]) *
				   nasal[N6][TOP][prev_ptr]);

    /*  RETURN SUMMED OUTPUT FROM MOUTH AND NOSE  */
    return(output);
}



/******************************************************************************
*
*	function:	throat
*
*	purpose:	Simulates the radiation of sound through the walls
*                       of the throat.  Note that this form of the filter
*                       uses addition instead of subtraction for the
*                       second term, since tb1 has reversed sign.
*
*       arguments:      input
*
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

double throat(double input)
{
    static double throatY = 0.0;

    double output = (ta0 * input) + (tb1 * throatY);
    throatY = output;
    return (output * throatGain);
}



/******************************************************************************
*
*	function:	bandpassFilter
*
*	purpose:	Frication bandpass filter, with variable center
*                       frequency and bandwidth.
*
*       arguments:      input
*
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

double bandpassFilter(double input)
{
    static double xn1 = 0.0, xn2 = 0.0, yn1 = 0.0, yn2 = 0.0;
    double output;


    output = 2.0 *
	((bpAlpha * (input - xn2)) + (bpGamma * yn1) - (bpBeta * yn2));

    xn2 = xn1;
    xn1 = input;
    yn2 = yn1;
    yn1 = output;

    return (output);
}



/******************************************************************************
*
*	function:	writeOutputToFile
*
*	purpose:	Scales the samples stored in the temporary file, and
*                       writes them to the output file, with the appropriate
*                       header.  Also does master volume scaling, and stereo
*                       balance scaling, if 2 channels of output.
*
*       arguments:      fileName
*
*	internal
*	functions:	writeAuFileHeader, writeSamplesMonoMsb,
*                       writeSamplesStereoMsb, writeAiffHeader,
*                       writeWaveHeader, writeSamplesMonoLsb,
*                       writeSamplesStereoLsb
*
*	library
*	functions:	fopen, printf, fclose
*
******************************************************************************/

void writeOutputToFile(char *fileName)
{
    FILE *fd;
    double scale, leftScale = 0.0, rightScale = 0.0;


    /*  Calculate scaling constant  */
    scale =
	OUTPUT_SCALE * (RANGE_MAX / maximumSampleValue) * amplitude(volume);

    /*  Print out info  */
    if (verbose) {
	printf("\nnumber of samples:\t%-ld\n", numberSamples);
	printf("maximum sample value:\t%.4f\n", maximumSampleValue);
	printf("scale:\t\t\t%.4f\n", scale);
    }

    /*  If stereo, calculate left and right scaling constants  */
    if (channels == 2) {
	/*  Calculate left and right channel amplitudes  */
	leftScale = -((balance / 2.0) - 0.5) * scale * 2.0;
	rightScale = ((balance / 2.0) + 0.5) * scale * 2.0;

	/*  Print out info  */
	if (verbose) {
	    printf("left scale:\t\t%.4f\n", leftScale);
	    printf("right scale:\t\t%.4f\n", rightScale);
	}
    }

    /*  Open the output file  */
    fd = fopen(fileName, "wb");

    /*  Scale and write out samples to the output file  */
    if (outputFileFormat == AU_FILE_FORMAT) {
      writeAuFileHeader(channels, numberSamples, outputRate, fd);
      if (channels == 1)
	writeSamplesMonoMsb(tempFilePtr, numberSamples, scale, fd);
      else
	writeSamplesStereoMsb(tempFilePtr, numberSamples, leftScale,
			      rightScale, fd);
    }
    else if (outputFileFormat == AIFF_FILE_FORMAT) {
      writeAiffFileHeader(channels, numberSamples, outputRate, fd);
      if (channels == 1)
	writeSamplesMonoMsb(tempFilePtr, numberSamples, scale, fd);
      else
	writeSamplesStereoMsb(tempFilePtr, numberSamples, leftScale,
			      rightScale, fd);
    }
    else if (outputFileFormat == WAVE_FILE_FORMAT) {
      writeWaveFileHeader(channels, numberSamples, outputRate, fd);
      if (channels == 1)
	writeSamplesMonoLsb(tempFilePtr, numberSamples, scale, fd);
      else
	writeSamplesStereoLsb(tempFilePtr, numberSamples, leftScale,
			      rightScale, fd);
    }

    /*  Close the output file  */
    fclose(fd);
}



/******************************************************************************
*
*       function:       writeAuFileHeader
*
*       purpose:        Writes the header in AU format to the output file.
*
*       internal
*       functions:      fwriteIntMsb
*
*       library
*       functions:      fputs
*
******************************************************************************/

void writeAuFileHeader(int channels, long int numberSamples,
		       float outputRate, FILE *outputFile)
{
  /*  AU magic string: ".snd"  */
  fputs(".snd", outputFile);

  /*  Header size (fixed in size at 28 bytes)  */
  fwriteIntMsb(28, outputFile);

  /*  Number of bytes of sound data  */
  fwriteIntMsb(channels * numberSamples * sizeof(short), outputFile);

  /*  Sound format:  3 is 16-bit linear  */
  fwriteIntMsb(3, outputFile);

  /*  Output sample rate in samples/second  */
  fwriteIntMsb((int)outputRate, outputFile);

  /*  Number of channels  */
  fwriteIntMsb(channels, outputFile);

  /*  Optional text description (4 bytes minimum)  */
  fwriteIntMsb(0, outputFile);
}



/******************************************************************************
*
*       function:       writeAiffFileHeader
*
*       purpose:        Writes the header in AIFF format to the output file.
*
*       internal
*       functions:      fwriteIntMsb, fwriteShortMsb, convertIntToFloat80
*
*       library
*       functions:      fputs, fwrite
*
******************************************************************************/

void writeAiffFileHeader(int channels, long int numberSamples,
			 float outputRate, FILE *outputFile)
{
  unsigned char sampleFramesPerSecond[10];
  int soundDataSize = channels * numberSamples * sizeof(short);
  int ssndChunkSize = soundDataSize + 8;
  int formSize = ssndChunkSize + 8 + 26 + 4;

  /*  Form container identifier  */
  fputs("FORM", outputFile);

  /*  Form size  */
  fwriteIntMsb(formSize, outputFile);

  /*  Form container type  */
  fputs("AIFF", outputFile);

  /*  Common chunk identifier  */
  fputs("COMM", outputFile);

  /*  Chunk size (fixed at 18 bytes)  */
  fwriteIntMsb(18, outputFile);

  /*  Number of channels  */
  fwriteShortMsb((short)channels, outputFile);

  /*  Number of sample frames  */
  fwriteIntMsb(numberSamples, outputFile);

  /*  Number of bits per samples (fixed at 16)  */
  fwriteShortMsb(BITS_PER_SAMPLE, outputFile);

  /*  Sample frames per second (output sample rate)  */
  /*  stored as an 80-bit (10-byte) float  */
  convertIntToFloat80((unsigned int)outputRate, sampleFramesPerSecond);
  fwrite(sampleFramesPerSecond, sizeof(unsigned char), 10, outputFile);

  /*  Sound Data chunk identifier  */
  fputs("SSND", outputFile);

  /*  Chunk size  */
  fwriteIntMsb(ssndChunkSize, outputFile);

  /*  Offset:  unused, so set to 0  */
  fwriteIntMsb(0, outputFile);

  /*  Block size:  unused, so set to 0  */
  fwriteIntMsb(0, outputFile);
}



/******************************************************************************
*
*       function:       writeWaveFileHeader
*
*       purpose:        Writes the header in WAVE format to the output file.
*
*       internal
*       functions:      fwriteIntLsb, fwriteShortLsb
*
*       library
*       functions:      fputs
*
******************************************************************************/

void writeWaveFileHeader(int channels, long int numberSamples,
			 float outputRate, FILE *outputFile)
{
  int soundDataSize = channels * numberSamples * sizeof(short);
  int dataChunkSize = soundDataSize;
  int formSize = dataChunkSize + 8 + 24 + 4;
  int frameSize = (int)ceil(channels * ((double)BITS_PER_SAMPLE / 8));
  int bytesPerSecond = (int)ceil(outputRate * frameSize);

  /*  Form container identifier  */
  fputs("RIFF", outputFile);

  /*  Form size  */
  fwriteIntLsb(formSize, outputFile);

  /*  Form container type  */
  fputs("WAVE", outputFile);

  /*  Format chunk identifier (Note:  space after 't' needed)  */
  fputs("fmt ", outputFile);

  /*  Chunk size (fixed at 16 bytes)  */
  fwriteIntLsb(16, outputFile);

  /*  Compression code:  1 = PCM  */
  fwriteShortLsb(1, outputFile);

  /*  Number of channels  */
  fwriteShortLsb((short)channels, outputFile);

  /*  Output Sample Rate  */
  fwriteIntLsb((int)outputRate, outputFile);

  /*  Bytes per second  */
  fwriteIntLsb(bytesPerSecond, outputFile);

  /*  Block alignment (frame size)  */
  fwriteShortLsb((short)frameSize, outputFile);

  /*  Bits per sample  */
  fwriteShortLsb((short)BITS_PER_SAMPLE, outputFile);

  /*  Sound Data chunk identifier  */
  fputs("data", outputFile);

  /*  Chunk size  */
  fwriteIntLsb(dataChunkSize, outputFile);
}



/******************************************************************************
*
*       function:       writeSamplesMonoMsb
*
*       purpose:        Reads the double f.p. samples in the temporary file,
*                       scales them, rounds them to a short (16-bit) integer,
*                       and writes them to the output file in big-endian
*                       format.
*
*       internal
*       functions:      fwriteShortMsb
*
*       library
*       functions:      rewind, fread
*
******************************************************************************/

void writeSamplesMonoMsb(FILE *tempFile, long int numberSamples,
			 double scale, FILE *outputFile)
{
  long int i;

  /*  Rewind the temporary file to beginning  */
  rewind(tempFile);

  /*  Write the samples to file, scaling each sample  */
  for (i = 0; i < numberSamples; i++) {
    double sample;

    fread(&sample, sizeof(sample), 1, tempFile);
    fwriteShortMsb((short)rint(sample * scale), outputFile);
  }
}



/******************************************************************************
*
*       function:       writeSamplesMonoLsb
*
*       purpose:        Reads the double f.p. samples in the temporary file,
*                       scales them, rounds them to a short (16-bit) integer,
*                       and writes them to the output file in little-endian
*                       format.
*
*       internal
*       functions:      fwriteShortLsb
*
*       library
*       functions:      rewind, fread
*
******************************************************************************/

void writeSamplesMonoLsb(FILE *tempFile, long int numberSamples,
			 double scale, FILE *outputFile)
{
  long int i;

  /*  Rewind the temporary file to beginning  */
  rewind(tempFile);

  /*  Write the samples to file, scaling each sample  */
  for (i = 0; i < numberSamples; i++) {
    double sample;

    fread(&sample, sizeof(sample), 1, tempFile);
    fwriteShortLsb((short)rint(sample * scale), outputFile);
  }
}



/******************************************************************************
*
*       function:       writeSamplesStereoMsb
*
*       purpose:        Reads the double f.p. samples in the temporary file,
*                       does stereo scaling, rounds them to a short (16-bit)
*                       integer, and writes them to the output file in
*                       big-endian format.
*
*       internal
*       functions:      fwriteShortMsb
*
*       library
*       functions:      rewind, fread
*
******************************************************************************/

void writeSamplesStereoMsb(FILE *tempFile, long int numberSamples,
			   double leftScale, double rightScale,
			   FILE *outputFile)
{
  long int i;

  /*  Rewind the temporary file to beginning  */
  rewind(tempFile);

  /*  Write the samples to file, scaling each sample  */
  for (i = 0; i < numberSamples; i++) {
    double sample;

    fread(&sample, sizeof(sample), 1, tempFile);
    fwriteShortMsb((short)rint(sample * leftScale), outputFile);
    fwriteShortMsb((short)rint(sample * rightScale), outputFile);
  }
}



/******************************************************************************
*
*       function:       writeSamplesStereoLsb
*
*       purpose:        Reads the double f.p. samples in the temporary file,
*                       does stereo scaling, rounds them to a short (16-bit)
*                       integer, and writes them to the output file in
*                       little-endian format.
*
*       internal
*       functions:      fwriteShortLsb
*
*       library
*       functions:      rewind, fread
*
******************************************************************************/

void writeSamplesStereoLsb(FILE *tempFile, long int numberSamples,
			   double leftScale, double rightScale,
			   FILE *outputFile)
{
  long int i;

  /*  Rewind the temporary file to beginning  */
  rewind(tempFile);

  /*  Write the samples to file, scaling each sample  */
  for (i = 0; i < numberSamples; i++) {
    double sample;

    fread(&sample, sizeof(sample), 1, tempFile);
    fwriteShortLsb((short)rint(sample * leftScale), outputFile);
    fwriteShortLsb((short)rint(sample * rightScale), outputFile);
  }
}



/******************************************************************************
*
*       function:       fwriteIntMsb
*
*       purpose:        Writes a 4-byte integer to the file stream, starting
*                       with the most significant byte (i.e. writes the int
*                       in big-endian form).  This routine will work on both
*                       big-endian and little-endian architectures.
*
*       internal
*       functions:      none
*
*       library
*       functions:      fwrite
*
******************************************************************************/

size_t fwriteIntMsb(int data, FILE *stream)
{
    unsigned char array[4];

    array[0] = (unsigned char)((data >> 24) & 0xFF);
    array[1] = (unsigned char)((data >> 16) & 0xFF);
    array[2] = (unsigned char)((data >> 8) & 0xFF);
    array[3] = (unsigned char)(data & 0xFF);
    return (fwrite(array, sizeof(unsigned char), 4, stream));
}



/******************************************************************************
*
*       function:       fwriteIntLsb
*
*       purpose:        Writes a 4-byte integer to the file stream, starting
*                       with the least significant byte (i.e. writes the int
*                       in little-endian form).  This routine will work on both
*                       big-endian and little-endian architectures.
*
*       internal
*       functions:      none
*
*       library
*       functions:      fwrite
*
******************************************************************************/

size_t fwriteIntLsb(int data, FILE *stream)
{
    unsigned char array[4];

    array[3] = (unsigned char)((data >> 24) & 0xFF);
    array[2] = (unsigned char)((data >> 16) & 0xFF);
    array[1] = (unsigned char)((data >> 8) & 0xFF);
    array[0] = (unsigned char)(data & 0xFF);
    return (fwrite(array, sizeof(unsigned char), 4, stream));
}



/******************************************************************************
*
*       function:       fwriteShortMsb
*
*       purpose:        Writes a 2-byte integer to the file stream, starting
*                       with the most significant byte (i.e. writes the int
*                       in big-endian form).  This routine will work on both
*                       big-endian and little-endian architectures.
*
*       internal
*       functions:      none
*
*       library
*       functions:      fwrite
*
******************************************************************************/

size_t fwriteShortMsb(int data, FILE *stream)
{
    unsigned char array[2];

    array[0] = (unsigned char)((data >> 8) & 0xFF);
    array[1] = (unsigned char)(data & 0xFF);
    return (fwrite(array, sizeof(unsigned char), 2, stream));
}



/******************************************************************************
*
*       function:       fwriteShortLsb
*
*       purpose:        Writes a 2-byte integer to the file stream, starting
*                       with the leastt significant byte (i.e. writes the int
*                       in little-endian form).  This routine will work on both
*                       big-endian and little-endian architectures.
*
*       internal
*       functions:      none
*
*       library
*       functions:      fwrite
*
******************************************************************************/

size_t fwriteShortLsb(int data, FILE *stream)
{
    unsigned char array[2];

    array[1] = (unsigned char)((data >> 8) & 0xFF);
    array[0] = (unsigned char)(data & 0xFF);
    return (fwrite(array, sizeof(unsigned char), 2, stream));
}



/******************************************************************************
*
*       function:       convertIntToFloat80
*
*       purpose:        Converts an unsigned 4-byte integer to an IEEE 754
*                       10-byte (80-bit) floating point number.
*
*       internal
*       functions:      none
*
*       library
*       functions:      memset
*
******************************************************************************/

void convertIntToFloat80(unsigned int value, unsigned char buffer[10])
{
  unsigned int exp;
  unsigned short i;

  /*  Set all bytes in buffer to 0  */
  memset(buffer, 0, 10);

  /*  Calculate the exponent  */
  exp = value;
  for (i = 0; i < 32; i++) {
    exp >>= 1;
    if (!exp)
      break;
  }

  /*  Add the bias to the exponent  */
  i += 0x3FFF;

  /*  Store the exponent  */
  buffer[0] = (unsigned char)((i >> 8) & 0x7F);
  buffer[1] = (unsigned char)(i & 0xFF);

  /*  Calculate the mantissa  */
  for (i = 32; i; i--) {
    if (value & 0x80000000)
      break;
    value <<= 1;
  }

  /*  Store the mantissa:  this should work on both big-endian and
      little-endian architectures  */
  buffer[2] = (unsigned char)((value >> 24) & 0xFF);
  buffer[3] = (unsigned char)((value >> 16) & 0xFF);
  buffer[4] = (unsigned char)((value >> 8) & 0xFF);
  buffer[5] = (unsigned char)(value & 0xFF);
}


/******************************************************************************
*
*       function:       amplitude
*
*       purpose:        Converts dB value to amplitude value.
*
*       internal
*       functions:      none
*
*       library
*       functions:      pow
*
******************************************************************************/

double amplitude(double decibelLevel)
{
    /*  CONVERT 0-60 RANGE TO -60-0 RANGE  */
    decibelLevel -= VOL_MAX;

    /*  IF -60 OR LESS, RETURN AMPLITUDE OF 0  */
    if (decibelLevel <= (-VOL_MAX))
        return(0.0);

    /*  IF 0 OR GREATER, RETURN AMPLITUDE OF 1  */
    if (decibelLevel >= 0.0)
        return(1.0);

    /*  ELSE RETURN INVERSE LOG VALUE  */
    return(pow(10.0,(decibelLevel/20.0)));
}



/******************************************************************************
*
*       function:       frequency
*
*       purpose:        Converts a given pitch (0 = middle C) to the
*                       corresponding frequency.
*
*       internal
*       functions:      none
*
*       library
*       functions:      pow
*
******************************************************************************/

double frequency(double pitch)
{
    return(PITCH_BASE * pow(2.0,(((double)(pitch+PITCH_OFFSET))/12.0)));
}



/******************************************************************************
*
*	function:	maximallyFlat
*
*	purpose:	Calculates coefficients for a linear phase lowpass FIR
*                       filter, with beta being the center frequency of the
*                       transition band (as a fraction of the sampling
*                       frequency), and gamme the width of the transition
*                       band.
*
*       arguments:      beta, gamma, np, coefficient
*
*	internal
*	functions:	rationalApproximation
*
*	library
*	functions:	cos, pow
*
******************************************************************************/

int maximallyFlat(double beta, double gamma, int *np, double *coefficient)
{
    double a[LIMIT+1], c[LIMIT+1], betaMinimum, ac;
    int nt, numerator, n, ll, i;


    /*  INITIALIZE NUMBER OF POINTS  */
    (*np) = 0;

    /*  CUT-OFF FREQUENCY MUST BE BETWEEN 0 HZ AND NYQUIST  */
    if ((beta <= 0.0) || (beta >= 0.5))
	return(BETA_OUT_OF_RANGE);

    /*  TRANSITION BAND MUST FIT WITH THE STOP BAND  */
    betaMinimum = ((2.0 * beta) < (1.0 - 2.0 * beta)) ? (2.0 * beta) :
	(1.0 - 2.0 * beta);
    if ((gamma <= 0.0) || (gamma >= betaMinimum))
	return(GAMMA_OUT_OF_RANGE);

    /*  MAKE SURE TRANSITION BAND NOT TOO SMALL  */
    nt = (int)(1.0 / (4.0 * gamma * gamma));
    if (nt > 160)
	return(GAMMA_TOO_SMALL);

    /*  CALCULATE THE RATIONAL APPROXIMATION TO THE CUT-OFF POINT  */
    ac = (1.0 + cos(TWO_PI * beta)) / 2.0;
    rationalApproximation(ac, &nt, &numerator, np);

    /*  CALCULATE FILTER ORDER  */
    n = (2 * (*np)) - 1;
    if (numerator == 0)
	numerator = 1;


    /*  COMPUTE MAGNITUDE AT NP POINTS  */
    c[1] = a[1] = 1.0;
    ll = nt - numerator;

    for (i = 2; i <= (*np); i++) {
	int j;
	double x, sum = 1.0, y;
	c[i] = cos(TWO_PI * ((double)(i-1)/(double)n));
	x = (1.0 - c[i]) / 2.0;
	y = x;

	if (numerator == nt)
	    continue;

	for (j = 1; j <= ll; j++) {
	    double z = y;
	    if (numerator != 1) {
		int jj;
		for (jj = 1; jj <= (numerator - 1); jj++)
		    z *= 1.0 + ((double)j / (double)jj);
	    }
	    y *= x;
	    sum += z;
	}
	a[i] = sum * pow((1.0 - x), numerator);
    }


    /*  CALCULATE WEIGHTING COEFFICIENTS BY AN N-POINT IDFT  */
    for (i = 1; i <= (*np); i++) {
	int j;
	coefficient[i] = a[1] / 2.0;
	for (j = 2; j <= (*np); j++) {
	    int m = ((i - 1) * (j - 1)) % n;
	    if (m > nt)
		m = n - m;
	    coefficient[i] += c[m+1] * a[j];
	}
	coefficient[i] *= 2.0/(double)n;
    }

    return(0);
}



/******************************************************************************
*
*	function:	trim
*
*	purpose:	Trims the higher order coefficients of the FIR filter
*                       which fall below the cutoff value.
*
*       arguments:      cutoff, numberCoefficients, coefficient
*
*	internal
*	functions:	none
*
*	library
*	functions:	fabs
*
******************************************************************************/

void trim(double cutoff, int *numberCoefficients, double *coefficient)
{
    int i;

    for (i = (*numberCoefficients); i > 0; i--) {
	if (fabs(coefficient[i]) >= fabs(cutoff)) {
	    (*numberCoefficients) = i;
	    return;
	}
    }
}



/******************************************************************************
*
*	function:	rationalApproximation
*
*	purpose:	Calculates the best rational approximation to 'number',
*                       given the maximum 'order'.
*
*       arguments:      number, order, numerator, denominator
*
*	internal
*	functions:	none
*
*	library
*	functions:	fabs
*
******************************************************************************/

void rationalApproximation(double number, int *order,
			   int *numerator, int *denominator)
{
    double fractionalPart, minimumError = 1.0;
    int i, orderMaximum, modulus = 0;


    /*  RETURN IMMEDIATELY IF THE ORDER IS LESS THAN ONE  */
    if (*order <= 0) {
	*numerator = 0;
	*denominator = 0;
	*order = -1;
	return;
    }

    /*  FIND THE ABSOLUTE VALUE OF THE FRACTIONAL PART OF THE NUMBER  */
    fractionalPart = fabs(number - (int)number);

    /*  DETERMINE THE MAXIMUM VALUE OF THE DENOMINATOR  */
    orderMaximum = 2 * (*order);
    orderMaximum = (orderMaximum > LIMIT) ? LIMIT : orderMaximum;

    /*  FIND THE BEST DENOMINATOR VALUE  */
    for (i = (*order); i <= orderMaximum; i++) {
	double ps = i * fractionalPart;
	int ip = (int)(ps + 0.5);
	double error = fabs( (ps - (double)ip)/(double)i );
	if (error < minimumError) {
	    minimumError = error;
	    modulus = ip;
	    *denominator = i;
	}
    }

    /*  DETERMINE THE NUMERATOR VALUE, MAKING IT NEGATIVE IF NECESSARY  */
    *numerator = (int)fabs(number) * (*denominator) + modulus;
    if (number < 0)
	*numerator *= (-1);

    /*  SET THE ORDER  */
    *order = *denominator - 1;

    /*  RESET THE NUMERATOR AND DENOMINATOR IF THEY ARE EQUAL  */
    if (*numerator == *denominator) {
	*denominator = orderMaximum;
	*order = *numerator = *denominator - 1;
    }
}



/******************************************************************************
*
*	function:	FIRFilter
*
*	purpose:	Is the linear phase, lowpass FIR filter.
*
*       arguments:      input, needOutput
*
*	internal
*	functions:	increment, decrement
*
*	library
*	functions:	none
*
******************************************************************************/

double FIRFilter(double input, int needOutput)
{
    if (needOutput) {
	int i;
	double output = 0.0;

	/*  PUT INPUT SAMPLE INTO DATA BUFFER  */
	FIRData[FIRPtr] = input;

	/*  SUM THE OUTPUT FROM ALL FILTER TAPS  */
	for (i = 0; i < numberTaps; i++) {
	    output += FIRData[FIRPtr] * FIRCoef[i];
	    FIRPtr = increment(FIRPtr, numberTaps);
	}

	/*  DECREMENT THE DATA POINTER READY FOR NEXT CALL  */
	FIRPtr = decrement(FIRPtr, numberTaps);

	/*  RETURN THE OUTPUT VALUE  */
	return(output);
    }
    else {
	/*  PUT INPUT SAMPLE INTO DATA BUFFER  */
	FIRData[FIRPtr] = input;

	/*  ADJUST THE DATA POINTER, READY FOR NEXT CALL  */
	FIRPtr = decrement(FIRPtr, numberTaps);

	return(0.0);
    }
}



/******************************************************************************
*
*	function:	increment
*
*	purpose:	Increments the pointer to the circular FIR filter
*                       buffer, keeping it in the range 0 -> modulus-1.
*
*       arguments:      pointer, modulus
*
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

int increment(int pointer, int modulus)
{
    if (++pointer >= modulus)
	return(0);
    else
	return(pointer);
}


/******************************************************************************
*
*	function:	decrement
*
*	purpose:	Decrements the pointer to the circular FIR filter
*                       buffer, keeping it in the range 0 -> modulus-1.
*
*       arguments:      pointer, modulus
*
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

int decrement(int pointer, int modulus)
{
    if (--pointer < 0)
	return(modulus-1);
    else
	return(pointer);
}



/******************************************************************************
*
*	function:	initializeConversion
*
*	purpose:	Initializes all the sample rate conversion functions.
*
*       arguments:      none
*
*	internal
*	functions:	initializeFilter, initializeBuffer
*
*	library
*	functions:	rint, pow
*
******************************************************************************/

void initializeConversion(void)
{
    double roundedSampleRateRatio;


    /*  INITIALIZE FILTER IMPULSE RESPONSE  */
    initializeFilter();

    /*  CALCULATE SAMPLE RATE RATIO  */
    sampleRateRatio = (double)outputRate / (double)sampleRate;

    /*  CALCULATE TIME REGISTER INCREMENT  */
    timeRegisterIncrement =
	(int)rint( pow(2.0, FRACTION_BITS) / sampleRateRatio );

    /*  CALCULATE ROUNDED SAMPLE RATE RATIO  */
    roundedSampleRateRatio =
	pow(2.0, FRACTION_BITS) / (double)timeRegisterIncrement;

    /*  CALCULATE PHASE OR FILTER INCREMENT  */
    if (sampleRateRatio >= 1.0) {
	filterIncrement = L_RANGE;
    }
    else {
	phaseIncrement =
	     (unsigned int)rint(sampleRateRatio * (double)FRACTION_RANGE);
    }

    /*  CALCULATE PAD SIZE  */
    padSize = (sampleRateRatio >= 1.0) ? ZERO_CROSSINGS :
	(int)((float)ZERO_CROSSINGS / roundedSampleRateRatio) + 1;

    /*  INITIALIZE THE RING BUFFER  */
    initializeBuffer();
}



/******************************************************************************
*
*	function:	initializeFilter
*
*	purpose:	Initializes filter impulse response and impulse delta
*                       values.
*
*       arguments:      none
*
*	internal
*	functions:	none
*
*	library
*	functions:	sin, cos
*
******************************************************************************/

void initializeFilter(void)
{
    double x, IBeta;
    int i;


    /*  INITIALIZE THE FILTER IMPULSE RESPONSE  */
    h[0] = LP_CUTOFF;
    x = PI / (double)L_RANGE;
    for (i = 1; i < FILTER_LENGTH; i++) {
	double y = (double)i * x;
	h[i] = sin(y * LP_CUTOFF) / y;
    }

    /*  APPLY A KAISER WINDOW TO THE IMPULSE RESPONSE  */
    IBeta = 1.0 / Izero(BETA);
    for (i = 0; i < FILTER_LENGTH; i++) {
	double temp = (double)i / FILTER_LENGTH;
	h[i] *= Izero(BETA * sqrt(1.0 - (temp * temp))) * IBeta;
    }

    /*  INITIALIZE THE FILTER IMPULSE RESPONSE DELTA VALUES  */
    for (i = 0; i < FILTER_LIMIT; i++)
	deltaH[i] = h[i+1] - h[i];
    deltaH[FILTER_LIMIT] = 0.0 - h[FILTER_LIMIT];
}



/******************************************************************************
*
*	function:	Izero
*
*	purpose:	Returns the value for the modified Bessel function of
*                       the first kind, order 0, as a double.
*
*       arguments:      x - input argument
*
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

double Izero(double x)
{
    double sum, u, halfx, temp;
    int n;


    sum = u = n = 1;
    halfx = x / 2.0;

    do {
	temp = halfx / (double)n;
	n += 1;
	temp *= temp;
	u *= temp;
	sum += u;
    } while (u >= (IzeroEPSILON * sum));

    return(sum);
}



/******************************************************************************
*
*	function:	initializeBuffer
*
*	purpose:	Initializes the ring buffer used for sample rate
*                       conversion.
*
*       arguments:      none
*
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

void initializeBuffer(void)
{
    int i;


    /*  FILL THE RING BUFFER WITH ALL ZEROS  */
    for (i = 0; i < BUFFER_SIZE; i++)
	buffer[i] = 0.0;

    /*  INITIALIZE FILL POINTER  */
    fillPtr = padSize;

    /*  CALCULATE FILL SIZE  */
    fillSize = BUFFER_SIZE - (2 * padSize);
}



/******************************************************************************
*
*	function:	dataFill
*
*	purpose:	Fills the ring buffer with a single sample, increments
*                       the counters and pointers, and empties the buffer when
*                       full.
*
*       arguments:      data
*
*	internal
*	functions:	srIncrement, dataEmpty
*
*	library
*	functions:	none
*
******************************************************************************/

void dataFill(double data)
{
    static int fillCounter = 0;


    /*  PUT THE DATA INTO THE RING BUFFER  */
    buffer[fillPtr] = data;

    /*  INCREMENT THE FILL POINTER, MODULO THE BUFFER SIZE  */
    srIncrement(&fillPtr, BUFFER_SIZE);

    /*  INCREMENT THE COUNTER, AND EMPTY THE BUFFER IF FULL  */
    if (++fillCounter >= fillSize) {
	dataEmpty();
	/* RESET THE FILL COUNTER  */
	fillCounter = 0;
    }
}



/******************************************************************************
*
*	function:	dataEmpty
*
*	purpose:	Converts available portion of the input signal to the
*                       new sampling rate, and outputs the samples to the
*                       sound struct.
*
*       arguments:      none
*
*	internal
*	functions:	srDecrement, srIncrement
*
*	library
*	functions:	rint, fabs, fwrite
*
******************************************************************************/

void dataEmpty(void)
{
    int endPtr;


    /*  CALCULATE END POINTER  */
    endPtr = fillPtr - padSize;

    /*  ADJUST THE END POINTER, IF LESS THAN ZERO  */
    if (endPtr < 0)
	endPtr += BUFFER_SIZE;

    /*  ADJUST THE ENDPOINT, IF LESS THEN THE EMPTY POINTER  */
    if (endPtr < emptyPtr)
	endPtr += BUFFER_SIZE;

    /*  UPSAMPLE LOOP (SLIGHTLY MORE EFFICIENT THAN DOWNSAMPLING)  */
    if (sampleRateRatio >= 1.0) {
	while (emptyPtr < endPtr) {
	    int index;
	    unsigned int filterIndex;
	    double output, interpolation, absoluteSampleValue;

	    /*  RESET ACCUMULATOR TO ZERO  */
	    output = 0.0;

	    /*  CALCULATE INTERPOLATION VALUE (STATIC WHEN UPSAMPLING)  */
	    interpolation = (double)mValue(timeRegister) / M_RANGE;

	    /*  COMPUTE THE LEFT SIDE OF THE FILTER CONVOLUTION  */
	    index = emptyPtr;
	    for (filterIndex = lValue(timeRegister);
		 filterIndex < FILTER_LENGTH;
		 srDecrement(&index,BUFFER_SIZE),
		 filterIndex += filterIncrement) {
		output += (buffer[index] *
		    (h[filterIndex] + (deltaH[filterIndex] * interpolation)));
	    }

	    /*  ADJUST VALUES FOR RIGHT SIDE CALCULATION  */
	    timeRegister = ~timeRegister;
	    interpolation = (double)mValue(timeRegister) / M_RANGE;

	    /*  COMPUTE THE RIGHT SIDE OF THE FILTER CONVOLUTION  */
	    index = emptyPtr;
	    srIncrement(&index,BUFFER_SIZE);
	    for (filterIndex = lValue(timeRegister);
		 filterIndex < FILTER_LENGTH;
		 srIncrement(&index,BUFFER_SIZE),
		 filterIndex += filterIncrement) {
		output += (buffer[index] *
		    (h[filterIndex] + (deltaH[filterIndex] * interpolation)));
	    }

	    /*  RECORD MAXIMUM SAMPLE VALUE  */
	    absoluteSampleValue = fabs(output);
	    if (absoluteSampleValue > maximumSampleValue)
		maximumSampleValue = absoluteSampleValue;

	    /*  INCREMENT SAMPLE NUMBER  */
	    numberSamples++;

	    /*  OUTPUT THE SAMPLE TO THE TEMPORARY FILE  */
	    fwrite((char *)&output, sizeof(output), 1, tempFilePtr);

	    /*  CHANGE TIME REGISTER BACK TO ORIGINAL FORM  */
	    timeRegister = ~timeRegister;

	    /*  INCREMENT THE TIME REGISTER  */
	    timeRegister += timeRegisterIncrement;

	    /*  INCREMENT THE EMPTY POINTER, ADJUSTING IT AND END POINTER  */
	    emptyPtr += nValue(timeRegister);

	    if (emptyPtr >= BUFFER_SIZE) {
		emptyPtr -= BUFFER_SIZE;
		endPtr -= BUFFER_SIZE;
	    }

	    /*  CLEAR N PART OF TIME REGISTER  */
	    timeRegister &= (~N_MASK);
	}
    }
    /*  DOWNSAMPLING CONVERSION LOOP  */
    else {
	while (emptyPtr < endPtr) {
	    int index;
	    unsigned int phaseIndex, impulseIndex;
	    double absoluteSampleValue, output, impulse;

	    /*  RESET ACCUMULATOR TO ZERO  */
	    output = 0.0;

	    /*  COMPUTE P PRIME  */
	    phaseIndex = (unsigned int)rint(
		   ((double)fractionValue(timeRegister)) * sampleRateRatio);

	    /*  COMPUTE THE LEFT SIDE OF THE FILTER CONVOLUTION  */
	    index = emptyPtr;
	    while ((impulseIndex = (phaseIndex>>M_BITS)) < FILTER_LENGTH) {
		impulse = h[impulseIndex] + (deltaH[impulseIndex] *
		    (((double)mValue(phaseIndex)) / M_RANGE));
		output += (buffer[index] * impulse);
		srDecrement(&index,BUFFER_SIZE);
		phaseIndex += phaseIncrement;
	    }

	    /*  COMPUTE P PRIME, ADJUSTED FOR RIGHT SIDE  */
	    phaseIndex = (unsigned int)rint(
		((double)fractionValue(~timeRegister)) * sampleRateRatio);

	    /*  COMPUTE THE RIGHT SIDE OF THE FILTER CONVOLUTION  */
	    index = emptyPtr;
	    srIncrement(&index,BUFFER_SIZE);
	    while ((impulseIndex = (phaseIndex>>M_BITS)) < FILTER_LENGTH) {
		impulse = h[impulseIndex] + (deltaH[impulseIndex] *
		    (((double)mValue(phaseIndex)) / M_RANGE));
		output += (buffer[index] * impulse);
		srIncrement(&index,BUFFER_SIZE);
		phaseIndex += phaseIncrement;
	    }

	    /*  RECORD MAXIMUM SAMPLE VALUE  */
	    absoluteSampleValue = fabs(output);
	    if (absoluteSampleValue > maximumSampleValue)
		maximumSampleValue = absoluteSampleValue;

	    /*  INCREMENT SAMPLE NUMBER  */
	    numberSamples++;

	    /*  OUTPUT THE SAMPLE TO THE TEMPORARY FILE  */
	    fwrite((char *)&output, sizeof(output), 1, tempFilePtr);

	    /*  INCREMENT THE TIME REGISTER  */
	    timeRegister += timeRegisterIncrement;

	    /*  INCREMENT THE EMPTY POINTER, ADJUSTING IT AND END POINTER  */
	    emptyPtr += nValue(timeRegister);
	    if (emptyPtr >= BUFFER_SIZE) {
		emptyPtr -= BUFFER_SIZE;
		endPtr -= BUFFER_SIZE;
	    }

	    /*  CLEAR N PART OF TIME REGISTER  */
	    timeRegister &= (~N_MASK);
	}
    }
}



/******************************************************************************
*
*	function:	flushBuffer
*
*	purpose:	Pads the buffer with zero samples, and flushes it by
*                       converting the remaining samples.
*
*       arguments:      none
*
*	internal
*	functions:	dataFill, dataEmpty
*
*	library
*	functions:	none
*
******************************************************************************/

void flushBuffer(void)
{
    int i;


    /*  PAD END OF RING BUFFER WITH ZEROS  */
    for (i = 0; i < (padSize * 2); i++)
	dataFill(0.0);

    /*  FLUSH UP TO FILL POINTER - PADSIZE  */
    dataEmpty();
}



/******************************************************************************
*
*	function:	srIncrement
*
*	purpose:	Increments the pointer, keeping it within the range
*                       0 to (modulus-1).
*
*       arguments:      pointer, modulus
*
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

void srIncrement(int *pointer, int modulus)
{
    if ( ++(*pointer) >= modulus)
	(*pointer) -= modulus;
}



/******************************************************************************
*
*	function:	srDecrement
*
*	purpose:	Decrements the pointer, keeping it within the range
*                       0 to (modulus-1).
*
*       arguments:      pointer, modulus
*
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

void srDecrement(int *pointer, int modulus)
{
    if ( --(*pointer) < 0)
	(*pointer) += modulus;
}

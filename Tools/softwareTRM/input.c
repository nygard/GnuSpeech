#include "input.h"

#include <stdlib.h>
#include "output.h"
#include "tube.h"

/*  VARIABLES FOR INPUT TABLE STORAGE  */
INPUT *inputHead = NULL;
static INPUT *inputTail = NULL;
int numberInputTables = 0;



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
    } else {
	tempPtr = inputTail;
	inputTail = tempPtr->next = newInputTable();
	inputTail->previous = tempPtr;
    }

    /*  SET NULL POINTER TO NEXT, SINCE END OF LIST  */
    inputTail->next = NULL;

    /*  ADD GLOTTAL PITCH AND VOLUME  */
    inputTail->parameters.glotPitch = glotPitch;
    inputTail->parameters.glotVol = glotVol;

    /*  ADD ASPIRATION  */
    inputTail->parameters.aspVol = aspVol;

    /*  ADD FRICATION PARAMETERS  */
    inputTail->parameters.fricVol = fricVol;
    inputTail->parameters.fricPos = fricPos;
    inputTail->parameters.fricCF = fricCF;
    inputTail->parameters.fricBW = fricBW;

    /*  ADD TUBE REGION RADII  */
    for (i = 0; i < TOTAL_REGIONS; i++)
	inputTail->parameters.radius[i] = radius[i];

    /*  ADD VELUM RADIUS  */
    inputTail->parameters.velum = velum;

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

// Returns the pitch stored in the table 'ptr'.
double glotPitchAt(INPUT *ptr)
{
    if (ptr)
	return ptr->parameters.glotPitch;

    return 0.0;
}

// Returns the glotVol stored in the table 'ptr'.
double glotVolAt(INPUT *ptr)
{
    if (ptr)
	return ptr->parameters.glotVol;

    return 0.0;
}

// Returns the variable tube radii stored in the table 'ptr'.
double *radiiAt(INPUT *ptr)
{
    if (ptr)
	return ptr->parameters.radius;

    return NULL;
}

// Returns the radius for 'region', from the table 'ptr'.
double radiusAtRegion(INPUT *ptr, int region)
{
    if (ptr)
	return ptr->parameters.radius[region];

    return 0.0;
}

// Returns the velum radius from the table 'ptr'.
double velumAt(INPUT *ptr)
{
    if (ptr)
	return ptr->parameters.velum;

    return 0.0;
}

// Returns the aspiration factor from the table 'ptr'.
double aspVolAt(INPUT *ptr)
{
    if (ptr)
	return ptr->parameters.aspVol;

    return 0.0;
}

// Returns the frication volume from the table 'ptr'.
double fricVolAt(INPUT *ptr)
{
    if (ptr)
	return ptr->parameters.fricVol;

    return 0.0;
}

// Returns the frication position from the table 'ptr'.
double fricPosAt(INPUT *ptr)
{
    if (ptr)
	return ptr->parameters.fricPos;

    return 0.0;
}

// Returns the frication center frequency from the table 'ptr'.
double fricCFAt(INPUT *ptr)
{
    if (ptr)
	return ptr->parameters.fricCF;

    return 0.0;
}

// Returns the frication bandwidth from the table 'ptr'.
double fricBWAt(INPUT *ptr)
{
    if (ptr)
	return ptr->parameters.fricBW;

    return 0.0;
}

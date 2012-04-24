//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "input.h"

// Variables for input table storage

static INPUT *newInputTable(void);
static int32_t inputTableLength(INPUT *ptr);

// Parses the input file and assigns values to global variables.
TRMDataList *parseInputFile(const char *inputFile)
{
    int32_t i;
    FILE *fp;
    char line[128];
    int32_t numberInputTables = 0;
    TRMDataList data, *result;


    if ((fp = fopen(inputFile, "r")) == NULL) {
        fprintf(stderr, "Can't open input file \"%s\".\n", inputFile);
        return NULL;
    }


    // Get the output file format
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read output file format.\n");
        return NULL;
    } else
        data.inputParameters.outputFileFormat = strtol(line, NULL, 10);

    // Get the output sample rate
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read output sample rate.\n");
        return NULL;
    } else
        data.inputParameters.outputRate = strtod(line, NULL);

    // Get the input control rate
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read input control rate.\n");
        return NULL;
    } else
        data.inputParameters.controlRate = strtod(line, NULL);


    // Get the master volume
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read master volume.\n");
        return NULL;
    } else
        data.inputParameters.volume = strtod(line, NULL);

    // Get the number of sound output channels
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read number of sound output channels.\n");
        return NULL;
    } else
        data.inputParameters.channels = strtol(line, NULL, 10);

    // Get the stereo balance
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read stereo balance.\n");
        return NULL;
    } else
        data.inputParameters.balance = strtod(line, NULL);


    // Get the glottal source waveform type
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read glottal source waveform type.\n");
        return NULL;
    } else
        data.inputParameters.waveform = strtol(line, NULL, 10);

    // Get the glottal pulse rise time (tp)
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read glottal pulse rise time (tp).\n");
        return NULL;
    } else
        data.inputParameters.tp = strtod(line, NULL);

    // Get the glottal pulse fall time minimum (tnMin)
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read glottal pulse fall time minimum (tnMin).\n");
        return NULL;
    } else
        data.inputParameters.tnMin = strtod(line, NULL);

    // Get the glottal pulse fall time maximum (tnMax)
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read glottal pulse fall time maximum (tnMax).\n");
        return NULL;
    } else
        data.inputParameters.tnMax = strtod(line, NULL);

    // Get the glottal source breathiness
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read glottal source breathiness.\n");
        return NULL;
    } else
        data.inputParameters.breathiness = strtod(line, NULL);


    // Get the nominal tube length
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read nominal tube length.\n");
        return NULL;
    } else
        data.inputParameters.length = strtod(line, NULL);

    // Get the tube temperature
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read tube temperature.\n");
        return NULL;
    } else
        data.inputParameters.temperature = strtod(line, NULL);

    // Get the junction loss factor
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read junction loss factor.\n");
        return NULL;
    } else
        data.inputParameters.lossFactor = strtod(line, NULL);


    // Get the aperture scaling radius
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read aperture scaling radius.\n");
        return NULL;
    } else
        data.inputParameters.apScale = strtod(line, NULL);

    // Get the mouth aperture coefficient
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read mouth aperture coefficient\n");
        return NULL;
    } else
        data.inputParameters.mouthCoef = strtod(line, NULL);

    // Get the nose aperture coefficient
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read nose aperture coefficient\n");
        return NULL;
    } else
        data.inputParameters.noseCoef = strtod(line, NULL);


    // Get the nose radii
    for (i = 1; i < TOTAL_NASAL_SECTIONS; i++) {
        if (fgets(line, 128, fp) == NULL) {
            fprintf(stderr, "Can't read nose radius %-d.\n", i);
            return NULL;
        } else
            data.inputParameters.noseRadius[i] = strtod(line, NULL);
    }


    // Get the throat lowpass frequency cutoff
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read throat lowpass filter cutoff.\n");
        return NULL;
    } else
        data.inputParameters.throatCutoff = strtod(line, NULL);

    // Get the throat volume
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read throat volume.\n");
        return NULL;
    } else
        data.inputParameters.throatVol = strtod(line, NULL);


    // Get the pulse modulation of noise flag
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read pulse modulation of noise flag.\n");
        return NULL;
    } else
        data.inputParameters.modulation = strtol(line, NULL, 10);

    // Get the noise crossmix offset
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read noise crossmix offset.\n");
        return NULL;
    } else
        data.inputParameters.mixOffset = strtod(line, NULL);


    data.inputHead = NULL;
    data.inputTail = NULL;

    // Get the inputtable values
    while (fgets(line, 128, fp)) {
        double glotPitch, glotVol, radius[TOTAL_REGIONS], velum, aspVol;
        double fricVol, fricPos, fricCF, fricBW;
        char *ptr = line;

        // Get each parameter
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

        // Add the parameters to the input list
        addInput(&data, glotPitch, glotVol, aspVol, fricVol, fricPos, fricCF, fricBW, radius, velum);
        numberInputTables++;
    }
#if 0
    // Double up the last input table, to help interpolation calculations
    if (numberInputTables > 0) {
        addInput(&data, glotPitchAt(data.inputTail), glotVolAt(data.inputTail),
                 aspVolAt(data.inputTail), fricVolAt(data.inputTail),
                 fricPosAt(data.inputTail), fricCFAt(data.inputTail),
                 fricBWAt(data.inputTail), radiiAt(data.inputTail),
                 velumAt(data.inputTail));
    }
#endif
    // Close the input file
    fclose(fp);

    result = (TRMDataList *)malloc(sizeof(TRMDataList));
    if (result == NULL) {
        fprintf(stderr, "Couldn't malloc() TRMData.\n");
        return NULL;
    }

    memcpy(result, &data, sizeof(TRMDataList));

    return result;
}

// Adds table control data to the end of a linked list.
void addInput(TRMDataList *data, double glotPitch, double glotVol, double aspVol, double fricVol,
              double fricPos, double fricCF, double fricBW, double *radius,
              double velum)
{
    int32_t i;
    INPUT *tempPtr;
#if 0
    printf("addInput(%p, %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g [%8.4g %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g %8.4g] %8.4g)\n", data,
           glotPitch, glotVol, aspVol, fricVol, fricPos, fricCF, fricBW,
           radius[0], radius[1], radius[2], radius[3], radius[4], radius[5], radius[6], radius[7],
           velum);
#endif
    if (data->inputHead == NULL) {
        data->inputTail = data->inputHead = newInputTable();
        data->inputTail->previous = NULL;
    } else {
        tempPtr = data->inputTail;
        data->inputTail = tempPtr->next = newInputTable();
        data->inputTail->previous = tempPtr;
    }

    // Set NULL pointer to next, since end of list
    data->inputTail->next = NULL;

    // Add glottal pitch and volume
    data->inputTail->parameters.glotPitch = glotPitch;
    data->inputTail->parameters.glotVol = glotVol;

    // Add aspiration
    data->inputTail->parameters.aspVol = aspVol;

    // Add frication parameters
    data->inputTail->parameters.fricVol = fricVol;
    data->inputTail->parameters.fricPos = fricPos;
    data->inputTail->parameters.fricCF = fricCF;
    data->inputTail->parameters.fricBW = fricBW;

    // Add tube region radii
    for (i = 0; i < TOTAL_REGIONS; i++)
        data->inputTail->parameters.radius[i] = radius[i];

    // Add velum radius
    data->inputTail->parameters.velum = velum;
}

// Allocates memory for a new input table.
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
double radiusAtRegion(INPUT *ptr, int32_t region)
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

int inputTableLength(INPUT *ptr)
{
    int32_t count = 0;

    while (ptr) {
        count++;
        ptr = ptr->next;
    }

    return count;
}

void printControlRateInputTable(TRMDataList *data)
{
    INPUT *ptr;
    int32_t index;

    // Echo table values
    printf("\n%-d control rate input tables:\n\n", inputTableLength(data->inputHead));

    // Header
    printf("glPitch");
    printf("\tglotVol");
    printf("\taspVol");
    printf("\tfricVol");
    printf("\tfricPos");
    printf("\tfricCF");
    printf("\tfricBW");
    for (index = 0; index < TOTAL_REGIONS; index++)
        printf("\tr%-d", index + 1);
    printf("\tvelum\n");

    // Actual values
    ptr = data->inputHead;
    while (ptr != NULL) {
        TRMParameters *parameters;

        parameters = &(ptr->parameters);
        printf("%.2f", parameters->glotPitch);
        printf("\t%.2f", parameters->glotVol);
        printf("\t%.2f", parameters->aspVol);
        printf("\t%.2f", parameters->fricVol);
        printf("\t%.2f", parameters->fricPos);
        printf("\t%.2f", parameters->fricCF);
        printf("\t%.2f", parameters->fricBW);
        for (index = 0; index < TOTAL_REGIONS; index++)
            printf("\t%.2f", parameters->radius[index]);
        printf("\t%.2f\n", parameters->velum);
        ptr = ptr->next;
    }
    printf("\n");
}

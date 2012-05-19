//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "input.h"

#import "TRMDataList.h"
#import "TRMInputParameters.h"
#import "TRMParameters.h"

// Parses the input file and assigns values to global variables.
TRMDataList *parseInputFile(const char *inputFile)
{
    FILE *fp = fopen(inputFile, "r");
    if (fp == NULL) {
        fprintf(stderr, "Can't open input file \"%s\".\n", inputFile);
        return NULL;
    }
    
    TRMDataList *dataList = [[[TRMDataList alloc] init] autorelease];
    char line[128];

    // Get the output file format
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read output file format.\n");
        return NULL;
    } else
        dataList.inputParameters.outputFileFormat = strtol(line, NULL, 10);

    // Get the output sample rate
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read output sample rate.\n");
        return NULL;
    } else
        dataList.inputParameters.outputRate = strtod(line, NULL);

    // Get the input control rate
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read input control rate.\n");
        return NULL;
    } else
        dataList.inputParameters.controlRate = strtod(line, NULL);


    // Get the master volume
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read master volume.\n");
        return NULL;
    } else
        dataList.inputParameters.volume = strtod(line, NULL);

    // Get the number of sound output channels
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read number of sound output channels.\n");
        return NULL;
    } else
        dataList.inputParameters.channels = strtol(line, NULL, 10);

    // Get the stereo balance
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read stereo balance.\n");
        return NULL;
    } else
        dataList.inputParameters.balance = strtod(line, NULL);


    // Get the glottal source waveform type
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read glottal source waveform type.\n");
        return NULL;
    } else
        dataList.inputParameters.waveform = strtol(line, NULL, 10);

    // Get the glottal pulse rise time (tp)
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read glottal pulse rise time (tp).\n");
        return NULL;
    } else
        dataList.inputParameters.tp = strtod(line, NULL);

    // Get the glottal pulse fall time minimum (tnMin)
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read glottal pulse fall time minimum (tnMin).\n");
        return NULL;
    } else
        dataList.inputParameters.tnMin = strtod(line, NULL);

    // Get the glottal pulse fall time maximum (tnMax)
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read glottal pulse fall time maximum (tnMax).\n");
        return NULL;
    } else
        dataList.inputParameters.tnMax = strtod(line, NULL);

    // Get the glottal source breathiness
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read glottal source breathiness.\n");
        return NULL;
    } else
        dataList.inputParameters.breathiness = strtod(line, NULL);


    // Get the nominal tube length
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read nominal tube length.\n");
        return NULL;
    } else
        dataList.inputParameters.length = strtod(line, NULL);

    // Get the tube temperature
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read tube temperature.\n");
        return NULL;
    } else
        dataList.inputParameters.temperature = strtod(line, NULL);

    // Get the junction loss factor
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read junction loss factor.\n");
        return NULL;
    } else
        dataList.inputParameters.lossFactor = strtod(line, NULL);


    // Get the aperture scaling radius
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read aperture scaling radius.\n");
        return NULL;
    } else
        dataList.inputParameters.apScale = strtod(line, NULL);

    // Get the mouth aperture coefficient
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read mouth aperture coefficient\n");
        return NULL;
    } else
        dataList.inputParameters.mouthCoef = strtod(line, NULL);

    // Get the nose aperture coefficient
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read nose aperture coefficient\n");
        return NULL;
    } else
        dataList.inputParameters.noseCoef = strtod(line, NULL);


    // Get the nose radii
    for (NSUInteger i = 1; i < TOTAL_NASAL_SECTIONS; i++) {
        if (fgets(line, 128, fp) == NULL) {
            fprintf(stderr, "Can't read nose radius %-lu.\n", i);
            return NULL;
        } else
            dataList.inputParameters.noseRadius[i] = strtod(line, NULL);
    }


    // Get the throat lowpass frequency cutoff
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read throat lowpass filter cutoff.\n");
        return NULL;
    } else
        dataList.inputParameters.throatCutoff = strtod(line, NULL);

    // Get the throat volume
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read throat volume.\n");
        return NULL;
    } else
        dataList.inputParameters.throatVol = strtod(line, NULL);


    // Get the pulse modulation of noise flag
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read pulse modulation of noise flag.\n");
        return NULL;
    } else
        dataList.inputParameters.modulation = strtol(line, NULL, 10);

    // Get the noise crossmix offset
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read noise crossmix offset.\n");
        return NULL;
    } else
        dataList.inputParameters.mixOffset = strtod(line, NULL);


    // Get the input table values
    while (fgets(line, 128, fp)) {
        char *ptr = line;
        TRMParameters *inputParameters = [[[TRMParameters alloc] init] autorelease];
        double *radius = inputParameters.radius;
        
        // Get each parameter
        inputParameters.glotPitch = strtod(ptr, &ptr);
        inputParameters.glotVol = strtod(ptr, &ptr);
        inputParameters.aspVol = strtod(ptr, &ptr);
        inputParameters.fricVol = strtod(ptr, &ptr);
        inputParameters.fricPos = strtod(ptr, &ptr);
        inputParameters.fricCF = strtod(ptr, &ptr);
        inputParameters.fricBW = strtod(ptr, &ptr);
        for (NSUInteger i = 0; i < TOTAL_REGIONS; i++)
            radius[i] = strtod(ptr, &ptr);
        inputParameters.velum = strtod(ptr, &ptr);

        [dataList.values addObject:inputParameters];
    }
    
    // Double up the last input table, to help interpolation calculations    if ([dataList.values count] > 0) {
    if ([dataList.values count] > 0) {
        [dataList.values addObject:[dataList.values lastObject]]; // TODO (201-04-28): Should copy object
    }

    // Close the input file
    fclose(fp);

    return dataList;
}

void printControlRateInputTable(TRMDataList *data)
{
    // Echo table values
    printf("\n%-lu control rate input tables:\n\n", [data.values count]);

    // Header
    printf("glPitch");
    printf("\tglotVol");
    printf("\taspVol");
    printf("\tfricVol");
    printf("\tfricPos");
    printf("\tfricCF");
    printf("\tfricBW");
    for (NSUInteger index = 0; index < TOTAL_REGIONS; index++)
        printf("\tr%-lu", index + 1);
    printf("\tvelum\n");

    // Actual values
    for (TRMParameters *parameters in data.values) {
        printf("%.2f", parameters.glotPitch);
        printf("\t%.2f", parameters.glotVol);
        printf("\t%.2f", parameters.aspVol);
        printf("\t%.2f", parameters.fricVol);
        printf("\t%.2f", parameters.fricPos);
        printf("\t%.2f", parameters.fricCF);
        printf("\t%.2f", parameters.fricBW);
        for (NSUInteger index = 0; index < TOTAL_REGIONS; index++)
            printf("\t%.2f", parameters.radius[index]);
        printf("\t%.2f\n", parameters.velum);
    }
    printf("\n");
}

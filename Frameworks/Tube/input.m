//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "input.h"

#import "TRMDataList.h"
#import "TRMInputParameters.h"
#import "TRMParameters.h"

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

#ifndef __TUBE_H
#define __TUBE_H

#include <stdio.h> // For FILE
#include <math.h> // For M_PI
#include "structs.h" // For TRMSampleRateConverter

/*  FUNCTION RETURN CONSTANTS  */
#define ERROR                     (-1)
#define SUCCESS                   0

/*  WAVEFORM TYPES  */
#define PULSE                     0
#define SINE                      1

/*  MATH CONSTANTS  */
#define TWO_PI                    (2.0 * M_PI)

TRMTubeModel *TRMTubeModelCreate(TRMInputParameters *inputParameters);
void TRMTubeModelFree(TRMTubeModel *model);

void synthesize(TRMTubeModel *tubeModel, TRMData *data);

#endif

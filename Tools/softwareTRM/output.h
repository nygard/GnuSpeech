#ifndef __OUTPUT_H
#define __OUTPUT_H

#include "structs.h" // For TRMData

/*  OUTPUT FILE FORMAT CONSTANTS  */
#define AU_FILE_FORMAT            0
#define AIFF_FILE_FORMAT          1
#define WAVE_FILE_FORMAT          2


void writeOutputToFile(struct _TRMData *data, char *fileName);

#endif

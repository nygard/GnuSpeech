#ifndef __OUTPUT_H
#define __OUTPUT_H

#include "structs.h" // For TRMData

/*  OUTPUT FILE FORMAT CONSTANTS  */
#define AU_FILE_FORMAT            0
#define AIFF_FILE_FORMAT          1
#define WAVE_FILE_FORMAT          2

/*  FINAL OUTPUT SCALING, SO THAT .SND FILES APPROX. MATCH DSP OUTPUT  */
//#define OUTPUT_SCALE              0.25
#define OUTPUT_SCALE              1.0

/*  MAXIMUM SAMPLE VALUE  */
#define RANGE_MAX                 32767.0

/*  SIZE IN BITS PER OUTPUT SAMPLE  */
#define BITS_PER_SAMPLE           16


void writeOutputToFile(struct _TRMData *data, char *fileName);

#endif

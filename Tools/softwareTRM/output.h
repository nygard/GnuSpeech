#ifndef __OUTPUT_H
#define __OUTPUT_H

#include <stdio.h>

/*  OUTPUT FILE FORMAT CONSTANTS  */
#define AU_FILE_FORMAT            0
#define AIFF_FILE_FORMAT          1
#define WAVE_FILE_FORMAT          2

extern int outputFileFormat;
extern double volume;
extern int channels;
extern double balance;


void writeOutputToFile(char *fileName);

#endif

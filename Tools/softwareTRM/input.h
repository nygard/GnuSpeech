#ifndef __INPUT_H
#define __INPUT_H

#include "tube.h" // For TOTAL_REGIONS

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

extern INPUT *inputHead;
extern INPUT *inputTail;
extern int numberInputTables;

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

#endif

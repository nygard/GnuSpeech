#include "input.h"

#include <stdlib.h>

/*  VARIABLES FOR INPUT TABLE STORAGE  */
INPUT *inputHead = NULL;
INPUT *inputTail = NULL;
int numberInputTables = 0;

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

// Returns the pitch stored in the table 'ptr'.
double glotPitchAt(INPUT *ptr)
{
    if (ptr)
	return ptr->glotPitch;

    return 0.0;
}

// Returns the glotVol stored in the table 'ptr'.
double glotVolAt(INPUT *ptr)
{
    if (ptr)
	return ptr->glotVol;

    return 0.0;
}

// Returns the variable tube radii stored in the table 'ptr'.
double *radiiAt(INPUT *ptr)
{
    if (ptr)
	return ptr->radius;

    return NULL;
}

// Returns the radius for 'region', from the table 'ptr'.
double radiusAtRegion(INPUT *ptr, int region)
{
    if (ptr)
	return ptr->radius[region];

    return 0.0;
}

// Returns the velum radius from the table 'ptr'.
double velumAt(INPUT *ptr)
{
    if (ptr)
	return ptr->velum;

    return 0.0;
}

// Returns the aspiration factor from the table 'ptr'.
double aspVolAt(INPUT *ptr)
{
    if (ptr)
	return ptr->aspVol;

    return 0.0;
}

// Returns the frication volume from the table 'ptr'.
double fricVolAt(INPUT *ptr)
{
    if (ptr)
	return ptr->fricVol;

    return 0.0;
}

// Returns the frication position from the table 'ptr'.
double fricPosAt(INPUT *ptr)
{
    if (ptr)
	return ptr->fricPos;

    return 0.0;
}

// Returns the frication center frequency from the table 'ptr'.
double fricCFAt(INPUT *ptr)
{
    if (ptr)
	return ptr->fricCF;

    return 0.0;
}

// Returns the frication bandwidth from the table 'ptr'.
double fricBWAt(INPUT *ptr)
{
    if (ptr)
	return ptr->fricBW;

    return 0.0;
}

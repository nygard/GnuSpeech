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
    }
    else {
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


/******************************************************************************
*
*	function:	glotPitchAt
*
*	purpose:	Returns the pitch stored in the table at 'position'.
*
*       arguments:      position
*
*	internal
*	functions:	none
*
*	library
*	functions:	inputAt
*
******************************************************************************/

double glotPitchAt(INPUT *ptr)
{
    if (ptr)
	return (ptr->glotPitch);
    else
	return (0.0);
}



/******************************************************************************
*
*	function:	glotVolAt
*
*	purpose:	Returns the glotVol stored in the table at 'position'.
*
*       arguments:      position
*
*	internal
*	functions:	none
*
*	library
*	functions:	inputAt
*
******************************************************************************/

double glotVolAt(INPUT *ptr)
{
    if (ptr)
	return (ptr->glotVol);
    else
	return (0.0);
}



/******************************************************************************
*
*	function:	radiiAt
*
*	purpose:	Returns the variable tube radii stored in the table at
*                       'position'.
*
*       arguments:      position
*
*	internal
*	functions:	none
*
*	library
*	functions:	inputAt
*
******************************************************************************/

double *radiiAt(INPUT *ptr)
{
    if (ptr)
	return (ptr->radius);
    else
	return (NULL);
}



/******************************************************************************
*
*	function:	radiusAtRegion
*
*	purpose:	Returns the radius for 'region', from the table at
*                       'position'.
*
*       arguments:      position, region
*
*	internal
*	functions:	inputAt
*
*	library
*	functions:	none
*
******************************************************************************/

double radiusAtRegion(INPUT *ptr, int region)
{
    if (ptr)
	return (ptr->radius[region]);
    else
	return (0.0);
}



/******************************************************************************
*
*	function:	velumAt
*
*	purpose:	Returns the velum radius from the table at 'position'.
*
*       arguments:      position
*
*	internal
*	functions:	inputAt
*
*	library
*	functions:	none
*
******************************************************************************/

double velumAt(INPUT *ptr)
{
    if (ptr)
	return (ptr->velum);
    else
	return (0.0);
}



/******************************************************************************
*
*	function:	aspVolAt
*
*	purpose:	Returns the aspiration factor from the table at
*                       'position'.
*
*       arguments:      position
*
*	internal
*	functions:	inputAt
*
*	library
*	functions:	none
*
******************************************************************************/

double aspVolAt(INPUT *ptr)
{
    if (ptr)
	return (ptr->aspVol);
    else
	return (0.0);
}



/******************************************************************************
*
*	function:	fricVolAt
*
*	purpose:	Returns the frication volume from the table at
*                       'position'.
*
*       arguments:      position
*
*	internal
*	functions:	inputAt
*
*	library
*	functions:	none
*
******************************************************************************/

double fricVolAt(INPUT *ptr)
{
    if (ptr)
	return (ptr->fricVol);
    else
	return (0.0);
}



/******************************************************************************
*
*	function:	fricPosAt
*
*	purpose:	Returns the frication position from the table at
*                       'position'.
*
*       arguments:      position
*
*	internal
*	functions:	inputAt
*
*	library
*	functions:	none
*
******************************************************************************/

double fricPosAt(INPUT *ptr)
{
    if (ptr)
	return (ptr->fricPos);
    else
	return (0.0);
}



/******************************************************************************
*
*	function:	fricCFAt
*
*	purpose:	Returns the frication center frequency from the table
*                       at 'position'.
*
*       arguments:      position
*
*	internal
*	functions:	inputAt
*
*	library
*	functions:	none
*
******************************************************************************/

double fricCFAt(INPUT *ptr)
{
    if (ptr)
	return (ptr->fricCF);
    else
	return (0.0);
}



/******************************************************************************
*
*	function:	fricBWAt
*
*	purpose:	Returns the frication bandwidth from the table
*                       at 'position'.
*
*       arguments:      position
*
*	internal
*	functions:	inputAt
*
*	library
*	functions:	none
*
******************************************************************************/

double fricBWAt(INPUT *ptr)
{
    if (ptr)
	return (ptr->fricBW);
    else
	return (0.0);
}


#if 0
/******************************************************************************
*
*	function:	inputAt
*
*	purpose:	Returns a pointer to the table specified by 'position'.
*
*       arguments:      position
*
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

INPUT *inputAt(int position)
{
    int i;
    INPUT *tempPtr = inputHead;

    if ((position < 0) || (position >= numberInputTables))
	return (NULL);

    /*  LOOP THROUGH TO PROPER POSITION IN LIST  */
    for (i = 0; i < position; i++)
	tempPtr = tempPtr->next;

    return (tempPtr);
}
#endif

/******************************************************************************
*
*     ie_to_y.c
*
*     
*     
*
******************************************************************************/

/*  HEADER FILES  ************************************************************/
#import "ie_to_y.h"



/******************************************************************************
*
*	function:	ie_to_y
*
*	purpose:	If final two characters are "ie" replace with "y" and
*                       return true.
*			
*       arguments:      in, end
*                       
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

int ie_to_y(char *in, char **end)
{
    register char      *t = *end;

    if ((*(t - 2) == 'i') && (*(t - 1) == 'e')) {
	*(t - 2) = 'y';
	*(t - 1) = '#';
	*end = --t;
	return(1);
    }
    return(0);
}

/******************************************************************************
*
*     ends_with.c
*
*     
*     
*
******************************************************************************/

/*  HEADER FILES  ************************************************************/
#import "ends_with.h"



/******************************************************************************
*
*	function:	ends_with
*
*	purpose:	Return 0 if word doesn't end with set element, else
*                       pointer to char before ending.
*			
*       arguments:      in, end, set
*                       
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

char *ends_with(char *in, char *end, char *set)
{
    register char      *temp;

    while (*set) {
	temp = end + 1;
	while (*--temp == *set)
	    set++;
	if (*set == '/')
	    return(temp);
	while (*set++ != '/');
    }
    return(0);
}

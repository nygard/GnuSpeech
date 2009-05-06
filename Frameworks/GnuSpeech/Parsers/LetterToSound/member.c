/******************************************************************************
*
*     member.c
*
*     
*     
*
******************************************************************************/

/*  HEADER FILES  ************************************************************/
#import "member.h"



/******************************************************************************
*
*	function:	member
*
*	purpose:	Return true if element in set, false otherwise.
*			
*       arguments:      element, set
*                       
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

int member(char element, char *set)
{
    while (*set)
	if (element == *set++)
	    return(1);

    return(0);
}

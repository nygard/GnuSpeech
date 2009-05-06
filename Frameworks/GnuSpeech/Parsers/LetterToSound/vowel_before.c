/******************************************************************************
*
*    vowel_before.c
*
*
*
*
******************************************************************************/

/*  HEADER FILES  ************************************************************/
#import "vowel_before.h"
#import "member.h"


/******************************************************************************
*
*       function:     vowel_before
*
*       purpose:      Return the position of a vowel prior to 'position'.
*                     If no vowel prior return 0.
*
*       arguments:    start, position
*
*       internal
*       functions:    member
*
*       library
*       functions:    none
*
******************************************************************************/

char *vowel_before(char *start, char *position)
{
    position--;
    while (position >= start) {
	if (member(*position, "aeiouyAEIOUY"))
	    return(position);
	position--;
    }
    return(0);
}

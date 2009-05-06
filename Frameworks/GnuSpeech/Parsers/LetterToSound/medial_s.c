/******************************************************************************
*
*     medial_s.c
*
*     
*     
*
******************************************************************************/

/*  HEADER FILES  ************************************************************/
#import "medial_s.h"
#import "member.h"



/******************************************************************************
*
*	function:	medial_s
*
*	purpose:	
*                       
*			
*       arguments:      in, eow
*                       
*	internal
*	functions:	member
*
*	library
*	functions:	none
*
******************************************************************************/

void medial_s(char *in, char **eow)
{
    register char      *end = *eow;

    while (in < end - 1) {
	if ((member(*in | 040, "aeiouy")) && (in[1] == 's')
	    && (member(in[2], "AEIOUYaeiouym")))
	    in[1] &= 0xdf;
	in++;
    }
}

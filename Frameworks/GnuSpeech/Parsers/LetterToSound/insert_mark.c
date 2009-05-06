/******************************************************************************
*
*     insert_mark.c
*
*     
*     
*
******************************************************************************/

/*  HEADER FILES  ************************************************************/
#import "insert_mark.h"



/******************************************************************************
*
*	function:	insert_mark
*
*	purpose:	
*                       
*			
*       arguments:      end, at
*                       
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

void insert_mark(char **end, char *at)
{
    register char      *temp = *end;

    at++;

    if (*at == 'e')
	at++;

    if (*at == '|')
	return;

    while (temp >= at)
	temp[1] = *temp--;

    *at = '|';
    (*end)++;
}

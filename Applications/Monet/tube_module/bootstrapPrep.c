/*  REVISION INFORMATION  *****************************************************

_Author: fedor $
_Date: 2002/12/15 05:05:11 $
_Revision: 1.2 $
_Source: /cvsroot/gnuspeech/gnuspeech/trillium/ObjectiveC/Monet/tube_module/bootstrapPrep.c,v $
_State: Exp $


_Log: bootstrapPrep.c,v $
Revision 1.2  2002/12/15 05:05:11  fedor
Port to Openstep and GNUstep

Revision 1.1  2002/03/21 16:49:47  rao
Initial import.

 * Revision 1.1  1995/02/27  17:29:12  len
 * Added support for Intel MultiSound DSP.  Module now compiles FAT.
 *

******************************************************************************/

/******************************************************************************
*
*     bootstrapPrep.c
*     
*     Converts the .lod file containing the bootstrap code segment (assembled
*     from bootstrap.asm), and writes out an array containing the code segment
*     to the specified .h file.  This file is included by c code, and is
*     used by that code to load the bootstrap.asm code into p:$0000 memory.
*
******************************************************************************/



/*  HEADER FILES  ************************************************************/
#import <stdlib.h>
#import <stdio.h>
#import <sys/param.h>
#import <ctype.h>
#import <Foundation/NSByteOrder.h>


/*  LOCAL DEFINES  ***********************************************************/
#define OUTPUTFILE_NAME_DEF   "bootstrap.h"
#define MAX_SEGMENT_SIZE      512
#define COLUMNS_DEF           6
#define SUCCESS               0
#define FAILURE               (-1)
#define EOS                   '\0'
#define NEWREC                '_'


/*  GLOBAL VARIABLES (LOCAL TO THIS FILE)  ***********************************/
static FILE *fp1, *fp2;
static char *inputFile, outputFile[MAXPATHLEN+1];
static int columns = COLUMNS_DEF;
static int totalSize, currentColumn, currentInt;


/*  GLOBAL FUNCTIONS (LOCAL TO THIS FILE)  ***********************************/
static int translate(void);
static int get_field(FILE *ifile, char *buf);
static int translateInt(int value);




/******************************************************************************
*
*	function:	main
*
*	purpose:	Controls overall execution of the program.
*                       
*       arguments:      argc - number of command line arguments
*                       argv[0] - program name
*                       argv[1] - input file name
*                       argv[2] - output file name (optional)
*                       
*	internal
*	functions:	translate
*
*	library
*	functions:	fprintf, exit, strcpy, fopen, fclose
*
******************************************************************************/

int main(int argc, char *argv[])
{
    FILE *fopen();
    int returnCode;


    /*  MAKE SURE RIGHT NUMBER OF ARGUMENTS  */
    if ((argc < 2) || (argc > 3)) {
	fprintf(stderr,"Usage:  %s infile.lod [outfile.h]\n", argv[0]);
	exit(FAILURE);
    }

    /*  MAKE INPUT FILE NAME GLOBALLY AVAILABLE  */
    inputFile = argv[1];

    /*  SUPPLY DEFAULT OUTPUT FILE NAME, IF NONE GIVEN  */
    if (argc == 2)
        strcpy(outputFile, OUTPUTFILE_NAME_DEF);
    else
        strcpy(outputFile, argv[2]);

    /*  OPEN THE INPUT FILE  */
    fp1 = fopen(inputFile, "r");
    if (fp1 == NULL) {
        fprintf(stderr, "Cannot open %s for reading\n", inputFile);
	exit(FAILURE);
    }

    /*  OPEN THE OUTPUT FILE  */
    fp2 = fopen(outputFile, "w");
    if (fp2 == NULL) {
        fprintf(stderr, "Cannot open %s for writing\n", outputFile);
	fclose(fp1);
	exit(FAILURE);
    }

    /*  TRANSLATE THE INPUT FILE, AND WRITE OUT ON OUTPUT FILE  */
    returnCode = translate();
    if (returnCode == FAILURE) {
        fprintf(stderr, "Error translating %s\n", inputFile);
        fclose(fp1);
	fclose(fp2);
	exit(FAILURE);
    }

    /*  CLOSE THE INPUT FILE  */
    fclose(fp1);

    /*  CLOSE THE OUTPUT FILE  */
    fclose(fp2);

    return(SUCCESS);
}



/******************************************************************************
*
*	function:	translate
*
*	purpose:        Translates the input .lod file, to produce an include
*                       file which contains the bootstrap.asm DSP code.
*                       
*       arguments:      none
*                       
*                       
*	internal
*	functions:	get_field, translateInt
*
*	library
*	functions:	strcmp, strtol, fprintf
*
******************************************************************************/

static int translate(void)
{
    char buffer[16];
    int i, instruction[MAX_SEGMENT_SIZE];
    int instructionCount = 0;
    int loadAddress;


    /*  SET THE COLUMN AND BYTE COUNTS TO INITIAL VALUES  */
    currentColumn = 1;
    currentInt = 1;

    /*  ADVANCE TO THE FIRST "_DATA" SEGMENT  */
    for (; ;) {
        if (get_field(fp1, buffer) == EOF)
	    return(FAILURE);
	if (!strcmp(buffer, "_DATA"))
	    break;
    }

    /*  THE NEXT FIELD MUST BE A "P" (PROGRAM SEGMENT)  */
    if (get_field(fp1, buffer) == EOF)
        return(FAILURE);
    if (strcmp(buffer, "P"))
        return(FAILURE);

    /*  THE NEXT FIELD IS THE LOAD ADDRESS  */
    if (get_field(fp1, buffer) == EOF)
        return(FAILURE);
    loadAddress = strtol(buffer, NULL, 16);

    /*  STORE ALL THE INSTRUCTIONS IN THIS SEGMENT, & KEEP COUNT  */
    for (; ;) {
        /*  GET THE NEXT FIELD  */
        if (get_field(fp1, buffer) == EOF)
	    return(FAILURE);

        /*  STOP READING INSTRUCTION WHEN WE GET THE "_END" FIELD  */
	if (!strcmp(buffer, "_END")) {
	    break;
	}
	else {
	    /*  FAILURE IF WE HAVE TOO MANY INSTRUCTIONS  */
	    if (instructionCount >= MAX_SEGMENT_SIZE)
	        return(FAILURE);
	    /*  STORE THE INSTRUCTION IN THE ARRAY, & KEEP COUNT  */
	    instruction[instructionCount++] = strtol(buffer, NULL, 16);
	}
    }

    /*  RECORD TOTAL SIZE OF THE CORE ARRAY  */
    totalSize = instructionCount;

    /*  WRITE OUT FILE INFORMATION  */
    fprintf(fp2, "/*\n");
    fprintf(fp2, " *   Include file:  %s\n", outputFile);
    fprintf(fp2, " *   Created by bootstrapPrep from %s\n", inputFile);
    fprintf(fp2, " */\n\n");

    /*  WRITE OUT SIZE IN C DECLARATION  */
    fprintf(fp2, "static int bootstrapCoreSize = %-d;\n", totalSize);

    /*  WRITE OUT C DECLARATION  */
    fprintf(fp2, "static int bootstrapCore[%-d] = {\n", totalSize);

    /*  WRITE OUT INSTRUCTIONS IN SEGMENT  */
    for (i = 0; i < instructionCount; i++)
        translateInt(instruction[i]);

    /*  WRITE OUT END OF STRUCT  */
    fprintf(fp2, "};\n");

    return(SUCCESS);
}



/******************************************************************************
*
*	function:	get_field
*
*	purpose:	Gets the next white space delimited field from the
*                       input .lod file.
*			
*       arguments:      ifile - FILE pointer to the input file
*                       buf - output buffer containing the field
*
*	internal
*	functions:	none
*
*	library
*	functions:	fgetc, isspace, ungetc
*
******************************************************************************/

static int get_field(FILE *ifile, char *buf)
{
    int c;
    char *p;


    /*  SKIP WHITE SPACE  */
    while ((c = fgetc(ifile)) != EOF && isspace(c))
        ;

    /*  RETURN EOF IF END OF INPUT FILE  */
    if (c == EOF)
        return(EOF);

    /*  FILL THE BUFFER WITH THE CURRENT FIELD  */
    for (p = buf, *p++ = c; (c = fgetc(ifile)) != EOF && !isspace(c); *p++ = c)
        ;

    /*  PUT A NULL AT THE END OF THE FIELD  */
    *p = EOS;

    /*  PUT THE LAST CHAR BACK IN THE STREAM, IF NOT END OF FILE  */
    if (c != EOF)
        ungetc(c, ifile);

    /*  RETURN 1 IF A NEW RECORD, 0 OTHERWISE  */
    return(*buf == NEWREC ? 1 : 0);
}



/******************************************************************************
*
*	function:	translateInt
*
*	purpose:	Prints the integer value to file.
*			
*       arguments:      value - the integer to be printed
*                       
*	internal
*	functions:	none
*
*	library
*	functions:	fprintf
*
******************************************************************************/

static int translateInt(int value)
{
    /*  PRINT THE INT OUT TO FILE  */
    fprintf(fp2, "0x%08X", value);

    /*  ADD A COMMA, UNLESS AT END  */
    if (currentInt != totalSize)
        fprintf(fp2, ",");

    /*  IF LAST COLUMN, ADD A NEWLINE CHARACTER, AND MOD COLUMN COUNT  */
    if (currentColumn == columns) {
        fprintf(fp2, "\n");
	currentColumn = 0;
    }

    /*  INCREMENT THE INT AND COLUMN COUNT  */
    currentInt++;
    currentColumn++;

    return(SUCCESS);
}

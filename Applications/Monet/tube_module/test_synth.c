/*  REVISION INFORMATION  *****************************************************

_Author: rao $
_Date: 2002/03/21 16:49:47 $
_Revision: 1.1 $
_Source: /cvsroot/gnuspeech/gnuspeech/trillium/ObjectiveC/Monet/tube_module/test_synth.c,v $
_State: Exp $


_Log: test_synth.c,v $
Revision 1.1  2002/03/21 16:49:47  rao
Initial import.

 * Revision 1.7  1995/04/04  01:57:58  len
 * Added "median pitch" volume scaling.
 *
 * Revision 1.6  1995/03/26  18:53:39  len
 * Optimized code and raised output volume.
 *
 * Revision 1.5  1995/03/03  22:53:05  len
 * Added a pitch sweep to the test_synth program.
 *
 * Revision 1.4  1995/03/02  02:55:33  len
 * Added means to call user-supplied page_consumed function, added means to
 * set the pad page to user-specified silence, and changed the controlRate
 * variable to a float.
 *
 * Revision 1.3  1995/02/27  17:29:30  len
 * Added support for Intel MultiSound DSP.  Module now compiles FAT.
 *
 * Revision 1.2  1994/11/18  04:28:44  len
 * Added high/low (22050/44100 Hz.) output sample rate switch.
 *
 * Revision 1.1.1.1  1994/09/06  21:45:52  len
 * Initial archive into CVS.
 *

******************************************************************************/

/*  INCLUDES  ****************************************************************/
#import <mach/mach_error.h>
#import "synthesizer_module.h"   /* NEEDED WHEN USING THE SYNTHESIZER MODULE */


/*  DEFINES  *****************************************************************/
#define PAGES_MAX      200          /*  ARBITRARY LIMIT  */
//#define SWEEP_BEGIN    (-12.0)
//#define SWEEP_END      0.0



/*  GLOBAL VARIABLES (LOCAL TO THIS FILE)  ***********************************/
static int blocking, consumer_index;



/******************************************************************************
*
*	function:	main
*
*	purpose:	Example of a program which uses the synthesizer module.
*                       It spawns the synthesizer thread, and then allows the
*                       user to synthesize an arbitrary number of default
*                       synthesizer control tables.  The function
*                       "update_synth_ptr" is an example of a user supplied
*                       function used by "await_request_new_page" to update
*                       the synth_read_ptr.
*
*	internal
*	functions:	update_synth_ptr
*
*	library
*	functions:	initialize_synthesizer_module, new_default_data_table,
*                       fprintf, printf, scanf, getchar, vm_deallocate,
*                       mach_error, vm_allocate, start_synthesizer,
*                       await_request_new_page, set_synthesizer_output
*
******************************************************************************/

void main(void)
{
    int npages, oldnpages = 0, i, j;
    int writeToFile = 0, numberChunks = 0;

    float outputSampleRate = 22050.0, tubeLength = 18.0;
    int channels = 2;
    float balance = 0.0;
    float controlRate = 250.0;
    int waveform = 0;
    kern_return_t k_error;
    DSPFix24 *page_start = NULL, *table_index;
    float medianPitch, sweepBegin, sweepEnd, sweepValue, sweepIncrement;
    float parameterTable[16] = 
	{GLOT_PITCH_DEF, GLOT_VOL_DEF, ASP_VOL_DEF, FRIC_VOL_DEF, FRIC_POS_DEF,
	 FRIC_CF_DEF, FRIC_BW_DEF, R1_DEF, R2_DEF, R3_DEF, R4_DEF, R5_DEF,
	 R6_DEF, R7_DEF, R8_DEF, VELUM_DEF};

    /*  USER SUPPLIED FUNCTION TO UPDATE THE GLOBAL synth_read_ptr  */
    void update_synth_ptr();

    /*  USER SUPPLIED FUNCTION TO SIGNAL A PAGE CONSUMED BY SYNTH MODULE  */
    void page_consumed();

    /*  USER-SUPPLIED SILENCE TABLE (NORMALLY TAKEN FROM SILENCE PHONE ^)  */
    float silenceParameterTable[] =
	{GLOT_PITCH_DEF, VOLUME_MIN, VOLUME_MIN, VOLUME_MIN, FRIC_POS_DEF,
	 FRIC_CF_DEF, FRIC_BW_DEF, R1_DEF, R2_DEF, R3_DEF, R4_DEF, R5_DEF,
	 R6_DEF, R7_DEF, R8_DEF, VELUM_DEF};
    

    /*  INITIALIZE THE SYNTHESIZER MODULE  */
    /*  THIS FUNCTION MUST BE INVOKED BEFORE ANY OTHER SYNTHESIZER
	MODULE FUNCTIONS ARE CALLED  */
    if (initialize_synthesizer_module() == ST_ERROR) {
	fprintf(stderr,
		"Aborting.  Could not initialize synthesizer module.\n");
	exit(-1);
    }


    /*  INPUT LOOP  */
    while (1) {
      qnpages:
	/*  QUERY USER FOR OUTPUT SAMPLE RATE  */
	printf("\nOutput sample rate? (22050.0, 44100.0):  ");
	scanf("%f", &outputSampleRate);

	/*  QUERY USER FOR TUBE LENGTH  */
	printf("Tube length? (10.0 - 20.0):  ");
	scanf("%f", &tubeLength);

	/*  QUERY USER FOR NUMBER OF CHANNELS  */
	printf("Number of Channels? (1, 2):  ");
	scanf("%d", &channels);

	/*  QUERY USER FOR STEREO BALANCE  */
	if (channels == 2) {
	    printf("Stereo balance? (-1.0 - +1.0):  ");
	    scanf("%f", &balance);
	}
	
	/*  QUERY USER FOR CONTROL RATE  */
	printf("Control Rate? (1.0 - 1000.0):  ");
	scanf("%f", &controlRate);

	/*  QUERY USER FOR CONTROL RATE  */
	printf("Glottal Pulse or Sine? (0, 1):  ");
	scanf("%d", &waveform);

	/*  QUERY USER FOR MEDIAN PITCH  */
	printf("Median Pitch? (-24.0 - +24.0):  ");
	scanf("%f", &medianPitch);

	/*  QUERY USER FOR SWEEP BEGIN PITCH  */
	printf("Sweep Begin Pitch? (-24.0 - +24.0):  ");
	scanf("%f", &sweepBegin);

	/*  QUERY USER FOR SWEEP END PITCH  */
	printf("Sweep End Pitch? (-24.0 - +24.0):  ");
	scanf("%f", &sweepEnd);

	/*  QUERY FOR NUMBER OF PAGES TO CREATE  */
	printf("Enter desired number of pages:  ");
	scanf("%d",&npages);
	if (npages < 1 || npages > PAGES_MAX) {
	    printf("  Illegal number of pages.  Try again.\n");
	    goto qnpages;
	}
	
	/*  DEALLOCATE PAGES OF MEMORY IF ALREADY ALLOCATED BEFORE  */
	if (page_start != NULL) {
	    k_error = vm_deallocate(task_self(), (vm_address_t)page_start,
				    (vm_size_t)(vm_page_size * oldnpages));
	    if (k_error != KERN_SUCCESS) {
		mach_error("Trouble freeing memory", k_error);
		exit(-1);
	    }
	}  
	
	/*  ALLOCATE REQUESTED NUMBER OF PAGES  */
	k_error = vm_allocate(task_self(), (vm_address_t *)&page_start, 
			      (vm_size_t)(vm_page_size * npages), 1);
	if (k_error != KERN_SUCCESS) {
	    mach_error("vm_allocate returned value of ", k_error); 
	    exit(-1);
	}
	oldnpages = npages;
	
	/*  SET UTTERANCE RATE PARAMETERS FIRST (MUST BE DONE BEFORE 
	    CREATING THE NEW DEFAULT TABLE)  */
#if VARIABLE_GP
	set_utterance_rate_parameters(outputSampleRate,
				      controlRate, MASTER_VOLUME_DEF,
				      channels, balance,
				      waveform, TP_DEF, TN_MIN_DEF,
				      TN_MAX_DEF, 0.0, tubeLength,
				      TEMPERATURE_DEF, LOSS_FACTOR_DEF,
				      APERTURE_SCALE_DEF, MOUTH_COEF_DEF,
				      NOSE_COEF_DEF, N1_DEF, N2_DEF, N3_DEF,
				      N4_DEF, N5_DEF, THROAT_CUTOFF_DEF,
				      THROAT_VOLUME_DEF, PULSE_MODULATION_DEF,
				      CROSSMIX_OFFSET_DEF, medianPitch,
				      silenceParameterTable);
#else
	set_utterance_rate_parameters(outputSampleRate,
				      controlRate, MASTER_VOLUME_DEF,
				      channels, balance,
				      waveform, TP_DEF, TN_MIN_DEF,
				      TOP_HARMONIC_DEF, 0.0,
				      tubeLength,
				      TEMPERATURE_DEF, LOSS_FACTOR_DEF,
				      APERTURE_SCALE_DEF, MOUTH_COEF_DEF,
				      NOSE_COEF_DEF, N1_DEF, N2_DEF, N3_DEF,
				      N4_DEF, N5_DEF, THROAT_CUTOFF_DEF,
				      THROAT_VOLUME_DEF, PULSE_MODULATION_DEF,
				      CROSSMIX_OFFSET_DEF, medianPitch,
				      silenceParameterTable);
#endif


	/*  CALCULATE SWEEP INCREMENT  */
	sweepIncrement = (sweepEnd - sweepBegin)/(npages * TABLES_PER_PAGE);
	sweepValue = sweepBegin;
	
	/*  FILL UP THE PAGES WITH THE SWEEP TONE TABLE  */
	table_index = page_start;
	for (i = 0; i < npages; i++) {
	    for (j = 0; j < TABLES_PER_PAGE; j++) {
		parameterTable[0] = sweepValue;
		convert_parameter_table(parameterTable, table_index);
		sweepValue += sweepIncrement;
		table_index += DATA_TABLE_SIZE;
	    }
	}


	/*  QUERY USER IF BLOCKING  */
	printf("Blocking? (0 or 1):  ");
	scanf("%d",&blocking);

    
	/*  QUERY USER IF WRITE TO FILE  */
	printf("Write to file? (0 or 1):  ");
	scanf("%d",&writeToFile);
	if (writeToFile) {
	    printf("Number Chunks?:  ");
	    scanf("%d",&numberChunks);
	}

    
	/*  QUERY USER TO START SOUND OUT  */
	getchar();
	printf("Push return to continue:  ");
	getchar();
	

	/*  SYNTHESIZE TO FILE  */
	if (writeToFile) {
	    /*  SYNTHESIZER MUST BE IN PAUSE STATE  */
	    if (synth_status == ST_PAUSE) {

		/*  SET THE OUTPUT TO FILE  */
		set_synthesizer_output("/tmp/file.snd", getuid(),
				       getgid(), numberChunks);

		/*  PROCESS EACH CHUNK  */
		while (numberChunks--) {
		    /*  LOOP UNTIL READY FOR NEXT CHUNK  */
		    while (synth_status == ST_RUN)
			;

		    /*  INITIALIZE THE SYNTHESIZER  */
		    if (start_synthesizer() != ST_NO_ERROR) {
			fprintf(stderr,"DSP busy\n");
			exit(-1);
		    }

		    /*  SEND THE PAGES TO THE SYNTHESIZER THREAD  */
		    /*  THE synth_read_ptr IS BACKED UP ONE PAGE, SINCE THE
			update_synth_ptr FUNCTION ADVANCES THE POINTER *BEFORE*
			THE PAGE IS SENT TO THE SYNTHESIZER  */
		    synth_read_ptr = (vm_address_t)page_start - vm_page_size;

		    if (blocking) {
			for (i = 0; i < npages; i++) {
			    /*  BLOCK WHILE WAITING; ALSO, MAKE
				SURE TO SIGNAL THE LAST PAGE  */
			    await_request_new_page(ST_YES,
				(i == (npages-1)) ? ST_YES : ST_NO,
				update_synth_ptr, page_consumed);
			}
		    }
		    else {
			consumer_index = 0;
			while (consumer_index < npages) {
			    /*  DON'T BLOCK WHILE WAITING; MAKE
				SURE TO SIGNAL THE LAST PAGE  */
			    await_request_new_page(ST_NO,
				(consumer_index == (npages-1)) ? ST_YES: ST_NO,
				update_synth_ptr, page_consumed);
			}
		    }
		}
	    }
	    /*  EXIT IF SYNTHESIZER STILL RUNNING  */
	    else {
		fprintf(stderr,"synth_status still ST_RUN\n");
		exit(-1);
	    }
	}
	/*  SYNTHESIZE TO DAC  */
	else {
	    /*  SYNTHESIZER MUST BE IN PAUSE STATE  */
	    if (synth_status == ST_PAUSE) {
		/*  INDICATE THAT OUTPUT IS TO DAC (I.E. NOT TO FILE)  */
		set_synthesizer_output(NULL, 0, 0, 0);

		/*  INITIALIZE THE SYNTHESIZER  */
		if (start_synthesizer() != ST_NO_ERROR) {
		    fprintf(stderr,"DSP busy\n");
		    exit(-1);
		}

		/*  SEND THE PAGES TO THE SYNTHESIZER THREAD  */
		/*  THE synth_read_ptr IS BACKED UP ONE PAGE, SINCE THE
		    update_synth_ptr FUNCTION ADVANCES THE POINTER *BEFORE*
		    THE PAGE IS SENT TO THE SYNTHESIZER  */
		synth_read_ptr = (vm_address_t)page_start - vm_page_size;
		
		if (blocking) {
		    for (i = 0; i < npages; i++) {
			/*  BLOCK WHILE WAITING; ALSO, MAKE SURE
			    TO SIGNAL THE LAST PAGE  */
			await_request_new_page(ST_YES,
			    (i == (npages-1)) ? ST_YES : ST_NO,
		            update_synth_ptr, page_consumed);
		    }
		}
		else {
		    consumer_index = 0;
		    while (consumer_index < npages) {
			/*  DON'T BLOCK WHILE WAITING; MAKE SURE
			    TO SIGNAL THE LAST PAGE  */
			await_request_new_page(ST_NO,
			    (consumer_index == (npages-1)) ? ST_YES : ST_NO,
			    update_synth_ptr, page_consumed);
		    }
		}
	    }
	    /*  EXIT IF SYNTHESIZER STILL RUNNING  */
	    else {
		fprintf(stderr,"synth_status still ST_RUN\n");
		exit(-1);
	    }
	}
    }
}



/******************************************************************************
*
*	function:	update_synth_ptr
*
*	purpose:	A user-supplied function which updates the
*                       synth_read_ptr as needed by the synthesizer module
*                       function "await_request_new_page".
*
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

void update_synth_ptr(void)
{
    synth_read_ptr += vm_page_size;
    if (!blocking)
	consumer_index++;
}



/******************************************************************************
*
*	function:	page_consumed
*
*	purpose:	A user-supplied function which is invoked every time
*                       a page is consumed by the synthesizer module.  This
*                       function is supplied to the await_request_new_page
*                       function.
*
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

void page_consumed(void)
{
#if DEBUG
    printf("page_consumed\n");
#endif
    return;
}

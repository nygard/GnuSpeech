/*  REVISION INFORMATION  *****************************************************

_Author: fedor $
_Date: 2002/12/15 05:05:11 $
_Revision: 1.2 $
_Source: /cvsroot/gnuspeech/gnuspeech/trillium/ObjectiveC/Monet/tube_module/synthesizer_module.c,v $
_State: Exp $


_Log: synthesizer_module.c,v $
Revision 1.2  2002/12/15 05:05:11  fedor
Port to Openstep and GNUstep

Revision 1.1  2002/03/21 16:49:47  rao
Initial import.

 * Revision 1.10  1995/05/03  03:41:20  len
 * Adjusted timeout and reset the "count" flag, to try to fix the pause bug.
 *
 * Revision 1.9  1995/04/04  01:57:54  len
 * Added "median pitch" volume scaling.
 *
 * Revision 1.8  1995/03/02  02:55:29  len
 * Added means to call user-supplied page_consumed function, added means to
 * set the pad page to user-specified silence, and changed the controlRate
 * variable to a float.
 *
 * Revision 1.7  1995/02/27  17:29:23  len
 * Added support for Intel MultiSound DSP.  Module now compiles FAT.
 *
 * Revision 1.6  1994/11/18  04:28:40  len
 * Added high/low (22050/44100 Hz.) output sample rate switch.
 *
 * Revision 1.5  1994/10/20  20:11:28  len
 * Changed nose and mouth aperture filter coefficients, so now specified
 * as Hz values (which scale appropriately as the tube length changes), rather
 * than arbitrary coefficient values (which don't scale).
 *
 * Revision 1.4  1994/10/03  04:06:00  len
 * Optimized crossmix calculations, added linear interpolation to glottal
 * volume, and added (optional) linear interpolation to radii.
 *
 * Revision 1.3  1994/09/19  18:50:49  len
 * Resectioned the TRM to have 10 sections in 8 regions.  Also changed
 * the frication to be continuous from sections 3 to 10.  Tube lengths
 * down to 15.8 cm are possible, with everything enabled.
 *
 * Revision 1.2  1994/09/13  22:37:22  len
 * Fixed betaTable loading bug.
 *
 * Revision 1.1.1.1  1994/09/06  21:45:50  len
 * Initial archive into CVS.
 *

******************************************************************************/



/*  HEADER FILES  ************************************************************/
#import "synthesizer_module.h"
#import "conversion.h"
#import "oversampling_filter.h"
#import "sr_conversion.h"
#import "fft.h"
#import "scaling.h"

#if i386
#import "ttsSnddriver.h"
#endif

#import <stdio.h>
#import <sound/sound.h>
#import <sound/sounddriver.h>
#import <dsp/dsp.h>
#import <math.h>
/*#import <AppKit/nextstd.h>*/
#import <streams/streams.h>
#import <sys/time.h>
#import <sys/types.h>
#import <sys/timeb.h>



/*  LOCAL DEFINES  ***********************************************************/
#define INFINITE_WAIT          0
#define POLL                   1

/*  DSP UTTERANCE-RATE PARAMETERS  */
#define NC_2                   0
#define NC_3                   1
#define NC_4                   2
#define NC_5                   3
#define NC_REFL                4
#define NC_RAD                 5
#define MASTER_VOLUME          6
#define CHANNELS               7
#define BALANCE                8
#define BREATHINESS            9
#define TIME_REG_INT           10
#define TIME_REG_FRAC          11
#define CONTROL_PERIOD         12
#define CONTROL_FACTOR         13
#define DAMPING                14
#define TP                     15
#define TN_MIN                 16
#define TN_MAX                 17
#define THROAT_CUTOFF          18
#define THROAT_VOLUME          19
#define MOUTH_COEF             20
#define NOSE_COEF              21
#define WAVEFORM_TYPE          22
#define PULSE_MODULATION       23
#define CROSSMIX_FACTOR        24
#define LEFT_SHIFT_SCALE       25

#define UTTERANCE_TABLE_SIZE   26



/*  EXTERNAL GLOBAL VARIABLES  ***********************************************/
/*  SYNTHESIZER READ POINTER INTO PAGED TABLE MEMORY  */
vm_address_t synth_read_ptr;

/*  STATUS FLAG FOR INTER-THREAD COMMUNICATION  */
int synth_status;


/*  STATIC GLOBAL VARIABLES (LOCAL TO THIS FILE)  ****************************/
/*  GLOBAL VARIABLES FOR SIGNALLING BETWEEN FUNCTIONS  */
static int stream_status;
static int prefill_count;
static vm_address_t pad_page;

/*  GLOBAL VARIABLES TO HANDLE PORTS AND MESSAGES  */
static kern_return_t k_err;
static port_t dev_port, owner_port, cmd_port, read_port, write_port,
       reply_port, file_reply_port;
static msg_header_t *reply_msg, *file_reply_msg;

/*  GLOBAL VARIABLES FOR WRITING TO FILE  */
static int outputMode = ST_OUT_DSP;
static int chunkNumber = 0;
static char file_path[MAXPATHLEN+1];
static int file_uid = 0, file_gid = 0;
static NXStream *fileStream = NULL;
static int numberChannels;

/*  VARIABLE TO STORE OUTPUT SAMPLE RATE  */
static float output_srate;

/*  TABLE TO STORE UTTERANCE-RATE PARAMETERS  */
static DSPFix24 utteranceTable[UTTERANCE_TABLE_SIZE];

/*  VARIABLES FOR THE OVERSAMPLING FIR FILTER  */
#if OVERSAMPLE_OSC
static int numberTaps;
static DSPFix24 *FIRCoefficients;
#endif

/*  VARIABLES FOR THE SAMPLE RATE CONVERSION FILTER  */
static int filterLength;
static DSPFix24 *h, *hDelta;

/*  VARIABLES FOR THE FIXED GLOTTAL PULSE TABLE  */
#if !VARIABLE_GP
static DSPFix24 gp_table[GP_TABLE_SIZE];
#endif



/*  STATIC GLOBAL FUNCTIONS (LOCAL TO THIS FILE)  ****************************/
static int grab_and_initialize_DSP(void);
static int relinquish_DSP(void);
static void flush_input_pages(void (*page_consumed_function)());
static void queue_page(void);
static void queue_pad_page(void);
static void resume_stream(void);
#if DEBUG
static void write_started(void *arg, int tag);
static void write_completed(void *arg, int tag);
static void under_run(void *arg, int tag);
#endif
static void recorded_data(void *arg, int tag, void *data, int nbytes);
static int await_write_done_message(int mode);
static double timeStamp(void);
static void defaultUtteranceRateParameters(void);
static void initialize_pad_page(float silenceParameterTable[]);
#if OVERSAMPLE_OSC
static int load_FIR_coefficients(void);
#endif
static int load_SRC_coefficients(void);
static int load_UR_data(void);
#if !VARIABLE_GP
static int create_bandlimited_gp_table(float riseTime, float fallTime,
				       int topHarmonic, float rolloff);
static int load_gp_table(void);
#endif

static void write_file(void);




/******************************************************************************
*
*	function:	grab_and_initialize_DSP
*
*	purpose:	Does initialization and setup necessary to gain control
*                       of the DSP and DAC device, and does stream setup.
*
*       arguments:      none
*
*	internal
*	functions:	load_FIR_coefficients, load_SRC_coefficients,
*                       load_gp_table, load_UR_data
*
*	library
*	functions:	SNDAcquire, snddriver_set_ramp,
*                       snddriver_set_sndout_bufsize,
*                       snddriver_get_dsp_cmd_port, snddriver_stream_setup,
*                       snddriver_dsp_protocol, SNDBootDSP,
*                       NXOpenMemory, snddriver_stream_control
*
******************************************************************************/

static int grab_and_initialize_DSP(void)
{
    int s_err, protocol;
    SNDSoundStruct *dspStruct;


    /*  GET CONTROL OF DEVICES  */
    if (outputMode == ST_OUT_DSP) {
	/*  GET CONTROL OF DSP AND DAC  */
	dev_port = owner_port = 0;
        #if m68k
	s_err = SNDAcquire(SND_ACCESS_DSP|SND_ACCESS_OUT,10,0,0,
			   NULL_NEGOTIATION_FUN,0,&dev_port,&owner_port);
        #elif i386
	s_err = ttsSNDAcquire(SND_ACCESS_DSP|SND_ACCESS_OUT,10,0,0,
			      NULL_NEGOTIATION_FUN,0,&dev_port,&owner_port);
        #endif
	if (s_err != SND_ERR_NONE)
	    return(ST_ERROR);
    }
    else {
	/*  GET CONTROL OF DSP ONLY  */
	dev_port = owner_port = 0;
        #if m68k
	s_err = SNDAcquire(SND_ACCESS_DSP,10,0,0,NULL_NEGOTIATION_FUN,0,
			   &dev_port,&owner_port); 
        #elif i386
	s_err = ttsSNDAcquire(SND_ACCESS_DSP,10,0,0,NULL_NEGOTIATION_FUN,0,
			      &dev_port,&owner_port); 
        #endif
	if (s_err != SND_ERR_NONE)
	    return(ST_ERROR);
    }

    /*  SET RAMPING OFF (NOT NEEDED, AND IT SLOWS SOUND OUT)  */
    #if m68k
    k_err = snddriver_set_ramp(dev_port,0);
    #elif i386
    k_err = tts_snddriver_set_ramp(dev_port,0);
    #endif
    if (k_err != KERN_SUCCESS)
	return(ST_ERROR);

    /*  SET THE SOUND OUT BUFFER SIZE SMALLER SO NO GLITCHES IN SOUND OUT  */
    #if m68k
    k_err = snddriver_set_sndout_bufsize(dev_port,owner_port,128);
    #elif i386
    k_err = tts_snddriver_set_sndout_bufsize(dev_port,owner_port,128);
    #endif
    if (k_err != KERN_SUCCESS)  /*  never set less than 128  */
	return(ST_ERROR);

    /*  GET THE DSP COMMAND PORT  */
    #if m68k
    k_err = snddriver_get_dsp_cmd_port(dev_port,owner_port,&cmd_port);
    #elif i386
    k_err = tts_snddriver_get_dsp_cmd_port(dev_port,owner_port,&cmd_port);
    #endif
    if (k_err != KERN_SUCCESS)
	return(ST_ERROR);
    

    /*  SET UP HOST->DSP, AND DSP->DAC OR DSP->HOST STREAMS  */
    /*  NOTE:  DMA_IN_SIZE MULTIPLIED BY 2, SINCE EACH DSPFix24
	IS SENT AS TWO 2-BYTE WORDS  */
    protocol = SNDDRIVER_DSP_PROTO_RAW;
    #if m68k
    k_err = snddriver_stream_setup(dev_port, owner_port,
				   SNDDRIVER_DMA_STREAM_TO_DSP,
				   DMA_IN_SIZE*2, 2,
				   LOW_WATER, HIGH_WATER,
				   &protocol, &read_port);
    #elif i386
    k_err = tts_snddriver_stream_setup(dev_port, owner_port,
				       SNDDRIVER_DMA_STREAM_TO_DSP,
				       DMA_IN_SIZE*2, 2,
				       LOW_WATER, HIGH_WATER,
				       &protocol, &read_port);
    #endif
    if (k_err != KERN_SUCCESS)
	return(ST_ERROR);
    
    if (outputMode == ST_OUT_DSP) {
	if (output_srate == OUTPUT_SRATE_HIGH) {
            #if m68k
	    k_err = snddriver_stream_setup(dev_port, owner_port,
					   SNDDRIVER_STREAM_DSP_TO_SNDOUT_44,
					   DMA_OUT_SIZE, 2, 
					   LOW_WATER, HIGH_WATER,
					   &protocol, &write_port);
	    #elif i386
	    k_err = tts_snddriver_stream_setup(dev_port, owner_port,
					   SNDDRIVER_STREAM_DSP_TO_SNDOUT_44,
					   DMA_OUT_SIZE, 2, 
					   LOW_WATER, HIGH_WATER,
					   &protocol, &write_port);
	    #endif
	    if (k_err != KERN_SUCCESS)
		return(ST_ERROR);
	}
	else {
            #if m68k
	    k_err = snddriver_stream_setup(dev_port, owner_port,
					   SNDDRIVER_STREAM_DSP_TO_SNDOUT_22,
					   DMA_OUT_SIZE, 2, 
					   LOW_WATER, HIGH_WATER,
					   &protocol, &write_port);
	    #elif i386
	    k_err = tts_snddriver_stream_setup(dev_port, owner_port,
					   SNDDRIVER_STREAM_DSP_TO_SNDOUT_22,
					   DMA_OUT_SIZE, 2, 
					   LOW_WATER, HIGH_WATER,
					   &protocol, &write_port);
	    #endif
	    if (k_err != KERN_SUCCESS)
		return(ST_ERROR);
	}
    }
    else {
        #if m68k
	k_err = snddriver_stream_setup(dev_port, owner_port,
				       SNDDRIVER_DMA_STREAM_FROM_DSP,
				       DMA_OUT_SIZE, 2, 
				       LOW_WATER, HIGH_WATER,
				       &protocol, &write_port);
	#elif i386
	k_err = tts_snddriver_stream_setup(dev_port, owner_port,
					   SNDDRIVER_DMA_STREAM_FROM_DSP,
					   DMA_OUT_SIZE, 2, 
					   LOW_WATER, HIGH_WATER,
					   &protocol, &write_port);
	#endif
	if (k_err != KERN_SUCCESS)
	    return(ST_ERROR);
    }


    /*  SET THE DSP PROTOCOL  */
    #if m68k
    k_err = snddriver_dsp_protocol(dev_port, owner_port, protocol);
    #elif i386
    k_err = tts_snddriver_dsp_protocol(dev_port, owner_port, protocol);
    #endif
    if (k_err != KERN_SUCCESS)
	return(ST_ERROR);

    /*  BOOT THE DSP WITH THE .lod IMAGE CONTAINED IN DSPCORE.H FILE  */
    /*  THE DSPCORE.H FILE IS MADE BY RUNNING dspLod2Core ON THE .lod FILE  */
    /*  INCLUDE DSP CORE FILE  */
    #if m68k
    {
        #include "dspcore_black.h"
        dspStruct = (SNDSoundStruct *)dspcore;
	s_err = SNDBootDSP(dev_port, owner_port, dspStruct);
    }
    #elif i386
    if (outputMode == ST_OUT_FILE) {
        #include "dspcore_white.h"
        dspStruct = (SNDSoundStruct *)dspcore;
	s_err = ttsSNDBootDSP(dev_port, owner_port, dspStruct);
    }
    else {
        #include "dspcore_white_ssi.h"
	dspStruct = (SNDSoundStruct *)dspcore;
	s_err = ttsSNDBootDSP(dev_port, owner_port, dspStruct);
    }
    #endif
    if (s_err != SND_ERR_NONE)
	return(ST_ERROR);


#if OVERSAMPLE_OSC
    /*  LOAD FIR COEFFICIENTS  */
    if (load_FIR_coefficients() == ST_ERROR)
	return(ST_ERROR);
#endif

    /*  LOAD THE SAMPLE RATE CONVERSTION COEFFICIENTS AND DELTAS  */
    if (load_SRC_coefficients() == ST_ERROR)
	return(ST_ERROR);

#if !VARIABLE_GP
    /*  LOAD THE BANDLIMITED GP WAVETABLE  */
    if (load_gp_table() == ST_ERROR)
	return(ST_ERROR);
#endif

    /*  LOAD THE UTTERANCE RATE PARAMETERS INTO THE DSP  */
    if (load_UR_data() == ST_ERROR)
	return(ST_ERROR);

    /*  SET UP MEMORY STREAM FOR FILE OUTPUT, UNLESS STREAM ALREADY SET UP  */
    if ((outputMode == ST_OUT_FILE) && (fileStream == NULL))
	fileStream = NXOpenMemory(NULL, 0, NX_READWRITE);

    /*  MAKE SURE STREAM TO DSP IS IN PAUSED STATE  */
    #if m68k
    k_err = snddriver_stream_control(read_port,0,SNDDRIVER_PAUSE_STREAM);
    #elif i386
    k_err = tts_snddriver_stream_control(read_port,0,SNDDRIVER_PAUSE_STREAM);
    #endif
    if (k_err != KERN_SUCCESS)
	return(ST_ERROR);

    /*  SET STREAM STATUS TO PAUSE  */
    stream_status = ST_PAUSE;

    /*  IF WE GET HERE, THEN THE DSP IS INITIALIZED AND READY TO GO  */
    return(ST_NO_ERROR);
}



/******************************************************************************
*
*	function:	relinquish_DSP
*
*	purpose:	Gives up control of the DSP and DAC devices.
*
*       arguments:      none
*
*	internal
*	functions:	none
*
*	library
*	functions:	SNDRelease
*
******************************************************************************/

static int relinquish_DSP(void)
{
    int s_err;
    

    /*  STOP THE DSP  */
    #if m68k
    snddriver_dsp_host_cmd(cmd_port, (u_int)HC_STOP, SNDDRIVER_LOW_PRIORITY);
    #elif i386
    tts_snddriver_dsp_host_cmd(cmd_port, (u_int)HC_STOP,
			       SNDDRIVER_LOW_PRIORITY);
    #endif


    if (outputMode == ST_OUT_DSP) {
	/*  GIVE UP CONTROL OVER DSP AND SOUND OUT  */
        #if m68k
	s_err = SNDRelease(SND_ACCESS_DSP|SND_ACCESS_OUT,dev_port,owner_port);
	#elif i386
	s_err = ttsSNDRelease(SND_ACCESS_DSP|SND_ACCESS_OUT,
			      dev_port,owner_port);
	#endif
	if (s_err != SND_ERR_NONE)
	    return(ST_ERROR);
	else
	    return (ST_NO_ERROR);
    }
    else {
        /*  GIVE UP CONTROL OVER DSP  */
        #if m68k
	s_err = SNDRelease(SND_ACCESS_DSP,dev_port,owner_port);
	#elif i386
	s_err = ttsSNDRelease(SND_ACCESS_DSP,dev_port,owner_port);
	#endif
	if (s_err != SND_ERR_NONE)
	    return(ST_ERROR);
	else
	    return (ST_NO_ERROR);
    }
}



/******************************************************************************
*
*	function:	flush_input_pages
*
*	purpose:	Appends a pad page to the stream, and waits until
*                       stream to synthesizer is done.
*
*       arguments:      page_consumed_function - user-supplied function
*                          invoked when the synthesizer consumes an input page.
*
*	internal
*	functions:	queue_pad_page, resume_stream, await_write_done_message
*
*	library
*	functions:	none
*
******************************************************************************/

static void flush_input_pages(void (*page_consumed_function)())
{
    int i, j;

    
    /*  ENQUEUE A PAD PAGE (SILENCE);  ENSURES THAT DSP BUFFERS ARE FLUSHED  */
    queue_pad_page();

    /*  QUEUE SILENCE BETWEEN CHUNKS, IF NEEDED  */
    if ((outputMode == ST_OUT_FILE) && (chunkNumber > 1)) {
	for (j = 0; j < INTER_CHUNK_SILENCE; j++)
	    queue_pad_page();
    }

    /*  IF THE STREAM IS STILL PAUSED, THEN START IT  */
    if (stream_status != ST_RUN)
	resume_stream();

    /*  WAIT UNTIL ALL INPUT PAGES ARE WRITTEN (EXCLUDING PAD PAGE)  */
    for (i = prefill_count; i < PREFILL_SIZE; i++) {
	await_write_done_message(INFINITE_WAIT);
	/*  WE'VE ACTUALLY CONSUMED A PAGE  */
	(*page_consumed_function)();
    }

    /*  WAIT UNTIL PAD PAGE IS WRITTEN  */
    await_write_done_message(INFINITE_WAIT);

    /*  WAIT UNTIL ALL INTER-CHUNK SILENCE PAGES ARE WRITTEN  */
    if ((outputMode == ST_OUT_FILE) && (chunkNumber > 1)) {
	for (j = 0; j < INTER_CHUNK_SILENCE; j++)
	    await_write_done_message(INFINITE_WAIT);
    }
}



/******************************************************************************
*
*	function:	queue_page
*
*	purpose:	Writes the page pointed to by synth_read_ptr to the
*                       stream to the DSP.
*
*       arguments:      none
*
*	internal
*	functions:	none
*
*	library
*	functions:	snddriver_stream_start_writing
*
******************************************************************************/

static void queue_page(void)
{
    #if m68k
    snddriver_stream_start_writing(read_port,
				   (void *)synth_read_ptr,
				   (vm_page_size / sizeof(short)),
				   1,
				   0,0,
				   0,1,0,0,0,0, reply_port);
    #elif i386
    tts_snddriver_stream_start_writing(read_port,
				       (void *)synth_read_ptr,
				       (vm_page_size / sizeof(short)),
				       1,
				       0,0,
				       0,1,0,0,0,0, reply_port);
    #endif
}



/******************************************************************************
*
*	function:	queue_pad_page
*
*	purpose:	Writes the pad page (silence) to the stream
*                       to the DSP.
*
*       arguments:      none
*
*	internal
*	functions:	none
*
*	library
*	functions:	snddriver_stream_start_writing
*
******************************************************************************/

static void queue_pad_page(void)
{
    #if m68k
    snddriver_stream_start_writing(read_port,
				   (void *)pad_page,
				   (vm_page_size / sizeof(short)),
				   1,
				   0,0,
				   0,1,0,0,0,0, reply_port);
    #elif i386
    tts_snddriver_stream_start_writing(read_port,
				       (void *)pad_page,
				       (vm_page_size / sizeof(short)),
				       1,
				       0,0,
				       0,1,0,0,0,0, reply_port);
    #endif
}



/******************************************************************************
*
*	function:	resume_stream
*
*	purpose:	Starts the stream to the DSP.
*
*       arguments:      none
*
*	internal
*	functions:	none
*
*	library
*	functions:	snddriver_stream_control, snddriver_dsp_host_cmd
*
******************************************************************************/

static void resume_stream(void)
{
    /*  SET STREAM STATUS VARIABLE  */
    stream_status = ST_RUN;

    /*  UNPAUSE STREAM TO DSP  */
    #if m68k
    snddriver_stream_control(read_port,0,SNDDRIVER_RESUME_STREAM);
    #elif i386
    tts_snddriver_stream_control(read_port,0,SNDDRIVER_RESUME_STREAM);
    #endif

    /*  SEND START HOST COMMAND TO DSP  */
    #if m68k
    snddriver_dsp_host_cmd(cmd_port, (u_int)HC_START, SNDDRIVER_LOW_PRIORITY);
    #elif i386
    tts_snddriver_dsp_host_cmd(cmd_port, (u_int)HC_START,
			       SNDDRIVER_LOW_PRIORITY);
    #endif
}



/******************************************************************************
*
*	function:	write_started, write_completed, under_run,
*                       recorded_data
*
*	purpose:	Handlers for messages from snddriver to reply port,
*                       and file reply port.
*
*       arguments:      arg - arbitrary argument (not used)
*                       tag - stream tag
*                       data - sound data
*                       nbytes - number of bytes of sound data
*
*	internal
*	functions:	none
*
*	library
*	functions:	fprintf, NXWrite, vm_deallocate, task_self
*
******************************************************************************/

#if DEBUG
static void write_started(void *arg, int tag)
{
    fprintf(stderr,"Started playing... %d \n",tag);
}



static void write_completed(void *arg, int tag)
{
    fprintf(stderr,"Playing done... %d\n",tag);
}



static void under_run(void *arg, int tag)
{
    fprintf(stderr,"Under run... %d\n",tag);
}
#endif



static void recorded_data(void *arg, int tag, void *data, int nbytes)
{
#if DEBUG
    fprintf(stderr,"Recorded data... %d %d\n", tag, nbytes);
#endif

    /*  WRITE DATA TO STREAM  */
    if (numberChannels == 2)
	NXWrite(fileStream, data, nbytes);
    else {
	int i;
	char *word;

	/*  USE ONLY THE LEFT CHANNEL  */
	for (i = 0, word = data; i < nbytes/4; i++, word += 4)
	    NXWrite(fileStream, word, 2);
    }
    

    /*  DEALLOCATE MEMORY PASSED IN  */
    vm_deallocate(task_self(), (pointer_t)data, nbytes);
}



/******************************************************************************
*
*	function:	await_write_done_message
*
*	purpose:	Waits for write done message from snddriver.
*
*       arguments:      mode - polled or timed wait.
*
*	internal
*	functions:	relinquish_DSP, timeStamp, exit, write_started,
*                       write_completed, under_run, recorded_data
*
*	library
*	functions:	snddriver_stream_start_reading, msg_receive,
*                       snddriver_reply_handler, NXLogError
*
******************************************************************************/

static int await_write_done_message(int mode)
{
    static int count = 0;
    static double startTime;
#if DEBUG
    snddriver_handlers_t handlers = {0,0,write_started,write_completed,
					 0,0,0,under_run,recorded_data};
#else
    snddriver_handlers_t handlers = {0,0,0,0,0,0,0,0,recorded_data};
#endif


    /*  READ FROM DSP, IF OUTPUT MODE IS FILE, CLEARING ANY OLD MESSAGES  */
    /*  THIS HACK IS NECESSARY WHEN NOT IN DEBUGGING MODE  */
    if (outputMode == ST_OUT_FILE) {
	while (1) {
	    #if m68k
	    snddriver_stream_start_reading(write_port,
					   NULL,
					   DMA_OUT_SIZE,
					   2,
					   0,0,0,0,0,0, file_reply_port);
	    #elif i386
	    tts_snddriver_stream_start_reading(write_port,
					       NULL,
					       DMA_OUT_SIZE,
					       2,
					       0,0,0,0,0,0, file_reply_port);
	    #endif
      
	    /*  RECEIVE MESSAGES FROM SOUND DRIVER  */
	    file_reply_msg->msg_size = MSG_SIZE_MAX;
	    file_reply_msg->msg_local_port = file_reply_port;
      
	    /*  WAIT FOR MESSAGE  */
	    k_err = msg_receive(file_reply_msg, RCV_TIMEOUT, 0);
	    if (k_err == RCV_TIMED_OUT)
		/*  BREAK OUT OF LOOP IF NO MORE MESSAGES  */
		break;
	    else if (k_err == RCV_SUCCESS)
		/*  HANDLE DATA FROM DSP, BY WRITING IT TO FILE  */
	        #if m68k
		k_err = snddriver_reply_handler(file_reply_msg, &handlers);
	        #elif i386
		k_err = tts_snddriver_reply_handler(file_reply_msg, &handlers);
	        #endif
	}
    }



    /*  RECEIVE MESSAGES FROM SOUND DRIVER  */
    reply_msg->msg_size = MSG_SIZE_MAX;
    reply_msg->msg_local_port = reply_port;


    /*  WAIT FOR MESSAGE USING msg_receive AND TIMEOUT OF 6 SECONDS  */
    if (mode == INFINITE_WAIT) {
	/*  RESET THE COUNT, IN CASE WE HAVE SWITCHED MODES  */
	count = 0;
	/*  WAIT FOR MESSAGE  */
	k_err = msg_receive(reply_msg, RCV_TIMEOUT, 6000);
	if (k_err == RCV_TIMED_OUT) {
	    /*  THIS ONLY HAPPENS UNDER VERY HEAVY LOADS (SWAPPING)  */
	    relinquish_DSP();
	    NSLog(@"TTS Server:  Sound Driver failed under heavy load (iw).");
	    exit(-1);
	}
#if DEBUG
	else if (k_err == RCV_SUCCESS)
	    #if m68k
	    k_err = snddriver_reply_handler(reply_msg, &handlers);
	    #elif i386
	    k_err = tts_snddriver_reply_handler(reply_msg, &handlers);
	    #endif
#endif
    }
    /*  SEE IF MESSAGE IS WAITING FOR US  */
    else if (mode == POLL) {
	/*  WAIT FOR MESSAGE  */
	k_err = msg_receive(reply_msg, RCV_TIMEOUT, 0);
	if (k_err == RCV_TIMED_OUT) {
	    /*  TIME STAMP FIRST TIME THE PORT IS POLLED  */
	    if (++count == 1)
		startTime = timeStamp();
	    else {
		if ((timeStamp() - startTime) > 6.0) {
		    /*  THIS ONLY HAPPENS UNDER VERY HEAVY LOADS (SWAPPING)  */
		    relinquish_DSP();
		    NSLog(@"TTS Server:  Sound Driver failed under heavy load (p).");
		    exit(-1);
		}
	    }
	    return(ST_NO_PAGE_REQUEST);
	}
#if DEBUG
        else if (k_err == RCV_SUCCESS)
	    #if m68k
	    k_err = snddriver_reply_handler(reply_msg, &handlers);
	    #elif i386
	    k_err = tts_snddriver_reply_handler(reply_msg, &handlers);
	    #endif
#endif

	/*  RESET COUNT TO ZERO  */
	count = 0;
    }


    /*  READ FROM THE DSP, IF OUTPUT MODE IS FILE  */
    if (outputMode == ST_OUT_FILE) {
	while (1) {
	    #if m68k
	    snddriver_stream_start_reading(write_port,
					   NULL,
					   DMA_OUT_SIZE,
					   2,
					   0,0,0,0,0,0, file_reply_port);
	    #elif i386
	    tts_snddriver_stream_start_reading(write_port,
					       NULL,
					       DMA_OUT_SIZE,
					       2,
					       0,1,0,0,0,0, file_reply_port);
	    #endif
      
	    /*  RECEIVE MESSAGES FROM SOUND DRIVER  */
	    file_reply_msg->msg_size = MSG_SIZE_MAX;
	    file_reply_msg->msg_local_port = file_reply_port;
      
	    /*  WAIT FOR MESSAGE  */
	    #if DEBUG
	    k_err = msg_receive(file_reply_msg, RCV_TIMEOUT, 200);
	    #else
	    k_err = msg_receive(file_reply_msg, RCV_TIMEOUT, 100);
	    #endif
	    if (k_err == RCV_TIMED_OUT)
		/*  BREAK OUT OF LOOP IF NO MORE MESSAGES  */
		break;
	    else if (k_err == RCV_SUCCESS)
		/*  HANDLE DATA FROM DSP, BY WRITING IT TO FILE  */
	        #if m68k
		k_err = snddriver_reply_handler(file_reply_msg, &handlers);
	        #elif i386
		k_err = tts_snddriver_reply_handler(file_reply_msg, &handlers);
	        #endif
	}
    }

    /*  IF HERE, WE ACTUALLY NEED A NEW PAGE  */
    return(ST_PAGE_REQUEST);
}



/******************************************************************************
*
*	function:	timeStamp
*
*	purpose:	Returns the current time as a time stamp.  This is
*                       a double, the fractional number of seconds since
*			a system start time.  Resolution is to milliseconds.

*       arguments:      none
*                       
*	internal
*	functions:	none
*
*	library
*	functions:	ftime
*
******************************************************************************/

static double timeStamp(void)
{
    struct timeb tp;
    void ftime();
    

    ftime(&tp);
    return( (double)tp.time + (double)tp.millitm / 1000.0);
}



/******************************************************************************
*
*	function:	defaultUtteranceRateParameters
*
*	purpose:	Sets the utterance-rate parameters to reasonable
*                       defaults.
*			
*       arguments:      none
*                       
*	internal
*	functions:	set_utterance_rate_parameters
*
*	library
*	functions:	none
*
******************************************************************************/

void defaultUtteranceRateParameters(void)
{
    float silenceParameterTable[] =
	{GLOT_PITCH_DEF, VOLUME_MIN, VOLUME_MIN, VOLUME_MIN, FRIC_POS_DEF,
	 FRIC_CF_DEF, FRIC_BW_DEF, R1_DEF, R2_DEF, R3_DEF, R4_DEF, R5_DEF,
	 R6_DEF, R7_DEF, R8_DEF, VELUM_DEF};

#if VARIABLE_GP
    set_utterance_rate_parameters(OUTPUT_SRATE_DEF,
				  CONTROL_RATE_DEF, MASTER_VOLUME_DEF,
				  CHANNELS_DEF, STEREO_BALANCE_DEF,
				  WAVEFORM_TYPE_DEF, TP_DEF, TN_MIN_DEF,
				  TN_MAX_DEF, BREATHINESS_DEF, LENGTH_DEF,
				  TEMPERATURE_DEF, LOSS_FACTOR_DEF,
				  APERTURE_SCALE_DEF, MOUTH_COEF_DEF,
				  NOSE_COEF_DEF, N1_DEF, N2_DEF, N3_DEF,
				  N4_DEF, N5_DEF, THROAT_CUTOFF_DEF,
				  THROAT_VOLUME_DEF, PULSE_MODULATION_DEF,
				  CROSSMIX_OFFSET_DEF, GLOT_PITCH_DEF,
				  silenceParameterTable);
#else
    set_utterance_rate_parameters(OUTPUT_SRATE_DEF,
				  CONTROL_RATE_DEF, MASTER_VOLUME_DEF,
				  CHANNELS_DEF, STEREO_BALANCE_DEF,
				  WAVEFORM_TYPE_DEF, TP_DEF, TN_MIN_DEF,
				  TOP_HARMONIC_DEF, BREATHINESS_DEF,LENGTH_DEF,
				  TEMPERATURE_DEF, LOSS_FACTOR_DEF,
				  APERTURE_SCALE_DEF, MOUTH_COEF_DEF,
				  NOSE_COEF_DEF, N1_DEF, N2_DEF, N3_DEF,
				  N4_DEF, N5_DEF, THROAT_CUTOFF_DEF,
				  THROAT_VOLUME_DEF, PULSE_MODULATION_DEF,
				  CROSSMIX_OFFSET_DEF, GLOT_PITCH_DEF,
				  silenceParameterTable);
#endif

}



/******************************************************************************
*
*	function:	initialize_pad_page
*
*	purpose:	Fills the pad page with control rate parameters such
*                       that only silence is synthesized.  This page is
*			used to flush the buffers on the DSP.  Note that the
*                       utterance rate parameters MUST be set before this
*                       function produces meaningful results.
*
*       arguments:      silenceParameterTable - user-supplied table of
*                           control-rate parameters which represent the
*                           "silence" phone (i.e. ^ or #)
*
*	internal
*	functions:	new_dsp_pad_table
*
*	library
*	functions:	cfree
*
******************************************************************************/

void initialize_pad_page(float silenceParameterTable[])
{
    int i, j;
    DSPFix24 *page_index, *pad_table;
    

    /*  TEMPORARILY CREATE A TABLE OF SILENCE  */
    pad_table = new_dsp_pad_table(silenceParameterTable);

    /*  FILL THE PAGE FULL OF SILENT TABLES  */
    page_index = (DSPFix24 *)pad_page;
    for (i = 0; i < TABLES_PER_PAGE; i++) {
	for (j = 0; j < DATA_TABLE_SIZE; j++) {
	    *(page_index++) = pad_table[j];
	}
    }

    /*  FREE THE SILENCE TABLE  */
    cfree(pad_table);
}




#if OVERSAMPLE_OSC
/******************************************************************************
*
*	function:	load_FIR_coefficients
*
*	purpose:	Writes the oversampling oscillator FIR filter
*                       coefficients to the DSP.  Note that the size of the
*                       array is sent first.
*			
*       arguments:      none
*                       
*	internal
*	functions:	none
*
*	library
*	functions:	snddriver_dsp_host_cmd, DSPIntToFix24,
*                       snddriver_dsp_write
*
******************************************************************************/

int load_FIR_coefficients(void)
{
    /*  SEND THE HOST COMMAND  */
    #if m68k
    k_err = snddriver_dsp_host_cmd(cmd_port, HC_LOAD_FIR_COEF,
				   SNDDRIVER_LOW_PRIORITY);
    #elif i386
    k_err = tts_snddriver_dsp_host_cmd(cmd_port, HC_LOAD_FIR_COEF,
				       SNDDRIVER_LOW_PRIORITY);
    #endif
    if (k_err != KERN_SUCCESS)
	return(ST_ERROR);
    else {
	DSPFix24 size = DSPIntToFix24(numberTaps);
	/*  SEND SIZE OF THE ARRAY FIRST  */
	#if m68k
	k_err = snddriver_dsp_write(cmd_port, &size, 1, sizeof(DSPFix24),
				    SNDDRIVER_LOW_PRIORITY);
	#elif i386
	k_err = tts_snddriver_dsp_write(cmd_port, &size, 1, sizeof(DSPFix24),
					SNDDRIVER_LOW_PRIORITY);
	#endif
	if (k_err != KERN_SUCCESS)
	    return(ST_ERROR);

	/*  SEND THE ARRAY ITSELF  */
	#if m68k
	k_err = snddriver_dsp_write(cmd_port, FIRCoefficients, numberTaps,
				    sizeof(DSPFix24), SNDDRIVER_LOW_PRIORITY);
	#elif i386
	k_err = tts_snddriver_dsp_write(cmd_port, FIRCoefficients, numberTaps,
					sizeof(DSPFix24),
					SNDDRIVER_LOW_PRIORITY);
	#endif
	if (k_err != KERN_SUCCESS)
	    return(ST_ERROR);
    }

    return(ST_NO_ERROR);
}
#endif



/******************************************************************************
*
*	function:	load_SRC_coefficients
*
*	purpose:	Writes the sampling rate conversion coefficients and
*                       deltas to the DSP.
*			
*       arguments:      none
*                       
*	internal
*	functions:	none
*
*	library
*	functions:	snddriver_dsp_host_cmd, snddriver_dsp_write
*
******************************************************************************/

int load_SRC_coefficients(void)
{
    /*  SEND THE HOST COMMAND  */
    #if m68k
    k_err = snddriver_dsp_host_cmd(cmd_port, HC_LOAD_SRC_COEF,
				   SNDDRIVER_LOW_PRIORITY);
    #elif i386
    k_err = tts_snddriver_dsp_host_cmd(cmd_port, HC_LOAD_SRC_COEF,
				       SNDDRIVER_LOW_PRIORITY);
    #endif
    if (k_err != KERN_SUCCESS)
	return(ST_ERROR);
    else {
	/*  SEND THE SAMPLE RATE CONVERSION COEFFICIENTS  */
        #if m68k
	k_err = snddriver_dsp_write(cmd_port, h, filterLength,
				    sizeof(DSPFix24), SNDDRIVER_LOW_PRIORITY);
	#elif i386
	k_err = tts_snddriver_dsp_write(cmd_port, h, filterLength,
					sizeof(DSPFix24),
					SNDDRIVER_LOW_PRIORITY);
	#endif
	if (k_err != KERN_SUCCESS)
	    return(ST_ERROR);

	/*  SEND THE DELTA VALUES  */
	#if m68k
	k_err = snddriver_dsp_write(cmd_port, hDelta, filterLength,
				    sizeof(DSPFix24), SNDDRIVER_LOW_PRIORITY);
	#elif i386
	k_err = tts_snddriver_dsp_write(cmd_port, hDelta, filterLength,
					sizeof(DSPFix24),
					SNDDRIVER_LOW_PRIORITY);
	#endif
	if (k_err != KERN_SUCCESS)
	    return(ST_ERROR);
    }

    return(ST_NO_ERROR);
}



/******************************************************************************
*
*	function:	load_UR_data
*
*	purpose:	Writes the utterance-rate parameters to the DSP.
*                       
*       arguments:      none
*                       
*	internal
*	functions:	none
*
*	library
*	functions:	snddriver_dsp_host_cmd, snddriver_dsp_write
*
******************************************************************************/

int load_UR_data(void)
{
    /*  SEND THE HOST COMMAND  */
    #if m68k
    k_err = snddriver_dsp_host_cmd(cmd_port, HC_LOAD_UR_DATA,
				   SNDDRIVER_LOW_PRIORITY);
    #elif i386
    k_err = tts_snddriver_dsp_host_cmd(cmd_port, HC_LOAD_UR_DATA,
				       SNDDRIVER_LOW_PRIORITY);
    #endif
    if (k_err != KERN_SUCCESS)
	return(ST_ERROR);
    else {
	/*  SEND THE UTTERANCE RATE DATA  */
        #if m68k
	k_err = snddriver_dsp_write(cmd_port, utteranceTable,
				    UTTERANCE_TABLE_SIZE, sizeof(DSPFix24),
				    SNDDRIVER_LOW_PRIORITY);
	#elif i386
	k_err = tts_snddriver_dsp_write(cmd_port, utteranceTable,
					UTTERANCE_TABLE_SIZE, sizeof(DSPFix24),
					SNDDRIVER_LOW_PRIORITY);
	#endif
	if (k_err != KERN_SUCCESS)
	    return(ST_ERROR);
    }

    return(ST_NO_ERROR);
}



#if !VARIABLE_GP
/******************************************************************************
*
*	function:	create_bandlimited_gp_table
*
*	purpose:	Creates a table which contains one cycle of a band-
*                       limited glottal pulse, with the specified rise time,
*                       fall time, top harmonic, and roll-off factor.
*			
*       arguments:      riseTime - rise time of the glottal pulse (0.0 - 0.5)
*                       fallTime - fall time of the glottal pulse (0.0 - 0.5)
*                       topHarmonic - harmonics above this are set to 0
*                       rolloff - factor used to rolloff upper harmonics
*	internal
*	functions:	four1
*
*	library
*	functions:	pow, DSPFloatToFix24
*
******************************************************************************/

int create_bandlimited_gp_table(float riseTime, float fallTime,
				int topHarmonic, float rolloff)
{
    float wavetable[GP_TABLE_SIZE], complexTable[GP_TABLE_SIZE*2];
    float maxSample = 0.0, scale;
    int i, j, tableDiv1, tableDiv2, tnLength, zeroHarmonics;
    int numberHarmonics = GP_TABLE_SIZE / 2;


    /*  GENERATE THE GLOTTAL PULSE WAVEFORM  */
    tableDiv1 = (int)rint(GP_TABLE_SIZE * riseTime);
    tableDiv2 = (int)rint(GP_TABLE_SIZE * (riseTime + fallTime));
    tnLength = tableDiv2 - tableDiv1;
    /*  CALCULATE RISE PORTION  */
    for (i = 0; i < tableDiv1; i++) {
	double x = (double)i / (double)tableDiv1;
	double x2 = x * x;
	double x3 = x2 * x;
	wavetable[i] = (3.0 * x2) - (2.0 * x3);
    }
    /*  CALCULATE FALL PORTION  */
    for (i = tableDiv1, j = 0; i < tableDiv2; i++, j++) {
	double x = (double)j / tnLength;
	wavetable[i] = 1.0 - (x * x);
    }
    /*  CALCULATE CLOSED PORTION  */
    for (i = tableDiv2; i < GP_TABLE_SIZE; i++)
	wavetable[i] = 0.0;


    /*  CONVERT INTO COMPLEX NUMBERS  */
    for (i = 0, j = 0; i < GP_TABLE_SIZE; i++) {
	complexTable[j++] = wavetable[i];
	complexTable[j++] = 0.0;
    }

    /*  PERFORM AN FFT ON THE WAVEFORM  */
    four1(complexTable, GP_TABLE_SIZE, 1);

    /*  REDUCE OR ELIMINATE HIGHER HARMONICS  */
    zeroHarmonics = numberHarmonics - topHarmonic;
    /*  ZERO NYQUIST HARMONIC  */
    complexTable[GP_TABLE_SIZE] = complexTable[GP_TABLE_SIZE+1] = 0.0;
    /*  ZERO OUT HARMONICS HARMONICS ABOVE CUTOFF  */
    for (i = 1; i < zeroHarmonics; i++) {
	int rightReal = GP_TABLE_SIZE + (i * 2);
	int rightImaginary = rightReal + 1;
	int leftReal = GP_TABLE_SIZE - (i * 2);
	int leftImaginary = leftReal + 1;

	complexTable[rightReal] = complexTable[rightImaginary] = 0.0;
	complexTable[leftReal] = complexTable[leftImaginary] = 0.0;
    }
    /*  SMOOTHLY ATTENUATE LOWER HARMONICS  */
    for (i = 1, j = zeroHarmonics; i <= topHarmonic; i++, j++) {
	int rightReal = GP_TABLE_SIZE + (j * 2);
	int rightImaginary = rightReal + 1;
	int leftReal = GP_TABLE_SIZE - (j * 2);
	int leftImaginary = leftReal + 1;
	float factor = (1.0 - pow(rolloff,(double)i)) / (float)GP_TABLE_SIZE;
    
	complexTable[rightReal] *= factor;
	complexTable[rightImaginary] *= factor;
	complexTable[leftReal] *= factor;
	complexTable[leftImaginary] *= factor;
    }
    /*  ALSO SCALE DC COMPONENT  */
    complexTable[0] *= ((1.0 - pow(rolloff,(double)i)) / (float)GP_TABLE_SIZE);
    complexTable[1] *= ((1.0 - pow(rolloff,(double)i)) / (float)GP_TABLE_SIZE);
    

    /*  TRANSFORM BACK TO TIME DOMAIN, USING IFFT  */
    four1(complexTable, GP_TABLE_SIZE, -1);

    /*  USE ONLY THE REAL PART  */
    for (i = 0, j = 0; i < GP_TABLE_SIZE; i++, j+=2) {
	wavetable[i] = complexTable[j];
	if (wavetable[i] > maxSample)
	    maxSample = wavetable[i];
    }

    /*  SCALE SO THAT VALUES STAY IN RANGE, AND CONVERT TO DSPFIX24s  */
    scale = MAX_SIZE / maxSample;
    for (i = 0; i < GP_TABLE_SIZE; i++)
	gp_table[i] = DSPFloatToFix24(wavetable[i] * scale);

    return(ST_NO_ERROR);
}



/******************************************************************************
*
*	function:	load_gp_table
*
*	purpose:	Loads the precomputed bandlimited glottal pulse into
*                       the wavetable memory on the DSP.
*			
*       arguments:      none
*                       
*	internal
*	functions:	none
*
*	library
*	functions:	snddriver_dsp_host_cmd, snddriver_dsp_write
*
******************************************************************************/

int load_gp_table(void)
{
    /*  SEND THE HOST COMMAND  */
    #if m68k
    k_err = snddriver_dsp_host_cmd(cmd_port, HC_LOAD_WAVETABLE,
				   SNDDRIVER_LOW_PRIORITY);
    #elif i386
    k_err = tts_snddriver_dsp_host_cmd(cmd_port, HC_LOAD_WAVETABLE,
				       SNDDRIVER_LOW_PRIORITY);
    #endif
    if (k_err != KERN_SUCCESS)
	return(ST_ERROR);
    else {
	/*  SEND THE WAVETABLE  */
        #if m68k
	k_err = snddriver_dsp_write(cmd_port, gp_table, GP_TABLE_SIZE,
				    sizeof(DSPFix24), SNDDRIVER_LOW_PRIORITY);
	#elif i386
	k_err = tts_snddriver_dsp_write(cmd_port, gp_table, GP_TABLE_SIZE,
					sizeof(DSPFix24),
					SNDDRIVER_LOW_PRIORITY);
	#endif
	if (k_err != KERN_SUCCESS)
	    return(ST_ERROR);
    }

    return(ST_NO_ERROR);
}
#endif



/******************************************************************************
*
*	function:	write_file
*
*	purpose:	Writes the samples stored in fileStream to a .snd
*                       type file with the pathname provided.  The uid and gid
*                       of the file are changed to that of the client.  The
*                       NXStream is deallocated here.
*                       
*			
*       arguments:      none
*                       
*	internal
*	functions:	none
*
*	library
*	functions:	fopen, NXGetMemoryBuffer, fwrite, fclose, chown,
*                       NXCloseMemory
*
******************************************************************************/

static void write_file(void)
{
    SNDSoundStruct sound;
    FILE *fopen(), *fd;
    char *streambuf;
    int len, maxlen;


    /*  OPEN THE OUTPUT FILE  */
    fd = fopen(file_path, "w");

    /*  GET THE MEMORY BUFFER FOR THE FILE STREAM (BIG-ENDIAN)  */
    NXGetMemoryBuffer(fileStream, &streambuf, &len, &maxlen);

    /*  INITIALIZE THE SOUND STRUCT  */
    sound.magic = NSSwapHostIntToBig(SND_MAGIC);
    sound.dataLocation = NSSwapHostIntToBig(sizeof(sound));
    sound.dataSize = NSSwapHostIntToBig(len);
    sound.dataFormat = NSSwapHostIntToBig(SND_FORMAT_LINEAR_16);
    sound.samplingRate = NSSwapHostIntToBig((int)output_srate);
    sound.channelCount = NSSwapHostIntToBig(numberChannels);
    sound.info[0] = '\0';

    /*  WRITE THE STRUCT TO FILE  */
    fwrite((char *)&sound, 1, sizeof(sound), fd);

    /*  WRITE THE MEMORY BUFFER TO FILE (AFTER THE HEADER)  */
    fwrite(streambuf, 1, len, fd);

    /*  CLOSE THE FILE  */
    fclose(fd);

    /*  CHANGE UID AND GID OF FILE TO OWNER AND GROUP OF THE USER  */
    chown(file_path, file_uid, file_gid);

    /*  DEALLOCATE THE MEMORY STREAM  */
    NXCloseMemory(fileStream, NX_FREEBUFFER);
    fileStream = NULL;
}



/*****************************************************************************/
/*****************************************************************************/
/*****************************************************************************/
/*               EXTERNAL FUNCTIONS USED BY CONTROL MODULE                   */
/*****************************************************************************/
/*****************************************************************************/
/*****************************************************************************/



/******************************************************************************
*
*	function:	initialize_synthesizer_module
*
*	purpose:	Initializes variables used in synthesizer module,
*                       and allocates the necessary memory and ports.
*
*       arguments:      none
*
*	internal
*	functions:	defaultUtteranceRateParameters, initializeFIR,
*                       initialize_sr_conversion
*
*	library
*	functions:	port_allocate, port_set_backlog, task_self, malloc
*
******************************************************************************/

int initialize_synthesizer_module(void)
{
    /*  ALLOCATE A PORT FOR REPLIES FROM THE SOUND DRIVER  */
    k_err = port_allocate(task_self(),&reply_port);
    if (k_err != KERN_SUCCESS)
	return(ST_ERROR);

    /*  ENLARGE REPLY QUEUE TO MAXIMUM ALLOWED SIZE  */
    k_err = port_set_backlog(task_self(), reply_port, PORT_BACKLOG_MAX);
    if (k_err != KERN_SUCCESS)
	return(ST_ERROR);

    /*  ALLOCATE A PORT FOR FILE REPLIES FROM THE SOUND DRIVER  */
    k_err = port_allocate(task_self(),&file_reply_port);
    if (k_err != KERN_SUCCESS)
	return(ST_ERROR);

    /*  ENLARGE FILE REPLY QUEUE TO MAXIMUM ALLOWED SIZE  */
    k_err = port_set_backlog(task_self(), file_reply_port, PORT_BACKLOG_MAX);
    if (k_err != KERN_SUCCESS)
	return(ST_ERROR);

    /*  ALLOCATE MEMORY FOR RETURN MESSAGE FROM SOUND DRIVER  */
    reply_msg = (msg_header_t *)malloc(MSG_SIZE_MAX);
    if (reply_msg == NULL)
	return(ST_ERROR);

    /*  ALLOCATE MEMORY FOR FILE RETURN MESSAGE FROM SOUND DRIVER  */
    file_reply_msg = (msg_header_t *)malloc(MSG_SIZE_MAX);
    if (file_reply_msg == NULL)
	return(ST_ERROR);

    /*  ALLOCATE THE PAGE OF MEMORY FOR THE PAD PAGE  */
    k_err = vm_allocate(task_self(), (vm_address_t *)&pad_page,
			(vm_size_t)vm_page_size, 1);
    if (k_err != KERN_SUCCESS)
	return(ST_ERROR);

    /*  INITIALIZE UTTERANCE RATE TABLE  */
    defaultUtteranceRateParameters();


#if OVERSAMPLE_OSC
    /*  INITIALIZE FIR FILTER COEFFICIENTS  */
    FIRCoefficients = initializeFIR(FIR_BETA, FIR_GAMMA, FIR_CUTOFF,
				    &numberTaps, FIRCoefficients);
#endif


    /*  INITIALIZE SAMPLING RATE CONVERSION FILTER COEFFICIENTS  */
    initialize_sr_conversion(ZERO_CROSSINGS, L_BITS, BETA, LP_CUTOFF,
			     &h, &hDelta, &filterLength);
    

    /*  IF WE GET HERE, THEN INITIALIZED WITH NO ERRORS  */
    return(ST_NO_ERROR);
}



/******************************************************************************
*
*	function:	free_synthesizer_module
*
*	purpose:	Frees all memory and ports used by the synthesizer
*                       module.  Note that the module will be unusable once
*                       this happens.
*			
*       arguments:      none
*                       
*	internal
*	functions:	none
*
*	library
*	functions:	port_deallocate, task_self, free, vm_deallocate, cfree
*
******************************************************************************/

int free_synthesizer_module(void)
{
    /*  DEALLOCATE PORT FOR REPLIES FROM THE SOUND DRIVER  */
    k_err = port_deallocate(task_self(), reply_port);
    if (k_err != KERN_SUCCESS)
	return(ST_ERROR);

    /*  DEALLOCATE PORT FOR FILE REPLIES FROM THE SOUND DRIVER  */
    k_err = port_deallocate(task_self(), file_reply_port);
    if (k_err != KERN_SUCCESS)
	return(ST_ERROR);

    /*  DEALLOCATE MEMORY FOR RETURN MESSAGE FROM SOUND DRIVER  */
    free(reply_msg);

    /*  DEALLOCATE MEMORY FOR FILE RETURN MESSAGE FROM SOUND DRIVER  */
    free(file_reply_msg);

    /*  DEALLOCATE THE PAD PAGE   */
    k_err = vm_deallocate(task_self(), (vm_address_t)pad_page,
			(vm_size_t)vm_page_size);
    if (k_err != KERN_SUCCESS)
	return(ST_ERROR);

#if OVERSAMPLE_OSC
    /*  FREE MEMORY USED FOR FIR FILTER COEFFICIENTS  */
    cfree((void *)FIRCoefficients);
#endif

    /*  FREE SAMPLING RATE CONVERSION FILTER COEFFICIENTS  */
    cfree((void *)h);
    cfree((void *)hDelta);

    /*  IF WE GET HERE, THEN FREED WITH NO ERRORS  */
    return(ST_NO_ERROR);
}



/******************************************************************************
*
*	Function:	set_synthesizer_output
*
*	purpose:	Used by the control thread to set the output mode to
*                       either file or dsp.  Set to file mode if path is non-
*                       NULL, and the other arguments are set.  If NULL, then
*                       set to dsp mode, and the other arguments are ignored.
*                       
*			
*       arguments:      path - pathname of the file to be written to.
*                       uid - the file is set to this user id.
*                       gid - the file is set to the group id.
*                       number_chunks - the number of chunks in the next
*                                       utterance.
*	internal
*	functions:	none
*
*	library
*	functions:	strcpy
*
******************************************************************************/

void set_synthesizer_output(char *path, int uid, int gid, int number_chunks)
{
    /*  IF PATH NOT NULL, SET OUTPUT MODE TO FILE, COPY PATH & IDS  */
    if (path) {
	outputMode = ST_OUT_FILE;
	strcpy(file_path, path);
	chunkNumber = number_chunks;
	file_uid = uid;
	file_gid = gid;
    }
    /*  ELSE, SET OUTPUT MODE TO DSP  */
    else {
	outputMode = ST_OUT_DSP;
	file_path[0] = '\0';
	chunkNumber = 0;
	file_uid = -1;
	file_gid = -1;
    }
}      



/******************************************************************************
*
*	function:	set_utterance_rate_parameters
*
*	purpose:	Sets the non-changeable parameters for the
*                       next utterance.
*			
*       arguments:      outputSampleRate - actual D/A rate (22050, 44100 Hz)
*                       controlRate - input control rate (1.0 - 1000.0 Hz)
*                       volume - master volume (0 - 60 dB)
*                       channels - number output channels (1, 2)
*                       balance - stereo balance (-1 to +1)
*
*                       waveform - GS waveform type (0 = pulse, 1 = sine)
*  (for variable gp)|   tp - glottal pulse rise time (5% - 50%)
*                   |   tnMin - glottal pulse fall time minimum (5% - 50%)
*                   |   tnMax - glottal pulse fall time maximum (5% - 50%)
*  (for fixed gp)   {   tp - glottal pulse rise time (5% - 50%)
*                   {   tn - glottal pulse fall time (5% - %50)
*                   {   topHarmonic - cutoff harmonic (1 - GP_TABLESIZE/2)
*                       breathiness - glottal source breathiness (0% - 10%)
*
*                       length - nominal tube length (10 - 20 cm)
*                       temperature - tube temperature (25 - 40 degrees C)
*                       lossFactor - junction loss factor (0% - 5%)
*
*                       apScale - aperture scaling radius (3.05 - 12 cm)
*                       mouthCoef - mouth aperture coef (100 - nyquist Hz)
*                       noseCoef - nose aperture coef (100 - nyquist Hz)
*
*                       n1 - nose section 1 radius (0 - 3 cm)
*                       n2 - nose section 2 radius (0 - 3 cm)
*                       n3 - nose section 3 radius (0 - 3 cm)
*                       n4 - nose section 4 radius (0 - 3 cm)
*                       n5 - nose section 5 radius (0 - 3 cm)
*
*                       throatCutoff - throat lp frequency (50 - nyquist Hz)
*                       throatVol - throat volume (0 - 48 dB)
*
*                       modulation - noise pulse modulation (0 = off, 1 = on)
*                       mixOffset - noise crossmix offset (30 - 60 dB)
*                       medianPitch - approx. center pitch (-24 - +24)
*
*                       silenceParameterTable - user-supplied table of
*                           control-rate parameters which represent the
*                           "silence" phone (i.e. ^ or #)
*
*                       
*	internal
*	functions:	convertLength, convertToTimeRegister,
*                       optimizeConversion, scaledVolume,
*                       scatteringCoefficient, endCoefficient, dampingFactor,
*                       scaledFrequency, scaledCrossmixFactor,
*                       initialize_pad_page, scaling
*
*	library
*	functions:	DSPFloatToFix24, DSPIntToFix24
*
******************************************************************************/

#if VARIABLE_GP
void set_utterance_rate_parameters(float outputSampleRate,
				   float controlRate, float volume,
				   int channels, float balance,
				   int waveform, float tp, float tnMin,
				   float tnMax, float breathiness,
				   float length, float temperature,
				   float lossFactor, float apScale,
				   float mouthCoef, float noseCoef, float n1,
				   float n2, float n3, float n4, float n5,
				   float throatCutoff, float throatVol,
				   int modulation, float mixOffset,
				   float medianPitch,
				   float silenceParameterTable[])
#else
void set_utterance_rate_parameters(float outputSampleRate,
				   float controlRate, float volume,
				   int channels, float balance,
				   int waveform, float tp, float tn,
				   int topHarmonic, float breathiness,
				   float length, float temperature,
				   float lossFactor, float apScale,
				   float mouthCoef, float noseCoef, float n1,
				   float n2, float n3, float n4, float n5,
				   float throatCutoff, float throatVol,
				   int modulation, float mixOffset,
				   float medianPitch,
				   float silenceParameterTable[])
#endif
{
    int controlPeriod, integerPart, fractionalPart, scale;
    float sampleRate, nyquist, reflectionCoefficient;


    /*  RECORD OUTPUT SAMPLE RATE  */
    output_srate = outputSampleRate;

    /*  CONVERT TUBE LENGTH AND TEMPERATURE INTO CONTROL PERIOD AND SRATE  */
    convertLength(length, temperature, controlRate,
		  &controlPeriod, &sampleRate);
    nyquist = sampleRate / 2.0;

//    printf("controlPeriod = %-d  sampleRate = %.2f  output_srate = %.1f\n",
//	   controlPeriod, sampleRate, output_srate);

    /*  CONVERT SAMPLE RATE INTO INTEGER AND FRACTIONAL PARTS OF TIME REG  */
    convertToTimeRegister(sampleRate, output_srate, 
			  &integerPart, &fractionalPart);

    /*  OPTIMIZE CONVERSION ROUTINES BY PRECALCULATING PERSISTENT VARIABLES  */
    optimizeConversion(sampleRate, waveform, apScale, n1);

#if !VARIABLE_GP
    /*  CALCULATE FIXED BANDLIMITED GLOTTAL PULSE WAVEFORM  */
    create_bandlimited_gp_table(tp/100.0, tn/100.0, topHarmonic,
				ROLLOFF_FACTOR);
#endif

    /*  INITIALIZE THE PAD PAGE SO THAT IT WORKS WITH THESE PARAMETERS  */
    initialize_pad_page(silenceParameterTable);


    /*  CALCULATE DSP UTTERANCE-RATE PARAMETERS, AND STORE IN TABLE  */
    /*  CALCULATE MOST SCATTERING JUNCTION COEFFICIENTS FOR NASAL CAVITY  */
    utteranceTable[NC_2] = DSPFloatToFix24(scatteringCoefficient(n1,n2));
    utteranceTable[NC_3] = DSPFloatToFix24(scatteringCoefficient(n2,n3));
    utteranceTable[NC_4] = DSPFloatToFix24(scatteringCoefficient(n3,n4));
    utteranceTable[NC_5] = DSPFloatToFix24(scatteringCoefficient(n4,n5));

    /*  CALCULATE NOSE JUNCTION COEFFICIENTS  */
    reflectionCoefficient = endCoefficient(n5);
    utteranceTable[NC_REFL] = DSPFloatToFix24(reflectionCoefficient);
    utteranceTable[NC_RAD] = DSPFloatToFix24(reflectionCoefficient + 1.0);

    /*  CALCULATE SCALED MASTER VOLUME  */
    utteranceTable[MASTER_VOLUME] = DSPFloatToFix24(scaledVolume(volume));

    /*  SET  NUMBER OF CHANNELS  */
    utteranceTable[CHANNELS] = DSPIntToFix24(channels);
    numberChannels = channels;

    /*  SET STEREO BALANCE  */
    utteranceTable[BALANCE] = DSPFloatToFix24(balance);

    /*  CONVERT BREATHINESS FROM PERCENTAGE TO FRACTION  */
    utteranceTable[BREATHINESS] = DSPFloatToFix24(breathiness/100.0);

    /*  SET THE TIME REGISTER INCREMENT, CONTROL PERIOD AND CONTROL FACTOR  */
    utteranceTable[TIME_REG_INT] = DSPIntToFix24(integerPart);
    utteranceTable[TIME_REG_FRAC] = DSPIntToFix24(fractionalPart);
    utteranceTable[CONTROL_PERIOD] = DSPIntToFix24(controlPeriod);
    utteranceTable[CONTROL_FACTOR] = DSPFloatToFix24(1.0/(float)controlPeriod);

    /*  CONVERT JUNCTION LOSS PERCENTAGE TO DAMPING FACTOR FRACTION  */
    utteranceTable[DAMPING] = DSPFloatToFix24(dampingFactor(lossFactor));

    /*  CONVERT GLOTTAL PULSE PARAMETERS FROM PERCENTAGES TO FRACTIONS  */
#if VARIABLE_GP
    utteranceTable[TP] = DSPFloatToFix24(tp/100.0);
    utteranceTable[TN_MIN] = DSPFloatToFix24(tnMin/100.0);
    utteranceTable[TN_MAX] = DSPFloatToFix24(tnMax/100.0);
#else
    /*  THESE (GARBAGE) VALUES ARE IGNORED BY THE DSP, SINCE FIXED GP USED  */
    utteranceTable[TP] = DSPFloatToFix24(tp/100.0);
    utteranceTable[TN_MIN] = DSPFloatToFix24(tn/100.0);
    utteranceTable[TN_MAX] = DSPIntToFix24(topHarmonic);
#endif

    /*  CONVERT THROAT LP CUTOFF FREQUENCY TO A FRACTION OF SR  */
    utteranceTable[THROAT_CUTOFF] =
	DSPFloatToFix24(scaledFrequency(throatCutoff));

    /*  CALCULATE SCALED THROAT VOLUME  */
    utteranceTable[THROAT_VOLUME] = DSPFloatToFix24(scaledVolume(throatVol));

    /*  SET MOUTH AND NOSE FILTER COEFFICIENTS  */
    utteranceTable[MOUTH_COEF] =
	DSPFloatToFix24((nyquist - mouthCoef) / nyquist);
    utteranceTable[NOSE_COEF] =
	DSPFloatToFix24((nyquist - noseCoef) / nyquist);

    /*  SET WAVEFORM TYPE  */
    utteranceTable[WAVEFORM_TYPE] = DSPIntToFix24(waveform);

    /*  SET PULSED MODULATION OF NOISE ON OR OFF  */
    utteranceTable[PULSE_MODULATION] = DSPIntToFix24(modulation);

    /*  CONVERT CROSSMIX OFFSET INTO SCALED FACTOR  */
    utteranceTable[CROSSMIX_FACTOR] =
	DSPFloatToFix24(scaledCrossmixFactor(mixOffset));

    /*  CALCULATE SCALING APPROPRIATE FOR CURRENT MEDIAN PITCH  */
    scale = (int)rint(scaling(medianPitch, mouthCoef, sampleRate) / 2.0);
    if (scale < 1)
	scale = 1;
    utteranceTable[LEFT_SHIFT_SCALE] = DSPIntToFix24(scale);
}



/******************************************************************************
*
*	function:	start_synthesizer
*
*	purpose:	Grabs control of the DSP/Sound hardware and initializes
*                       it, and initializes other variables.
*
*       arguments:      none
*
*	internal
*	functions:	grab_and_initialize_DSP
*
*	library
*	functions:	none
*
******************************************************************************/

int start_synthesizer(void)
{
    /*  TRY TO GET CONTROL OVER THE SOUND/DSP HARDWARE  */
    if (grab_and_initialize_DSP() == ST_ERROR)
	return(ST_ERROR);

    /*  INITIALIZE THE PREFILL_COUNT AND SYNTHESIZER STATUS  */
    prefill_count = PREFILL_SIZE;
    synth_status = ST_RUN;

    return(ST_NO_ERROR);
}



/******************************************************************************
*
*	function:	await_request_new_page
*
*	purpose:	Does a blocking or non-blocking wait for synthesizer
*                       request for a new page.  If last_page is set to ST_YES,
*                       then the synthesizer is stopped after the page pointed
*                       at by synth_read_ptr is processed.  The user must
*                       supply a function to update this pointer -- the result
*                       provided by this function is the page that is sent to
*                       the synthesizer.
*
*       arguments:      blocking_request - blocking flag
*                       last_page - last page indicator
*                       ptr_update_function - user supplied ptr update routine
*
*	internal
*	functions:	queue_page, resume_stream, await_write_done_message,
*                       flush_input_pages, relinquish_DSP, write_file
*
*	library
*	functions:	none
*
******************************************************************************/

void await_request_new_page(int blocking_request, int last_page, 
			    void (*ptr_update_function)(),
			    void (*page_consumed_function)())
{
    if (prefill_count > 0) {
	/*  UPDATE POINTER TO INPUT PAGE  */
	(*ptr_update_function)();

	/*  QUEUE THAT PAGE TO THE STREAM TO THE SYNTHESIZER  */
	queue_page();

	/*  ONCE ENOUGH PAGES QUEUED, START THE STREAM TO THE SYNTHESIZER  */
	if ( (--prefill_count) == 0)
	    resume_stream();
    }
    else {
	if (blocking_request) {
	    /*  CHECK REPLY PORT WITH INFINITE TIME OUT  */
	    await_write_done_message(INFINITE_WAIT);
	    /*  WE'VE ACTUALLY CONSUMED A PAGE  */
	    (*page_consumed_function)();
	}
	else {
	    /*  POLL REPLY PORT WITH 0 TIME OUT; IF NO PAGE REQUEST, RETURN  */
	    if (await_write_done_message(POLL) == ST_NO_PAGE_REQUEST)
		return;
	    else
		/*  WE'VE ACTUALLY CONSUMED A PAGE  */
		(*page_consumed_function)();
	}

	/*  UPDATE POINTER TO INPUT PAGE  */
	(*ptr_update_function)();

	/*  QUEUE THAT PAGE TO THE STREAM TO THE SYNTHESIZER  */
	queue_page();
    }

    /*  DEAL WITH LAST PAGE  */
    if (last_page) {
	/*  FLUSH ALL INPUT PAGES  */
	flush_input_pages(page_consumed_function);

	/*  GIVE UP CONTROL OVER THE DSP AND SOUND OUT HARDWARE  */
	relinquish_DSP();

	/*  WRITE TO FILE, IF NECESSARY  */
	if ((outputMode == ST_OUT_FILE) && (--chunkNumber <= 0))
	    write_file();

	/*  SET SYNTHESIZER STATUS TO PAUSE  */
	synth_status = ST_PAUSE;
    }
}



/******************************************************************************
*
*	function:	convert_parameter_table
*
*	purpose:	Converts the user-supplied table of control-rate
*                       parameters to values appropriate for input into the
*			DSP, and writes these to user-allocated memory.
*
*       arguments:      parameterTable - user-supplied table of control-rate
*                                        parameters.
*                       dspTable - user-allocated memory to write converted
*                                  values to.
*
*	internal
*	functions:	tableIncrement, scaledVolume, scaledPosition,
*                       scaledFrequency, alphaCoefficients,
*                       scatteringCoefficient, endCoefficient, n0Coefficient
*
*	library
*	functions:	DSPIntToFix24, DSPFloatToFix24
*
******************************************************************************/

void convert_parameter_table(float parameterTable[], DSPFix24 *dspTable)
{
    float inc, alpha0, alpha1, alpha2, reflectionCoefficient;

    /*  CALCULATE THE OSCILLATOR TABLE INCREMENT  */
    inc = tableIncrement(parameterTable[GLOT_PITCH]);
    dspTable[TABLE_INC_INT] = DSPIntToFix24((int)inc);
    dspTable[TABLE_INC_FRAC] = DSPFloatToFix24(inc - (float)((int)inc));

    /*  CALCULATE GLOTTAL SOURCE VOLUME  */
    dspTable[SOURCE_VOLUME] =
	DSPFloatToFix24(scaledVolume(parameterTable[GLOT_VOL]));

    /*  CALCULATE ASPIRATION VOLUME  */
    dspTable[ASP_VOLUME] =
	DSPFloatToFix24(scaledVolume(parameterTable[ASP_VOL]));

    /*  CALCULATE FRICATION VOLUME  */
    dspTable[FRICATION_VOLUME] =
	DSPFloatToFix24(scaledVolume(parameterTable[FRIC_VOL]));

    /*  CALCULATE FRICATION POSITION  */
    dspTable[FRICATION_POSITION] =
	DSPFloatToFix24(scaledPosition(parameterTable[FRIC_POS]));

    /*  CALCULATE FRICATION CENTER FREQUENCY AS FRACTION OF SR  */
    dspTable[CENTER_FREQUENCY] =
	DSPFloatToFix24(scaledFrequency(parameterTable[FRIC_CF]));

    /*  CALCULATE FRICATION BANDWIDTH AS A FRACTION OF SR  */
    dspTable[BANDWIDTH] = 
	DSPFloatToFix24(scaledFrequency(parameterTable[FRIC_BW]));

    /*  CALCULATE PHARYNX SCATTERING JUNCTION COEFFICIENTS  */
    dspTable[OPC_1] =
	DSPFloatToFix24(scatteringCoefficient(parameterTable[R1],
					      parameterTable[R2]));
    dspTable[OPC_2] =
	DSPFloatToFix24(scatteringCoefficient(parameterTable[R2],
					      parameterTable[R3]));
    dspTable[OPC_3] =
	DSPFloatToFix24(scatteringCoefficient(parameterTable[R3],
					      parameterTable[R4]));

    /*  CALCULATE 3-WAY JUNCTION COEFFICIENTS  */
    alphaCoefficients(parameterTable[R4], parameterTable[R4],
		      parameterTable[VELUM], &alpha0, &alpha1, &alpha2);
    dspTable[ALPHA_L] = DSPFloatToFix24(alpha0);
    dspTable[ALPHA_R] = DSPFloatToFix24(alpha1);
    dspTable[ALPHA_T] = DSPFloatToFix24(alpha2);

    /*  CALCULATE ORAL CAVITY SCATTERING JUNCTION COEFFICIENTS  */
    dspTable[OPC_4] =
	DSPFloatToFix24(scatteringCoefficient(parameterTable[R4],
					      parameterTable[R5]));
    dspTable[OPC_5] =
	DSPFloatToFix24(scatteringCoefficient(parameterTable[R5],
					      parameterTable[R6]));
    dspTable[OPC_6] =
	DSPFloatToFix24(scatteringCoefficient(parameterTable[R6],
					      parameterTable[R7]));
    dspTable[OPC_7] =
	DSPFloatToFix24(scatteringCoefficient(parameterTable[R7],
					      parameterTable[R8]));

    /*  CALCULATE COEFFICIENTS FOR JUNCTION AT MOUTH  */
    reflectionCoefficient = endCoefficient(parameterTable[R8]);
    dspTable[OPC_REFL] = DSPFloatToFix24(reflectionCoefficient);
    dspTable[OPC_RAD] = DSPFloatToFix24(reflectionCoefficient + 1.0);

    /*  CALCULATE JUNCTION BETWEEN THE VELUM AND FIRST NOSE SECTION  */
    dspTable[NC_1] =
	DSPFloatToFix24(n0Coefficient(parameterTable[VELUM]));
}



/******************************************************************************
*
*	function:	new_dsp_pad_table
*
*	purpose:	Allocates a pad table (silence).
*
*       arguments:      silenceParameterTable - user-supplied table of
*                           control-rate parameters which represent the
*                           "silence" phone (i.e. ^ or #)
*
*	internal
*	functions:	convert_parameter_table
*
*	library
*	functions:	calloc, DSPIntToFix24
*
******************************************************************************/

DSPFix24 *new_dsp_pad_table(float silenceParameterTable[])
{
    int i;
    DSPFix24 *data_table;

    
    /*  ALLOCATE MEMORY FOR DATA TABLE  */
    data_table = (DSPFix24 *)calloc(DATA_TABLE_SIZE, sizeof(DSPFix24));
    if (data_table == NULL)
	return(NULL);

    /*  CONVERT DEFAULTS TO OUTPUT DSP TABLE  */
    convert_parameter_table(silenceParameterTable, (void *)data_table);
    
    /*  SET BALANCE OF TABLE TO ZERO  */
    for (i = DSP_CR_PARAMETERS; i < DATA_TABLE_SIZE; i++)
	data_table[i] = DSPIntToFix24(0);
    
    /*  RETURN THE NEWLY CREATED TABLE  */
    return(data_table);
}



/******************************************************************************
*
*	function:	new_dsp_default_table
*
*	purpose:	Allocates a default table which can be sent to the
*                       dsp.  Produces an "aw" sound.
*
*       arguments:      none
*
*	internal
*	functions:	convert_parameter_table
*
*	library
*	functions:	calloc, DSPIntToFix24
*
******************************************************************************/

DSPFix24 *new_dsp_default_table(void)
{
    int i;
    DSPFix24 *data_table;
    float parameterTable[INPUT_CR_TABLE_SIZE] =
	{GLOT_PITCH_DEF, GLOT_VOL_DEF, ASP_VOL_DEF, FRIC_VOL_DEF, FRIC_POS_DEF,
	 FRIC_CF_DEF, FRIC_BW_DEF, R1_DEF, R2_DEF, R3_DEF, R4_DEF, R5_DEF,
	 R6_DEF, R7_DEF, R8_DEF, VELUM_DEF};

    
    /*  ALLOCATE MEMORY FOR DATA TABLE  */
    data_table = (DSPFix24 *)calloc(DATA_TABLE_SIZE, sizeof(DSPFix24));
    if (data_table == NULL)
	return(NULL);

    /*  CONVERT DEFAULTS TO OUTPUT DSP TABLE  */
    convert_parameter_table(parameterTable, (void *)data_table);
    
    /*  SET BALANCE OF TABLE TO ZERO  */
    for (i = DSP_CR_PARAMETERS; i < DATA_TABLE_SIZE; i++)
	data_table[i] = DSPIntToFix24(0);
    
    /*  RETURN THE NEWLY CREATED TABLE  */
    return(data_table);
}

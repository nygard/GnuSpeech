/*  REVISION INFORMATION  *****************************************************

_Author: fedor $
_Date: 2002/12/15 05:05:11 $
_Revision: 1.2 $
_Source: /cvsroot/gnuspeech/gnuspeech/trillium/ObjectiveC/Monet/tube_module/ttsSnddriver.c,v $
_State: Exp $


_Log: ttsSnddriver.c,v $
Revision 1.2  2002/12/15 05:05:11  fedor
Port to Openstep and GNUstep

Revision 1.1  2002/03/21 16:49:47  rao
Initial import.

 * Revision 1.1  1995/02/27  17:29:32  len
 * Added support for Intel MultiSound DSP.  Module now compiles FAT.
 *

******************************************************************************/

/******************************************************************************
*
*     ttsSnddriver.c
*     
*     Intel replacement code for snddriver functions.  Serves as an interface
*     to the Music Kit DSP driver.
*
******************************************************************************/


#if i386
/*  HEADER FILES  ************************************************************/
#import "ttsSnddriver.h"
#import <dsp/dsp.h>
#import <dsp/dspdriverAccess.h>


/*  LOCAL DEFINES  ***********************************************************/
#define NO                       0
#define YES                      1

#define PORT_OWNER               1
#define PORT_DEVICE              2
#define PORT_COMMAND             3
#define PORT_STREAM_TO_DSP       4
#define PORT_STREAM_FROM_DSP     5
#define PORT_STREAM_DSP_TO_DAC   6

#define WRITE_STARTED            1
#define WRITE_COMPLETED          2
#define READ_COMPLETED           3



/*  LOCAL TYPEDEFS  **********************************************************/
typedef struct {
    msg_header_t  h;
    msg_type_t    t;
    int           regionTag;
} SimpleMessage;

typedef struct {
    msg_header_t  h;
    msg_type_t    t1;
    int           regionTag;
    int           nbytes;
    msg_type_t    t2;
    short         *data;
} DataMessage;



/*  GLOBAL VARIABLES (LOCAL TO THIS FILE)  ***********************************/
static int dspId;
static int streamFromDSPWordCount;




/******************************************************************************
*
*	function:	ttsSNDAcquire
*
*	purpose:	Intel replacement for NeXT SNDAcquire function.
*                       Acquires control of DSP/Sound devices.
*			
*       arguments:      access_code - bitwise or of desired devices
*                       priority - not used
*                       preempt - not used
*                       timeout - not used
*                       negotiation_function - not used
*                       arg - not used
*                       device_port - port which controls devices
*                       owner_port - port which owns DSP/Sound devices
*                       
*	internal
*	functions:	none
*
*	library
*	functions:	DSPOpenNoBoot, DSPGetCurrentDSP, dsp_putArray,
*                       DSPSetHF0, usleep, DSPClearHF0, 
*
******************************************************************************/

int ttsSNDAcquire(int access_code, int priority, int preempt, int timeout,
		  SNDNegotiationFun negotiation_function, void *arg,
		  port_t *device_port, port_t *owner_port)
{
    #include "bootstrap.h"   /*  BOOTSTRAP CODE  */
    #include "loader.h"      /*  LOADER CODE  */


    /*  OPEN DSP IF POSSIBLE, RETURNING ERROR IF ALREADY IN USE  */
    if (DSPOpenNoBoot())
	return(SND_ERR_CANNOT_ACCESS);

    /*  GET THE ID OF THE OPENED DSP  */
    dspId = DSPGetCurrentDSP();

    /*  LOAD THE BOOTSTRAP CODE (LITTLE-ENDIAN) INTO THE DSP  */
    dsp_putArray(dspId, bootstrapCore, bootstrapCoreSize);

    /*  TURN OFF THE BOOTSTRAP LOAD, AND THEN CLEAR THE PAUSED MODE  */
    DSPSetHF0();
    [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:(1)/1000000.0]];
    DSPClearHF0();

    /*  LOAD THE LOADER CODE (LITTLE-ENDIAN) INTO HIGH MEMORY  */
    dsp_putArray(dspId, loaderCore, loaderCoreSize);

    /*  CREATE PORTS (THESE AREN'T REAL PORTS, BUT WE FAKE NUMERIC ID'S)  */
    *device_port = PORT_DEVICE;
    *owner_port = PORT_OWNER;

    return(SND_ERR_NONE);
}



/******************************************************************************
*
*	function:	ttsSNDRelease
*
*	purpose:	Intel replacement for NeXT SNDRelease function.
*                       Releases control of DSP/Sound devices.
*			
*       arguments:      access_code - bitwise or of desired devices
*                       device_port - port which controls devices
*                       owner_port - port which owns DSP/Sound devices
*                       
*	internal
*	functions:	none
*
*	library
*	functions:	DSPClose
*
******************************************************************************/

int ttsSNDRelease(int access_code, port_t device_port, port_t owner_port)
{
    /*  MAKE SURE THAT THE PORTS ARE VALID  */
    if ((device_port != PORT_DEVICE) || (owner_port != PORT_OWNER))
        return(SND_ERR_CANNOT_ACCESS);

    /*  RESET PORT FAKE NUMERIC ID'S (LIKE DEALLOCATING A PORT)  */
    device_port = owner_port = 0;
 
    /*  SHUT DOWN THE DSP  */
    DSPClose();

    return(SND_ERR_NONE);
}



/******************************************************************************
*
*	function:	ttsSNDBootDSP
*
*	purpose:	Intel replacement for NeXT SNDBootDSP function.
*                       Boots the DSP with the user code contained in the
*                       dspCore Sound Struct.
*			
*       arguments:      device_port - device port already acquired
*                       owner_port - owner port already acquired
*                       dspCore - the Sound Struct which contains the
*                                 DSP user code
*                       
*	internal
*	functions:	none
*
*	library
*	functions:	NXSwapBigIntToHost, calloc, dsp_putArray, cfree
*
******************************************************************************/

int ttsSNDBootDSP(port_t device_port, port_t owner_port,
		  SNDSoundStruct *dspCore)
{
    int i, numberWords, *core, *wordPtr;

    int magic = NSSwapBigIntToHost(dspCore->magic);
    int dataLocation = NSSwapBigIntToHost(dspCore->dataLocation);
    int dataSize = NSSwapBigIntToHost(dspCore->dataSize);
    int dataFormat = NSSwapBigIntToHost(dspCore->dataFormat);


    /*  MAKE SURE THAT THE PORTS ARE VALID  */
    if ((device_port != PORT_DEVICE) || (owner_port != PORT_OWNER))
        return(SND_ERR_CANNOT_ACCESS);

    /*  MAKE SURE WE HAVE A SOUND OBJECT  */
    if (magic != 0x2E736E64)
        return(SND_ERR_NOT_SOUND);

    /*  MAKE SURE THAT THE FORMAT IS DSPCORE  */
    if (dataFormat != SND_FORMAT_DSP_CORE)
	return(SND_ERR_BAD_FORMAT);

    /*  CALCULATE NUMBER OF WORDS TO SEND (EXCLUDE 8 WORD HEADER)  */
    numberWords = (dataSize / 4) - 8;

    /*  ALLOCATE A BUFFER TO HOLD SWAPPED CORE WORDS  */
    core = (int *)calloc((numberWords+1),sizeof(int));

    /*  CALCULATE START POINT OF DATA (AFTER 8 WORD HEADER)  */
    wordPtr = (int *)((char *)dspCore + dataLocation) + 8;

    /*  CHANGE BIG-ENDIAN WORDS TO LITTLE-ENDIAN  */
    for (i = 0; i < numberWords; i++, wordPtr++)
        core[i] = NSSwapBigIntToHost(*wordPtr);

    /*  ADD A ZERO WORD, TO SIGNAL THAT THE LOAD IS OVER  */
    core[numberWords] = 0;

    /*  SEND THE PROGRAM TO THE DSP, WHERE PUT INTO PLACE BY LOADER.ASM  */
    dsp_putArray(dspId, core, (numberWords+1));

    /*  FREE THE ALLOCATED MEMORY  */
    cfree((char *)core);

    /*  IF HERE, WE'VE BOOTED USER CODE SUCCESSFULLY  */
    return(SND_ERR_NONE);
}



/******************************************************************************
*
*	function:	tts_snddriver_get_dsp_cmd_port
*
*	purpose:	Intel replacement for NeXT snddriver_get_dsp_cmd_port
*                       function.
*			
*       arguments:      devicePort - device port already acquired
*                       ownerPort - owner port already acquired
*                       commandPort - command port returned
*
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

kern_return_t
tts_snddriver_get_dsp_cmd_port(port_t devicePort, port_t ownerPort,
			       port_t *commandPort)
{
    /*  MAKE SURE THAT THE PORTS ARE VALID  */
    if ((devicePort != PORT_DEVICE) && (ownerPort != PORT_OWNER))
        return(KERN_NO_ACCESS);

    /*  CREATE PORT (THIS ISN'T A REAL PORT, BUT WE FAKE A NUMERIC ID)  */
    *commandPort = PORT_COMMAND;

    return(KERN_SUCCESS);
}



/******************************************************************************
*
*	function:	tts_snddriver_dsp_host_cmd
*
*	purpose:	Intel replacement for NeXT snddriver_dsp_host_cmd
*                       function.  Executes a host command on the DSP.
*			
*       arguments:      commandPort - command port already acquired
*                       hostCommand - host command to be executed
*                       priority - priority level of the command
*
*	internal
*	functions:	none
*
*	library
*	functions:	DSPHostCommand
*
******************************************************************************/

kern_return_t
tts_snddriver_dsp_host_cmd(port_t commandPort, u_int hostCommand,
			   u_int priority)
{
    /*  MAKE SURE THAT THE PORT IS VALID  */
    if (commandPort != PORT_COMMAND)
        return(KERN_NO_ACCESS);

    return(DSPHostCommand(hostCommand));
}



/******************************************************************************
*
*	function:	tts_snddriver_dsp_write
*
*	purpose:	Intel replacement for the NeXT snddriver_dsp_write
*                       function.  Writes data buffer to the DSP.
*			
*       arguments:      commandPort - command port already acquired
*                       buffer - pointer to the data to be transferred
*                       elementCount - number of items in the data buffer
*                       elementSize - number of bytes in each data element
*                       priority - priority level of the command
*
*	internal
*	functions:	none
*
*	library
*	functions:	dsp_putByteArray, dsp_putShortArray, dsp_putArray
*
******************************************************************************/

kern_return_t
tts_snddriver_dsp_write(port_t commandPort, void *buffer, int elementCount,
			int elementSize, int priority)
{
    /*  MAKE SURE THAT THE PORT IS VALID  */
    if (commandPort != PORT_COMMAND)
        return(KERN_NO_ACCESS);

    /*  WRITE THE DATA TO THE DSP  */
    switch(elementSize) {
      case 1:
	dsp_putByteArray(dspId, (char *)buffer, elementCount);
	break;
      case 2:
	dsp_putShortArray(dspId, (short *)buffer, elementCount);
	break;
      case 4:
	dsp_putArray(dspId, (int *)buffer, elementCount);
	break;
      default:
        return(KERN_FAILURE);
	break;
    }

    return(KERN_SUCCESS);
}



/******************************************************************************
*
*	function:	tts_snddriver_stream_setup
*
*	purpose:	Intel replacement for the NeXT snddriver_stream_setup
*                       function.  Sets up streams to and from the DSP.
*			
*       arguments:      devicePort - device port already acquired
*                       ownerPort - owner port already acquired
*                       dataPath - path for the stream being set up
*                       sampleCount - size of buffers used in stream transfer
*                       sampleSize - size in bytes of each data element
*                       lowWater - ignored
*                       highWater - ignored
*                       protocol - ignored
*                       streamPort - returned port which represent the stream
*
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

kern_return_t
tts_snddriver_stream_setup(port_t devicePort, port_t ownerPort, int dataPath,
			   int sampleCount, int sampleSize, int lowWater,
			   int highWater, int *protocol, port_t *streamPort)
{
    /*  MAKE SURE THAT THE PORTS ARE VALID  */
    if ((devicePort != PORT_DEVICE) && (ownerPort != PORT_OWNER))
        return(KERN_NO_ACCESS);


    if (dataPath == SNDDRIVER_DMA_STREAM_TO_DSP) {
        *streamPort = PORT_STREAM_TO_DSP;
    }
    else if (dataPath == SNDDRIVER_DMA_STREAM_FROM_DSP) {
        *streamPort = PORT_STREAM_FROM_DSP;
	streamFromDSPWordCount = sampleCount;
    }
    else if (dataPath == SNDDRIVER_STREAM_DSP_TO_SNDOUT_44) {
        *streamPort = PORT_STREAM_DSP_TO_DAC;
    }
    else if (dataPath == SNDDRIVER_STREAM_DSP_TO_SNDOUT_22) {
        *streamPort = PORT_STREAM_DSP_TO_DAC;
    }
    else {
        *streamPort = 0;
        return(KERN_FAILURE);
    }

    return(KERN_SUCCESS);
}



/******************************************************************************
*
*	function:	tts_snddriver_dsp_protocol
*
*	purpose:	Intel replacement for NeXT snddriver_dsp_protocol
*                       function.  Does nothing.
*			
*       arguments:      devicePort - device port already assigned
*                       ownerPort - owner port alread assigned
*                       protocol - ignored
*
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

kern_return_t
tts_snddriver_dsp_protocol(port_t devicePort, port_t ownerPort, int protocol)
{
    /*  MAKE SURE THAT THE PORTS ARE VALID  */
    if ((devicePort != PORT_DEVICE) && (ownerPort != PORT_OWNER))
        return(KERN_NO_ACCESS);

    return(KERN_SUCCESS);
}



/******************************************************************************
*
*	function:	tts_snddriver_set_ramp
*
*	purpose:	Intel replacement for the NeXT snddriver_set_ramp
*                       function.  Does nothing.
*			
*       arguments:      devicePort - device port already assigned
*                       rampOn - ignored
*
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

kern_return_t
tts_snddriver_set_ramp(port_t devicePort, int rampOn)
{
    /*  MAKE SURE THAT THE PORT IS VALID  */
    if (devicePort != PORT_DEVICE)
        return(KERN_NO_ACCESS);

    return(KERN_SUCCESS);
}



/******************************************************************************
*
*	function:	tts_snddriver_set_sndout_bufsize
*
*	purpose:	Intel replacement for the NeXT
*                       snddriver_set_sndout_bufsize function.  Does nothing.
*			
*       arguments:      devicePort - device port already acquired
*                       sndoutPort - ignored
*                       size - ignored
*
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

kern_return_t
tts_snddriver_set_sndout_bufsize(port_t devicePort, port_t sndoutPort,
				 int size)
{
    /*  MAKE SURE THAT THE PORT IS VALID  */
    if (devicePort != PORT_DEVICE)
        return(KERN_NO_ACCESS);

    return(KERN_SUCCESS);
}



/******************************************************************************
*
*	function:	tts_snddriver_stream_control
*
*	purpose:	Intel replacement for the NeXT snddriver_stream_control
*                       function.  Turns driver messaging mode off or on.
*			
*       arguments:      streamPort - stream port already acquired
*                       regionTag - ignored
*                       control - pause or resume the stream
*
*	internal
*	functions:	none
*
*	library
*	functions:	dsp_setMessaging
*
******************************************************************************/

kern_return_t
tts_snddriver_stream_control(port_t streamPort, int regionTag, int control)
{
    if (streamPort == PORT_STREAM_TO_DSP) {
        if (control == SNDDRIVER_PAUSE_STREAM) {
	    /*  TURN MESSAGING MODE ON IN DRIVER  */
	    dsp_setMessaging(dspId, NO);

	    return(KERN_SUCCESS);
	}
	else if (control == SNDDRIVER_RESUME_STREAM) {
	    /*  TURN MESSAGING MODE OFF IN DRIVER  */
	    dsp_setMessaging(dspId, YES);

	    return(KERN_SUCCESS);
	}
	else
	    return(KERN_FAILURE);
    }
    else if (streamPort == PORT_STREAM_FROM_DSP) {
        if (control == SNDDRIVER_PAUSE_STREAM) {
	    return(KERN_SUCCESS);
	}
	else if (control == SNDDRIVER_RESUME_STREAM) {
	    return(KERN_SUCCESS);
	}
	else
	    return(KERN_FAILURE);
    }

    /*  IF HERE, UNRECOGNIZED STREAM PORT  */
    return(KERN_FAILURE);
}



/******************************************************************************
*
*	function:	tts_snddriver_stream_start_writing
*
*	purpose:	Replacement for the NeXT snddriver_stream_start_writing
*                       function.  Queues a page of data in the driver for
*			stream transfer to the DSP.
*
*       arguments:      streamPort - stream port already acquired
*                       data - pointer to vm page containing the data
*                       sampleCount - ignored
*                       regionTag - tag number assigned to the page
*                       preempt - ignored
*                       deallocateWhenDone - ignored
*                       msgStarted - flag for a started message to the reply
*                                    port
*                       msgCompleted - flag for a completed message to the
*                                      reply port
*                       msgAborted - ignored
*                       msgPaused - ignored
*                       msgResumed - ignored
*                       msgUnderrun - ignored
*                       replyPort - port where reply messages are sent to
*
*	internal
*	functions:	none
*
*	library
*	functions:	dsp_queuePage
*
******************************************************************************/

kern_return_t
tts_snddriver_stream_start_writing(port_t streamPort, void *data,
				   int sampleCount, int regionTag,
				   boolean_t preempt,
				   boolean_t deallocateWhenDone,
				   boolean_t msgStarted,
				   boolean_t msgCompleted,
				   boolean_t msgAborted, boolean_t msgPaused,
				   boolean_t msgResumed, boolean_t msgUnderrun,
				   port_t replyPort)
{
    /*  RETURN IMMEDIATELY IF WE CAN'T WRITE TO THIS STREAM  */
    if (streamPort != PORT_STREAM_TO_DSP)
        return(KERN_FAILURE);

    /*  SEND THE PAGE TO THE OUTPUT QUEUE IN THE DRIVER  */
    dsp_queuePage(dspId, (vm_address_t)data, regionTag,	msgStarted,
		  msgCompleted, replyPort);

    return(KERN_SUCCESS);
}



/******************************************************************************
*
*	function:	tts_snddriver_stream_start_reading
*
*	purpose:	Replacement for the NeXT snddriver_stream_start_reading
*                       function.  Tells the driver where to send return data,
*			what size buffers are used, and what tag is used.
*
*       arguments:      streamPort - stream port already acquired
*                       filename - ignored
*                       sampleCount - ignored
*                       regionTag - tag number assigned to the page
*                       msgStarted - ignored
*                       msgCompleted - ignored
*                       msgAborted - ignored
*                       msgPaused - ignored
*                       msgResumed - ignored
*                       msgUnderrun - ignored
*                       replyPort - port where reply messages are sent to
*
*	internal
*	functions:	none
*
*	library
*	functions:	dsp_setShortSwappedReturn
*
******************************************************************************/

kern_return_t
tts_snddriver_stream_start_reading(port_t streamPort, char *filename,
				   int sampleCount, int regionTag,
				   boolean_t msgStarted,
				   boolean_t msgCompleted,
				   boolean_t msgAborted, boolean_t msgPaused,
				   boolean_t msgResumed, boolean_t msgOverrun,
				   port_t replyPort)
{
    /*  RETURN IMMEDIATELY IF WE CAN'T READ FROM THIS STREAM  */
    if (streamPort != PORT_STREAM_FROM_DSP)
        return(KERN_FAILURE);

    /*  TELL THE DRIVER WE EXPECT SWAPPED SHORT INTS TO BE RETURNED
        IN MESSAGES TO THE REPLY PORT  */
    dsp_setShortSwappedReturn(dspId, regionTag, streamFromDSPWordCount,
			      replyPort);

    return(KERN_SUCCESS);
}



/******************************************************************************
*
*	function:	tts_snddriver_reply_handler
*
*	purpose:	Intel replacement for the NeXT snddriver_reply_handler
*                       function.  Invokes appropriate user-supplied function
*			according to the message ID of the received message.
*
*       arguments:      reply - pointer to the mach message
*                       handlers - pointer to a list of handler functions
*                       
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

kern_return_t
tts_snddriver_reply_handler(msg_header_t *reply,
			    snddriver_handlers_t *handlers)
{
    switch (reply->msg_id) {
      case WRITE_STARTED: {
	  /*  INVOKE THE STARTED REPLY HANLDER, IF SET  */
	  if (handlers->started)
	      (*(handlers->started))(handlers->arg,
				     ((SimpleMessage *)reply)->regionTag);
	  break;
      }
      case WRITE_COMPLETED: {
	  /*  INVOKE THE COMPLETED REPLY HANLDER, IF SET  */
	  if (handlers->completed)
	      (*(handlers->completed))(handlers->arg,
				       ((SimpleMessage *)reply)->regionTag);
	  break;
      }
      case READ_COMPLETED: {
	  /*  INVOKE THE RECORDED DATA REPLY HANLDER, IF SET  */
	  if (handlers->recorded_data)
	      (*(handlers->recorded_data))(handlers->arg,
					   ((DataMessage *)reply)->regionTag,
					   ((DataMessage *)reply)->data,
					   ((DataMessage *)reply)->nbytes);
	  break;
      }
      default:
	  return(KERN_FAILURE);
	  break;
    }

    return(KERN_SUCCESS);
}

#endif

/*  REVISION INFORMATION  *****************************************************

_Author: rao $
_Date: 2002/03/21 16:49:47 $
_Revision: 1.1 $
_Source: /cvsroot/gnuspeech/gnuspeech/trillium/ObjectiveC/Monet/tube_module/ttsSnddriver.h,v $
_State: Exp $


_Log: ttsSnddriver.h,v $
Revision 1.1  2002/03/21 16:49:47  rao
Initial import.

 * Revision 1.1  1995/02/27  17:29:33  len
 * Added support for Intel MultiSound DSP.  Module now compiles FAT.
 *

******************************************************************************/


/*  HEADER FILES  ************************************************************/
#import <sound/accesssound.h>
#import <sound/soundstruct.h>
#import <sound/sounderror.h>
#import <sound/sounddriver.h>
#import <sys/types.h>
#import <mach/cthreads.h>



/*  GLOBAL DEFINES  **********************************************************/
#define SND_ACCESS_OUT        1
#define SND_ACCESS_DSP        2
#define SND_ACCESS_IN         4
#define NULL_NEGOTIATION_FUN  ((SNDNegotiationFun)0)



/*  GLOBAL FUNCTIONS  ********************************************************/
extern int
ttsSNDAcquire(int access_code, int priority, int preempt, int timeout,
	      SNDNegotiationFun negotiation_function, void *arg,
	      port_t *device_port, port_t *owner_port);

extern int
ttsSNDRelease(int access_code, port_t device_port, port_t owner_port);

extern int
ttsSNDBootDSP(port_t device_port, port_t owner_port, SNDSoundStruct *dspCore);

extern kern_return_t
tts_snddriver_get_dsp_cmd_port(port_t devicePort, port_t ownerPort,
			       port_t *commandPort);

extern kern_return_t
tts_snddriver_dsp_host_cmd(port_t commandPort, u_int hostCommand,
			   u_int priority);

extern kern_return_t
tts_snddriver_get_dsp_cmd_port(port_t devicePort, port_t ownerPort,
			       port_t *commandPort);

extern kern_return_t
tts_snddriver_dsp_write(port_t commandPort, void *buffer, int elementCount,
			int elementSize, int priority);

extern kern_return_t
tts_snddriver_stream_setup(port_t devicePort, port_t ownerPort, int dataPath,
			   int sampleCount, int sampleSize, int lowWater,
			   int highWater, int *protocol, port_t *streamPort);

extern kern_return_t
tts_snddriver_dsp_protocol(port_t devicePort, port_t ownerPort,	int protocol);

extern kern_return_t
tts_snddriver_set_ramp(port_t devicePort, int rampOn);

extern kern_return_t
tts_snddriver_set_sndout_bufsize(port_t devicePort,port_t sndoutPort,
				 int size);

extern kern_return_t
tts_snddriver_dsp_protocol(port_t devicePort, port_t ownerPort,	int protocol);

extern kern_return_t
tts_snddriver_stream_control(port_t streamPort, int regionTag, int control);

extern kern_return_t
tts_snddriver_stream_start_writing(port_t streamPort, void *data,
				   int sampleCount, int regionTag,
				   boolean_t preempt,
				   boolean_t deallocateWhenDone,
				   boolean_t msgStarted,
				   boolean_t msgCompleted,
				   boolean_t msgAborted, boolean_t msgPaused,
				   boolean_t msgResumed, boolean_t msgUnderrun,
				   port_t replyPort);

extern kern_return_t
tts_snddriver_stream_start_reading(port_t streamPort, char *filename,
				   int sampleCount, int regionTag,
				   boolean_t msgStarted,
				   boolean_t msgCompleted,
				   boolean_t msgAborted, boolean_t msgPaused,
				   boolean_t msgResumed, boolean_t msgOverrun,
				   port_t replyPort);

extern kern_return_t
tts_snddriver_reply_handler(msg_header_t *reply,
			    snddriver_handlers_t *handlers);

/*  LOCAL DEFINES  ***********************************************************/
#define INITIAL_SEED     0.7892347
#define FACTOR           377.0


/*  GLOBAL VARIABLES (LOCAL TO THIS FILE)  ***********************************/
static float pitchDeviation = 0.0, pitchOffset = 0.0;
static float seed = INITIAL_SEED;
static float a0 = 0.0, b1 = 0.0, previousSample = 0.0;



/******************************************************************************
*
*	function:	setDriftGenerator
*
*	purpose:	Sets the parameters of the drift generator.
*
*       arguments:      deviation - the amount of drift in semitones above
*                            and below the median.  A value around 1 or
*                            so should give good results.
*                       sampleRate - the rate of the system in Hz---this
*                            should be the same as the control rate (250 Hz).
*                       lowpassCutoff - the cutoff in Hz of the lowpass filter
*                            applied to the noise generator.  This value must
*                            range from 0 Hz to nyquist.  A low value around
*                            1 - 4 Hz should give good results.
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

void setDriftGenerator(float deviation, float sampleRate, float lowpassCutoff)
{
    /*  SET PITCH DEVIATION AND OFFSET VARIABLES  */
    pitchDeviation = deviation * 2.0;
    pitchOffset = deviation;

    /*  CHECK RANGE OF THE LOWPASS CUTOFF ARGUMENT  */
    if (lowpassCutoff < 0.0)
	lowpassCutoff = 0.0;
    else if (lowpassCutoff > (sampleRate / 2.0))
	lowpassCutoff = sampleRate / 2.0;

    /*  SET THE FILTER COEFFICIENTS  */
    a0 = (lowpassCutoff * 2.0) / sampleRate;
    b1 = 1.0 - a0;

    /*  CLEAR THE PREVIOUS SAMPLE MEMORY  */
    previousSample = 0.0;
}



/******************************************************************************
*
*	function:	drift
*
*	purpose:	Returns one sample of the drift signal.
*
*       arguments:      none
*
*	internal
*	functions:	none
*
*	library
*	functions:	none
*
******************************************************************************/

float drift(void)
{
    float temp;

    /*  CREATE RANDOM NUMBER BETWEEN 0 AND 1  */
    temp = seed * FACTOR;
    seed = temp - (int)temp;  /* SEED IS SAVED FOR NEXT INVOCATION  */

    /*  CREATE RANDOM SIGNAL WITH RANGE -DEVIATION TO +DEVIATION  */
    temp = (seed * pitchDeviation) - pitchOffset;

    /*  LOWPASS FILTER THE RANDOM SIGNAL (OUTPUT IS SAVED FOR NEXT TIME)  */
    return previousSample = (a0 * temp) + (b1 * previousSample);
}

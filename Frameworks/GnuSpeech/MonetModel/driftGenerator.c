//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright (c) 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

/*  LOCAL DEFINES  ***********************************************************/
#define INITIAL_SEED     0.7892347
#define FACTOR           377.0


/*  GLOBAL VARIABLES (LOCAL TO THIS FILE)  ***********************************/
static float pitchDeviation = 0.0;
static float pitchOffset    = 0.0;
static float seed           = INITIAL_SEED;
static float a0             = 0.0;
static float b1             = 0.0;
static float previousSample = 0.0;



/******************************************************************************
*
* purpose:	Sets the parameters of the drift generator.
*
* arguments: deviation     - the amount of drift in semitones above and below the median.  A value around 1 or so should give good results.
*
*            sampleRate    - the rate of the system in Hz--this should be the same as the control rate (250 Hz).
*
*            lowpassCutoff - the cutoff in Hz of the lowpass filter applied to the noise generator.  This value must
*                            range from 0 Hz to Nyquist.  A low value around 1 - 4 Hz should give good results.
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


// Returns one sample of the drift signal.

float drift(void)
{
    static NSUInteger count = 0;
    float temp;

    /*  CREATE RANDOM NUMBER BETWEEN 0 AND 1  */
    temp = seed * FACTOR;
    seed = temp - (int32_t)temp;  /* SEED IS SAVED FOR NEXT INVOCATION  */

    /*  CREATE RANDOM SIGNAL WITH RANGE -DEVIATION TO +DEVIATION  */
    temp = (seed * pitchDeviation) - pitchOffset;

    /*  LOWPASS FILTER THE RANDOM SIGNAL (OUTPUT IS SAVED FOR NEXT TIME)  */
    previousSample = (a0 * temp) + (b1 * previousSample);
    NSLog(@"%10lu: drift() = %f", count++, previousSample);
    
    return previousSample;
}

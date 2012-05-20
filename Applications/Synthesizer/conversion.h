//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

/*  GLOBAL FUNCTIONS *********************************************************/
extern double frequency(double pitch);
extern double Pitch(double frequency);
extern float normalizedPitch(int semitones, int cents);
extern float scaledVolume(float decibel_level);
extern double amplitude2(double decibelLevel);

/*  GLOBAL DEFINES  **********************************************************/
#define VOLUME_MIN        0
#define VOLUME_MAX        60
#define VOLUME_DEF        60

#define PITCH_BASE        220.0
#define PITCH_OFFSET      3           /*  MIDDLE C = 0  */
#define LOG_FACTOR        3.32193

#define AMPLITUDE_SCALE       64.0        /*  DIVISOR FOR AMPLITUDE SCALING  */
#define CROSSMIX_FACTOR_SCALE 32.0  /*  DIVISOR FOR CROSSMIX_FACTOR SCALING  */
#define POSITION_SCALE        8.0    /*  DIVISOR FOR FRIC. POSITION SCALING  */


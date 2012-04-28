/*******************************************************************************
 *
 *  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
 *
 *  Contributors: David Hill
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License     
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *******************************************************************************
 *
 *  structs.h
 *  Synthesizer
 *
 *  Created by David Hill on 3/29/06.
 *
 *  Version: 0.7.4
 *
 ******************************************************************************/

#include <sys/param.h>


#define TOTAL_NASAL_SECTIONS 6
//#define MAXPATHLEN 255
#define TOTAL_REGIONS 8
#define FALSE 0
#define TABLE_LENGTH              512
#define TEMPERATURE_DEF		32.0
#define GLOT_PITCH_DEF 0.0
#define GLOT_VOL_DEF 60



/*  DATA TYPES  **************************************************************/


/*  GLOBAL VARIABLES *********************************************************/

/*  COMMAND LINE ARGUMENT VARIABLES  */
int verbose;
char inputFile[MAXPATHLEN+1];
char outputFile[MAXPATHLEN+1];

//Global declaration of tube signal accumulator
double gsignal;
int run;

// Envelope data for spectrograph
float *envelopeData;

/*  INPUT VARIABLES  */
TRMSoundFileFormat outputFileFormat;   //  file format (0=AU, 1=AIFF, 2=WAVE)
float  outputRate;                  /*  output sample rate (22.05, 44.1 KHz)  */
//float  controlRate;                 /*  1.0-1000.0 input tables/second (Hz)  */

double volume;                      /*  master volume (0 - 60 dB)  */
int    channels;                    /*  # of sound output channels (1, 2)  */
double balance;                     /*  stereo balance (-1 to +1)  */

int    waveform;                    /*  GS waveform type (0=PULSE, 1=SINE)  */

double tp;                          /*  % glottal pulse rise time  */
double tnMin;                       /*  % glottal pulse fall time minimum  */
double tnMax;                       /*  % glottal pulse fall time maximum  */
double breathiness;                 /*  % glottal source breathiness  */

double length;                      /*  nominal tube length (10 - 20 cm)  */
//double temperature;                 /*  tube temperature (25 - 40 C)  */
double lossFactor;                  /*  junction loss factor in (0 - 5 %)  */

double apScale;                     /*  aperture scl. radius (3.05 - 12 cm)  */
double mouthCoef;                   /*  mouth aperture coefficient  */
double noseCoef;                    /*  nose aperture coefficient  */

double noseRadius[TOTAL_NASAL_SECTIONS];  /*  fixed nose radii (0 - 3 cm)  */
double noseRadiusOriginalDefaults[TOTAL_NASAL_SECTIONS];  /*  fixed nose radii (0 - 3 cm)  */

double throatCutoff;                /*  throat lp cutoff (50 - nyquist Hz)  */
double throatVol;                   /*  throat volume (0 - 48 dB) */

int    modulation;                  /*  pulse mod. of noise (0=OFF, 1=ON)  */
double mixOffset;                   /*  noise crossmix offset (30 - 60 dB)  */


/*  DERIVED VALUES  */
int    controlPeriod;
int    sampleRate;
double actualTubeLength;            /*  actual length in cm  */

double dampingFactor;               /*  calculated damping factor  */
double crossmixFactor;              /*  calculated crossmix factor  */

double *tempDoubleWavetable;
float *tempFloatWavetable;
int    tableDiv1;
double wavetable[TABLE_LENGTH];
int    tableDiv2;
double tnLength;
double tnDelta;
double breathinessFactor;

double basicIncrement;

/*  POSITION IN THE WAVETABLE  */
double currentPosition;

/*  GLOTTAL SOURCE OSCILLATOR TABLE VARIABLES  */
//#define TABLE_LENGTH              512
#define TABLE_MODULUS             (TABLE_LENGTH-1)


/*  VARIABLES FOR INTERPOLATION  */
/*
static struct _postureRateParameters
{
    double glotPitch;
    double glotPitchDelta;
    double glotVol;
    double glotVolDelta;
    double aspVol;
    double aspVolDelta;
    double fricVol;
    double fricVolDelta;
    double fricPos;
    double fricPosDelta;
    double fricCF;
    double fricCFDelta;
    double fricBW;
    double fricBWDelta;
    double radius[TOTAL_REGIONS];
    double radiusDelta[TOTAL_REGIONS];
    double velum;
    double velumDelta;
} current;

static struct _postureRateParameters originalDefaults;

*/

//static void *currentPointer;

#define TOTAL_NASAL_COEFFICIENTS  TOTAL_NASAL_SECTIONS
#define TOTAL_ALPHA_COEFFICIENTS  3
#define TOTAL_SECTIONS            10
#define TOTAL_COEFFICIENTS        TOTAL_REGIONS

#define CONTROL_RATE          100.0

#define CIRC_BUFF_SIZE			2048
#define CIRC_BUFF2_SIZE			8192
#define EMPTY					-1
#define FULL					1
#define OK						0


int _isPlaying;

/* DECLARATION FOR INITIALISE SYNTHESIZER AND UPDATE WAVETABLE */
int initializeSynthesizer();
void updateWavetable(double amplitude);

/*  MEMORY FOR TUBE AND TUBE COEFFICIENTS  */
double oropharynx[TOTAL_SECTIONS][2][2];
double oropharynx_coeff[TOTAL_COEFFICIENTS];

double nasal[TOTAL_NASAL_SECTIONS][2][2];
double nasal_coeff[TOTAL_NASAL_COEFFICIENTS];

double alpha[TOTAL_ALPHA_COEFFICIENTS];
int current_ptr;
int prev_ptr;

/* CIRCULAR BUFFER FOR RECEIVING SAMPLES */
float circBuff[CIRC_BUFF_SIZE];
float *circBuffStart;
float *circBuffInPtr;
float *circBuffOutPtr;
float *circBuffEnd;
int circBuffFlag;
void initCircBuff();
void putCircBuff(float circBuffValue);
float getCircBuff();

/* CIRCULAR BUFFER FOR RECEIVING OUTPUT SAMPLES */
float circBuff2[CIRC_BUFF2_SIZE];
float *circBuff2Start;
float *circBuff2InPtr;
float *circBuff2OutPtr;
float *circBuff2End;
int circBuff2Flag;
int circBuff2Count;
void initCircBuff2();
int putCircBuff2(float circBuffValue);
float getCircBuff2();
void fillAudioBuff(float * buf, int count);

// Variable for synthesize thread PID
pthread_t threadID;


// Detached thread flag

int * getThreadFlag();



void *synthesize();

// FUNCTION TO RETURN MODIFIED BESSEL FUNCTION OF THE FIRST KIND, ORDER 0

double Izero2(double x);



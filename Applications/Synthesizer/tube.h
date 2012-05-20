//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#include <stdio.h>
#include <stdlib.h>
#include <sys/param.h>
#include <math.h>
#include <string.h>
#include "syn_structs.h"
#include "structs2.h"
#include <pthread.h>

/*	FUNCTIONS TO ALLOW OBJECTIVE-C TO ACCESS THE SYNTHESIS VARIABLES  */
void setGlotPitch(float value);
void setGlotVol(float value);
void setAspVol(float value);
void setFricVol(float value);
void setfricPos(float value);
void setFricCF(float value);
void setFricBW(float value);
void setRadius(float value, int index);
void setVelum(float value);
void setVolume(double value);
void setWaveformType(int value);
void setTp(double value);
void setTnMin(double value);
void setTnMax(double value);
void setBreathiness(double value);
void setLength(double value);
void setTemperature(double value);
void setLossFactor(double value);
void setApScale(double value);
void setMouthCoef(double value);
void setNoseCoef(double value);
void setNoseRadius(double value, int index);
void setThroatCoef(double value);
void setModulation(int value);
void setMixOffset(double value);

/*  FUNCTIONS TO ALLOW INTERFACE OBJECTIVE-C ACCESS TO DEFAULT TUBE PARAMETERS  */
double *getGlotPitchDefault();
double *getGlotVolDefault();
double *getAspVolDefault();
double *getFricVolDefault();
double *getFricPosDefault();
double *getFricCFDefault();
double *getFricBWDefault();
double *getRadiusDefault(int index);
double *getVelumRadiusDefault();
double *getVolumeDefault();
double *getBalanceDefault();
int *getWaveformDefault();
double *getTpDefault();
double *getTnMinDefault();
double *getTnMaxDefault();
double *getBreathinessDefault();
double *getLengthDefault();
double *getTemperatureDefault();
double *getLossFactorDefault();
double *getApScaleDefault();
double *getMouthCoefDefault();
double *getNoseCoefDefault();
double *getNoseRadiusDefault(int index);
double *getThroatCutoffDefault();
double *getThroatVolDefault();
int *getModulationDefault();
double *getMixOffsetDefault();

/*  FUNCTIONS TO ALLOW INTERFACE OBJECTIVE-C ACCESS TO TUBE PARAMETERS  */
double *getGlotPitch();
double *getGlotVol();
double *getAspVol();
double *getFricVol();
double *getFricPos();
double *getFricCF();
double *getFricBW();
double *getRadius(int index);
double *getVelumRadius();
double *getVolume();
double *getBalance();
int *getWaveform();
double *getTp();
double *getTnMin();
double *getTnMax();
double *getBreathiness();
double *getLength();
double *getTemperature();
double *getLossFactor();
double *getApScale();
double *getMouthCoef();
double *getNoseCoef();
double *getNoseRadius(int index);
double *getThroatCutoff();
double *getThroatVol();
int *getModulation();
double *getMixOffset();
double *getActualTubeLength();
int *getControlPeriod();
float *getControlRate();
double * getWavetable(int index);
int *getSampleRate();


/*  GLOBAL FUNCTIONS (LOCAL TO THIS FILE)  ***********************************/

void setupInputTables(double glotPitch, double glotVol, double aspVol, double fricVol, double fricPos, double fricCF,
						double fricBW, double *radius, double velum);

//void printInfo(void);
//int parseInputFile(char *inputFile);
//int initializeSynthesizer(void);

void initializeWavetable(void);
double speedOfSound(double temperature);
//void updateWavetable(double amplitude);
void initializeFIR(double beta, double gamma, double cutoff);
double noise(void);
double noiseFilter(double input);
void initializeMouthCoefficients(double coeff);
double reflectionFilter(double input);
double radiationFilter(double input);
void initializeNasalFilterCoefficients(double coeff);
double nasalReflectionFilter(double input);
double nasalRadiationFilter(double input);


void initializeNasalCavity(void);
void initializeThroat(void);
void calculateTubeCoefficients(void);
void setFricationTaps(void);
void calculateBandpassCoefficients(void);
double mod0(double value);
void incrementTablePosition(double frequency);
double oscillator(double frequency);
double vocalTract(double input, double frication);
double throat(double input);
double bandpassFilter(double input);
//void convertIntToFloat80(unsigned int value, unsigned char buffer[10]);
double amplitude(double decibelLevel);
double frequency(double pitch);
int maximallyFlat(double beta, double gamma, int *np, double *coefficient);
void trim(double cutoff, int *numberCoefficients, double *coefficient);
void rationalApproximation(double number, int *order, int *numerator,
			   int *denominator);
double FIRFilter(double input, int needOutput);
int increment(int pointer, int modulus);
int decrement(int pointer, int modulus);
void initializeConversion(void);
void initializeFilter(void);
//double Izero2(double x);
void initializeBuffer(void);
void dataFill(double data);
void dataEmpty(void);
void flushBuffer(void);
void srIncrement(int *pointer, int modulus);
void srDecrement(int *pointer, int modulus);

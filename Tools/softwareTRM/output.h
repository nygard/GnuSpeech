#ifndef __OUTPUT_H
#define __OUTPUT_H

#include <stdio.h>

/*  OUTPUT FILE FORMAT CONSTANTS  */
#define AU_FILE_FORMAT            0
#define AIFF_FILE_FORMAT          1
#define WAVE_FILE_FORMAT          2

extern int outputFileFormat;
extern double volume;
extern int channels;
extern double balance;


void writeOutputToFile(char *fileName);
void writeAuFileHeader(int channels, long int numberSamples,
		       float outputRate, FILE *outputFile);
void writeAiffFileHeader(int channels, long int numberSamples,
			 float outputRate, FILE *outputFile);
void writeWaveFileHeader(int channels, long int numberSamples,
			 float outputRate, FILE *outputFile);
void writeSamplesMonoMsb(FILE *tempFile, long int numberSamples,
			 double scale, FILE *outputFile);
void writeSamplesMonoLsb(FILE *tempFile, long int numberSamples,
			 double scale, FILE *outputFile);
void writeSamplesStereoMsb(FILE *tempFile, long int numberSamples,
			   double leftScale, double rightScale,
			   FILE *outputFile);
void writeSamplesStereoLsb(FILE *tempFile, long int numberSamples,
			   double leftScale, double rightScale,
			   FILE *outputFile);
size_t fwriteIntMsb(int data, FILE *stream);
size_t fwriteIntLsb(int data, FILE *stream);
size_t fwriteShortMsb(int data, FILE *stream);
size_t fwriteShortLsb(int data, FILE *stream);
void convertIntToFloat80(unsigned int value, unsigned char buffer[10]);

#endif

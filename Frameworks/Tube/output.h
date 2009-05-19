/*******************************************************************************
 *
 *  Copyright (c) 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
 *  
 *  Contributors: Steve Nygard
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
 *  output.h
 *  Tube
 *
 *  Version: 1.0
 *
 ******************************************************************************/

#ifndef __OUTPUT_H
#define __OUTPUT_H

#include "structs.h" // For TRMData

/*  OUTPUT FILE FORMAT CONSTANTS  */
#define AU_FILE_FORMAT            0
#define AIFF_FILE_FORMAT          1
#define WAVE_FILE_FORMAT          2

/*  FINAL OUTPUT SCALING, SO THAT .SND FILES APPROX. MATCH DSP OUTPUT  */
//#define OUTPUT_SCALE              0.25
#define OUTPUT_SCALE              1.0

/*  MAXIMUM SAMPLE VALUE  */
#define RANGE_MAX                 32767.0

/*  SIZE IN BITS PER OUTPUT SAMPLE  */
#define BITS_PER_SAMPLE           16


void writeOutputToFile(TRMSampleRateConverter *sampleRateConverter, TRMData *data, const char *fileName);
void convertIntToFloat80(unsigned int value, unsigned char buffer[10]);

void writeAuFileHeader(int channels, long int numberSamples, float outputRate, FILE *outputFile);
size_t fwriteShortMsb(int data, FILE *stream);

#endif

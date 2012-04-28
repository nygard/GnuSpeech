//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#include "output.h"

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include "tube.h"
#include "util.h"

//void writeAuFileHeader(int channels, long int numberSamples, float outputRate, FILE *outputFile);
static void writeAiffFileHeader(int32_t channels, int32_t numberSamples, float outputRate, FILE *outputFile);
static void writeWaveFileHeader(int32_t channels, int32_t numberSamples, float outputRate, FILE *outputFile);
static void writeSamplesMonoMsb(FILE *tempFile, int32_t numberSamples, double scale, FILE *outputFile);
static void writeSamplesMonoLsb(FILE *tempFile, int32_t numberSamples, double scale, FILE *outputFile);
static void writeSamplesStereoMsb(FILE *tempFile, int32_t numberSamples, double leftScale, double rightScale, FILE *outputFile);
static void writeSamplesStereoLsb(FILE *tempFile, int32_t numberSamples, double leftScale, double rightScale, FILE *outputFile);
static size_t fwriteIntMsb(int32_t data, FILE *stream);
static size_t fwriteIntLsb(int32_t data, FILE *stream);
//size_t fwriteShortMsb(int data, FILE *stream);
static size_t fwriteShortLsb(int32_t data, FILE *stream);
//static void convertIntToFloat80(uint32_t value, uint8_t buffer[10]);

// Scales the samples stored in the temporary file, and writes them to the output file, with the appropriate
// header.  Also does master volume scaling, and stereo balance scaling, if 2 channels of output.
void writeOutputToFile(TRMSampleRateConverter *sampleRateConverter, TRMDataList *data, const char *fileName)
{
    //printf("maximumSampleValue: %g\n", sampleRateConverter->maximumSampleValue);
    
    // Calculate scaling constant
    double scale = (TRMSampleValue_Maximum / sampleRateConverter->maximumSampleValue) * amplitude(data->inputParameters.volume);

    /*if (verbose)*/ {
        printf("\nnumber of samples:\t%-d\n", sampleRateConverter->numberSamples);
        printf("maximum sample value:\t%.4f\n", sampleRateConverter->maximumSampleValue);
        printf("scale:\t\t\t%.4f\n", scale);
    }

    // If stereo, calculate left and right scaling constants
    double leftScale = 1.0, rightScale = 1.0;
    if (data->inputParameters.channels == 2) {
		// Calculate left and right channel amplitudes
		leftScale = -((data->inputParameters.balance / 2.0) - 0.5) * scale * 2.0;
		rightScale = ((data->inputParameters.balance / 2.0) + 0.5) * scale * 2.0;

		if (verbose) {
			printf("left scale:\t\t%.4f\n", leftScale);
			printf("right scale:\t\t%.4f\n", rightScale);
		}
    }

    // Rewind the temporary file to beginning
    rewind(sampleRateConverter->tempFilePtr);

    // Open the output file
    FILE *outputFileDescriptor = fopen(fileName, "wb");
    if (outputFileDescriptor == NULL) {
        perror("fopen");
        exit(-1);
    }

    // Scale and write out samples to the output file
    if (data->inputParameters.outputFileFormat == TRMSoundFileFormat_AU) {
        writeAuFileHeader(data->inputParameters.channels, sampleRateConverter->numberSamples, data->inputParameters.outputRate, outputFileDescriptor);
        if (data->inputParameters.channels == 1)
            writeSamplesMonoMsb(sampleRateConverter->tempFilePtr, sampleRateConverter->numberSamples, scale, outputFileDescriptor);
        else
            writeSamplesStereoMsb(sampleRateConverter->tempFilePtr, sampleRateConverter->numberSamples, leftScale, rightScale, outputFileDescriptor);
    } else if (data->inputParameters.outputFileFormat == TRMSoundFileFormat_AIFF) {
        writeAiffFileHeader(data->inputParameters.channels, sampleRateConverter->numberSamples, data->inputParameters.outputRate, outputFileDescriptor);
        if (data->inputParameters.channels == 1)
            writeSamplesMonoMsb(sampleRateConverter->tempFilePtr, sampleRateConverter->numberSamples, scale, outputFileDescriptor);
        else
            writeSamplesStereoMsb(sampleRateConverter->tempFilePtr, sampleRateConverter->numberSamples, leftScale, rightScale, outputFileDescriptor);
    } else if (data->inputParameters.outputFileFormat == TRMSoundFileFormat_WAVE) {
        writeWaveFileHeader(data->inputParameters.channels, sampleRateConverter->numberSamples, data->inputParameters.outputRate, outputFileDescriptor);
        if (data->inputParameters.channels == 1)
            writeSamplesMonoLsb(sampleRateConverter->tempFilePtr, sampleRateConverter->numberSamples, scale, outputFileDescriptor);
        else
            writeSamplesStereoLsb(sampleRateConverter->tempFilePtr, sampleRateConverter->numberSamples, leftScale, rightScale, outputFileDescriptor);
    }

    fclose(outputFileDescriptor);
}

// Writes the header in AU format to the output file.
void writeAuFileHeader(int32_t channels, int32_t numberSamples, float outputRate, FILE *outputFile)
{
    // AU magic string: ".snd"
    fputs(".snd", outputFile);

    // Header size (fixed in size at 28 bytes)
    fwriteIntMsb(28, outputFile);

    // Number of bytes of sound data
    fwriteIntMsb(channels * numberSamples * sizeof(short), outputFile);

    // Sound format:  3 is 16-bit linear
    fwriteIntMsb(3, outputFile);

    // Output sample rate in samples/second
    fwriteIntMsb((int)outputRate, outputFile);

    // Number of channels
    fwriteIntMsb(channels, outputFile);

    // Optional text description (4 bytes minimum)
    fwriteIntMsb(0, outputFile);
}

// Writes the header in AIFF format to the output file.
void writeAiffFileHeader(int32_t channels, int32_t numberSamples, float outputRate, FILE *outputFile)
{
    uint8_t sampleFramesPerSecond[10];
    int32_t soundDataSize = channels * numberSamples * sizeof(uint16_t);
    int32_t ssndChunkSize = soundDataSize + 8;
    int32_t formSize = ssndChunkSize + 8 + 26 + 4;

    // Form container identifier
    fputs("FORM", outputFile);

    // Form size
    fwriteIntMsb(formSize, outputFile);

    // Form container type
    fputs("AIFF", outputFile);

    // Common chunk identifier
    fputs("COMM", outputFile);

    // Chunk size (fixed at 18 bytes)
    fwriteIntMsb(18, outputFile);

    // Number of channels
    fwriteShortMsb((short)channels, outputFile);

    // Number of sample frames
    fwriteIntMsb(numberSamples, outputFile);

    // Number of bits per samples (fixed at 16)
    fwriteShortMsb(TRMBitsPerSample, outputFile);

    // Sample frames per second (output sample rate)
    // stored as an 80-bit (10-byte) float
    convertIntToFloat80((uint32_t)outputRate, sampleFramesPerSecond);
    fwrite(sampleFramesPerSecond, sizeof(uint8_t), 10, outputFile);

    // Sound Data chunk identifier
    fputs("SSND", outputFile);

    // Chunk size
    fwriteIntMsb(ssndChunkSize, outputFile);

    // Offset:  unused, so set to 0
    fwriteIntMsb(0, outputFile);

    // Block size:  unused, so set to 0
    fwriteIntMsb(0, outputFile);
}

// Writes the header in WAVE format to the output file.
void writeWaveFileHeader(int32_t channels, int32_t numberSamples, float outputRate, FILE *outputFile)
{
    int32_t soundDataSize = channels * numberSamples * sizeof(uint16_t);
    int32_t dataChunkSize = soundDataSize;
    int32_t formSize = dataChunkSize + 8 + 24 + 4;
    int32_t frameSize = (int32_t)ceil(channels * ((double)TRMBitsPerSample / 8));
    int32_t bytesPerSecond = (int32_t)ceil(outputRate * frameSize);

    // Form container identifier
    fputs("RIFF", outputFile);

    // Form size
    fwriteIntLsb(formSize, outputFile);

    // Form container type
    fputs("WAVE", outputFile);

    // Format chunk identifier (Note:  space after 't' needed)
    fputs("fmt ", outputFile);

    // Chunk size (fixed at 16 bytes)
    fwriteIntLsb(16, outputFile);

    // Compression code:  1 = PCM
    fwriteShortLsb(1, outputFile);

    // Number of channels
    fwriteShortLsb((short)channels, outputFile);

    // Output Sample Rate
    fwriteIntLsb((int)outputRate, outputFile);

    // Bytes per second
    fwriteIntLsb(bytesPerSecond, outputFile);

    // Block alignment (frame size)
    fwriteShortLsb((short)frameSize, outputFile);

    // Bits per sample
    fwriteShortLsb((short)TRMBitsPerSample, outputFile);

    // Sound Data chunk identifier
    fputs("data", outputFile);

    // Chunk size
    fwriteIntLsb(dataChunkSize, outputFile);
}

// Reads the double f.p. samples in the temporary file, scales them, rounds them to a short (16-bit) integer,
// and writes them to the output file in big-endian format.
void writeSamplesMonoMsb(FILE *tempFile, int32_t numberSamples, double scale, FILE *outputFile)
{
    // Write the samples to file, scaling each sample
    for (int32_t i = 0; i < numberSamples; i++) {
        double sample;

        fread(&sample, sizeof(sample), 1, tempFile);
        fwriteShortMsb((int16_t)rint(sample * scale), outputFile);
        //printf("%8ld: %g -> %hd\n", i, sample, (short)rint(sample * scale));
    }
}

// Reads the double f.p. samples in the temporary file, scales them, rounds them to a short (16-bit) integer,
// and writes them to the output file in little-endian format.
void writeSamplesMonoLsb(FILE *tempFile, int32_t numberSamples, double scale, FILE *outputFile)
{
    // Write the samples to file, scaling each sample
    for (int32_t i = 0; i < numberSamples; i++) {
        double sample;

        fread(&sample, sizeof(sample), 1, tempFile);
        fwriteShortLsb((int16_t)rint(sample * scale), outputFile);
    }
}

// Reads the double f.p. samples in the temporary file, does stereo scaling, rounds them to a short (16-bit)
// integer, and writes them to the output file in big-endian format.
void writeSamplesStereoMsb(FILE *tempFile, int32_t numberSamples, double leftScale, double rightScale, FILE *outputFile)
{
    // Write the samples to file, scaling each sample
    for (int32_t i = 0; i < numberSamples; i++) {
        double sample;

        fread(&sample, sizeof(sample), 1, tempFile);
        fwriteShortMsb((int16_t)rint(sample * leftScale), outputFile);
        fwriteShortMsb((int16_t)rint(sample * rightScale), outputFile);
    }
}

// Reads the double f.p. samples in the temporary file, does stereo scaling, rounds them to a short (16-bit)
// integer, and writes them to the output file in little-endian format.
void writeSamplesStereoLsb(FILE *tempFile, int32_t numberSamples, double leftScale, double rightScale, FILE *outputFile)
{
    // Write the samples to file, scaling each sample
    for (int32_t i = 0; i < numberSamples; i++) {
        double sample;

        fread(&sample, sizeof(sample), 1, tempFile);
        fwriteShortLsb((int16_t)rint(sample * leftScale), outputFile);
        fwriteShortLsb((int16_t)rint(sample * rightScale), outputFile);
    }
}

// Writes a 4-byte integer to the file stream, starting with the most significant byte (i.e. writes the int
// in big-endian form).  This routine will work on both big-endian and little-endian architectures.
size_t fwriteIntMsb(int32_t data, FILE *stream)
{
    uint8_t array[4];

    array[0] = (uint8_t)((data >> 24) & 0xFF);
    array[1] = (uint8_t)((data >> 16) & 0xFF);
    array[2] = (uint8_t)((data >> 8) & 0xFF);
    array[3] = (uint8_t)(data & 0xFF);
    return (fwrite(array, sizeof(uint8_t), 4, stream));
}

// Writes a 4-byte integer to the file stream, starting with the least significant byte (i.e. writes the int
// in little-endian form).  This routine will work on both big-endian and little-endian architectures.
size_t fwriteIntLsb(int32_t data, FILE *stream)
{
    uint8_t array[4];

    array[3] = (uint8_t)((data >> 24) & 0xFF);
    array[2] = (uint8_t)((data >> 16) & 0xFF);
    array[1] = (uint8_t)((data >> 8) & 0xFF);
    array[0] = (uint8_t)(data & 0xFF);
    return (fwrite(array, sizeof(uint8_t), 4, stream));
}

// Writes a 2-byte integer to the file stream, starting with the most significant byte (i.e. writes the int
// in big-endian form).  This routine will work on both big-endian and little-endian architectures.
size_t fwriteShortMsb(int32_t data, FILE *stream)
{
    uint8_t array[2];

    array[0] = (uint8_t)((data >> 8) & 0xFF);
    array[1] = (uint8_t)(data & 0xFF);
    return (fwrite(array, sizeof(uint8_t), 2, stream));
}

// Writes a 2-byte integer to the file stream, starting with the leastt significant byte (i.e. writes the int
// in little-endian form).  This routine will work on both big-endian and little-endian architectures.
size_t fwriteShortLsb(int data, FILE *stream)
{
    uint8_t array[2];

    array[1] = (uint8_t)((data >> 8) & 0xFF);
    array[0] = (uint8_t)(data & 0xFF);
    return (fwrite(array, sizeof(uint8_t), 2, stream));
}

// Converts an unsigned 4-byte integer to an IEEE 754 10-byte (80-bit) floating point number.
void convertIntToFloat80(uint32_t value, uint8_t buffer[10])
{
    uint16_t i;

    // Set all bytes in buffer to 0
    memset(buffer, 0, 10);

    // Calculate the exponent
    uint32_t exp = value;
    for (i = 0; i < 32; i++) {
        exp >>= 1;
        if (!exp)
            break;
    }

    // Add the bias to the exponent
    i += 0x3FFF;

    // Store the exponent
    buffer[0] = (uint8_t)((i >> 8) & 0x7F);
    buffer[1] = (uint8_t)(i & 0xFF);

    // Calculate the mantissa
    for (i = 32; i; i--) {
        if (value & 0x80000000)
            break;
        value <<= 1;
    }

    // Store the mantissa:  this should work on both big-endian and little-endian architectures
    buffer[2] = (uint8_t)((value >> 24) & 0xFF);
    buffer[3] = (uint8_t)((value >> 16) & 0xFF);
    buffer[4] = (uint8_t)((value >> 8) & 0xFF);
    buffer[5] = (uint8_t)(value & 0xFF);
}

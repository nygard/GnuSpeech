//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "TRMSynthesizer.h"

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudio.h>
#import <AudioToolbox/AudioToolbox.h>
#import "MMSynthesisParameters.h"
#include "input.h"
#include "output.h"
#include "tube.h"
#include "util.h"

typedef struct {
    char a, b, c, d;
} MyFourCharCode;

@interface NSString (MyExtensions)
+ (NSString *)stringWithFourCharCode:(unsigned int)code;
@end

@implementation NSString (MyExtensions)
+ (NSString *)stringWithFourCharCode:(unsigned int)code;
{
    MyFourCharCode *charcode = (MyFourCharCode *)(&code);

    return [NSString stringWithFormat:@"%c%c%c%c", charcode->a, charcode->b, charcode->c, charcode->d];
}
@end

int verbose = 0;

OSStatus myInputCallback(void *inRefCon, AudioUnitRenderActionFlags inActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, AudioBuffer *ioData)
{
    [(TRMSynthesizer *)inRefCon fillBuffer:ioData];

    return kAudioHardwareNoError;
}

@implementation TRMSynthesizer

- (id)init;
{
    if ([super init] == nil)
        return nil;

    inputData = (TRMData *)malloc(sizeof(TRMData));
    if (inputData == NULL) {
        NSLog(@"Failed to malloc TRMData.");
        [super release];
        return nil;
    }

    inputData->inputHead = NULL;
    inputData->inputTail = NULL;

    soundData = [[NSMutableData alloc] init];

    [self setupSoundDevice];

    return self;
}

- (void)dealloc;
{
    NSLog(@"%s, free(inputData)", _cmd);
    free(inputData);
    [soundData release];

    [super dealloc];
}

- (void)setupSynthesisParameters:(MMSynthesisParameters *)synthesisParameters;
{
    inputData->inputParameters.outputFileFormat = 0;
    inputData->inputParameters.outputRate = [MMSynthesisParameters samplingRate:[synthesisParameters samplingRate]];
    inputData->inputParameters.controlRate = 250;
    inputData->inputParameters.volume = [synthesisParameters masterVolume];
    inputData->inputParameters.channels = [synthesisParameters outputChannels] + 1;
    inputData->inputParameters.balance = [synthesisParameters balance];
    inputData->inputParameters.waveform = [synthesisParameters glottalPulseShape];
    inputData->inputParameters.tp = [synthesisParameters tp];
    inputData->inputParameters.tnMin = [synthesisParameters tnMin];
    inputData->inputParameters.tnMax = [synthesisParameters tnMax];
    inputData->inputParameters.breathiness = [synthesisParameters breathiness];
    inputData->inputParameters.length = [synthesisParameters vocalTractLength];
    inputData->inputParameters.temperature = [synthesisParameters temperature];
    inputData->inputParameters.lossFactor = [synthesisParameters lossFactor];
    inputData->inputParameters.apScale = [synthesisParameters apertureScaling];
    inputData->inputParameters.mouthCoef = [synthesisParameters mouthCoef];
    inputData->inputParameters.noseCoef = [synthesisParameters noseCoef];
    inputData->inputParameters.noseRadius[0] = 0; // Give it a predictable value.
    inputData->inputParameters.noseRadius[1] = [synthesisParameters n1];
    inputData->inputParameters.noseRadius[2] = [synthesisParameters n2];
    inputData->inputParameters.noseRadius[3] = [synthesisParameters n3];
    inputData->inputParameters.noseRadius[4] = [synthesisParameters n4];
    inputData->inputParameters.noseRadius[5] = [synthesisParameters n5];
    inputData->inputParameters.throatCutoff = [synthesisParameters throatCutoff];
    inputData->inputParameters.throatVol = [synthesisParameters throatVolume];
    inputData->inputParameters.modulation = [synthesisParameters shouldUseNoiseModulation];
    inputData->inputParameters.mixOffset = [synthesisParameters mixOffset];

    {
        char buf[100];

        sprintf(buf, "%f", [MMSynthesisParameters samplingRate:[synthesisParameters samplingRate]]);
        inputData->inputParameters.outputRate = strtod(buf, NULL);

        sprintf(buf, "%f", [synthesisParameters masterVolume]);
        inputData->inputParameters.volume = strtod(buf, NULL);

        sprintf(buf, "%f", [synthesisParameters balance]);
        inputData->inputParameters.balance = strtod(buf, NULL);

        sprintf(buf, "%f", [synthesisParameters tp]);
        inputData->inputParameters.tp = strtod(buf, NULL);

        sprintf(buf, "%f", [synthesisParameters tnMin]);
        inputData->inputParameters.tnMin = strtod(buf, NULL);

        sprintf(buf, "%f", [synthesisParameters tnMax]);
        inputData->inputParameters.tnMax = strtod(buf, NULL);

        sprintf(buf, "%f", [synthesisParameters breathiness]);
        inputData->inputParameters.breathiness = strtod(buf, NULL);

        sprintf(buf, "%f", [synthesisParameters vocalTractLength]);
        inputData->inputParameters.length = strtod(buf, NULL);

        sprintf(buf, "%f", [synthesisParameters temperature]);
        inputData->inputParameters.temperature = strtod(buf, NULL);

        sprintf(buf, "%f", [synthesisParameters lossFactor]);
        inputData->inputParameters.lossFactor = strtod(buf, NULL);

        sprintf(buf, "%f", [synthesisParameters apertureScaling]);
        inputData->inputParameters.apScale = strtod(buf, NULL);

        sprintf(buf, "%f", [synthesisParameters mouthCoef]);
        inputData->inputParameters.mouthCoef = strtod(buf, NULL);

        sprintf(buf, "%f", [synthesisParameters noseCoef]);
        inputData->inputParameters.noseCoef = strtod(buf, NULL);

        sprintf(buf, "%f", [synthesisParameters n1]);
        inputData->inputParameters.noseRadius[1] = strtod(buf, NULL);

        sprintf(buf, "%f", [synthesisParameters n2]);
        inputData->inputParameters.noseRadius[2] = strtod(buf, NULL);

        sprintf(buf, "%f", [synthesisParameters n3]);
        inputData->inputParameters.noseRadius[3] = strtod(buf, NULL);

        sprintf(buf, "%f", [synthesisParameters n4]);
        inputData->inputParameters.noseRadius[4] = strtod(buf, NULL);

        sprintf(buf, "%f", [synthesisParameters n5]);
        inputData->inputParameters.noseRadius[5] = strtod(buf, NULL);

        sprintf(buf, "%f", [synthesisParameters throatCutoff]);
        inputData->inputParameters.throatCutoff = strtod(buf, NULL);

        sprintf(buf, "%f", [synthesisParameters throatVolume]);
        inputData->inputParameters.throatVol = strtod(buf, NULL);

        sprintf(buf, "%f", [synthesisParameters mixOffset]);
        inputData->inputParameters.mixOffset = strtod(buf, NULL);
    }

    {
        OSStatus result;
        UInt32 count;
        AudioStreamBasicDescription format;

        count = sizeof(format);
        result = AudioUnitGetProperty(outputUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &format, &count);
        if (result != kAudioHardwareNoError) {
            NSLog(@"AudioUnitGetProperty() failed.");
            return;
        }

        // It looks like you need to use an AudioConverter to change the sampling rate.
        format.mFormatID = kAudioFormatLinearPCM;
        format.mSampleRate = [MMSynthesisParameters samplingRate:[synthesisParameters samplingRate]];
        format.mFormatFlags = kAudioFormatFlagIsBigEndian | kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
        format.mChannelsPerFrame = [synthesisParameters outputChannels] + 1;
        format.mBytesPerPacket = 2 * format.mChannelsPerFrame;
        format.mFramesPerPacket = 1;
        format.mBytesPerFrame = 2 * format.mChannelsPerFrame;
        format.mBitsPerChannel = 16;

        NSLog(@"sample rate: %f", format.mSampleRate);
        NSLog(@"format id: %08x (%@)", format.mFormatID, [NSString stringWithFourCharCode:format.mFormatID]);
        NSLog(@"format flags: %x", format.mFormatFlags);
        NSLog(@"bytes per packet: %d", format.mBytesPerPacket);
        NSLog(@"frames per packet: %d", format.mFramesPerPacket);
        NSLog(@"bytes per frame: %d", format.mBytesPerFrame);
        NSLog(@"channels per frame: %d", format.mChannelsPerFrame);
        NSLog(@"bits per channel: %d", format.mBitsPerChannel);

        result = AudioUnitSetProperty(outputUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &format, sizeof(format));
        if (result != kAudioHardwareNoError) {
            NSLog(@"AudioUnitSetProperty(StreamFormat) failed: %d %x %@", result, result, [NSString stringWithFourCharCode:result]);
        } else {
            NSLog(@"It worked! (setting the stream data format)");
        }
    }
}

- (void)removeAllParameters;
{
    INPUT *ptr, *next;

    ptr = inputData->inputHead;
    while (ptr != NULL) {
        next = ptr->next;
        free(ptr);
        ptr = next;
    }

    inputData->inputHead = NULL;
    inputData->inputTail = NULL;
}

- (void)addParameters:(float *)values;
{
    double dvalues[16];
    double radius[TOTAL_REGIONS];

    {
        int index;
        char buf[100];

        for (index = 0; index < 16; index++) {
            sprintf(buf, "%.3f", values[index]);
            dvalues[index] = strtod(buf, NULL);
        }
    }

    // TODO (2004-05-07): I don't think the last two are used!
    radius[0] = dvalues[7];
    radius[1] = dvalues[8];
    radius[2] = dvalues[9];
    radius[3] = dvalues[10];
    radius[4] = dvalues[11];
    radius[5] = dvalues[12];
    radius[6] = dvalues[13];
    radius[7] = dvalues[14];
    addInput(inputData, dvalues[0], dvalues[1], dvalues[2], dvalues[3], dvalues[4], dvalues[5], dvalues[6], radius, dvalues[15]);
}

- (void)synthesize;
{
    TRMTubeModel *tube;

    tube = TRMTubeModelCreate(&(inputData->inputParameters));
    if (tube == NULL) {
        NSLog(@"Warning: Failed to create tube model.");
        return;
    }

    synthesize(tube, inputData);
    writeOutputToFile(&(tube->sampleRateConverter), inputData, "/tmp/out.au");

    [self convertSamplesIntoData:&(tube->sampleRateConverter)];
    TRMTubeModelFree(tube);

    [self startPlaying];
}

- (void)synthesizeToSoundFile:(NSString *)filename type:(int)type;
{
    TRMTubeModel *tube;

    inputData->inputParameters.outputFileFormat = type;

    tube = TRMTubeModelCreate(&(inputData->inputParameters));
    if (tube == NULL) {
        NSLog(@"Warning: Failed to create tube model.");
        return;
    }

    synthesize(tube, inputData);
    writeOutputToFile(&(tube->sampleRateConverter), inputData, [filename UTF8String]);
    TRMTubeModelFree(tube);
}

- (void)convertSamplesIntoData:(TRMSampleRateConverter *)sampleRateConverter;
{
    double scale;
    long int index;

    [soundData setLength:0];
    bufferIndex = 0;

    if (sampleRateConverter->maximumSampleValue == 0)
        NSBeep();

    scale = (RANGE_MAX / sampleRateConverter->maximumSampleValue) * amplitude(inputData->inputParameters.volume) ;

    NSLog(@"number of samples:\t%-ld\n", sampleRateConverter->numberSamples);
    NSLog(@"maximum sample value:\t%.4f\n", sampleRateConverter->maximumSampleValue);
    NSLog(@"scale:\t\t\t%.4f\n", scale);

    /*  Rewind the temporary file to beginning  */
    rewind(sampleRateConverter->tempFilePtr);

    if (inputData->inputParameters.channels == 2) {
        double leftScale, rightScale;

	/*  Calculate left and right channel amplitudes  */
#if 0
	leftScale = -((inputData->inputParameters.balance / 2.0) - 0.5) * scale * 2.0;
	rightScale = ((inputData->inputParameters.balance / 2.0) + 0.5) * scale * 2.0;
#else
        // This doesn't have the crackling when at all left or all right, but it's not as loud as Mono by default.
	leftScale = -((inputData->inputParameters.balance / 2.0) - 0.5) * scale;
	rightScale = ((inputData->inputParameters.balance / 2.0) + 0.5) * scale;
#endif
        printf("left scale:\t\t%.4f\n", leftScale);
        printf("right scale:\t\t%.4f\n", rightScale);

        for (index = 0; index < sampleRateConverter->numberSamples; index++) {
            double sample;
            short value;

            fread(&sample, sizeof(sample), 1, sampleRateConverter->tempFilePtr);

            value = (short)rint(sample * leftScale);
            [soundData appendBytes:&value length:sizeof(value)];

            value = (short)rint(sample * rightScale);
            [soundData appendBytes:&value length:sizeof(value)];
        }
    } else {
        for (index = 0; index < sampleRateConverter->numberSamples; index++) {
            double sample;
            short value;

            fread(&sample, sizeof(sample), 1, sampleRateConverter->tempFilePtr);

            value = (short)rint(sample * scale);
            [soundData appendBytes:&value length:sizeof(value)];
        }
    }

    //NSLog(@"soundData: %p, length: %d", soundData, [soundData length]);
    bufferLength = [soundData length] / sizeof(short);
    //NSLog(@"bufferLength: %ld", bufferLength);
}

- (void)startPlaying;
{
    AudioOutputUnitStart(outputUnit);
}

- (void)stopPlaying;
{
    AudioOutputUnitStop(outputUnit);
}

// See <http://developer.apple.com/documentation/MusicAudio/Reference/CoreAudio/core_audio_types/chapter_6_section_4.html>

- (void)setupSoundDevice;
{
    OSStatus result;
    UInt32 count;

    result = OpenDefaultAudioOutput(&outputUnit);
    if (result != kAudioHardwareNoError) {
        NSLog(@"OpenDefaultAudioOutput() failed: %@", [NSString stringWithFourCharCode:result]);
    } else {
        NSLog(@"Got default audio output.");
    }

    result = AudioUnitInitialize(outputUnit);
    if (result != kAudioHardwareNoError) {
        NSLog(@"AudioUnitInitialize() failed: %@", [NSString stringWithFourCharCode:result]);
    } else {
        NSLog(@"initialized.");
    }

    {
        AudioStreamBasicDescription format;

        count = sizeof(format);
        result = AudioUnitGetProperty(outputUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &format, &count);
        if (result != kAudioHardwareNoError) {
            NSLog(@"AudioUnitGetProperty() failed.");
            return;
        }

        NSLog(@"sample rate: %f", format.mSampleRate);
        NSLog(@"format id: %08x (%@)", format.mFormatID, [NSString stringWithFourCharCode:format.mFormatID]);
        NSLog(@"format flags: %x", format.mFormatFlags);
        NSLog(@"bytes per packet: %d", format.mBytesPerPacket);
        NSLog(@"frames per packet: %d", format.mFramesPerPacket);
        NSLog(@"bytes per frame: %d", format.mBytesPerFrame);
        NSLog(@"channels per frame: %d", format.mChannelsPerFrame);
        NSLog(@"bits per channel: %d", format.mBitsPerChannel);

        // It looks like you need to use an AudioConverter to change the sampling rate.
        format.mFormatID = kAudioFormatLinearPCM;
        //format.mSampleRate = 22050.0;  // We *can* change the sample rate of the input stream.
        format.mFormatFlags = kAudioFormatFlagIsBigEndian | kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
        format.mBytesPerPacket = 2;
        format.mFramesPerPacket = 1;
        format.mBytesPerFrame = 2;
        format.mChannelsPerFrame = 1;
        format.mBitsPerChannel = 16;

#if 1
        {
            result = AudioUnitSetProperty(outputUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &format, sizeof(format));
            if (result != kAudioHardwareNoError) {
                NSLog(@"AudioUnitSetProperty(StreamFormat) failed: %d %x %@", result, result, [NSString stringWithFourCharCode:result]);
            } else {
                NSLog(@"It worked! (setting the stream data format)");
            }
        }
#endif
    }

    // Need to set kAudioUnitProperty_SetInputCallback
    {
        AudioUnitInputCallback inputCallback;

        inputCallback.inputProc = myInputCallback;
        inputCallback.inputProcRefCon = self;
        count = sizeof(inputCallback);
        result = AudioUnitSetProperty(outputUnit, kAudioUnitProperty_SetInputCallback, kAudioUnitScope_Global, 0, &inputCallback, sizeof(inputCallback));
        if (result != kAudioHardwareNoError) {
            NSLog(@"AudioUnitSetProperty(SetInputCallback) failed: %d %x %@", result, result, [NSString stringWithFourCharCode:result]);
            return;
        } else {
            NSLog(@"Set input callback!");
        }
    }
}

- (void)fillBuffer:(AudioBuffer *)ioData;
{
    short *buffer;
    int index, count;
    const short *ptr = [soundData bytes];

    //NSLog(@"mNumberChannels: %d", ioData->mNumberChannels);
    // It looks like the buffer size is 4096
    //NSLog(@"mDataByteSize: %d", ioData->mDataByteSize);

    count = ioData->mDataByteSize / sizeof(short);
    buffer = ioData->mData;

    //NSLog(@"%s, bufferIndex: %d, bufferLength: %d", _cmd, bufferIndex, bufferLength);
    for (index = 0; index < count && bufferIndex < bufferLength; index++) {
        buffer[index] = ptr[bufferIndex];
        bufferIndex++;
    }

    for (; index < count; index++) {
        buffer[index] = 0;
    }

    if (bufferIndex >= bufferLength)
        [self stopPlaying];
}

@end

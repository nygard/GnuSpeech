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
    TRMSynthesizer *synthesizer;
    int sampleCount;
    BOOL shouldStop;

    //NSLog(@"myInputCallback()");
    synthesizer = (TRMSynthesizer *)inRefCon;
    //NSLog(@"synthesizer: %@", synthesizer);
    //NSLog(@"mNumberChannels: %d", ioData->mNumberChannels);
    //NSLog(@"mDataByteSize: %d", ioData->mDataByteSize);

    sampleCount = (ioData->mDataByteSize / sizeof(short));
    shouldStop = [synthesizer fillBuffer:ioData->mData count:sampleCount];

    if (shouldStop)
        [synthesizer stopPlaying];
#if 0
    // This reduces the strange artifact, but I think it's still there... :(
    //memset(ioData->mData, 0, ioData->mDataByteSize);

    {
        int index;
        float freq = 1000;
        short *buf = ioData->mData;
        static int where = 0;

        for (index = 0; index < sampleCount; index++) {
            buf[index] = 32767 * .75 * sin(2 * M_PI * freq / 44100.0 * (where + index));
        }

        where += sampleCount;
    }
#endif

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
    NSLog(@" > %s", _cmd);

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
    inputData->inputParameters.noseRadius[0] = [synthesisParameters n1];
    inputData->inputParameters.noseRadius[1] = [synthesisParameters n2];
    inputData->inputParameters.noseRadius[2] = [synthesisParameters n3];
    inputData->inputParameters.noseRadius[3] = [synthesisParameters n4];
    inputData->inputParameters.noseRadius[4] = [synthesisParameters n5];
    inputData->inputParameters.throatCutoff = [synthesisParameters throatCutoff];
    inputData->inputParameters.throatVol = [synthesisParameters throatVolume];
    inputData->inputParameters.modulation = [synthesisParameters shouldUseNoiseModulation];
    inputData->inputParameters.mixOffset = [synthesisParameters mixOffset];

    NSLog(@"<  %s", _cmd);
}

- (void)removeAllParameters;
{
    INPUT *ptr, *next;

    NSLog(@" > %s", _cmd);

    ptr = inputData->inputHead;
    while (ptr != NULL) {
        next = ptr->next;
        free(ptr);
        ptr = next;
    }

    inputData->inputHead = NULL;
    inputData->inputTail = NULL;

    NSLog(@"<   %s", _cmd);
}

- (void)addParameters:(float *)values;
{
    double radius[TOTAL_REGIONS];

    // TODO (2004-05-07): I don't think the last two are used!
    radius[0] = values[7];
    radius[1] = values[8];
    radius[2] = values[9];
    radius[3] = values[10];
    radius[4] = values[11];
    radius[5] = values[12];
    radius[6] = values[13];
    radius[7] = values[14];
    addInput(inputData, values[0], values[1], values[2], values[3], values[4], values[5], values[6], radius, values[15]);
}

- (void)synthesize;
{
    NSLog(@" > %s", _cmd);

    // TODO (2004-05-07): Add parameters to inputData.  The inputParameters should be set directly before calling this method.

    initializeSynthesizer(&(inputData->inputParameters));

    synthesize(inputData);

    [self convertSamplesIntoData];
    [self startPlaying];

    NSLog(@"<  %s", _cmd);
}

- (void)convertSamplesIntoData;
{
    double scale;
    long int index;

    [soundData setLength:0];
    bufferIndex = 0;

    NSLog(@"sampleRateConverter.numberSamples: %d", sampleRateConverter.numberSamples);

    // TODO (2004-05-07): Would need to reset maximumSampleValue at the beginning of each synthesis
    //scale = (RANGE_MAX / sampleRateConverter.maximumSampleValue) * amplitude(inputData->inputParameters.volume);
    NSLog(@"amplitude(inputData->inputParameters.volume): %g", amplitude(inputData->inputParameters.volume));
    NSLog(@"sampleRateConverter.maximumSampleValue: %.4f", sampleRateConverter.maximumSampleValue);
    if (sampleRateConverter.maximumSampleValue == 0)
        NSBeep();
    scale = (RANGE_MAX / sampleRateConverter.maximumSampleValue) * amplitude(inputData->inputParameters.volume) ;
    NSLog(@"scale: %.4f", scale);

    /*  Rewind the temporary file to beginning  */
    rewind(sampleRateConverter.tempFilePtr);

    for (index = 0; index < sampleRateConverter.numberSamples; index++) {
        double sample;
        short value;

        fread(&sample, sizeof(sample), 1, sampleRateConverter.tempFilePtr);

        value = rint(sample * scale);
        //printf("%8ld: %g -> %hd\n", index, sample, (short)rint(sample * scale));
        //NSLog(@"value: %hd", value);
        [soundData appendBytes:&value length:sizeof(value)];
    }

    NSLog(@"soundData: %p, length: %d", soundData, [soundData length]);
    bufferLength = [soundData length] / sizeof(short);
    NSLog(@"bufferLength: %ld", bufferLength);
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
    double sampleRate;
    float volume;

#if 1
    result = OpenDefaultAudioOutput(&outputUnit);
    if (result != kAudioHardwareNoError) {
        NSLog(@"OpenDefaultAudioOutput() failed: %@", [NSString stringWithFourCharCode:result]);
    } else {
        NSLog(@"Got default audio output.");
    }
#else
    {
        Component comp;
        ComponentDescription desc;

        desc.componentType = kAudioUnitType_Output;
        desc.componentSubType = kAudioUnitSubType_DefaultOutput;
        desc.componentManufacturer = kAudioUnitManufacturer_Apple;
        desc.componentFlags = 0;
        desc.componentFlagsMask = 0;

        comp = FindNextComponent(NULL, &desc);
        if (comp == NULL) {
            NSLog(@"Couldn't find component.");
            return;
        }

        OpenAComponent(comp, &outputUnit);
    }
#endif

    result = AudioUnitInitialize(outputUnit);
    if (result != kAudioHardwareNoError) {
        NSLog(@"AudioUnitInitialize() failed: %@", [NSString stringWithFourCharCode:result]);
    } else {
        NSLog(@"initialized.");
    }

    {
        Boolean isWritable;

        result = AudioUnitGetPropertyInfo(outputUnit, kAudioUnitProperty_SampleRate, kAudioUnitScope_Output, 0, &count, &isWritable);
        if (result != kAudioHardwareNoError) {
            NSLog(@"AudioUnitGetPropertyInfo() failed.");
        } else {
            NSLog(@"sample rate size: %d, isWritable: %d", count, isWritable);
        }
    }

    //

    sampleRate = 45;

    count = sizeof(sampleRate);
    result = AudioUnitGetProperty(outputUnit, kAudioUnitProperty_SampleRate, kAudioUnitScope_Global, 0, &sampleRate, &count);
    if (result != kAudioHardwareNoError) {
        NSLog(@"AudioUnitGetProperty() failed: %@", [NSString stringWithFourCharCode:result]);
    } else {
        NSLog(@"Got property.");
    }

    NSLog(@"sampleRate: %g", sampleRate);
#if 0
    sampleRate = 22050.0;

    result = AudioUnitSetProperty(outputUnit, kAudioUnitProperty_SampleRate, kAudioUnitScope_Output, 0, &sampleRate, sizeof(sampleRate));
    if (result != kAudioHardwareNoError) {
        NSLog(@"AudioUnitSetProperty() failed: %d %x %@", result, result, [NSString stringWithFourCharCode:result]);
    } else {
        NSLog(@"Set property, sampleRate = 22050");
    }
#endif
    //
    NSLog(@"**********************************************************************");

    {
        AudioUnitParameterInfo parameterInfo;

        count = sizeof(parameterInfo);
        result = AudioUnitGetProperty(outputUnit, kAudioUnitProperty_ParameterInfo, kAudioUnitScope_Global, kHALOutputParam_Volume,
                                      &parameterInfo, &count);
        if (result != kAudioHardwareNoError) {
            NSLog(@"AudioUnitGetProperty(volume) failed: %d %x %@", result, result, [NSString stringWithFourCharCode:result]);
        } else {
            NSLog(@"Got parameter info - volume.");
            if (parameterInfo.flags & kAudioUnitParameterFlag_HasCFNameString) {
                NSLog(@"kAudioUnitParameterFlag_HasCFNameString: %@", parameterInfo.cfNameString);
            }
            NSLog(@"unit: %d", parameterInfo.unit);
            NSLog(@"minValue: %f", parameterInfo.minValue);
            NSLog(@"maxValue: %f", parameterInfo.maxValue);
            NSLog(@"defaultValue: %f", parameterInfo.defaultValue);
            NSLog(@"flags: %x", parameterInfo.flags);
        }
    }
    NSLog(@"**********************************************************************");

    volume = 2;

    count = sizeof(volume);
    result = AudioUnitGetProperty(outputUnit, kHALOutputParam_Volume, kAudioUnitScope_Global, 0, &volume, &count);
    if (result != kAudioHardwareNoError) {
        NSLog(@"AudioUnitGetProperty(volume) failed: %@", [NSString stringWithFourCharCode:result]);
    } else {
        NSLog(@"Got property.");
    }

    NSLog(@"volume: %f", volume);

#if 0
    result = AudioUnitSetProperty(outputUnit, kHALOutputParam_Volume, kAudioUnitScope_Output, 0, &volume, sizeof(volume));
    if (result != kAudioHardwareNoError) {
        NSLog(@"AudioUnitSetProperty(volume) failed: %@", [NSString stringWithFourCharCode:result]);
        NSLog(@"result: %d", result);
        // Result is generally kAudioUnitErr_PropertyNotWritable :(
    } else {
        NSLog(@"Set property, sampleRate = 22050");
    }
#endif

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

- (BOOL)fillBuffer:(short *)buffer count:(int)count;
{
    int index;
    const short *ptr = [soundData bytes];

    // It looks like the buffer size is 4096
    //NSLog(@"ptr: %p", ptr);
    NSLog(@"%s, bufferIndex: %d, bufferLength: %d", _cmd, bufferIndex, bufferLength);
    for (index = 0; index < count && bufferIndex < bufferLength; index++) {
        //buffer[2 * index] = ptr[bufferIndex] / (float)RANGE_MAX;
        //buffer[2 * index + 1] = ptr[bufferIndex] / (float)RANGE_MAX;
        buffer[index] = ptr[bufferIndex];
        //buffer[2 * index + 1] = ptr[bufferIndex];
        //NSLog(@"value: %hd %f", ptr[bufferIndex], buffer[2 * index]);
        bufferIndex++;
    }

    for (; index < count; index++) {
        buffer[index] = 0;
        //buffer[2 * index + 1] = 0;
    }

    return bufferIndex >= bufferLength;
}

@end

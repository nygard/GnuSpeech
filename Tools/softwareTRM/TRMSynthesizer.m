//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "TRMSynthesizer.h"

#import <Foundation/Foundation.h>
#import "MMSynthesisParameters.h"
#include "input.h"
#include "output.h"
#include "tube.h"
#include "util.h"

typedef struct {
    char a, b, c, d;
} MyFourCharCode;


int verbose = 0;

OSStatus playIOProc(AudioDeviceID inDevice,
                    const AudioTimeStamp *inNow,
                    const AudioBufferList *inInputData,
                    const AudioTimeStamp *inInputTime,
                    AudioBufferList *outOutputData,
                    const AudioTimeStamp *inOutputTime,
                    void *inClientData)
{
    TRMSynthesizer *synthesizer;
    int size, sampleCount;
    float *ptr;
    BOOL shouldStop;

    synthesizer = (TRMSynthesizer *)inClientData;
    size = outOutputData->mBuffers[0].mDataByteSize;
    sampleCount = (size / sizeof(float)) / 2;

    //NSLog(@"size: %d, sampleCount: %d", size, sampleCount);
    //NSLog(@"outOutputData->mNumberBuffers: %d", outOutputData->mNumberBuffers);

    memset(outOutputData->mBuffers[0].mData, 0, size);
    ptr = outOutputData->mBuffers[0].mData;
    shouldStop = [synthesizer fillBuffer:ptr count:sampleCount];

    if (shouldStop)
        [synthesizer stopPlaying];

    return kAudioHardwareNoError;
    //return kAudioHardwareNoError;
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

    _deviceReady = NO;
    _device = kAudioDeviceUnknown;
    _isPlaying = NO;

    [self setupSoundDevice];

    return self;
}

- (void)dealloc;
{
    free(inputData);
    [soundData release];

    [super dealloc];
}

#if 0
- (TRMInputParameters *)inputParameters;
{
    return &(inputData->inputParameters);
}
#endif

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
    NSLog(@"sampleRateConverter.maximumSampleValue: %g", sampleRateConverter.maximumSampleValue);
    if (sampleRateConverter.maximumSampleValue == 0)
        NSBeep();
    scale = 0.5 * amplitude(inputData->inputParameters.volume) / sampleRateConverter.maximumSampleValue;
    NSLog(@"scale: %g", scale);

    /*  Rewind the temporary file to beginning  */
    rewind(sampleRateConverter.tempFilePtr);

    for (index = 0; index < sampleRateConverter.numberSamples; index++) {
        double sample;
        float value;

        fread(&sample, sizeof(sample), 1, sampleRateConverter.tempFilePtr);

        value = sample * scale;
        //NSLog(@"value: %f", value);
        [soundData appendBytes:&value length:sizeof(value)];
    }

    NSLog(@"soundData: %p, length: %d", soundData, [soundData length]);
    bufferLength = [soundData length] / sizeof(float);
}

- (void)startPlaying;
{
    OSStatus err = kAudioHardwareNoError;

    NSLog(@" > %s", _cmd);

    if (_isPlaying)
        return;

    err = AudioDeviceAddIOProc(_device, playIOProc, (void *)self);
    if (err != kAudioHardwareNoError) {
        NSLog(@"%s, Error adding IO proc", _cmd);
        return;
    }

    err = AudioDeviceStart(_device, playIOProc);
    if (err != kAudioHardwareNoError) {
        NSLog(@"%s, Error starting audio device", _cmd);
        return;
    }

    _isPlaying = YES;

    NSLog(@"<  %s", _cmd);
}

- (void)stopPlaying;
{
    if (_isPlaying) {
        OSStatus err = kAudioHardwareNoError;

        err = AudioDeviceStop(_device, playIOProc);
        if (err != kAudioHardwareNoError) {
            NSLog(@"%s, Error stopping audio device", _cmd);
            return;
        }

        err = AudioDeviceRemoveIOProc(_device, playIOProc);
        if (err != kAudioHardwareNoError) {
            NSLog(@"%s, Error removing IO proc", _cmd);
            return;
        }

        _isPlaying = NO;
    }
}
- (void)trySomething;
{
#if 0
    OSStatus result;
    UInt32 count;

    result = AudioHardwareGetPropertyInfo();
#endif
}

// See <http://developer.apple.com/documentation/MusicAudio/Reference/CoreAudio/core_audio_types/chapter_6_section_4.html>

- (void)setupSoundDevice;
{
    OSStatus err;
    UInt32 count, bufferSize;
    AudioDeviceID device = kAudioDeviceUnknown;
    AudioStreamBasicDescription format;

    MyFourCharCode *charcode;
    CFStringRef name;

    [self trySomething];

    _deviceReady = NO;
    count = sizeof(AudioDeviceID);
    err = AudioHardwareGetProperty(kAudioHardwarePropertyDefaultOutputDevice, &count, (void *)&device);
    if (err != kAudioHardwareNoError) {
        NSLog(@"Failed to get default output device");
        return;
    }

    count = sizeof(UInt32);
    err = AudioDeviceGetProperty(device, 0, false, kAudioDevicePropertyBufferSize, &count, &bufferSize);
    if (err != kAudioHardwareNoError) {
        NSLog(@"Couldn't get default buffer size.");
        return;
    }

    count = sizeof(CFStringRef);
    err = AudioDeviceGetProperty(device, 0, false, kAudioDevicePropertyDeviceNameCFString, &count, &name);
    if (err != kAudioHardwareNoError) {
        NSLog(@"Couldn't get device name.");
    } else {
        NSLog(@"device name: %@", name);
        CFRelease(name);
    }
    count = sizeof(AudioStreamBasicDescription);
    err = AudioDeviceGetProperty(device, 0, false, kAudioDevicePropertyStreamFormat, &count, &format);
    if (err != kAudioHardwareNoError) {
        NSLog(@"Couldn't get data format of default device");
        return;
    }

#if 0
    count = sizeof(AudioStreamBasicDescription);
    err = AudioDeviceGetProperty(device, 0, false, kAudioDevicePropertyStreamFormat, &count, &format);
    if (err != kAudioHardwareNoError) {
        NSLog(@"Couldn't get data format of default device");
        return;
    }
#endif

    charcode = (MyFourCharCode *)(&(format.mFormatID));

    NSLog(@"bufferSize: %d", bufferSize);
    NSLog(@"format:");
    NSLog(@"sample rate: %f", format.mSampleRate);
    NSLog(@"format id: %08x (%c%c%c%c)", format.mFormatID, charcode->a, charcode->b, charcode->c, charcode->d);
    NSLog(@"format flags: %x", format.mFormatFlags);
    NSLog(@"bytes per packet: %d", format.mBytesPerPacket);
    NSLog(@"frames per packet: %d", format.mFramesPerPacket);
    NSLog(@"bytes per frame: %d", format.mBytesPerFrame);
    NSLog(@"channels per frame: %d", format.mChannelsPerFrame);
    NSLog(@"bits per channel: %d", format.mBitsPerChannel);

    // we want linear pcm
    if (format.mFormatID != kAudioFormatLinearPCM) {
        NSLog(@"Not linear PCM.");
        return;
    }

    if (!(format.mFormatFlags & kAudioFormatFlagIsFloat)) {
        NSLog(@"Not float format.");
        return;
    }
#if 0
    {
        AudioTimeStamp inWhen;

        format.mSampleRate = 22050.0;
        //err = AudioHardwareSetProperty(kAudioDevicePropertyStreamFormat, sizeof(AudioStreamBasicDescription), &format);
        err = AudioDeviceSetProperty(device, &inWhen, 0, false, kAudioDevicePropertyStreamFormat, sizeof(AudioStreamBasicDescription), &format);
        if (err != kAudioHardwareNoError) {
            NSLog(@"Couldn't set the data format...");
            charcode = (MyFourCharCode *)&err;
            NSLog(@"error: %08x (%c%c%c%c)", err, charcode->a, charcode->b, charcode->c, charcode->d);
            // This gives a kAudioDeviceUnsupportedFormatError
        } else {
            NSLog(@"It worked!");
        }
    }
#endif

    _device = device;
    _bufferSize = bufferSize;
    _format = format;

    _deviceReady = YES;
}

- (BOOL)fillBuffer:(float *)buffer count:(int)count;
{
    int index;
    const float *ptr = [soundData bytes];

    // It looks like the buffer size is 4096
    //NSLog(@"ptr: %p", ptr);
    //NSLog(@"%s, bufferIndex: %d, bufferLength: %d", _cmd, bufferIndex, bufferLength);
    for (index = 0; index < count && bufferIndex < bufferLength; index++) {
        //buffer[2 * index] = ptr[bufferIndex] / (float)RANGE_MAX;
        //buffer[2 * index + 1] = ptr[bufferIndex] / (float)RANGE_MAX;
        buffer[2 * index] = ptr[bufferIndex];
        buffer[2 * index + 1] = ptr[bufferIndex];
        //NSLog(@"value: %hd %f", ptr[bufferIndex], buffer[2 * index]);
        bufferIndex++;
    }

    for (; index < count; index++) {
        buffer[2 * index] = 0;
        buffer[2 * index + 1] = 0;
    }

    return bufferIndex >= bufferLength;
}

@end

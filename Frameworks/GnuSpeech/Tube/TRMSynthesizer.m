////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
//  
//  Contributors: Steve Nygard
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
////////////////////////////////////////////////////////////////////////////////
//
//  TRMSynthesizer.m
//  GnuSpeech
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.9.1
//
////////////////////////////////////////////////////////////////////////////////

#import "TRMSynthesizer.h"
#import "MMSynthesisParameters.h"
#import <Foundation/Foundation.h>

#ifndef GNUSTEP

#import <CoreAudio/CoreAudio.h>
#import <AudioToolbox/AudioToolbox.h>

#else

#import <AppKit/NSSound.h>
#import <AppKit/NSGraphics.h>
#import <Foundation/NSAutoreleasePool.h>

#endif


/* Checks if currect architecture is big-endian (PowerPC). */
static BOOL isBigEndian()
{
	unsigned long value = 0x12345678;
	if (*(unsigned char *)(&value) == 0x12)
		return YES;
	return NO;
}


/* Checks if currect architecture is little-endian (Intel). */
static BOOL isLittleEndian()
{
	unsigned long value = 0x12345678;
	if (*(unsigned char *)(&value) == 0x78)
		return YES;
	return NO;
}


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

	// On Intel (little-endian) we need to use kAudioFormatFlagIsAlignedHigh; on PowerPC (big-endian) kAudioFormatFlagIsBigEndian.
	if (isLittleEndian())
		return [NSString stringWithFormat:@"%c%c%c%c", charcode->d, charcode->c, charcode->b, charcode->a];
	else
		return [NSString stringWithFormat:@"%c%c%c%c", charcode->a, charcode->b, charcode->c, charcode->d];		
}
@end



#ifndef GNUSTEP
OSStatus renderSpeechCallback(void *inRefCon,
							  AudioUnitRenderActionFlags inActionFlags, 
							  const AudioTimeStamp *inTimeStamp, 
							  UInt32 inBusNumber, 
							  AudioBuffer *ioData)
{
    [(TRMSynthesizer *)inRefCon fillBuffer:ioData];
    return kAudioHardwareNoError;
}
#endif


#ifndef GNUSTEP
OSStatus renderSineCallback(void *inRefCon, 
							AudioUnitRenderActionFlags inActionFlags, 
							const AudioTimeStamp *inTimeStamp, 
							UInt32 inBusNumber, 
							AudioBuffer *ioData)
{
	static double phase;
	int x, c;
	double stride;
	UInt32 samplesPerBuffer;
	double phasePerStream;
	static UInt64 firstTime = 0;
	static UInt64 totalSamples = 0;
		
	if (firstTime == 0)
		firstTime = inTimeStamp->mHostTime;
	
	if (totalSamples > 88200)
	{
		firstTime = inTimeStamp->mHostTime;
		totalSamples = 0;
	}
	
	stride = *(double *)inRefCon;
	
	{
		phasePerStream = phase;
		samplesPerBuffer = ioData->mDataByteSize / sizeof(Float32);
		totalSamples += samplesPerBuffer / ioData->mNumberChannels;
		for ( x = 0; x < samplesPerBuffer; x+=ioData->mNumberChannels )
		{
			for ( c = 0; c < ioData->mNumberChannels; c++ )
			{
				((Float32 *)(ioData->mData))[x + c] = sin ( phasePerStream ) * 0.01 ;
			}
			phasePerStream += stride;
			while (phasePerStream > (2.0 * M_PI))
				phasePerStream -= (2.0 * M_PI);
		}
	}
	
	phase = phasePerStream;
    return kAudioHardwareNoError;
}
#endif


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

    inputData->inputParameters.outputFileFormat = 0;
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

	/*
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
	*/

#ifndef GNUSTEP
	
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
	format.mSampleRate = inputData->inputParameters.outputRate;
	format.mChannelsPerFrame = inputData->inputParameters.channels;	
	format.mBytesPerPacket = 2 * format.mChannelsPerFrame;
	format.mFramesPerPacket = 1;
	format.mBytesPerFrame = 2 * format.mChannelsPerFrame;
	format.mBitsPerChannel = 16;
	
	// On Intel (little-endian) we need to use kAudioFormatFlagIsAlignedHigh; on PowerPC (big-endian) kAudioFormatFlagIsBigEndian.
	if (isLittleEndian())
		format.mFormatFlags =  kAudioFormatFlagIsAlignedHigh | kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
	else
		format.mFormatFlags =  kAudioFormatFlagIsBigEndian | kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;	

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
	}

#endif

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

- (BOOL)shouldSaveToSoundFile;
{
    return shouldSaveToSoundFile;
}

- (void)setShouldSaveToSoundFile:(BOOL)newFlag;
{
    shouldSaveToSoundFile = newFlag;
}

- (NSString *)filename;
{
    return filename;
}

- (void)setFilename:(NSString *)newFilename;
{
    if (newFilename == filename)
        return;

    [filename release];
    filename = [newFilename retain];
}

- (int)fileType;
{
    return inputData->inputParameters.outputFileFormat;
}

- (void)setFileType:(int)newFileType;
{
    inputData->inputParameters.outputFileFormat = newFileType;
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

    if (shouldSaveToSoundFile) {
		
        writeOutputToFile(&(tube->sampleRateConverter), inputData, [filename UTF8String]);

    } else {

		// The following is used to bypass Core Audio and play from a file instead. -- added by dalmazio, October 19, 2008
		//
		// const char *tempName = tempnam("/tmp", NULL);
		// writeOutputToFile(&(tube->sampleRateConverter), inputData, tempName);
		// NSSound *sound = [[[NSSound alloc] initWithContentsOfFile:[NSString stringWithUTF8String:tempName] byReference:YES] autorelease];
		// [sound play];

		[self convertSamplesIntoData:&(tube->sampleRateConverter)];		
		[self startPlaying];
    }

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

    scale = OUTPUT_SCALE * (RANGE_MAX / sampleRateConverter->maximumSampleValue) * amplitude(inputData->inputParameters.volume) ;

    NSLog(@"number of samples:\t%-ld\n", sampleRateConverter->numberSamples);
    NSLog(@"maximum sample value:\t%.4f\n", sampleRateConverter->maximumSampleValue);
    NSLog(@"scale:\t\t\t%.4f\n", scale);

    /*  Rewind the temporary file to beginning  */
    rewind(sampleRateConverter->tempFilePtr);

    if (inputData->inputParameters.channels == 2) {
        double leftScale, rightScale;
	
		// Calculate left and right channel amplitudes.
		//
		// leftScale = -((inputData->inputParameters.balance / 2.0) - 0.5) * scale * 2.0;
		// rightScale = ((inputData->inputParameters.balance / 2.0) + 0.5) * scale * 2.0;

        // This doesn't have the crackling when at all left or all right, but it's not as loud as Mono by default.
		leftScale = -((inputData->inputParameters.balance / 2.0) - 0.5) * scale;
		rightScale = ((inputData->inputParameters.balance / 2.0) + 0.5) * scale;

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
#ifndef GNUSTEP
    AudioOutputUnitStart(outputUnit);
#else
    CREATE_AUTORELEASE_POOL(pool);
    NSSound *sound = [[NSSound alloc] initWithData: soundData];
    [sound play];
    RELEASE(pool);
#endif
}

- (void)stopPlaying;
{
#ifndef GNUSTEP
    AudioOutputUnitStop(outputUnit);
#endif
}

// See <http://developer.apple.com/documentation/MusicAudio/Reference/CoreAudio/core_audio_types/chapter_6_section_4.html>
- (void)setupSoundDevice;
{

#ifndef GNUSTEP
	
    ComponentDescription searchDesc;
    Component theAUComponent;
    OSErr err;
    OSStatus result;
    UInt32 count;

    searchDesc.componentType = kAudioUnitComponentType;
    searchDesc.componentSubType = kAudioUnitSubType_Output;
    searchDesc.componentManufacturer = kAudioUnitID_DefaultOutput;
    searchDesc.componentFlags = 0;
    searchDesc.componentFlagsMask = 0;

    theAUComponent = FindNextComponent(NULL, &searchDesc);
    if (theAUComponent == 0) {
        NSLog(@"Error: Couldn't find default output audio unit.");
        return;
    }

    err = OpenAComponent(theAUComponent, &outputUnit);
    if (err != noErr) {
        NSLog(@"Error: Couldn't open default output audio unit.");
        return;
    }

    result = AudioUnitInitialize(outputUnit);
    if (result != kAudioHardwareNoError) {
        NSLog(@"AudioUnitInitialize() failed: %@", [NSString stringWithFourCharCode:result]);
    }

    // Need to set kAudioUnitProperty_SetInputCallback	
	AudioUnitInputCallback inputCallback;
	inputCallback.inputProc = renderSpeechCallback;
	inputCallback.inputProcRefCon = self;
	count = sizeof(inputCallback);
	
	result = AudioUnitSetProperty(outputUnit, kAudioUnitProperty_SetInputCallback, kAudioUnitScope_Global, 0, &inputCallback, sizeof(inputCallback));
	if (result != kAudioHardwareNoError) {
		NSLog(@"AudioUnitSetProperty(SetInputCallback) failed: %d %x %@", result, result, [NSString stringWithFourCharCode:result]);
		return;
    }
	
#endif
	
}

#ifndef GNUSTEP
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
#endif

@end

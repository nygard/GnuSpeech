//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "TRMSynthesizer.h"
#import "MMSynthesisParameters.h"
#import <Foundation/Foundation.h>
#import "NSData-STExtensions.h"
#import <AVFoundation/AVFoundation.h>

const uint16_t kWAVEFormat_Unknown         = 0x0000;
const uint16_t kWAVEFormat_UncompressedPCM = 0x0001;

/*  SIZE IN BITS PER OUTPUT SAMPLE  */
#define BITS_PER_SAMPLE           16

@implementation TRMSynthesizer

- (id)init;
{	
    if ([super init] == nil)
        return nil;

    inputData = (TRMDataList *)malloc(sizeof(TRMDataList));
    if (inputData == NULL) {
        NSLog(@"Failed to malloc TRMData.");
        [super release];
        return nil;
    }

    inputData->inputParameters.outputFileFormat = 0;
    inputData->inputHead = NULL;
    inputData->inputTail = NULL;
	
    return self;
}

- (void)dealloc;
{
    free(inputData);
    [m_audioPlayer release];
	
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
#if 0
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
	NSLog(@"format id: %08lx (%@)", format.mFormatID, [NSString stringWithFourCharCode:format.mFormatID]);
	NSLog(@"format flags: %lx", format.mFormatFlags);
	NSLog(@"bytes per packet: %ld", format.mBytesPerPacket);
	NSLog(@"frames per packet: %ld", format.mFramesPerPacket);
	NSLog(@"bytes per frame: %ld", format.mBytesPerFrame);
	NSLog(@"channels per frame: %ld", format.mChannelsPerFrame);
	NSLog(@"bits per channel: %ld", format.mBitsPerChannel);

	result = AudioUnitSetProperty(outputUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &format, sizeof(format));
	if (result != kAudioHardwareNoError) {
		NSLog(@"AudioUnitSetProperty(StreamFormat) failed: %ld %lx %@", result, result, [NSString stringWithFourCharCode:result]);
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

		[self generateWAVDataWithSampleRateConverter:&(tube->sampleRateConverter)];		
		[self startPlaying:tube];
    }

    TRMTubeModelFree(tube);
}

// RIFF
#define WAV_CHUNK_ID        0x52494646

// WAVE
#define WAV_RIFF_TYPE       0x57415645

// fmt
#define WAV_FORMAT_CHUNK_ID 0x666d7420

// data
#define WAV_DATA_CHUNK_ID   0x64617461

- (NSData *)generateWAVDataWithSampleRateConverter:(TRMSampleRateConverter *)sampleRateConverter;
{
    double scale;
    long int index;

    if (sampleRateConverter->maximumSampleValue == 0)
        NSBeep();

    NSMutableData *sampleData = [[NSMutableData alloc] init];

    scale = OUTPUT_SCALE * (RANGE_MAX / sampleRateConverter->maximumSampleValue) * amplitude(inputData->inputParameters.volume) ;

    NSLog(@"number of samples:\t%-d\n", sampleRateConverter->numberSamples);
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
            [sampleData appendBytes:&value length:sizeof(value)];

            value = (short)rint(sample * rightScale);
            [sampleData appendBytes:&value length:sizeof(value)];
        }
		
    } else {
		
        for (index = 0; index < sampleRateConverter->numberSamples; index++) {
            double sample;
            short value;

            fread(&sample, sizeof(sample), 1, sampleRateConverter->tempFilePtr);

            value = (short)rint(sample * scale);
            [sampleData appendBytes:&value length:sizeof(value)];
        }
    }

    int frameSize = (int)ceil(inputData->inputParameters.channels * ((double)BITS_PER_SAMPLE / 8));
    int bytesPerSecond = (int)ceil(inputData->inputParameters.outputRate * frameSize);
    
    NSMutableData *data = [NSMutableData data];
    uint32_t subChunk1Size = 18;
    uint32_t subChunk2Size = [sampleData length];
    uint32_t chunkSize = 4 + (8 + subChunk1Size) + (8 + subChunk2Size);
    
    // Header - RIFF type chunk
    [data appendBigInt32:WAV_CHUNK_ID]; // RIFF
    [data appendLittleInt32:chunkSize];
    [data appendBigInt32:WAV_RIFF_TYPE]; // WAVE
    
    // Format chunk
    [data appendBigInt32:WAV_FORMAT_CHUNK_ID]; // fmt
    [data appendLittleInt32:subChunk1Size];
    [data appendLittleInt16:kWAVEFormat_UncompressedPCM];
    [data appendLittleInt16:inputData->inputParameters.channels];
    [data appendLittleInt32:inputData->inputParameters.outputRate];
    [data appendLittleInt32:bytesPerSecond];
    [data appendLittleInt16:frameSize];
    [data appendLittleInt16:BITS_PER_SAMPLE];
    [data appendLittleInt16:0];
    
    // Data chunk
    [data appendBigInt32:WAV_DATA_CHUNK_ID];
    [data appendLittleInt32:subChunk2Size];
    
    [data appendData:sampleData];
    
    return [[data copy] autorelease];
}

- (AVAudioPlayer *)audioPlayer;
{
    return m_audioPlayer;
}

- (void)setAudioPlayer:(AVAudioPlayer *)audioPlayer;
{
    if (audioPlayer != m_audioPlayer) {
        [m_audioPlayer release];
        m_audioPlayer = [audioPlayer retain];
    }
}

- (void)startPlaying:(TRMTubeModel *)tube;
{
    NSError *error = nil;
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithData:[self generateWAVDataWithSampleRateConverter:&(tube->sampleRateConverter)] error:&error];
    if (audioPlayer == nil) {
        NSLog(@"error: %@", error);
    } else {
        [self setAudioPlayer:audioPlayer];
        [audioPlayer play];
    }
}

- (void)stopPlaying;
{
    [[self audioPlayer] stop];
    [self setAudioPlayer:nil];
}

@end

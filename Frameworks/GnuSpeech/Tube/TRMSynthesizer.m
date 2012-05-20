//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "TRMSynthesizer.h"

#import <AVFoundation/AVFoundation.h>
#import "MMSynthesisParameters.h"
#import "NSData-STExtensions.h"
#import <Tube/TRMDataList.h>
#import <Tube/TRMInputParameters.h>
#import <Tube/TRMParameters.h>
#import <Tube/TRMTubeModel.h>

const uint16_t kWAVEFormat_Unknown         = 0x0000;
const uint16_t kWAVEFormat_UncompressedPCM = 0x0001;

@interface TRMSynthesizer ()
- (NSData *)generateWAVDataWithSampleRateConverter:(TRMSampleRateConverter *)sampleRateConverter;
@property (strong) AVAudioPlayer *audioPlayer;

- (void)startPlaying:(TRMTubeModel *)tube;
- (void)stopPlaying;
@end

#pragma mark -

@implementation TRMSynthesizer
{
    TRMDataList *m_inputData;
    
    BOOL m_shouldSaveToSoundFile;
    NSString *m_filename;
    AVAudioPlayer *m_audioPlayer;
}

- (id)init;
{	
    if ((self = [super init])) {
        m_inputData = [[TRMDataList alloc] init];
        
        m_inputData.inputParameters.outputFileFormat = 0;
    }
	
    return self;
}

- (void)dealloc;
{
    free(m_inputData);
    [m_audioPlayer release];
	
    [super dealloc];
}

#pragma mark -

- (void)setupSynthesisParameters:(MMSynthesisParameters *)synthesisParameters;
{
    m_inputData.inputParameters.outputRate    = synthesisParameters.sampleRate;
    m_inputData.inputParameters.controlRate   = 250;
    m_inputData.inputParameters.volume        = [synthesisParameters masterVolume];
    m_inputData.inputParameters.channels      = [synthesisParameters outputChannels] + 1;
    m_inputData.inputParameters.balance       = [synthesisParameters balance];
    m_inputData.inputParameters.waveform      = [synthesisParameters glottalPulseShape];
    m_inputData.inputParameters.tp            = [synthesisParameters tp];
    m_inputData.inputParameters.tnMin         = [synthesisParameters tnMin];
    m_inputData.inputParameters.tnMax         = [synthesisParameters tnMax];
    m_inputData.inputParameters.breathiness   = [synthesisParameters breathiness];
    m_inputData.inputParameters.length        = [synthesisParameters vocalTractLength];
    m_inputData.inputParameters.temperature   = [synthesisParameters temperature];
    m_inputData.inputParameters.lossFactor    = [synthesisParameters lossFactor];
    m_inputData.inputParameters.apScale       = [synthesisParameters apertureScaling];
    m_inputData.inputParameters.mouthCoef     = [synthesisParameters mouthCoef];
    m_inputData.inputParameters.noseCoef      = [synthesisParameters noseCoef];
    m_inputData.inputParameters.noseRadius[0] = 0; // Give it a predictable value.
    m_inputData.inputParameters.noseRadius[1] = [synthesisParameters n1];
    m_inputData.inputParameters.noseRadius[2] = [synthesisParameters n2];
    m_inputData.inputParameters.noseRadius[3] = [synthesisParameters n3];
    m_inputData.inputParameters.noseRadius[4] = [synthesisParameters n4];
    m_inputData.inputParameters.noseRadius[5] = [synthesisParameters n5];
    m_inputData.inputParameters.throatCutoff  = [synthesisParameters throatCutoff];
    m_inputData.inputParameters.throatVol     = [synthesisParameters throatVolume];
    m_inputData.inputParameters.modulation    = [synthesisParameters shouldUseNoiseModulation];
    m_inputData.inputParameters.mixOffset     = [synthesisParameters mixOffset];
#if 0
	// It looks like you need to use an AudioConverter to change the sampling rate.
	format.mFormatID         = kAudioFormatLinearPCM;
	format.mSampleRate       = inputData->inputParameters.outputRate;
	format.mChannelsPerFrame = inputData->inputParameters.channels;	
	format.mBytesPerPacket   = 2 * format.mChannelsPerFrame;
	format.mFramesPerPacket  = 1;
	format.mBytesPerFrame    = 2 * format.mChannelsPerFrame;
	format.mBitsPerChannel   = 16;
	
	// On Intel (little-endian) we need to use kAudioFormatFlagIsAlignedHigh; on PowerPC (big-endian) kAudioFormatFlagIsBigEndian.
	if (isLittleEndian())
		format.mFormatFlags =  kAudioFormatFlagIsAlignedHigh | kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
	else
		format.mFormatFlags =  kAudioFormatFlagIsBigEndian | kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;	

	NSLog(@"sample rate: %f",         format.mSampleRate);
	NSLog(@"format id: %08lx (%@)",   format.mFormatID, [NSString stringWithFourCharCode:format.mFormatID]);
	NSLog(@"format flags: %lx",       format.mFormatFlags);
	NSLog(@"bytes per packet: %ld",   format.mBytesPerPacket);
	NSLog(@"frames per packet: %ld",  format.mFramesPerPacket);
	NSLog(@"bytes per frame: %ld",    format.mBytesPerFrame);
	NSLog(@"channels per frame: %ld", format.mChannelsPerFrame);
	NSLog(@"bits per channel: %ld",   format.mBitsPerChannel);

	result = AudioUnitSetProperty(outputUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &format, sizeof(format));
	if (result != kAudioHardwareNoError) {
		NSLog(@"AudioUnitSetProperty(StreamFormat) failed: %ld %lx %@", result, result, [NSString stringWithFourCharCode:result]);
	}
#endif
}

- (void)removeAllParameters;
{
    [m_inputData.values removeAllObjects];
}

- (void)addParameters:(float *)values;
{
    TRMParameters *inputValues = [[[TRMParameters alloc] init] autorelease];
    inputValues.glotPitch = values[0];
    inputValues.glotVol   = values[1];
    inputValues.aspVol    = values[2];
    inputValues.fricVol   = values[3];
    inputValues.fricPos   = values[4];
    inputValues.fricCF    = values[5];
    inputValues.fricBW    = values[6];
    inputValues.radius[0] = values[7];
    inputValues.radius[1] = values[8];
    inputValues.radius[2] = values[9];
    inputValues.radius[3] = values[10];
    inputValues.radius[4] = values[11];
    inputValues.radius[5] = values[12];
    inputValues.radius[6] = values[13];
    inputValues.radius[7] = values[14];
    inputValues.velum     = values[15];
    [m_inputData.values addObject:inputValues];
}

@synthesize shouldSaveToSoundFile = m_shouldSaveToSoundFile;
@synthesize filename = m_filename;

- (int)fileType;
{
    return m_inputData.inputParameters.outputFileFormat;
}

- (void)setFileType:(int)newFileType;
{
    m_inputData.inputParameters.outputFileFormat = newFileType;
}

- (void)synthesize;
{
    TRMTubeModel *tube = [[[TRMTubeModel alloc] initWithInputParameters:m_inputData.inputParameters] autorelease];
    if (tube == nil) {
        NSLog(@"Warning: Failed to create tube model.");
        return;
    }

    [tube synthesizeFromDataList:m_inputData];

    if (self.shouldSaveToSoundFile) {
		
        writeOutputToFile(tube.sampleRateConverter, m_inputData, [self.filename UTF8String]);

    } else {

		// The following is used to bypass Core Audio and play from a file instead. -- added by dalmazio, October 19, 2008
		//
		// const char *tempName = tempnam("/tmp", NULL);
		// writeOutputToFile(&(tube->sampleRateConverter), inputData, tempName);
		// NSSound *sound = [[[NSSound alloc] initWithContentsOfFile:[NSString stringWithUTF8String:tempName] byReference:YES] autorelease];
		// [sound play];

		[self generateWAVDataWithSampleRateConverter:tube.sampleRateConverter];
		[self startPlaying:tube];
    }
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
    if (sampleRateConverter->maximumSampleValue == 0)
        NSBeep();

    NSMutableData *sampleData = [[NSMutableData alloc] init];

    double scale = (TRMSampleValue_Maximum / sampleRateConverter->maximumSampleValue) * amplitude(m_inputData.inputParameters.volume);

    NSLog(@"number of samples:\t%-d\n", sampleRateConverter->numberSamples);
    NSLog(@"maximum sample value:\t%.4f\n", sampleRateConverter->maximumSampleValue);
    NSLog(@"scale:\t\t\t%.4f\n", scale);
    
    /*  Rewind the temporary file to beginning  */
    rewind(sampleRateConverter->tempFilePtr);

    if (m_inputData.inputParameters.channels == 2) {
		// Calculate left and right channel amplitudes.
		//
		// leftScale = -((inputData->inputParameters.balance / 2.0) - 0.5) * scale * 2.0;
		// rightScale = ((inputData->inputParameters.balance / 2.0) + 0.5) * scale * 2.0;

        // This doesn't have the crackling when at all left or all right, but it's not as loud as Mono by default.
		double leftScale = -((m_inputData.inputParameters.balance / 2.0) - 0.5) * scale;
		double rightScale = ((m_inputData.inputParameters.balance / 2.0) + 0.5) * scale;

        printf("left scale:\t\t%.4f\n", leftScale);
        printf("right scale:\t\t%.4f\n", rightScale);

        for (NSUInteger index = 0; index < sampleRateConverter->numberSamples; index++) {
            double sample;

            fread(&sample, sizeof(sample), 1, sampleRateConverter->tempFilePtr);

            uint16_t value = (short)rint(sample * leftScale);
            [sampleData appendBytes:&value length:sizeof(value)];

            value = (short)rint(sample * rightScale);
            [sampleData appendBytes:&value length:sizeof(value)];
        }
		
    } else {
		
        for (NSUInteger index = 0; index < sampleRateConverter->numberSamples; index++) {
            double sample;

            fread(&sample, sizeof(sample), 1, sampleRateConverter->tempFilePtr);

            uint16_t value = (short)rint(sample * scale);
            [sampleData appendBytes:&value length:sizeof(value)];
        }
    }

    int frameSize = (int)ceil(m_inputData.inputParameters.channels * ((double)TRMBitsPerSample / 8));
    int bytesPerSecond = (int)ceil(m_inputData.inputParameters.outputRate * frameSize);
    
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
    [data appendLittleInt16:m_inputData.inputParameters.channels];
    [data appendLittleInt32:m_inputData.inputParameters.outputRate];
    [data appendLittleInt32:bytesPerSecond];
    [data appendLittleInt16:frameSize];
    [data appendLittleInt16:TRMBitsPerSample];
    [data appendLittleInt16:0];
    
    // Data chunk
    [data appendBigInt32:WAV_DATA_CHUNK_ID];
    [data appendLittleInt32:subChunk2Size];
    
    [data appendData:sampleData];
    
    return [[data copy] autorelease];
}

@synthesize audioPlayer = m_audioPlayer;

- (void)startPlaying:(TRMTubeModel *)tube;
{
    NSError *error = nil;
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithData:[self generateWAVDataWithSampleRateConverter:tube.sampleRateConverter] error:&error];
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

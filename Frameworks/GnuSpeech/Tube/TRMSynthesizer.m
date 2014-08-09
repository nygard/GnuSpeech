//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "TRMSynthesizer.h"

#import <AVFoundation/AVFoundation.h>
#import "MMSynthesisParameters.h"
#import <Tube/Tube.h>

@interface TRMSynthesizer ()
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
    [m_inputData release];
    [m_audioPlayer release];
	
    [super dealloc];
}

#pragma mark -

- (void)setupSynthesisParameters:(MMSynthesisParameters *)synthesisParameters;
{
    m_inputData.inputParameters.outputRate     = synthesisParameters.sampleRate;
    m_inputData.inputParameters.controlRate    = 250;
    m_inputData.inputParameters.volume         = [synthesisParameters masterVolume];
    m_inputData.inputParameters.channels       = [synthesisParameters outputChannels] + 1;
    m_inputData.inputParameters.balance        = [synthesisParameters balance];
    m_inputData.inputParameters.waveform       = [synthesisParameters glottalPulseShape];
    m_inputData.inputParameters.tp             = [synthesisParameters tp];
    m_inputData.inputParameters.tnMin          = [synthesisParameters tnMin];
    m_inputData.inputParameters.tnMax          = [synthesisParameters tnMax];
    m_inputData.inputParameters.breathiness    = [synthesisParameters breathiness];
    m_inputData.inputParameters.length         = [synthesisParameters vocalTractLength];
    m_inputData.inputParameters.temperature    = [synthesisParameters temperature];
    m_inputData.inputParameters.lossFactor     = [synthesisParameters lossFactor];
    m_inputData.inputParameters.apScale        = [synthesisParameters apertureScaling];
    m_inputData.inputParameters.mouthCoef      =  [synthesisParameters mouthCoef];
    m_inputData.inputParameters.noseCoef       = [synthesisParameters noseCoef];
    m_inputData.inputParameters.noseRadius[0]  = 0; // Give it a predictable value.
    m_inputData.inputParameters.noseRadius[1]  = [synthesisParameters n1];
    m_inputData.inputParameters.noseRadius[2]  = [synthesisParameters n2];
    m_inputData.inputParameters.noseRadius[3]  = [synthesisParameters n3];
    m_inputData.inputParameters.noseRadius[4]  = [synthesisParameters n4];
    m_inputData.inputParameters.noseRadius[5]  = [synthesisParameters n5];
    m_inputData.inputParameters.throatCutoff   = [synthesisParameters throatCutoff];
    m_inputData.inputParameters.throatVol      = [synthesisParameters throatVolume];
    m_inputData.inputParameters.usesModulation = [synthesisParameters shouldUseNoiseModulation];
    m_inputData.inputParameters.mixOffset      = [synthesisParameters mixOffset];
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
    inputValues.glottalPitch             = values[0];
    inputValues.glottalVolume            = values[1];
    inputValues.aspirationVolume         = values[2];
    inputValues.fricationVolume          = values[3];
    inputValues.fricationPosition        = values[4];
    inputValues.fricationCenterFrequency = values[5];
    inputValues.fricationBandwidth       = values[6];
    inputValues.radius[0]                = values[7];
    inputValues.radius[1]                = values[8];
    inputValues.radius[2]                = values[9];
    inputValues.radius[3]                = values[10];
    inputValues.radius[4]                = values[11];
    inputValues.radius[5]                = values[12];
    inputValues.radius[6]                = values[13];
    inputValues.radius[7]                = values[14];
    inputValues.velum                    = values[15];
    [m_inputData.values addObject:inputValues];
}

@synthesize shouldSaveToSoundFile = m_shouldSaveToSoundFile;
@synthesize filename = m_filename;

- (NSUInteger)fileType;
{
    return m_inputData.inputParameters.outputFileFormat;
}

- (void)setFileType:(NSUInteger)newFileType;
{
    m_inputData.inputParameters.outputFileFormat = newFileType;
}

- (void)synthesize;
{
    TRMTubeModel *tube = [[[TRMTubeModel alloc] initWithInputData:m_inputData] autorelease];
    if (tube == nil) {
        NSLog(@"Warning: Failed to create tube model.");
        return;
    }

    [tube synthesize];

    if (self.shouldSaveToSoundFile) {
        NSError *error = nil;
        if (![tube saveOutputToFile:self.filename error:&error]) {
            NSLog(@"Failed to save output: %@", error);
        }
    } else {
		[self startPlaying:tube];
    }
}

@synthesize audioPlayer = m_audioPlayer;

- (void)startPlaying:(TRMTubeModel *)tube;
{
    NSData *WAVData = [tube generateWAVData];
    if (WAVData == nil) {
        NSBeep();
    } else {
        NSError *error = nil;
        AVAudioPlayer *audioPlayer = [[[AVAudioPlayer alloc] initWithData:WAVData error:&error] autorelease];
        if (audioPlayer == nil) {
            NSLog(@"error: %@", error);
        } else {
            [self setAudioPlayer:audioPlayer];
            [audioPlayer play];
        }
    }
}

- (void)stopPlaying;
{
    [[self audioPlayer] stop];
    [self setAudioPlayer:nil];
}

@end

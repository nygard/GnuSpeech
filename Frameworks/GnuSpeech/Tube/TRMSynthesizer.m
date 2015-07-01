//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "TRMSynthesizer.h"

#import <AVFoundation/AVFoundation.h>
#import "MMSynthesisParameters.h"
#import <Tube/Tube.h>

@interface TRMSynthesizer ()
@property (strong) AVAudioPlayer *audioPlayer;
@end

#pragma mark -

@implementation TRMSynthesizer
{
    TRMDataList *_inputData;

    BOOL _shouldSaveToSoundFile;
    NSString *_filename;
    AVAudioPlayer *_audioPlayer;
}

- (id)init;
{	
    if ((self = [super init])) {
        _inputData = [[TRMDataList alloc] init];
        
        _inputData.inputParameters.outputFileFormat = 0;
    }
	
    return self;
}

#pragma mark -

- (void)setupSynthesisParameters:(MMSynthesisParameters *)synthesisParameters;
{
    _inputData.inputParameters.outputRate     = synthesisParameters.sampleRate;
    _inputData.inputParameters.controlRate    = 250;
    _inputData.inputParameters.volume         = [synthesisParameters masterVolume];
    _inputData.inputParameters.channels       = [synthesisParameters outputChannels] + 1;
    _inputData.inputParameters.balance        = [synthesisParameters balance];
    _inputData.inputParameters.waveform       = [synthesisParameters glottalPulseShape];
    _inputData.inputParameters.tp             = [synthesisParameters tp];
    _inputData.inputParameters.tnMin          = [synthesisParameters tnMin];
    _inputData.inputParameters.tnMax          = [synthesisParameters tnMax];
    _inputData.inputParameters.breathiness    = [synthesisParameters breathiness];
    _inputData.inputParameters.length         = [synthesisParameters vocalTractLength];
    _inputData.inputParameters.temperature    = [synthesisParameters temperature];
    _inputData.inputParameters.lossFactor     = [synthesisParameters lossFactor];
    _inputData.inputParameters.apScale        = [synthesisParameters apertureScaling];
    _inputData.inputParameters.mouthCoef      =  [synthesisParameters mouthCoef];
    _inputData.inputParameters.noseCoef       = [synthesisParameters noseCoef];
    _inputData.inputParameters.noseRadius[0]  = 0; // Give it a predictable value.
    _inputData.inputParameters.noseRadius[1]  = [synthesisParameters n1];
    _inputData.inputParameters.noseRadius[2]  = [synthesisParameters n2];
    _inputData.inputParameters.noseRadius[3]  = [synthesisParameters n3];
    _inputData.inputParameters.noseRadius[4]  = [synthesisParameters n4];
    _inputData.inputParameters.noseRadius[5]  = [synthesisParameters n5];
    _inputData.inputParameters.throatCutoff   = [synthesisParameters throatCutoff];
    _inputData.inputParameters.throatVol      = [synthesisParameters throatVolume];
    _inputData.inputParameters.usesModulation = [synthesisParameters shouldUseNoiseModulation];
    _inputData.inputParameters.mixOffset      = [synthesisParameters mixOffset];
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
    [_inputData.values removeAllObjects];
}

- (void)addParameters:(TRMParameters *)parameters;
{
    [_inputData.values addObject:parameters];
}

- (NSUInteger)fileType;
{
    return _inputData.inputParameters.outputFileFormat;
}

- (void)setFileType:(NSUInteger)newFileType;
{
    _inputData.inputParameters.outputFileFormat = newFileType;
}

- (void)synthesize;
{
    TRMTubeModel *tube = [[TRMTubeModel alloc] initWithInputData:_inputData];
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

- (void)startPlaying:(TRMTubeModel *)tube;
{
    NSData *WAVData = [tube generateWAVData];
    if (WAVData == nil) {
        NSBeep();
    } else {
        NSError *error = nil;
        AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithData:WAVData error:&error];
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

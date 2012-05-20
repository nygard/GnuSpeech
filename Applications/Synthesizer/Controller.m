//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "Controller.h"
#import <CoreAudio/AudioHardware.h>
#import <math.h>
#import "tube.h"

#define TONE_FREQ (440.0)
//#define TONE_FREQ 400.0
#define SUCCESS 0
#define LOSS_FACTOR_MIN	0.0
#define LOSS_FACTOR_MAX	5.0


//=============================================================================
//	IO Management (from AudioHardware.h documentation)
//
//	These routines allow a client to send and receive data on a given device.
//	They also provide support for tracking where in a stream of data the
//	hardware is at currently.
//=============================================================================

//-----------------------------------------------------------------------------
//	AudioDeviceIOProc
//
//	This is a client supplied routine that the HAL calls to do an
//	IO transaction for a given device. All input and output is presented
//	to the client simultaneously for processing. The inNow parameter
//	is the time that should be used as the basis of now rather than
//	what might be provided by a query to the device's clock. This is necessary
//	because time will continue to advance while this routine is executing
//	making retrieving the current time from the appropriate parameter
//	unreliable for synch operations. The time stamp for theInputData represents
//	when the data was recorded. For the output, the time stamp represents
//	when the first sample will be played. In all cases, each time stamp is
//	accompanied by its mapping into host time.
//
//	The format of the actual data depends of the sample format of the streams
//	on the device as specified by its properties. It may be raw or compressed,
//	interleaved or not interleaved as determined by the requirements of the
//	device and its settings.
//
//	If the data for either the input or the output is invalid, the time stamp
//	will have a value of 0. This happens when a device doesn't have any inputs
//	or outputs.
//
//	On exiting, the IOProc should set the mDataByteSize field of each AudioBuffer
//	(if any) in the output AudioBufferList. On input, this value is set to the
//	size of the buffer, so it will only need to be changed for cases where
//	the number of bytes for the buffer size (kAudioDevicePropertyBufferFrameSize)
//	of the IO transaction. This may be the case for compressed formats like AC-3.
//-----------------------------------------------------------------------------


OSStatus sineIOProc (AudioDeviceID inDevice,
                     const AudioTimeStamp *inNow,
                     const AudioBufferList *inInputData,
                     const AudioTimeStamp *inInputTime,
                     AudioBufferList *outOutputData,
                     const AudioTimeStamp *inOutputTime,
                     void *inClientData)

{
    Controller *controller;
	int size;
	int sampleCount;
	float *buf; // , rate;

	
    controller = (Controller *)inClientData;
    size = outOutputData->mBuffers[0].mDataByteSize;
    sampleCount = size / sizeof(float);
    buf = (float *)malloc(sampleCount * sizeof(float));

	
	int i;
	while (circBuff2Count < 512) ;
	for (i = 0; i < sampleCount/2; i++) {
		buf[2*i] = getCircBuff2();
		buf[2*i+1] = buf[2*i];
	}

	
    memcpy(outOutputData->mBuffers[0].mData, buf, size); // move data
	
    free(buf);
	
    return noErr;
}


@implementation Controller


- (id)init;
{
    if ([super init] == nil)
        return nil;

    _deviceReady = NO;
    _device = kAudioDeviceUnknown;
    _isPlaying = NO;
    toneFrequency = TONE_FREQ;
	NSNotificationCenter *nc;
	nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(sliderMoved:)
			   name:@"SliderMoved"
			 object:nil];
		NSLog(@"Registered Controller as observer with notification centre\n");
	NSLog(@"We have init");
		[nc addObserver:self selector:@selector(handleFricArrowMoved:)
			   name:@"FricArrowMoved"
			 object:nil];
	NSLog(@"Registered noiseSource as FricArrowMoved notification observer");

    return self;
}

- (void)awakeFromNib;
{
    NSLog(@"awaking...");
    // TODO (2012-05-19): Set up number formatters
    [_mainWindow makeKeyAndOrderFront:self];
	toneFrequency = TONE_FREQ;
	//[toneFrequencyTextField setFloatingPointFormat:(BOOL)NO left:(unsigned)4 right:(unsigned)1];
    [toneFrequencyTextField setFloatValue:toneFrequency];
    [toneFrequencySlider setFloatValue:toneFrequency];
	//NSLog(@"Tone Frequency is %f", toneFrequency);
#if 0
	[tubeLengthField setFloatingPointFormat:(BOOL)NO left:(unsigned)2 right:(unsigned)2];
	[temperatureField setFloatingPointFormat:(BOOL)NO left:(unsigned)2 right:(unsigned)2];
	
	[actualLengthField setFloatingPointFormat:(BOOL)NO left:2 right:4];
	[sampleRateField setFloatingPointFormat:(BOOL)NO left:6 right:0];
	[controlPeriodField setFloatingPointFormat:(BOOL)NO left:3 right:0];
	
	[stereoBalanceField setFloatingPointFormat:(BOOL)NO left:(unsigned)2 right:(unsigned)2];
	[breathinessField setFloatingPointFormat:(BOOL)NO left:(unsigned)2 right:(unsigned)2];
	[lossFactorField setFloatingPointFormat:(BOOL)NO left:(unsigned)2 right:(unsigned)2];
	[tpField setFloatingPointFormat:(BOOL)NO left:(unsigned)2 right:(unsigned)2];
	[tnMinField setFloatingPointFormat:(BOOL)NO left:(unsigned)2 right:(unsigned)2];

	[tnMaxField setFloatingPointFormat:(BOOL)NO left:(unsigned)2 right:(unsigned)2];
	[throatCutOff setFloatingPointFormat:(BOOL)NO left:(unsigned)2 right:(unsigned)2];
	[throatVolumeField setFloatingPointFormat:(BOOL)NO left:(unsigned)2 right:(unsigned)2];
	[apertureScalingField setFloatingPointFormat:(BOOL)NO left:(unsigned)2 right:(unsigned)2];
	[mouthCoefField setFloatingPointFormat:(BOOL)NO left:(unsigned)2 right:(unsigned)2];
	[noseCoefField setFloatingPointFormat:(BOOL)NO left:(unsigned)2 right:(unsigned)2];
	[mixOffsetField setFloatingPointFormat:(BOOL)NO left:(unsigned)2 right:(unsigned)2];
	[glottalVolumeField setFloatingPointFormat:(BOOL)NO left:(unsigned)2 right:(unsigned)2];
	[pitchField setFloatingPointFormat:(BOOL)NO left:(unsigned)2 right:(unsigned)2];
	[aspVolField setFloatingPointFormat:(BOOL)NO left:(unsigned)2 right:(unsigned)2];
	[fricVolField setFloatingPointFormat:(BOOL)NO left:(unsigned)2 right:(unsigned)2];
	[fricPosField setFloatingPointFormat:(BOOL)NO left:(unsigned)2 right:(unsigned)1];
	[fricCFField setFloatingPointFormat:(BOOL)NO left:(unsigned)4 right:(unsigned)0];
	[fricBWField setFloatingPointFormat:(BOOL)NO left:(unsigned)3 right:(unsigned)1];
#endif
	[fricativeArrow setFricationPosition:(float)7.0];
	
	[self setDefaults];

	initializeSynthesizer();


}

- (void)setDefaults

{

	//int initSynthResult;
	
	*((double *) getLength()) = LENGTH_DEF;
	*((double *) getTemperature()) = TEMPERATURE_DEF;
	NSLog(@"Controller.m:180 Temperature is %f", *((double *) getTemperature()));
	*((int *) getBalance()) = BALANCE_DEF;
	*((double *) getBreathiness()) = BREATHINESS_DEF;
	*((double *) getLossFactor()) = LOSSFACTOR_DEF;
	*((double *) getTp()) = RISETIME_DEF;
	*((double *) getTnMin()) = FALLTIMEMIN_DEF;
	*((double *) getTnMax()) = FALLTIMEMAX_DEF;
	*((double *) getThroatCutoff()) = THROATCUTOFF_DEF;
	*((double *) getThroatVol()) = THROATVOLUME_DEF;
	*((double *) getApScale()) = APSCALE_DEF;
	*((double *) getMouthCoef()) = MOUTHCOEF_DEF;
	*((double *) getNoseCoef()) = NOSECOEF_DEF;
	*((double *) getMixOffset()) = MIXOFFSET_DEF;
	*((double *) getGlotVol()) = GLOTVOL_DEF;
	*((double *) getGlotPitch()) = GLOTPITCH_DEF;
	*((double *) getAspVol()) = ASPVOL_DEF;
	*((double *) getFricVol()) = FRIC_VOL_DEF;
	*((double *) getFricPos()) = FRIC_POS_DEF;
	*((double *) getFricCF()) = FRIC_CF_DEF;
	*((double *) getFricBW()) = FRIC_BW_DEF;
	

	[tubeLengthField setDoubleValue:*((double *) getLength())];
	[tubeLengthSlider setDoubleValue:*((double *) getLength())];
	[temperatureField setDoubleValue:*((double *) getTemperature())];
	[temperatureSlider setDoubleValue:*((double *) getTemperature())];
	[stereoBalanceField setIntValue:*((int *) getBalance())];
	[breathinessField setDoubleValue:*((double *) getBreathiness())];
	[lossFactorField setDoubleValue:*((double *) getLossFactor())];
	[tpField setDoubleValue:*((double *) getTp())];
	[tnMinField setDoubleValue:*((double *) getTnMin())];
	[tnMaxField setDoubleValue:*((double *) getTnMax())];
	[harmonicsSwitch selectCellAtRow:0 column:1];
	[throatCutOff setDoubleValue:*((double *) getThroatCutoff())];
	[throatVolumeField setDoubleValue:*((double *) getThroatVol())];
	[apertureScalingField setDoubleValue:*((double *) getApScale())];
	[mouthCoefField setDoubleValue:*((double *) getMouthCoef())];
	[noseCoefField setDoubleValue:*((double *) getNoseCoef())];
	[mixOffsetField setDoubleValue:*((double *) getMixOffset())];
	[glottalVolumeField setDoubleValue:*((double *) getGlotVol())];
	[glottalVolumeSlider setDoubleValue:*((double *) getGlotVol())];
	[pitchField setDoubleValue:*((double *) getGlotPitch())];
	NSLog(@"Controller.m:219 glotPitch is %f", *((double *) getGlotPitch()));
	[pitchSlider setDoubleValue:*((double *) getGlotPitch())];
	[aspVolField setDoubleValue:*((double *) getAspVol())];
	[aspVolSlider setDoubleValue:*((double *) getAspVol())];
	[aspVolSlider setMaxValue:ASP_VOL_MAX];
	[fricVolField setDoubleValue:*((double *) getFricVol())];
	[fricVolSlider setDoubleValue:*((double *) getFricVol())];
	[fricPosField setDoubleValue:*((double *) getFricPos())];
	[fricPosSlider setDoubleValue:*((double *) getFricPos())];
	[fricCFField setDoubleValue:*((double *) getFricCF())];
	//NSLog(@"SampleRate prior to fricSliderSet is %f", *((double *) getSampleRate()));
	[fricCFSlider setMaxValue:((double)*((int *) getSampleRate()) / 2.0)];
	[fricCFSlider setMinValue:FRIC_CF_MIN];
	[fricCFSlider setDoubleValue:*((double *) getFricCF())];
	[fricBWField setDoubleValue:*((double *) getFricBW())];
	[fricBWSlider setMaxValue:((double)*((int *) getSampleRate()) / 2.0)];
	[fricBWSlider setMinValue:FRIC_BW_MIN];
	[fricBWSlider setDoubleValue:*((double *) getFricBW())];

	
	//initSynthResult = initializeSynthesizer();
	//if (initSynthResult == SUCCESS) NSLog(@"Controller.m:240 synthesizer initialisation succeeded");
	//NSLog(@"Controller.m:241glotPitch is %f", *((double *) getGlotPitch()));
	
	[rS1 setValue:(*((double *) getRadiusDefault(0)))];
	(*((double *) getRadius(0))) = (*((double *) getRadiusDefault(0)));
	[rS2 setValue:(*((double *) getRadiusDefault(1)))];
	(*((double *) getRadius(1))) = (*((double *) getRadiusDefault(1)));
	[rS3 setValue:(*((double *) getRadiusDefault(2)))];
	(*((double *) getRadius(2))) = (*((double *) getRadiusDefault(2)));
	[rS4 setValue:(*((double *) getRadiusDefault(3)))];
	(*((double *) getRadius(3))) = (*((double *) getRadiusDefault(3)));
	[rS5 setValue:(*((double *) getRadiusDefault(4)))];
	(*((double *) getRadius(4))) = (*((double *) getRadiusDefault(4)));
	[rS6 setValue:(*((double *) getRadiusDefault(5)))];
	(*((double *) getRadius(5))) = (*((double *) getRadiusDefault(5)));
	[rS7 setValue:(*((double *) getRadiusDefault(6)))];
	(*((double *) getRadius(6))) = (*((double *) getRadiusDefault(6)));
	[rS8 setValue:(*((double *) getRadiusDefault(7)))];
	(*((double *) getRadius(7))) = (*((double *) getRadiusDefault(7)));
	NSLog(@"Controller.m:247 Set r8 to %f", (*((double *) getRadiusDefault(7))));
	
	[nS1 setValue:(*((double *) getNoseRadiusDefault(1)))];
	(*((double *) getNoseRadius(1))) = (*((double *) getNoseRadiusDefault(1)));
	[nS2 setValue:(*((double *) getNoseRadiusDefault(2)))];
	(*((double *) getNoseRadius(2))) = (*((double *) getNoseRadiusDefault(2)));
	[nS3 setValue:(*((double *) getNoseRadiusDefault(3)))];
	(*((double *) getNoseRadius(3))) = (*((double *) getNoseRadiusDefault(3)));
	[nS4 setValue:(*((double *) getNoseRadiusDefault(4)))];
	(*((double *) getNoseRadius(4))) = (*((double *) getNoseRadiusDefault(4)));
	[nS5 setValue:(*((double *) getNoseRadiusDefault(5)))];
	(*((double *) getNoseRadius(5))) = (*((double *) getNoseRadiusDefault(5)));
	
	[vS setValue:(*((double *) getVelumRadiusDefault()))];
	(*((double *) getVelumRadius())) = (*((double *) getVelumRadiusDefault()));
	
	
	[self adjustSampleRate];
	
	NSLog(@"Controller.m:262 Sample rate is %d", (*((int *) getSampleRate())));



}


- (IBAction)saveOutputFile:(id)sender
{
	
}


- (float)toneFrequency;
{
    return toneFrequency;
}

- (void)setToneFrequency:(float)newValue;
{
    toneFrequency = newValue;
}

- (IBAction)updateToneFrequency:(id)sender;
{
    float fr;

    fr = [sender floatValue];
    [self setToneFrequency:fr];
    [toneFrequencyTextField setFloatValue:fr];
    [toneFrequencySlider setFloatValue:fr];
}

- (IBAction)playSine:(id)sender;
{
	//threadFlag = [NSThread isMultiThreaded];
	//NSLog(@"Controller.m:322 Is the application multithreaded: answer = %threadFlagFlag is %d", [NSThread isMultiThreaded], threadFlag);
    OSStatus err = noErr;
	

    if (_isPlaying) {
		//NSLog(@"running: Controller.m 176");

		return;
	}
	
	//initializeSynthesizer();

	
	//Make sure the "fixed" parameters get updated (maybe need to change the way they are handled)
	if (*((int *) getThreadFlag()) == 0) initializeSynthesizer(); //  If it is not already running, this includes starting the synthesize thread which also detaches itself
	//NSLog(@"Controller.m:340 threadFlag is %d", *((int *) getThreadFlag()));

    err = AudioDeviceAddIOProc(_device, sineIOProc, (void *)self);
    if (err != noErr)
        return;
	
    err = AudioDeviceStart(_device, sineIOProc);
    if (err != noErr)
        return;
	
    _isPlaying = YES;
	[runStopButton setState:NSOnState];
	[analysis setRunning];
}

- (IBAction)stopPlaying:(id)sender;
{
    OSStatus err = noErr;
	NSLog(@"Stop");
	//NSLog(@"Controller.m:351 Is the application multithreaded: answer = %d threadFlag is %d", [NSThread isMultiThreaded], threadFlag);
	//pthread_testcancel(threadID);  // Stop playing and cancel detached thread

	[runStopButton setState:NSOffState];
	[analysis setRunning];
	//NSLog(@"About to stop thread");


    if (_isPlaying) {
        err = AudioDeviceStop(_device, sineIOProc);
		//NSLog(@"Stopped AudioDevice, error is %d", err);
        if (err != noErr) {
			NSLog(@"Stop has problem with Is Playing");
			return;
		}


        err = AudioDeviceRemoveIOProc(_device, sineIOProc);
		//NSLog(@"Removed AudioDevice, error is %d", err);

        if (err != noErr) {
			NSLog(@"Stop has problem with Is Playing");
			return;
		}

	}
 
	_isPlaying = false;

	NSLog(@"Stop has succeeded");
	//NSLog(@"Controller.m:376 Is the application multithreaded: answer = %d threadFlag is %d", [NSThread isMultiThreaded], threadFlag);

}

// Note: this notification method only takes effect if File's Owner delegate outlet
// is connected to the controller

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
	//double *temp = (double *) getActualTubeLength();
    NSLog(@"Did finish launching...");
    [self setupSoundDevice];
	//NSLog(@"Actual tube length after launch is %f", *((double *) getActualTubeLength()));
	//temp = (double *) getActualTubeLength();
	//NSLog(@"Temp is %f", *temp);
	//[actualLengthField  setDoubleValue:(*((double *) getActualTubeLength()))];
	//[actualLengthField setDoubleValue:*temp];
	//NSLog(@"Actual tube length after launch is %f", *((double *) getActualTubeLength()));
	//NSLog(@"Actual tube length after launch is %f", *((double *) getActualTubeLength()));


    NSLog(@"buffer size : %d", _bufferSize);
	[self setDefaults];

}

- (void)setupSoundDevice;
{
    OSStatus err;
    UInt32 count, bufferSize;
    AudioDeviceID device = kAudioDeviceUnknown;
    AudioStreamBasicDescription format;

    _deviceReady = NO;
    // get the default output device for the HAL
    count = sizeof(AudioDeviceID);
    err = AudioHardwareGetProperty(kAudioHardwarePropertyDefaultOutputDevice, &count, (void *)&device);
    if (err != noErr) {
        NSLog(@"Failed to get default output device");
        return;
    }

    // get the buffersize that the default device uses for IO
    count = sizeof(UInt32);
    err = AudioDeviceGetProperty(device, 0, false, kAudioDevicePropertyBufferSize, &count, &bufferSize);
    if (err != noErr)
        return;

    // get a description of the data format used by the default device
    count = sizeof(AudioStreamBasicDescription);
    err = AudioDeviceGetProperty(device, 0, false, kAudioDevicePropertyStreamFormat, &count, &format);
    if (err != noErr)
        return;

    NSLog(@"format:");
    NSLog(@"sample rate: %f", format.mSampleRate);
    NSLog(@"format id: %d", format.mFormatID);
    NSLog(@"format flags: %x", format.mFormatFlags);
    NSLog(@"bytes per packet: %d", format.mBytesPerPacket);


    // we want linear pcm
    if (format.mFormatID != kAudioFormatLinearPCM)
        return;

    // everything is ok so fill in these globals
    _device = device;
    _bufferSize = bufferSize;
    _format = format;

    _deviceReady = YES;
}

- (UInt32)bufferSize;
{
    return _bufferSize;
}

- (double)sRate; //sampleRate;
{
    //NSLog(@"Setting sample rate");
	if (_deviceReady)
        return _format.mSampleRate;

    return 44100.0;
}


- (IBAction)runButtonPushed:(id)sender
{
	if (_isPlaying == false)

		[self playSine:self];

	else [self stopPlaying:sender];

}


- (IBAction)loadDefaultsButtonPushed:(id)sender
{
	
	[self setDefaults];
	NSNotificationCenter *nc;
	nc = [NSNotificationCenter defaultCenter];
	//NSLog(@"Sending notification SynthDefaultsReloaded");
	[nc postNotificationName:@"SynthDefaultsReloaded" object:self];
	initializeSynthesizer();
	
}

- (IBAction)saveToDefaultsButtonPushed:(id)sender
{
	
}

- (IBAction)loadFileButtonPushed:(id)sender
{
	
}


- (IBAction)glottalWaveformSelected:(id)sender
{
	
}

- (IBAction)noisePulseModulationSelected:(id)sender
{
	
}

- (IBAction)samplingRateSelected:(id)sender
{
	
}

- (IBAction)monoStereoSelected:(id)sender
{
	
}

/*
- (IBAction)tpFieldEntered:(id)sender
{
	
}

- (IBAction)tnMinFieldEntered:(id)sender
{
	
}

- (IBAction)tnMaxFieldEntered:(id)sender
{
	
}

*/

- (IBAction)tubeLengthFieldEntered:(id)sender
{
	int error = 0;
	double tempTubeLength = [tubeLengthField doubleValue];
	if (tempTubeLength > MAX_TUBE_LENGTH) {
		tempTubeLength = MAX_TUBE_LENGTH;
		error = 1;
	}
	if (tempTubeLength < MIN_TUBE_LENGTH) {
		tempTubeLength = MIN_TUBE_LENGTH;
		error = 1;
	}
	//NSLog(@"Controller.m:546 tubeLengthField is %f", tempTubeLength);
	[tubeLengthSlider setDoubleValue:tempTubeLength];
	[tubeLengthField setDoubleValue:tempTubeLength];
	*((double *) getLength()) = tempTubeLength; // (double) [tubeLengthField doubleValue];
	[self adjustSampleRate];
	//NSLog(@"Controller.m:529 Sample rate changed, due to tube length change, to %f", (*((double *) getSampleRate()) / 2.0));
	// Reset maximum value for fricative bandwidth according to sample rate and adjust field and slider if necessary

	initializeSynthesizer();

	[fricCFSlider setMaxValue:(*((double *) getSampleRate()) / 2.0)];
	if ([fricCFField floatValue] > (*((int *) getSampleRate()) / 2.0)) {
		[fricCFField setDoubleValue:(*((int *) getSampleRate()) / 2.0)];
		[fricCFSlider setDoubleValue:(*((int *) getSampleRate()) / 2.0)];
	}
	[fricCFSlider setMaxValue:(*((int *) getSampleRate()) / 2.0)];

	if ([fricBWField floatValue] > (*((int *) getSampleRate()) / 2.0)) {
		[fricBWField setDoubleValue:(*((int *) getSampleRate()) / 2.0)];
		[fricBWSlider setDoubleValue:(*((int *) getSampleRate()) / 2.0)];
	}
	[fricBWSlider setMaxValue:(*((int *) getSampleRate()) / 2.0)];
	
	if (error == 1) NSBeep();
	

}

- (IBAction)temperatureFieldEntered:(id)sender
{

	int error = 0;
	double tempTemp = [temperatureField doubleValue];
	if (tempTemp > MAX_TEMP) {
		tempTemp = MAX_TEMP;
		error = 1;
	}
	if (tempTemp < MIN_TEMP) {
		tempTemp = MIN_TEMP;
		error = 1;
	}

	
	[temperatureSlider setDoubleValue:[temperatureField doubleValue]];
	[temperatureField setDoubleValue:tempTemp];
	*((double *) getTemperature()) = tempTemp;
	[self adjustSampleRate];
	NSLog(@"Controller.m:551 Sample rate changed, due to temperature field change, to %f", (*((double *) getSampleRate()) / 2.0));
	// Reset maximum value for fricative bandwidth according to sample rate and adjust field and slider if necessary

	initializeSynthesizer();


	[fricCFSlider setMaxValue:(*((double *) getSampleRate()) / 2.0)];
	if ([fricCFField floatValue] > (*((double *) getSampleRate()) / 2.0)) {
		[fricCFField setDoubleValue:(*((double *) getSampleRate()) / 2.0)];
	}
	[fricCFSlider setDoubleValue:(*((double *) getSampleRate()) / 2.0)];

	
	if ([fricBWField floatValue] > (*((double *) getSampleRate()) / 2.0)) {
		[fricBWField setDoubleValue:(*((double *) getSampleRate()) / 2.0)];
		[fricBWSlider setDoubleValue:(*((double *) getSampleRate()) / 2.0)];
	}
	[fricBWSlider setMaxValue:(*((double *) getSampleRate()) / 2.0)];
	
	if (error == 1) NSBeep();
	
}

- (IBAction)stereoBalanceFieldEntered:(id)sender
{
	
}

- (IBAction)breathinessFieldEntered:(id)sender
{
	
}

- (IBAction)lossFactorFieldEntered:(id)sender
{
	
	BOOL rangeError = NO;
	
    /*  GET CURRENT ROUNDED VALUE FROM FIELD  */
    double currentValue = ([sender doubleValue]);
	
    /*  MAKE SURE VALUE IS IN RANGE  */
    if (currentValue < LOSS_FACTOR_MIN) {
		rangeError = YES;
		currentValue = LOSS_FACTOR_MIN;
    }
    else if (currentValue > LOSS_FACTOR_MAX) {
		rangeError = YES;
		currentValue = LOSS_FACTOR_MAX;
    }
	
    /*  SET THE FIELD TO THE ROUNDED, CORRECTED VALUE  */
    [sender setFloatValue:currentValue];
	
    /*  IF CURRENT VALUE IS DIFFERENT FROM PREVIOUS VALUE, DEAL WITH IT  */
    if (currentValue != *((double *) getLossFactor())) {
		
		/*  SET INSTANCE VARIABLE  */
		*((double *) getLossFactor()) = currentValue;
		
		initializeSynthesizer();
		
		/*  SET SLIDER TO NEW VALUE  */
		[lossFactorSlider setFloatValue:*((double *) getLossFactor())];
		
		/*  SEND ASPIRATION VOLUME TO SYNTHESIZER  */
		//[synthesizer setAspirationVolume:aspirationVolume];
		//*((double *) getAspVol()) = rint(currentValue);
		NSLog(@"Controller.m:615 lossFactor is %f", *((double *) getLossFactor()));
		
		/*  SET DIRTY BIT  */
		[self setDirtyBit];
		
	}
	
	
	// *((double *) getLossFactor()) = [lossFactorField floatValue];
	// [lossFactorSlider setDoubleValue:*((double *) getLossFactor())];
	// NSLog(@"Controller.m:625 lossFactor is %f", *((double *) getLossFactor()));

}

- (IBAction)throatCutoffFieldEntered:(id)sender
{
	
}

- (IBAction)throatVolumeFieldEntered:(id)sender
{
	
}

- (IBAction)apertureScalingFieldEntered:(id)sender
{
	
}

- (IBAction)mouthApertureCoefficientFieldEntered:(id)sender
{
	
}

- (IBAction)noseApertureCoefficientFieldEntered:(id)sender
{
	
}

- (IBAction)mixOffsetFieldEntered:(id)sender
{
	
}

- (IBAction)n1RadiusFieldEntered:(id)sender
{
	
}

- (IBAction)n2RadiusFieldEntered:(id)sender
{
	
}

- (IBAction)n3RadiusFieldEntered:(id)sender
{
	
}

- (IBAction)n4RadiusFieldEntered:(id)sender
{
	
}

- (IBAction)n5RadiusFieldEntered:(id)sender
{
	
}

- (IBAction)glottalVolumeFieldEntered:(id)sender
{
	
}

- (IBAction)pitchFieldEntered:(id)sender
{
	//[pitchScale drawPitch:(int)pitch Cents:(int)cents Volume:(float)volume];
}

- (IBAction)aspVolFieldEntered:(id)sender
{
	BOOL rangeError = NO;
	
    /*  GET CURRENT ROUNDED VALUE FROM FIELD  */
    int currentValue = (int)rint([sender doubleValue]);
	
    /*  MAKE SURE VALUE IS IN RANGE  */
    if (currentValue < VOLUME_MIN) {
		rangeError = YES;
		currentValue = VOLUME_MIN;
    }
    else if (currentValue > VOLUME_MAX) {
		rangeError = YES;
		currentValue = VOLUME_MAX;
    }
	
    /*  SET THE FIELD TO THE ROUNDED, CORRECTED VALUE  */
    [sender setIntValue:currentValue];
	
    /*  IF CURRENT VALUE IS DIFFERENT FROM PREVIOUS VALUE, DEAL WITH IT  */
    if (currentValue != *((double *) getAspVol())) {
		/*  SET INSTANCE VARIABLE  */
		*((double *) getAspVol()) = rint(currentValue);
		NSLog(@"Controller.m:651 aspVol is %f", *((double *) getAspVol()));
		
		/*  SET SLIDER TO NEW VALUE  */
		[aspVolSlider setIntValue:rint(*((double *) getAspVol()))];
		
		/*  SEND ASPIRATION VOLUME TO SYNTHESIZER  */
		//[synthesizer setAspirationVolume:aspirationVolume];
		
		/*  SET DIRTY BIT  */
		[self setDirtyBit];
    }
	
    /*  BEEP AND HIGHLIGHT FIELD IF RANGE ERROR  */
    if (rangeError) {
		NSBeep();
		//[sender selectText:self];
    } 
	
}

- (IBAction)fricVolFieldEntered:(id)sender
{
	BOOL rangeError = NO;
	
	/*  GET CURRENT VALUE FROM SLIDER  */
    int currentValue = [sender intValue];
	NSLog(@"In fricVolFieldEntered, value %d",currentValue);
	
    /*  CORRECT OUT OF RANGE VALUES  */
    if (currentValue < FRIC_VOL_MIN) {
		rangeError = YES;
		currentValue = FRIC_VOL_MIN;
    }
    else if (currentValue > FRIC_VOL_MAX) {
		rangeError = YES;
		currentValue = FRIC_VOL_MAX;
    }
	
    /*  ADJUST SOUND IF VALUE IS DIFFERENT FROM OLD VALUE  */
    if (currentValue != (int)*((double *) getFricVol())) {
		/*  SET FRICATION VOLUME  */
		*((double *) getFricVol()) = (double)currentValue;
		
		/*  SET FIELD TO VALUE  */
		[fricVolSlider setDoubleValue:*((double *) getFricVol())];
		
		/*  SEND PARAMETER TO THE SYNTHESIZER  */
		//[synthesizer setFricationVolume:fricationVolume];
		*((double *) getFricVol()) = (double)currentValue;
		
		
		/*  SET DIRTY BIT  */
		[self setDirtyBit];
    } 
	if (rangeError) {
		NSBeep();
		[sender setFloatValue:currentValue];
	}
}

- (IBAction)fricPosFieldEntered:(id)sender
{
	BOOL rangeError = NO;
	
    /*  GET CURRENT VALUE FROM FIELD  */
    float currentValue = [sender floatValue];
	
    /*  CORRECT OUT OF RANGE VALUES  */
    if (currentValue < FRIC_POS_MIN) {
		rangeError = YES;
		currentValue = FRIC_POS_MIN;
    }
    else if (currentValue > FRIC_POS_MAX) {
		rangeError = YES;
		currentValue = FRIC_POS_MAX;
    }
	
    /*  IF CURRENT VALUE IS DIFFERENT FROM PREVIOUS VALUE, DEAL WITH IT  */
    if (currentValue != *((double *) getFricPos())) {
		/*  SET INSTANCE VARIABLE  */
		*((double *) getFricPos()) = (int)currentValue;
		//NSLog(@"Controller.m:845 new fricPos field is %f and currentValue is %f", *((double *) getFricPos()), currentValue);
		
		/*  SET SLIDER TO NEW VALUE  */
		[fricPosSlider setFloatValue:*((double *) getFricPos())];
		
		// SET FRICATIVE ARROW TO REQUIRED SPOT
		[self injectFricationAt:(float)currentValue];
		
		/*  SEND FRICATION POSITION TO SYNTHESIZER  */
		//[synthesizer setFricationPosition:fricationPosition];
		
		/*  SET DIRTY BIT  */
		[self setDirtyBit];
    }
	
    /*  BEEP AND HIGHLIGHT FIELD IF RANGE ERROR  */
    if (rangeError) {
		NSBeep();
		[sender setFloatValue:currentValue];
		initializeSynthesizer();

    } 
}

- (IBAction)fricCFFieldEntered:(id)sender
{
	
    BOOL rangeError = NO;
	
    /*  GET CURRENT ROUNDED VALUE FROM FIELD  */
    int currentValue = (int)rint([sender doubleValue]);
	double maxValue = (double)(*((int *) getSampleRate()) / 2.0);
	NSLog(@"In fricCFFieldEntered, value is %d, maxValue is %f, sample rate %f", currentValue, maxValue, *((int *) getSampleRate()));
	
    /*  CORRECT OUT OF RANGE VALUES  */
    if (currentValue < FRIC_CF_MIN) {
		rangeError = YES;
		currentValue = FRIC_CF_MIN;
    }
    else if (currentValue > maxValue) {
		NSLog(@"SampleRate is %f", maxValue);
		rangeError = YES;
		currentValue = (int)maxValue;
    }
	
    /*  SET THE FIELD TO THE ROUNDED, CORRECTED VALUE  */
    [sender setIntValue:currentValue];
	
    /*  IF CURRENT VALUE IS DIFFERENT FROM PREVIOUS VALUE, DEAL WITH IT  */
    if (currentValue != *((double *) getFricCF())) {
		/*  SET INSTANCE VARIABLE  */
		*((double *) getFricCF()) = currentValue;
		
		/*  SET SLIDER TO NEW VALUE  */
		[fricCFSlider setDoubleValue:*((double *) getFricCF())];
		
		/*  DISPLAY NEW FREQUENCY RESPONSE  */
		//[bandpassView drawCenterFrequency:centerFrequency bandwidth:bandwidth sampleRate:[resonantSystem sampleRate] scale:responseScale];
		
		/*  SEND CENTER FREQUENCY TO SYNTHESIZER  */
		//[synthesizer setFricationCenterFrequency:centerFrequency];
		
		/*  SET DIRTY BIT  */
		[self setDirtyBit];
    }
	NSLog(@"Range error is %d", rangeError);
    /*  BEEP AND HIGHLIGHT FIELD IF RANGE ERROR  */
    if (rangeError) {
		NSBeep();
		//[sender selectText:self];
    } 
	
}

- (IBAction)fricBWFieldEntered:(id)sender
{
	BOOL rangeError = NO;
	
    /*  GET CURRENT ROUNDED VALUE FROM FIELD  */
    int currentValue = (int)rint([sender doubleValue]);
	double maxValue = (double)(*((int *) getSampleRate()) / 2.0);
	NSLog(@"In fricBWFieldEntered, value is %d, maxValue is %f, sample rate %d", currentValue, maxValue, *((int *) getSampleRate()));
	
    /*  CORRECT OUT OF RANGE VALUES  */
    if (currentValue < FRIC_BW_MIN) {
		rangeError = YES;
		currentValue = FRIC_BW_MIN;
    }
    else if (currentValue > maxValue) {
		NSLog(@"SampleRate is %f", maxValue);
		rangeError = YES;
		currentValue = (int)maxValue;
    }
	
    /*  SET THE FIELD TO THE ROUNDED, CORRECTED VALUE  */
    [sender setIntValue:currentValue];
	
    /*  IF CURRENT VALUE IS DIFFERENT FROM PREVIOUS VALUE, DEAL WITH IT  */
    if (currentValue != (int)*((double *) getFricBW())) {
		/*  SET INSTANCE VARIABLE  */
		*((double *) getFricBW()) = (double)currentValue;
		
		/*  SET SLIDER TO NEW VALUE  */
		[fricBWSlider setIntValue:(int)*((double *) getFricBW())];
		
		/*  DISPLAY NEW FREQUENCY RESPONSE  */
		//[bandpassView drawCenterFrequency:centerFrequency bandwidth:bandwidth sampleRate:[resonantSystem sampleRate] scale:responseScale];
		
		/*  SEND CENTER FREQUENCY TO SYNTHESIZER  */
		//[synthesizer setFricationCenterFrequency:centerFrequency];
		
		/*  SET DIRTY BIT  */
		[self setDirtyBit];
    }
	NSLog(@"Range error is %d", rangeError);
    /*  BEEP AND HIGHLIGHT FIELD IF RANGE ERROR  */
    if (rangeError) {
		NSBeep();
		//[sender selectText:self];
    } 
	
}


- (IBAction)r1RadiusFieldEntered:(id)sender
{
	
}

- (IBAction)r2RadiusFieldEntered:(id)sender
{
	
}

- (IBAction)r3RadiusFieldEntered:(id)sender
{
	
}

- (IBAction)r4RadiusFieldEntered:(id)sender
{
	
}

- (IBAction)r5RadiusFieldEntered:(id)sender
{
	
}

- (IBAction)r6RadiusFieldEntered:(id)sender
{
	
}

- (IBAction)r7RadiusFieldEntered:(id)sender
{
	
}

- (IBAction)r8RadiusFieldEntered:(id)sender
{
	
}

- (IBAction)vRadiusFieldEntered:(id)sender;
{
	
}

/*

- (IBAction)tpSliderMoved:(id)sender
{
	
}

- (IBAction)tnMinSliderMoved:(id)sender
{
	
}

- (IBAction)tnMaxSliderMoved:(id)sender
{
	
}

*/

- (IBAction)tubeLengthSliderMoved:(id)sender
{
	[tubeLengthField setDoubleValue:[tubeLengthSlider doubleValue]];
	*((double *) getLength()) = (double) [tubeLengthSlider doubleValue];
	[self adjustSampleRate];
	//NSLog(@"Controller.m:944 Sample rate changed, due to tube length change, to %f", (*((double *) getSampleRate()) / 2.0));

	initializeSynthesizer();

	[fricCFSlider setMaxValue:(double)(*((int *) getSampleRate()) / 2.0)];
	if ([fricCFField floatValue] > (float)(*((int *) getSampleRate()) / 2.0)) {
		[fricCFField setDoubleValue:(double)(*((int *) getSampleRate()) / 2.0)];
		[fricCFSlider setDoubleValue:(double)(*((int *) getSampleRate()) / 2.0)];
	}

	
	if ([fricBWField floatValue] > ((float)*((int *) getSampleRate()) / 2.0)) {
		[fricBWField setDoubleValue:((double)*((int *) getSampleRate()) / 2.0)];
		[fricBWSlider setDoubleValue:((double)*((int *) getSampleRate()) / 2.0)];
	}
	[fricBWSlider setMaxValue:((double)*((int *) getSampleRate()) / 2.0)];
	

}

- (IBAction)temperatureSliderMoved:(id)sender
{
	[temperatureField setDoubleValue:[temperatureSlider doubleValue]];
	*((double *) getTemperature()) = (double) [temperatureSlider doubleValue];
	[self adjustSampleRate];
	//NSLog(@"Sample rate changed, due to temperature slider change, to %f", (*((double *) getSampleRate()) / 2.0));

	initializeSynthesizer();

	[fricCFSlider setMaxValue:(double)(*((int *) getSampleRate()) / 2.0)];
	if ([fricCFField floatValue] > (*((int *) getSampleRate()) / 2.0)) {
		[fricCFField setDoubleValue:(double)(*((int *) getSampleRate()) / 2.0)];
		[fricCFSlider setDoubleValue:(double)(*((int *) getSampleRate()) / 2.0)];
	}
	
	
	if ([fricBWField floatValue] > ((float)*((int *) getSampleRate()) / 2.0)) {
		[fricBWField setDoubleValue:((double)*((int *) getSampleRate()) / 2.0)];
		[fricBWSlider setDoubleValue:((double)*((int *) getSampleRate()) / 2.0)];
	}
	[fricBWSlider setMaxValue:((double)*((int *) getSampleRate()) / 2.0)];
	
}

- (IBAction)stereoBalanceSliderMoved:(id)sender
{
	
}

- (IBAction)breathinessSliderMoved:(id)sender
{
	
}

- (IBAction)lossFactorSliderMoved:(id)sender
{
	
	BOOL rangeError = NO;
	
    /*  GET CURRENT ROUNDED VALUE FROM FIELD  */
    double currentValue = ([sender doubleValue]);
	
    /*  MAKE SURE VALUE IS IN RANGE  */
    if (currentValue < LOSS_FACTOR_MIN) {
		rangeError = YES;
		currentValue = LOSS_FACTOR_MIN;
    }
    else if (currentValue > LOSS_FACTOR_MAX) {
		rangeError = YES;
		currentValue = LOSS_FACTOR_MAX;
    }
	
    /*  SET THE FIELD TO THE ROUNDED, CORRECTED VALUE  */
    [sender setFloatValue:currentValue];
	
    /*  IF CURRENT VALUE IS DIFFERENT FROM PREVIOUS VALUE, DEAL WITH IT  */
    if (currentValue != *((double *) getLossFactor())) {
		
	/*  SET INSTANCE VARIABLE  */
		*((double *) getLossFactor()) = currentValue;
		
	initializeSynthesizer();
			
	/*  SET SLIDER TO NEW VALUE  */
		[lossFactorField setFloatValue:*((double *) getLossFactor())];
		
	/*  SEND ASPIRATION VOLUME TO SYNTHESIZER  */
		//[synthesizer setAspirationVolume:aspirationVolume];
		//*((double *) getAspVol()) = rint(currentValue);
		NSLog(@"Controller.m:1059 lossFactor is %f", *((double *) getLossFactor()));
		
		/*  SET DIRTY BIT  */
		[self setDirtyBit];
		
		}
	
	// *((double *) getLossFactor()) = [lossFactorSlider floatValue];
	// [lossFactorField setDoubleValue:*((double *) getLossFactor())];

}

- (IBAction)throatCutoffSliderMoved:(id)sender
{
	
}

- (IBAction)throatVolumeSliderMoved:(id)sender
{
	
}

- (IBAction)apertureScalingSliderMoved:(id)sender
{
	
}

- (IBAction)mouthApertureCoefficientSliderMoved:(id)sender
{
	
}

- (IBAction)noseApertureCoefficientSliderMoved:(id)sender
{
	
}

- (IBAction)mixOffsetSliderMoved:(id)sender
{
	
}

- (IBAction)n1RadiusSliderMoved:(id)sender
{
	
}

- (IBAction)n2RadiusSliderMoved:(id)sender
{
	
}

- (IBAction)n3RadiusSliderMoved:(id)sender
{
	
}

- (IBAction)n4RadiusSliderMoved:(id)sender
{
	
}

- (IBAction)n5RadiusSliderMoved:(id)sender
{
	
}

- (IBAction)glottalVolumeSliderMoved:(id)sender
{
	
}

/*
- (IBAction)pitchSliderMoved:(id)sender
{
	*((double *) getGlotPitch()) = (double) [pitchSlider floatValue];
	NSLog(@"Pitch is now %f", *((double *) getGlotPitch()));
}
*/

- (IBAction)aspVolSliderMoved:(id)sender
{
	BOOL rangeError = NO;
	
    /*  GET CURRENT ROUNDED VALUE FROM FIELD  */
    int currentValue = (int)rint([sender doubleValue]);
	
    /*  MAKE SURE VALUE IS IN RANGE  */
    if (currentValue < VOLUME_MIN) {
		rangeError = YES;
		currentValue = VOLUME_MIN;
    }
    else if (currentValue > VOLUME_MAX) {
		rangeError = YES;
		currentValue = VOLUME_MAX;
    }
	
    /*  SET THE FIELD TO THE ROUNDED, CORRECTED VALUE  */
    [sender setIntValue:rint(currentValue)];
	
    /*  IF CURRENT VALUE IS DIFFERENT FROM PREVIOUS VALUE, DEAL WITH IT  */
    if (currentValue != *((double *) getAspVol())) {
		/*  SET INSTANCE VARIABLE  */
		*((double *) getAspVol()) = currentValue;
		
		/*  SET SLIDER TO NEW VALUE  */
		[aspVolField setDoubleValue:rint(*((double *) getAspVol()))];
		
		/*  SEND ASPIRATION VOLUME TO SYNTHESIZER  */
		//[synthesizer setAspirationVolume:aspirationVolume];
		//*((double *) getAspVol()) = rint(currentValue);
		NSLog(@"Controller.m:1059 aspVol is %f", *((double *) getAspVol()));
		
		/*  SET DIRTY BIT  */
		[self setDirtyBit];
    }
	
    /*  BEEP AND HIGHLIGHT FIELD IF RANGE ERROR  */
    if (rangeError) {
		NSBeep();
		//[sender selectText:self];
    } 
	
}

- (IBAction)fricVolSliderMoved:(id)sender
{
	BOOL rangeError = NO;
	
    /*  GET CURRENT VALUE FROM FIELD  */
    int currentValue = rint([sender doubleValue]);
	NSLog(@"Controller.m:1089 In fricVolSliderMoved %d", currentValue);

	
    /*  CORRECT OUT OF RANGE VALUES  */
    if (currentValue < FRIC_VOL_MIN) {
		rangeError = YES;
		currentValue = FRIC_VOL_MIN;
    }
    else if (currentValue > FRIC_VOL_MAX) {
		rangeError = YES;
		currentValue = FRIC_VOL_MAX;
    }
	
    /*  SET THE FIELD TO THE ROUNDED, CORRECTED VALUE  */
    [fricVolField setIntValue:currentValue];
	
    /*  IF CURRENT VALUE IS DIFFERENT FROM PREVIOUS VALUE, DEAL WITH IT  */
    if (currentValue != (int)*((double *) getFricVol())) {
		/*  SET INSTANCE VARIABLE  */
		*((double *) getFricVol()) = (double)currentValue;
		
		/*  SET SLIDER TO NEW VALUE  */
		[fricVolField setDoubleValue:*((double *) getFricVol())];
		
		/*  SEND FRICATION VOLUME TO SYNTHESIZER  */
		//[synthesizer setFricationVolume:fricationVolume];
		//*((float *) getFricVol());
		
		/*  SET DIRTY BIT  */
		[self setDirtyBit];
    }
	
    /*  BEEP AND HIGHLIGHT FIELD IF RANGE ERROR  */
    if (rangeError)
		NSBeep();
	//	[sender selectText:self];
    //} 
}

- (IBAction)fricPosSliderMoved:(id)sender
{
	BOOL rangeError = NO;
	
    //  GET CURRENT VALUE FROM SLIDER  
    double currentValue = [sender floatValue];
	NSLog(@"In fricPosSliderMoved value %f", currentValue);
	
    //  CORRECT OUT OF RANGE VALUES  
    if (currentValue < FRIC_POS_MIN) {
		rangeError = YES;
		currentValue = FRIC_POS_MIN;
    }
    else if (currentValue > FRIC_POS_MAX) {
		rangeError = YES;
		currentValue = FRIC_POS_MAX;
    }
	
    /*  IF CURRENT VALUE IS DIFFERENT FROM PREVIOUS VALUE, DEAL WITH IT  */
    if (currentValue != *((double *) getFricPos())) {
		/*  SET INSTANCE VARIABLE  */
		*((double *) getFricPos()) = (double)currentValue;
		//NSLog(@"Controller.m:1319 new fricPos slider is %d and currentValue is %f", *((double *) getFricPos()), currentValue);
		
		/*  SET POSITION FIELD TO NEW VALUE  */
		[fricPosField setFloatValue:(float)(*((double *) getFricPos()))];
		
		// SET FRICATIVE ARROW TO REQUIRED SPOT
		[self injectFricationAt:(float)currentValue];
		
		/*  DISPLAY POSITION OF FRICATION IN RESONANT SYSTEM  */
		//[resonantSystem injectFricationAt:fricationPosition];
		
		/*  SEND FRICATION POSITION TO SYNTHESIZER  */
		//[synthesizer setFricationPosition:fricationPosition];
		
		/*  SET DIRTY BIT  */
		[self setDirtyBit];
    }
	
    /*  BEEP AND HIGHLIGHT FIELD IF RANGE ERROR  */
    if (rangeError) {
		NSBeep();
		[sender setFloatValue:currentValue];
		//[sender selectText:self];
    } 
	
}

- (IBAction)fricCFSliderMoved:(id)sender
{
	
    BOOL rangeError = NO;
	
    /*  GET CURRENT ROUNDED VALUE FROM SLIDER  */
    int currentValue = rint([sender doubleValue]);
	double maxValue = (double)(*((int *) getSampleRate()) / 2.0);
	NSLog(@"In fricCFSliderMoved, value is %d, maxValue is %f, sample rate %d", currentValue, maxValue, *((int *) getSampleRate()));
	
    /*  CORRECT OUT OF RANGE VALUES  */
    if (currentValue < FRIC_CF_MIN) {
		rangeError = YES;
		currentValue = FRIC_CF_MIN;
    }
    else if (currentValue > (int)maxValue) {
		NSLog(@"SampleRate is %f", maxValue);
		rangeError = YES;
		currentValue = maxValue;
    }
	
    /*  SET THE SLIDER TO THE ROUNDED, CORRECTED VALUE  */
    [sender setIntValue:currentValue];
	
    /*  IF CURRENT VALUE IS DIFFERENT FROM PREVIOUS VALUE, DEAL WITH IT  */
    if (currentValue != (int)*((double *) getFricCF())) {
		/*  SET INSTANCE VARIABLE  */
		*((double *) getFricCF()) = currentValue;
		
		/*  SET FIELD TO NEW VALUE  */
		[fricCFField setDoubleValue:*((double *) getFricCF())];
		
		/*  DISPLAY NEW FREQUENCY RESPONSE  */
		//[bandpassView drawCenterFrequency:centerFrequency bandwidth:bandwidth sampleRate:[resonantSystem sampleRate] scale:responseScale];
		
		/*  SEND CENTER FREQUENCY TO SYNTHESIZER  */
		//[synthesizer setFricationCenterFrequency:centerFrequency];
		
		/*  SET DIRTY BIT  */
		[self setDirtyBit];
    }
	NSLog(@"Range error is %d", rangeError);
    /*  BEEP AND HIGHLIGHT FIELD IF RANGE ERROR  */
    if (rangeError) {
		NSBeep();
		//[sender selectText:self];
    } 
	
	
}

- (IBAction)fricBWSliderMoved:(id)sender
{
	BOOL rangeError = NO;
	
    /*  GET CURRENT ROUNDED VALUE FROM SLIDER  */
    int currentValue = rint([sender doubleValue]);
	double maxValue = (double)(*((int *) getSampleRate()) / 2.0);
	NSLog(@"In fricBWSliderMoved, value is %d, maxValue is %f, sample rate %d", currentValue, maxValue, *((int *) getSampleRate()));
	
    /*  CORRECT OUT OF RANGE VALUES  */
    if (currentValue < FRIC_BW_MIN) {
		rangeError = YES;
		currentValue = FRIC_BW_MIN;
    }
    else if (currentValue > (int)maxValue) {
		NSLog(@"SampleRate is %f", maxValue);
		rangeError = YES;
		currentValue = maxValue;
    }
	
    /*  SET THE SLIDER TO THE ROUNDED, CORRECTED VALUE  */
    [sender setIntValue:currentValue];
	
    /*  IF CURRENT VALUE IS DIFFERENT FROM PREVIOUS VALUE, DEAL WITH IT  */
    if (currentValue != (int)*((double *) getFricBW())) {
		/*  SET INSTANCE VARIABLE  */
		*((double *) getFricBW()) = (double)currentValue;
		
		/*  SET FIELD TO NEW VALUE  */
		[fricBWField setDoubleValue:*((double *) getFricBW())];
		
		/*  DISPLAY NEW FREQUENCY RESPONSE  */
		//[bandpassView drawCenterFrequency:centerFrequency bandwidth:bandwidth sampleRate:[resonantSystem sampleRate] scale:responseScale];
		
		/*  SEND CENTER FREQUENCY TO SYNTHESIZER  */
		//[synthesizer setFricationCenterFrequency:centerFrequency];
		
		/*  SET DIRTY BIT  */
		[self setDirtyBit];
    }
	NSLog(@"Range error is %d", rangeError);
    /*  BEEP AND HIGHLIGHT FIELD IF RANGE ERROR  */
    if (rangeError) {
		NSBeep();
		//[sender selectText:self];
    } 
	
}

- (IBAction)r1RadiusSliderMoved:(id)sender
{
	
}

- (IBAction)r2RadiusSliderMoved:(id)sender
{
	
}

- (IBAction)r3RadiusSliderMoved:(id)sender
{
	
}

- (IBAction)r4RadiusSliderMoved:(id)sender
{
	
}

- (IBAction)r5RadiusSliderMoved:(id)sender
{
	
}

- (IBAction)r6RadiusSliderMoved:(id)sender
{
	
}

- (IBAction)r7RadiusSliderMoved:(id)sender
{
	
}

- (IBAction)r8RadiusSliderMoved:(id)sender
{
	
}

- (IBAction)vSliderMoved:(id)sender
{
	
}

- (void)sliderMoved:(NSNotification *)originator

// This method handles the section sliders associated with nose, velum and oropharynx sections
// based on a notification from the associated slider object which also supplies tag info.  The
// slider objects that need attention (TubeSection and VelumSlider) post a notification and this
// method picks it up and deals with it.

{

	int sectionId;
	float radius;
	
	sectionId = [[[originator userInfo] objectForKey:@"sliderId"] shortValue];
	radius = [[[originator userInfo] objectForKey:@"radius"] floatValue];
	//NSLog(@"In sliderMoved id is %d and radius is %f", sectionId, radius);
	if (sectionId == 14) {
		*((double *) getVelumRadius()) = (double) radius;
	}	
	else {
		if (sectionId > 8) {
		*((double *) getNoseRadius(sectionId - 8)) = (double) radius;
			//NSLog(@"Nasal section ID is %d radius %f", sectionId, radius);
		}

		else {
			*((double *) getRadius(sectionId - 1)) = (double) radius;
			//NSLog(@"Current oral section is R%d and radius %f", sectionId, *((double *) getRadius(sectionId - 1)));
			}
	}
}

- (void)setDirtyBit
{
	
}

/*  Set methods to link Objective-C code and C modules  */

- (void)csetGlotPitch:(float) value
{
	setGlotPitch(value);
}

- (void)csetGlotVol:(float) value
{
	
}

- (void)csetAspVol:(float) value
{
	
}

- (void)csetFricVol:(float) value
{
	
}

- (void)csetfricPos:(float) value
{
	
}

- (void)csetFricCF:(float) value
{
	
}

- (void)csetFricBW:(float) value
{
	
}

- (void)csetRadius:(float) value: (int) index
{
	
}

- (void)csetVelum:(float) value
{
	
}

- (void)csetVolume:(double) value
{
	
}

- (void)csetWaveform:(int) value
{
	
}

- (void)csetTp:(double) value
{
	
}

- (void)csetTnMin:(double) value
{
	
}

- (void)csetTnMax:(double) value
{
	
}

- (void)csetBreathiness:(double) value
{
	
}

- (void)csetLength:(double) value
{
	
}

- (void)csetTemperature:(double) value
{
	
}

- (void)csetLossFactor:(double) value
{
	
}

- (void)csetApScale:(double) value
{
	
}

- (void)csetMouthCoef:(double) value
{
	
}

- (void)csetNoseCoef:(double) value
{
	
}

- (void)csetNoseRadius:(double) value: (int) index
{
	
}

- (void)csetThroatCoef:(double) value
{
	
}

- (void)csetModulation:(int) value
{
	
}

- (void)csetMixOffset:(double) value
{
	
}

- (void)csetThroatCutoff:(double) value
{
	
}

- (void)csetThroatVolume:(double) value
{
	
}

- (void)adjustToNewSampleRate
{
    int nyquistFrequency;
	
	NSLog(@"Controller.m:1525 In Controller: adjusting to new sample rate");
	
    /* CALCULATE NYQUIST FREQUENCY  */
    nyquistFrequency = (int)rint(*((int *) getSampleRate()) / 2.0);
	//NSLog(@"Controller.m:1529 Nyquist freq is %d", nyquistFrequency);
	
    /*  SET THE MAXIMUM FOR THE SLIDERS  */
    [mouthCoefSlider setMaxValue:nyquistFrequency];
    [noseCoefSlider setMaxValue:nyquistFrequency];
	
    /*  CHANGE MOUTH FILTER COEFFICIENT, IF NECESSARY  */
    if (*((double *) getMouthCoef()) > nyquistFrequency) {
		*((double *) getMouthCoef()) = nyquistFrequency;
		
		/*  RE-INITIALIZE MOUTH FILTER OBJECTS  */
		[mouthCoefSlider setDoubleValue:*((double *) getMouthCoef())];
		[mouthCoefField setDoubleValue:*((double *) getMouthCoef())];
		//[synthesizer setMouthFilterCoefficient:mouthFilterCoefficient]; **** 
    }
	
    /*  CHANGE NOSE FILTER COEFFICIENT, IF NECESSARY  */
    if (*((double *) getNoseCoef()) > nyquistFrequency) {
		*((double *) getNoseCoef()) = nyquistFrequency;
		
		/*  RE-INITIALIZE NOSE FILTER OBJECTS  */
		[noseCoefSlider setDoubleValue:*((double *) getNoseCoef())];
		[noseCoefField setDoubleValue:*((double *) getNoseCoef())];
		//[synthesizer setNoseFilterCoefficient:noseFilterCoefficient]; **** 
    }
	
    /*  RE-DISPLAY APERTURE FREQUENCY RESPONSES  */
    //[mouthFrequencyResponse drawFrequencyResponse:mouthFilterCoefficient sampleRate:sampleRate scale:mouthResponseScale]; **** 
    //[noseFrequencyResponse drawFrequencyResponse:noseFilterCoefficient sampleRate:sampleRate scale:noseResponseScale]; **** 
	
	// Redisplay tube sample rate and control period

    [sampleRateField setIntValue:*((int *) getSampleRate())];
    [controlPeriodField setIntValue:*((int *) getControlPeriod())];
	
}



- (void)adjustSampleRate
{
    /*  CALCULATE SAMPLE RATE, CONTROL PERIOD, ACTUAL LENGTH  */
    [self calculateSampleRate];
	
    /*  DISPLAY THESE VALUES  */
    [actualLengthField setDoubleValue:*((double *) getActualTubeLength())];
    [sampleRateField setIntValue:*((int *) getSampleRate())];
    [controlPeriodField setIntValue:*((int *) getControlPeriod())];
	
    /*  REDISPLAY APERTURE, NOISE SOURCE, AND THROAT FREQUENCY RESPONSES  */
    [self adjustToNewSampleRate];
    //[noiseSource adjustToNewSampleRate]; **** 
    //[throat adjustToNewSampleRate]; **** 
	
    /*  SEND APPROPRIATE VALUES TO THE SYNTHESIZER  */
    //[synthesizer setActualLength:actualLength sampleRate:sampleRate controlPeriod:controlPeriod]; **** 
	
    
    /*  SET DIRTY BIT  */
    [self setDirtyBit]; 
}


- (void)injectFricationAt:(float)position
{
    /*  DRAW ARROW WHERE FRICATION IS TO BE INJECTED  */
    [fricativeArrow setFricationPosition:position]; 
}


- (void)setTitle:(NSString *)path
{
    [_mainWindow setTitleWithRepresentedFilename:path];
}

- (void)calculateSampleRate
{
    double c; //, speedOfSound();
	
	//NSLog(@"Controller.m:1582 Control period is %d sample rate is %d actual tube length is %f control rate is %f temperature is %f",
		 // *((int *) getControlPeriod()), *((int *) getSampleRate()), *((double *) getLength()), *((float *) getControlRate()), *((double *) getTemperature()));
	
    /*  CALCULATE THE SPEED OF SOUND AT CURRENT TEMPERATURE  */
    c = (331.4 + (0.6 * *((double *) getTemperature())));
	//NSLog(@"Controller.m:1587 Speed of Sound is %f control rate is %f", c, *((float *) getControlRate()));

	/*  CALCULATE THE CONTROL PERIOD  */
    *((int *) getControlPeriod()) = (int)rint((c * TOTAL_SECTIONS * 100.0) /
											  (*((double *) getLength()) * *((float *) getControlRate()))); //CONTROL_RATE));

	NSLog(@"Controller.m:1593 Control period is %d sample rate is %d actual tube length is %f",
		  *((int *) getControlPeriod()), *((int *) getSampleRate()), *((double *) getLength()));

											  
    /*  CALCULATE THE NEAREST SAMPLE RATE  */
    *((int *) getSampleRate()) = *((int *) getControlPeriod()) * *((float *) getControlRate()); // CONTROL_RATE * *((int *) getControlPeriod());

	//NSLog(@"Controller.m:1599 Control period is %d sample rate is %d actual tube length is %f",
		 // *((int *) getControlPeriod()), *((int *) getSampleRate()), *((double *) getLength()));
	
    /*  CALCULATE THE ACTUAL LENGTH OF THE TUBE  */
   *((double *) getActualTubeLength()) = (c * TOTAL_SECTIONS * 100.0) / *((int *) getSampleRate());
											
	//NSLog(@"In Controller.m 1606: Control period is %d sample rate is %d actual tube length is %f",
		 // *((int *) getControlPeriod()), *((int *) getSampleRate()), *((double *) getLength()));
}

- (void)handleFricArrowMoved:(NSNotification *)note
{
	NSLog(@"Controller.m:1612 Received FricArrowMoved notification: %@", note);
	
	/*  GET CURRENT VALUE FROM SLIDER  */
    float currentValue = [[note object] floatValue];
	
    /*  IF CURRENT VALUE IS DIFFERENT FROM PREVIOUS VALUE, DEAL WITH IT  */
    if (currentValue != *((double *) getFricPos())) {
		/*  SET INSTANCE VARIABLE  */
		*((double *) getFricPos()) = currentValue;
		NSLog(@"fricationPosition = %f", *((double *) getFricPos()));
		
		/*  SET FIELD TO VALUE  */
		[fricPosField setIntValue:currentValue];
		
		
		/*  SET SLIDER TO NEW VALUE  */
		[fricPosSlider setFloatValue:*((double *) getFricPos())];
		
		/*  SEND FRICATION POSITION TO SYNTHESIZER  */
		//[synthesizer setFricationPosition:fricationPosition];
		*((double *) getFricPos()) = currentValue;
		
		
		/*  SET DIRTY BIT  */
		[self setDirtyBit];
		}
    }
	
- (BOOL)tubeRunState
{
	return _isPlaying;
}

@end

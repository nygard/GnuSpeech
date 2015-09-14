//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

/*
 * Revision 1.11 2014-08-16
 * Added a panel etc. to allow Monet postures to be loaded. Implemented apScale fields &
 * slider. Added write/read "all parameters" record (.trmp files). Added breathiness
 * control. Updated oral/nasal tube control fields to "with NumberFormatter".changed damping & apScale
 * defaults. Note, field tags are used for identification of "sender" when several fields call
 * the same routine.
 *

 */

#import "Controller.h"
#import <CoreAudio/AudioHardware.h>
#import <math.h>
#import "tube.h"
#import "PitchScale.h"
#import "VelumSlider.h"
#import "PitchScale.h"

#define TONE_FREQ (440.0)
//#define TONE_FREQ 400.0
#define SUCCESS 0
#define LOSS_FACTOR_MIN	0.0
#define LOSS_FACTOR_MAX	5.0
#define BREATHINESS_MIN 0.0
#define BREATHINESS_MAX 10.0



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
    //Controller *controller = (Controller *)inClientData;
    int size = outOutputData->mBuffers[0].mDataByteSize;
    int sampleCount = size / sizeof(float);
    float *buf = (float *)malloc(sampleCount * sizeof(float));
    
	
	while (circBuff2Count < 512) ;
	for (int i = 0; i < sampleCount/2; i++) {
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
    if ((self = [super init])) {
        _deviceReady = NO;
        _device = kAudioDeviceUnknown;
        _isPlaying = NO;
        toneFrequency = TONE_FREQ;
        NSNotificationCenter *nc;
        nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(sliderMoved:) //This allows the Controller to note tube section changes
                   name:@"SliderMoved"
                 object:nil];
		NSLog(@"Registered Controller as observer with notification centre\n");
        NSLog(@"We have init");
		
        [nc addObserver:self selector:@selector(handleFricArrowMoved:) // Ditto for the fricative slider
                   name:@"FricArrowMoved"
                 object:nil];
        NSLog(@"Registered noiseSource as FricArrowMoved notification observer");
        

       
        /*
        [nc addObserver:PitchScale selector:@selector(handlePitchChanged:) // Ditto for the pitch display
                   name:@"pitchChanged"
                 object:nil];
        NSLog(@"Registered pitchScale as pitchChanged notification observer");
       
        [nc addObserver:ApFrequencyResponse selector:@selector(handleNoseCoefChanged:) // Ditto for the nose coefficient
                   name:@"handleNoseCoefChanged"
                 object:nil];
        NSLog(@"Registered apFrequencyRespone as HandleNoseCoefChanged notification observer");
        
        [nc addObserver:ApFrequencyResponse selector:@selector(handleMouthCoefChanged:) // Ditto for the mouth coefficient
                   name:@"handleMouthCoeffChanged"
                 object:nil];
        NSLog(@"Registered ApFrequencyResponse as handleMouthCoefChanged notification observer");
        */
    }

    return self;
}

- (void)awakeFromNib;
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    // TODO (2012-05-19): Set up number formatters
    [_mainWindow makeKeyAndOrderFront:self];
	toneFrequency = TONE_FREQ;
	//[toneFrequencyTextField setFloatingPointFormat:NO left:4 right:1];
    [toneFrequencyTextField setFloatValue:toneFrequency];
    [toneFrequencySlider setFloatValue:toneFrequency];
	//NSLog(@"Tone Frequency is %f", toneFrequency);
#if 0
	[tubeLengthField      setFloatingPointFormat:NO left:2 right:2];
	[temperatureField     setFloatingPointFormat:NO left:2 right:2];
	
	[actualLengthField    setFloatingPointFormat:NO left:2 right:4];
	[sampleRateField      setFloatingPointFormat:NO left:6 right:0];
	[controlPeriodField   setFloatingPointFormat:NO left:3 right:0];
	
	[stereoBalanceField   setFloatingPointFormat:NO left:2 right:2];
	[breathinessField     setFloatingPointFormat:NO left:2 right:2];
	[lossFactorField      setFloatingPointFormat:NO left:2 right:2];
	[tpField              setFloatingPointFormat:NO left:2 right:2];
	[tnMinField           setFloatingPointFormat:NO left:2 right:2];

	[tnMaxField           setFloatingPointFormat:NO left:2 right:2];
	[throatCutOff         setFloatingPointFormat:NO left:2 right:2];
	[throatVolumeField    setFloatingPointFormat:NO left:2 right:2];
    [apertureRadiusField    setFloatingPointFormat:NO left:2 right:2];
    [apertureDiameterField  setFloatingPointFormat:NO left:2 right:2];
	[apertureAreaField      setFloatingPointFormat:NO left:2 right:2];
	[apertureScalingField setFloatingPointFormat:NO left:2 right:2];
    [dampingFactorField   setFloatingPointFormat:NO left:2 right:2];
	[mouthCoefField       setFloatingPointFormat:NO left:2 right:2];
	[noseCoefField        setFloatingPointFormat:NO left:2 right:2];
	[mixOffsetField       setFloatingPointFormat:NO left:2 right:2];
	[glottalVolumeField   setFloatingPointFormat:NO left:2 right:2];
	[pitchField           setFloatingPointFormat:NO left:2 right:2];
	[aspVolField          setFloatingPointFormat:NO left:2 right:2];
	[fricVolField         setFloatingPointFormat:NO left:2 right:2];
	[fricPosField         setFloatingPointFormat:NO left:2 right:1];
	[fricCFField          setFloatingPointFormat:NO left:4 right:0];
	[fricBWField          setFloatingPointFormat:NO left:3 right:1];
#endif
	[fricativeArrow setFricationPosition:(float)7.0];
	
	[self setDefaults];

	initializeSynthesizer();

}

- (void)setDefaults;
{
	//int initSynthResult;

	*((double *) getLength()) = LENGTH_DEF;
	*((double *) getTemperature()) = TEMPERATURE_DEF;
	NSLog(@"Controller.m:180 Temperature is %f", *((double *) getTemperature()));
	*((int *) getBalance()) = BALANCE_DEF;
	*((double *) getBreathiness()) = BREATHINESS_DEF;
	*((double *) getLossFactor()) = LOSSFACTOR_DEF;
    [lossFactorSlider setFloatValue:LOSSFACTOR_DEF];
    [dampingFactorField setFloatValue:(1-LOSSFACTOR_DEF/100)];
	*((double *) getTp()) = RISETIME_DEF;
	*((double *) getTnMin()) = FALLTIMEMIN_DEF;
	*((double *) getTnMax()) = FALLTIMEMAX_DEF;
	*((double *) getThroatCutoff()) = THROATCUTOFF_DEF;
    [throatCutoffSlider setFloatValue:THROATCUTOFF_DEF];
	*((double *) getThroatVol()) = THROATVOLUME_DEF;
	*((double *) getApScale()) = APSCALE_DEF;
	*((double *) getMouthCoef()) = MOUTHCOEF_DEF;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"MouthCoefChanged" object:self];
	*((double *) getNoseCoef()) = NOSECOEF_DEF;
    //NSLog(@"Sending coefChanged notification");
    [nc postNotificationName:@"NoseCoefChanged" object:self];
	*((double *) getMixOffset()) = MIXOFFSET_DEF;
	*((double *) getGlotVol()) = GLOTVOL_DEF;
	*((double *) getGlotPitch()) = GLOTPITCH_DEF;
     //NSLog(@"Sending pitchChanged notification");
     [nc postNotificationName:@"pitchChanged" object:self];
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
	[lossFactorField setDoubleValue:*((double *) getLossFactor())*100];
    [dampingFactorField setDoubleValue:(1.00 - (*((double *) getLossFactor())
        / 100.00))*100];
	[tpField setDoubleValue:*((double *) getTp())];
	[tnMinField setDoubleValue:*((double *) getTnMin())];
	[tnMaxField setDoubleValue:*((double *) getTnMax())];
	[harmonicsSwitch selectCellAtRow:0 column:1];
	[throatCutoffField setDoubleValue:*((double *) getThroatCutoff())];
	[throatVolumeField setDoubleValue:*((double *) getThroatVol())];
    [throatVolumeSlider setDoubleValue:*((double *) getThroatVol())];
    [apertureRadiusField    setDoubleValue:(*((double *) getApScale()))/2];
    [apertureDiameterField  setDoubleValue:(*((double *) getApScale()))];
	[apertureAreaField      setDoubleValue:(*((double *) getApScale()))
        * (*((double *) getApScale())) * PI];
	[mouthCoefField setDoubleValue:*((double *) getMouthCoef())];
    [mouthCoefSlider setDoubleValue:*((double *) getMouthCoef())];
	[noseCoefField setDoubleValue:*((double *) getNoseCoef())];
    [noseCoefSlider setDoubleValue:*((double *) getNoseCoef())];

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
    [fricCFSlider setDoubleValue:*((double *) getFricCF())];
    NSLog(@"FricCFSlider set to %f", *((double *) getFricCF()));
	[fricCFSlider setMaxValue:((double)*((int *) getSampleRate()) / 2.0)];
	[fricBWField setDoubleValue:*((double *) getFricBW())];
	[fricBWSlider setMaxValue:((double)*((int *) getSampleRate()) / 2.0)];
	[fricBWSlider setMinValue:FRIC_BW_MIN];
	[fricBWSlider setDoubleValue:*((double *) getFricBW())];
	
    
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

#if 0
    // TODO (2012-05-19): Deal with this error.
	[vS setValue:(*((double *) getVelumRadiusDefault()))];
	(*((double *) getVelumRadius())) = (*((double *) getVelumRadiusDefault()));
#endif
	
	[postureLabel setStringValue:@"ee"];
	[self adjustSampleRate];
	
	NSLog(@"Controller.m:262 Sample rate is %d", (*((int *) getSampleRate())));
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
    float fr = [sender floatValue];
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
	if (*((int *) getThreadFlag()) == 0)
        initializeSynthesizer(); //  If it is not already running, this includes starting the synthesize thread which also detaches itself
	//NSLog(@"Controller.m:340 threadFlag is %d", *((int *) getThreadFlag()));

    err = AudioDeviceAddIOProc(_device, sineIOProc, (void *)self);
    if (err != noErr)
        return;
	
    err = AudioDeviceStart(_device, sineIOProc);
    if (err != noErr)
        return;
	
    _isPlaying = YES;
	[runStopButton setState:NSOnState];
    [runStopButton2 setState:NSOnState];
	[analysis setRunning];
}

- (IBAction)stopPlaying:(id)sender;
{
    OSStatus err = noErr;
	NSLog(@"Stop");
	//NSLog(@"Controller.m:351 Is the application multithreaded: answer = %d threadFlag is %d", [NSThread isMultiThreaded], threadFlag);
	//pthread_testcancel(threadID);  // Stop playing and cancel detached thread

	[runStopButton setState:NSOffState];
    [runStopButton2 setState:NSOffState];
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

- (IBAction)runButtonPushed:(id)sender;
{
	if (_isPlaying == false)
		[self playSine:self];
	else
        [self stopPlaying:sender];
}


- (IBAction)loadDefaultsButtonPushed:(id)sender;
{
	[self setDefaults];
	NSNotificationCenter *nc;
    
	nc = [NSNotificationCenter defaultCenter];
	//NSLog(@"Sending notification SynthDefaultsReloaded");
	[nc postNotificationName:@"SynthDefaultsReloaded" object:self];
	initializeSynthesizer();
    [nc postNotificationName:@"throatCutoffChanged" object:self];
    [nc postNotificationName:@"pitchChanged" object:self];
    [nc postNotificationName:@"mixOffsetChanged" object:self];
    [nc postNotificationName:@"fricParamChanged" object:self];
    [nc postNotificationName:@"noseCoefChanged" object:self];
    [nc postNotificationName:@"mouthCoefChanged" object:self];





}


- (IBAction)loadMonetPostureButtonPushed:(id)sender;
{
 
 NSLog(@"Controller m:22 -- load Monet posture button pushed");
 NSArray *controlRatePostures = [[NSArray alloc] initWithObjects:@"#" @"glotVol", @"0", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.5", @"fricCF", @"2500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"0.89", @"r3", @"0.99", @"r4", @"0.81", @"r5", @"0.76", @"r6", @"1.05", @"r7", @"1.23", @"r8", @"0.01", @"velum", @"0.1", @"^", @"glotVol", @"0", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.5", @"fricCF", @"2500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"0.89", @"r3", @"0.99", @"r4", @"0.81", @"r5", @"0.76", @"r6", @"1.05", @"r7", @"1.23", @"r8", @"0.01", @"velum", @"0.1", @"a", @"glotVol", @"60", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.5", @"fricCF", @"2500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"0.65", @"r3", @"0.65", @"r4", @"0.65", @"r5", @"1.31", @"r6", @"1.23", @"r7", @"1.31", @"r8", @"1.67", @"velum", @"0.1", @"aa", @"glotVol", @"60", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.5", @"fricCF", @"2500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"0.65", @"r3", @"0.84", @"r4", @"1.15", @"r5", @"1.31", @"r6", @"1.59", @"r7", @"1.59", @"r8", @"2.61", @"velum", @"0.1", @"ah", @"glotVol", @"60", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.5", @"fricCF", @"2500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"0.65", @"r3", @"0.45", @"r4", @"0.94", @"r5", @"1.1", @"r6", @"1.52", @"r7", @"1.46", @"r8", @"2.45", @"velum", @"0.1", @"an", @"glotVol", @"60", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.5", @"fricCF", @"2500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"0.52", @"r3", @"0.45", @"r4", @"0.79", @"r5", @"1.49", @"r6", @"1.67", @"r7", @"1.02", @"r8", @"1.59", @"velum", @"1.5", @"ar", @"glotVol", @"60", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.5", @"fricCF", @"2500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"0.52", @"r3", @"0.45", @"r4", @"0.79", @"r5", @"1.49", @"r6", @"1.67", @"r7", @"1.02", @"r8", @"1.59", @"velum", @"0.1", @"aw", @"glotVol", @"60", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.5", @"fricCF", @"2500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"1.1", @"r3", @"0.94", @"r4", @"0.42", @"r5", @"1.49", @"r6", @"1.67", @"r7", @"1.78", @"r8", @"1.05", @"velum", @"0.1", @"b", @"glotVol", @"43.5", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"7", @"fricCF", @"2000", @"fricBW", @"700", @"r1", @"0.8", @"r2", @"0.89", @"r3", @"0.76", @"r4", @"1.28", @"r5", @"1.8", @"r6", @"0.99", @"r7", @"0.84", @"r8", @"0.1", @"velum", @"0.1", @"bx", @"glotVol", @"43.5", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"7", @"fricCF", @"2000", @"fricBW", @"700", @"r1", @"0.8", @"r2", @"0.89", @"r3", @"0.76", @"r4", @"1.28", @"r5", @"1.8", @"r6", @"0.99", @"r7", @"0.84", @"r8", @"0.1", @"velum", @"0.1", @"ch", @"glotVol", @"0", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.6", @"fricCF", @"2500", @"fricBW", @"2600", @"r1", @"0.8", @"r2", @"1.36", @"r3", @"1.74", @"r4", @"1.87", @"r5", @"0.94", @"r6", @"0", @"r7", @"0.79", @"r8", @"0.79", @"velum", @"0.1", @"d", @"glotVol", @"43.5", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"6.7", @"fricCF", @"4500", @"fricBW", @"2000", @"r1", @"0.8", @"r2", @"1.31", @"r3", @"1.49", @"r4", @"1.25", @"r5", @"0.76", @"r6", @"0.1", @"r7", @"1.44", @"r8", @"1.3", @"velum", @"0.1", @"dh", @"glotVol", @"54", @"aspVol", @"0", @"fricVol", @"0.25", @"fricPos", @"6", @"fricCF", @"4400", @"fricBW", @"4500", @"r1", @"0.8", @"r2", @"1.2", @"r3", @"1.5", @"r4", @"1.35", @"r5", @"1.2", @"r6", @"1.2", @"r7", @"0.4", @"r8", @"1", @"velum", @"0.1", @"dx", @"glotVol", @"43.5", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"6.7", @"fricCF", @"4500", @"fricBW", @"2000", @"r1", @"0.8", @"r2", @"1.31", @"r3", @"1.49", @"r4", @"1.25", @"r5", @"0.76", @"r6", @"0.1", @"r7", @"1.44", @"r8", @"1.31", @"velum", @"0.1", @"e", @"glotVol", @"60", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.5", @"fricCF", @"2500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"0.68", @"r3", @"1.12", @"r4", @"1.695", @"r5", @"1.385", @"r6", @"1.07", @"r7", @"1.045", @"r8", @"2.06", @"velum", @"0.1", @"ee", @"glotVol", @"60", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.5", @"fricCF", @"2500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"1.67", @"r3", @"1.905", @"r4", @"1.985", @"r5", @"0.81", @"r6", @"0.495", @"r7", @"0.73", @"r8", @"1.485", @"velum", @"0.1", @"er", @"glotVol", @"60", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.5", @"fricCF", @"2500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"0.885", @"r3", @"0.99", @"r4", @"0.81", @"r5", @"0.755", @"r6", @"1.045", @"r7", @"1.225", @"r8", @"1.12", @"velum", @"0.1", @"f", @"glotVol", @"0", @"aspVol", @"0", @"fricVol", @"0.5", @"fricPos", @"7", @"fricCF", @"3300", @"fricBW", @"1000", @"r1", @"0.8", @"r2", @"0.89", @"r3", @"0.99", @"r4", @"0.81", @"r5", @"0.76", @"r6", @"0.89", @"r7", @"0.84", @"r8", @"0.5", @"velum", @"0.1", @"g", @"glotVol", @"43.5", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"4.7", @"fricCF", @"2000", @"fricBW", @"2000", @"r1", @"0.8", @"r2", @"1.7", @"r3", @"1.3", @"r4", @"0.99", @"r5", @"0.1", @"r6", @"1.07", @"r7", @"0.73", @"r8", @"1.49", @"velum", @"0.1", @"gs", @"glotVol", @"0", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.5", @"fricCF", @"2500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"0.8", @"r3", @"0.8", @"r4", @"0.8", @"r5", @"0.8", @"r6", @"0.8", @"r7", @"0.8", @"r8", @"0.8", @"velum", @"0.1", @"h", @"glotVol", @"0", @"aspVol", @"10.0", @"fricVol", @"0", @"fricPos", @"5.5", @"fricCF", @"2500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"0.8", @"r3", @"0.8", @"r4", @"0.8", @"r5", @"0.8", @"r6", @"0.8", @"r7", @"0.8", @"r8", @"0.8", @"velum", @"0.1", @"hh", @"glotVol", @"0", @"aspVol", @"10", @"fricVol", @"0", @"fricPos", @"1", @"fricCF", @"1000", @"fricBW", @"1000", @"r1", @"0.8", @"r2", @"0.24", @"r3", @"0.4", @"r4", @"0.81", @"r5", @"0.76", @"r6", @"1.05", @"r7", @"1.23", @"r8", @"1.12", @"velum", @"0.1", @"hv", @"glotVol", @"42", @"aspVol", @"10", @"fricVol", @"0", @"fricPos", @"5.5", @"fricCF", @"2500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"0.8", @"r3", @"0.8", @"r4", @"0.8", @"r5", @"0.8", @"r6", @"0.8", @"r7", @"0.8", @"r8", @"0.8", @"velum", @"0.1", @"i", @"glotVol", @"60", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.5", @"fricCF", @"2500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"1.045", @"r3", @"1.565", @"r4", @"1.75", @"r5", @"0.94", @"r6", @"0.68", @"r7", @"0.785", @"r8", @"1.12", @"velum", @"0.1", @"in", @"glotVol", @"60", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.5", @"fricCF", @"2500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"0.65", @"r3", @"0.835", @"r4", @"1.15", @"r5", @"1.305", @"r6", @"1.59", @"r7", @"1.59", @"r8", @"2.61", @"velum", @"1.5", @"j", @"glotVol", @"48", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.6", @"fricCF", @"2500", @"fricBW", @"2600", @"r1", @"0.8", @"r2", @"1.36", @"r3", @"1.74", @"r4", @"1.87", @"r5", @"0.94", @"r6", @"0", @"r7", @"0.79", @"r8", @"0.79", @"velum", @"0.1", @"k", @"glotVol", @"0", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"4.7", @"fricCF", @"2000", @"fricBW", @"2000", @"r1", @"0.8", @"r2", @"1.7", @"r3", @"1.3", @"r4", @"0.99", @"r5", @"0.1", @"r6", @"1.07", @"r7", @"0.73", @"r8", @"1.49", @"velum", @"0.1", @"kx", @"glotVol", @"0", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"4.7", @"fricCF", @"2000", @"fricBW", @"2000", @"r1", @"0.8", @"r2", @"1.7", @"r3", @"1.3", @"r4", @"0.99", @"r5", @"0.1", @"r6", @"1.07", @"r7", @"0.73", @"r8", @"1.49", @"velum", @"0.1", @"l", @"glotVol", @"60", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.5", @"fricCF", @"2500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"0.89", @"r3", @"1.1", @"r4", @"0.97", @"r5", @"0.89", @"r6", @"0.34", @"r7", @"0.29", @"r8", @"1.12", @"velum", @"0.1", @"ll", @"glotVol", @"60", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.5", @"fricCF", @"2500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"0.63", @"r3", @"0.47", @"r4", @"0.65", @"r5", @"1.54", @"r6", @"0.45", @"r7", @"0.26", @"r8", @"1.05", @"velum", @"0.1", @"ls", @"glotVol", @"60", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.5", @"fricCF", @"2500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"0.63", @"r3", @"0.47", @"r4", @"0.65", @"r5", @"1.54", @"r6", @"0.45", @"r7", @"0.26", @"r8", @"1.05", @"velum", @"0.1", @"m", @"glotVol", @"60", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.5", @"fricCF", @"2500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"0.89", @"r3", @"0.76", @"r4", @"1.28", @"r5", @"1.8", @"r6", @"0.99", @"r7", @"0.84", @"r8", @"0.1", @"velum", @"0.5", @"n", @"glotVol", @"60", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.5", @"fricCF", @"2500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"1.31", @"r3", @"1.49", @"r4", @"1.25", @"r5", @"1", @"r6", @"0.05", @"r7", @"1.44", @"r8", @"1.31", @"velum", @"0.5", @"ng", @"glotVol", @"60", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.5", @"fricCF", @"2500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"1.7", @"r3", @"1.3", @"r4", @"0.99", @"r5", @"0.1", @"r6", @"1.07", @"r7", @"0.73", @"r8", @"1.49", @"velum", @"0.5", @"o", @"glotVol", @"60", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.5", @"fricCF", @"2500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"1", @"r3", @"0.925", @"r4", @"0.6", @"r5", @"1.27", @"r6", @"1.83", @"r7", @"1.97", @"r8", @"1.12", @"velum", @"0.1", @"oh", @"glotVol", @"0", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.5", @"fricCF", @"2500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"0.885", @"r3", @"0.99", @"r4", @"0.81", @"r5", @"0.755", @"r6", @"1.045", @"r7", @"1.225", @"r8", @"1.12", @"velum", @"0.1", @"on", @"glotVol", @"60", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.5", @"fricCF", @"2500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"1", @"r3", @"0.925", @"r4", @"0.6", @"r5", @"1.265", @"r6", @"1.83", @"r7", @"1.965", @"r8", @"1.12", @"velum", @"1.5", @"ov", @"glotVol", @"60", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.5", @"fricCF", @"2500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"0.885", @"r3", @"0.99", @"r4", @"0.81", @"r5", @"0.755", @"r6", @"1.045", @"r7", @"1.225", @"r8", @"1.12", @"velum", @"0.1", @"p", @"glotVol", @"0", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"7", @"fricCF", @"2000", @"fricBW", @"700", @"r1", @"0.8", @"r2", @"0.89", @"r3", @"0.76", @"r4", @"1.28", @"r5", @"1.8", @"r6", @"0.99", @"r7", @"0.84", @"r8", @"0.1", @"velum", @"0.1", @"ph", @"glotVol", @"0", @"aspVol", @"0", @"fricVol", @"24", @"fricPos", @"7", @"fricCF", @"864", @"fricBW", @"3587", @"r1", @"0.8", @"r2", @"0.89", @"r3", @"0.99", @"r4", @"0.81", @"r5", @"0.6", @"r6", @"0.52", @"r7", @"0.71", @"r8", @"0.24", @"velum", @"0.1", @"px", @"glotVol", @"0", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"7", @"fricCF", @"2000", @"fricBW", @"700", @"r1", @"0.8", @"r2", @"0.89", @"r3", @"0.76", @"r4", @"1.28", @"r5", @"1.8", @"r6", @"0.99", @"r7", @"0.84", @"r8", @"0.1", @"velum", @"0.1", @"q", @"glotVol", @"0", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.5", @"fricCF", @"2500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"0.89", @"r3", @"0.99", @"r4", @"0.81", @"r5", @"0.76", @"r6", @"1.05", @"r7", @"1.23", @"r8", @"0.01", @"velum", @"0.1", @"qc", @"glotVol", @"0", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.6", @"fricCF", @"2500", @"fricBW", @"2600", @"r1", @"0.8", @"r2", @"1.36", @"r3", @"1.74", @"r4", @"1.87", @"r5", @"0.94", @"r6", @"0.1", @"r7", @"0.79", @"r8", @"0.79", @"velum", @"0.1", @"qk", @"glotVol", @"0", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"4.7", @"fricCF", @"2000", @"fricBW", @"2000", @"r1", @"0.8", @"r2", @"1.7", @"r3", @"1.3", @"r4", @"0.99", @"r5", @"0.1", @"r6", @"1.07", @"r7", @"0.73", @"r8", @"1.49", @"velum", @"0.1", @"qp", @"glotVol", @"0", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"7", @"fricCF", @"2000", @"fricBW", @"700", @"r1", @"0.8", @"r2", @"0.89", @"r3", @"0.76", @"r4", @"1.28", @"r5", @"1.8", @"r6", @"0.99", @"r7", @"0.84", @"r8", @"0.1", @"velum", @"0.1", @"qs", @"glotVol", @"0", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.8", @"fricCF", @"5500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"1.31", @"r3", @"1.49", @"r4", @"1.25", @"r5", @"0.9", @"r6", @"0.2", @"r7", @"0.4", @"r8", @"1.31", @"velum", @"0.1", @"qt", @"glotVol", @"0", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"7", @"fricCF", @"4500", @"fricBW", @"2000", @"r1", @"0.8", @"r2", @"1.31", @"r3", @"1.49", @"r4", @"1.25", @"r5", @"0.76", @"r6", @"0.1", @"r7", @"1.44", @"r8", @"1.31", @"velum", @"0.1", @"qz", @"glotVol", @"0", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.8", @"fricCF", @"5500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"1.31", @"r3", @"1.49", @"r4", @"1.25", @"r5", @"0.9", @"r6", @"0.2", @"r7", @"0.6", @"r8", @"1.31", @"velum", @"0.1", @"r", @"glotVol", @"60", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.5", @"fricCF", @"2500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"1.31", @"r3", @"0.73", @"r4", @"1.07", @"r5", @"2.12", @"r6", @"0.47", @"r7", @"1.78", @"r8", @"0.65", @"velum", @"0.1", @"rr", @"glotVol", @"60", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.5", @"fricCF", @"2500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"1.31", @"r3", @"0.73", @"r4", @"1.31", @"r5", @"2.12", @"r6", @"0.63", @"r7", @"1.78", @"r8", @"0.65", @"velum", @"0.1", @"s", @"glotVol", @"0", @"aspVol", @"0", @"fricVol", @"0.8", @"fricPos", @"5.8", @"fricCF", @"5500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"1.31", @"r3", @"1.49", @"r4", @"1.25", @"r5", @"0.9", @"r6", @"0.2", @"r7", @"0.4", @"r8", @"1.31", @"velum", @"0.1", @"sh", @"glotVol", @"0", @"aspVol", @"0", @"fricVol", @"0.4", @"fricPos", @"5.6", @"fricCF", @"2500", @"fricBW", @"2600", @"r1", @"0.8", @"r2", @"1.36", @"r3", @"1.74", @"r4", @"1.87", @"r5", @"0.94", @"r6", @"0.37", @"r7", @"0.79", @"r8", @"0.79", @"velum", @"0.1", @"t", @"glotVol", @"0", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"7", @"fricCF", @"4500", @"fricBW", @"2000", @"r1", @"0.8", @"r2", @"1.31", @"r3", @"1.49", @"r4", @"1.25", @"r5", @"0.76", @"r6", @"0.1", @"r7", @"1.44", @"r8", @"1.31", @"velum", @"0.1", @"th", @"glotVol", @"0", @"aspVol", @"0", @"fricVol", @"0.25", @"fricPos", @"6", @"fricCF", @"4400", @"fricBW", @"4500", @"r1", @"0.8", @"r2", @"1.2", @"r3", @"1.5", @"r4", @"1.35", @"r5", @"1.2", @"r6", @"1.2", @"r7", @"0.4", @"r8", @"1", @"velum", @"0.1", @"tx", @"glotVol", @"0", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"6.7", @"fricCF", @"4500", @"fricBW", @"2000", @"r1", @"0.8", @"r2", @"1.31", @"r3", @"1.49", @"r4", @"1.25", @"r5", @"0.76", @"r6", @"0.1", @"r7", @"1.44", @"r8", @"1.31", @"velum", @"0.1", @"u", @"glotVol", @"60", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.5", @"fricCF", @"2500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"0.625", @"r3", @"0.6", @"r4", @"0.705", @"r5", @"1.12", @"r6", @"1.93", @"r7", @"1.515", @"r8", @"0.625", @"velum", @"0.1", @"uh", @"glotVol", @"60", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.5", @"fricCF", @"2500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"0.89", @"r3", @"0.99", @"r4", @"0.81", @"r5", @"0.76", @"r6", @"1.05", @"r7", @"1.23", @"r8", @"1.12", @"velum", @"0.1", @"un", @"glotVol", @"60", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.5", @"fricCF", @"2500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"0.885", @"r3", @"0.99", @"r4", @"0.81", @"r5", @"0.755", @"r6", @"1.045", @"r7", @"1.225", @"r8", @"1.12", @"velum", @"1.5", @"uu", @"glotVol", @"60", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.5", @"fricCF", @"2500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"1.91", @"r3", @"1.44", @"r4", @"0.6", @"r5", @"1.02", @"r6", @"1.33", @"r7", @"1.56", @"r8", @"0.55", @"velum", @"0.1", @"v", @"glotVol", @"54", @"aspVol", @"0", @"fricVol", @"0.2", @"fricPos", @"7", @"fricCF", @"3300", @"fricBW", @"1000", @"r1", @"0.8", @"r2", @"0.89", @"r3", @"0.99", @"r4", @"0.81", @"r5", @"0.76", @"r6", @"0.89", @"r7", @"0.84", @"r8", @"0.5", @"velum", @"0.1", @"w", @"glotVol", @"60", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.5", @"fricCF", @"2500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"1.91", @"r3", @"1.44", @"r4", @"0.6", @"r5", @"1.02", @"r6", @"1.33", @"r7", @"1.56", @"r8", @"0.55", @"velum", @"0.1", @"x", @"glotVol", @"0", @"aspVol", @"0", @"fricVol", @"0.5", @"fricPos", @"2", @"fricCF", @"1770", @"fricBW", @"900", @"r1", @"0.8", @"r2", @"1.7", @"r3", @"1.3", @"r4", @"0.4", @"r5", @"0.99", @"r6", @"1.07", @"r7", @"0.73", @"r8", @"1.49", @"velum", @"0.1", @"y", @"glotVol", @"60", @"aspVol", @"0", @"fricVol", @"0", @"fricPos", @"5.5", @"fricCF", @"2500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"1.67", @"r3", @"1.91", @"r4", @"1.99", @"r5", @"0.63", @"r6", @"0.29", @"r7", @"0.58", @"r8", @"1.49", @"velum", @"0.25", @"z", @"glotVol", @"54", @"aspVol", @"0", @"fricVol", @"0.8", @"fricPos", @"5.8", @"fricCF", @"5500", @"fricBW", @"500", @"r1", @"0.8", @"r2", @"1.31", @"r3", @"1.49", @"r4", @"1.25", @"r5", @"0.9", @"r6", @"0.2", @"r7", @"0.6", @"r8", @"1.31", @"velum", @"0.1", @"zh", @"glotVol", @"54", @"aspVol", @"0", @"fricVol", @"0.4", @"fricPos", @"5.6", @"fricCF", @"2500", @"fricBW", @"2600", @"r1", @"0.8", @"r2", @"1.36", @"r3", @"1.74", @"r4", @"1.87", @"r5", @"0.94", @"r6", @"0.37", @"r7", @"0.79", @"r8", @"0.79", @"velum", @"0.1", nil];
 
 long tag = [sender tag];
 long index = (tag) * lengthOfMonetRecords-1;
 
 double temp;
 NSLog(@"Controller m:485 -- button tag is %ld", tag);
 
 NSLog(@"Controller m:487 Value of object at index %ld is %@", index, [controlRatePostures objectAtIndex:index]);
 
    
    

NSString *glotVolStr = [controlRatePostures objectAtIndex:index+glotVolOffset];
NSLog(@"Controller m:493 The glottalVolume in the array is %@", glotVolStr);
temp = [glotVolStr doubleValue];
*((double *) getGlotVol()) = temp;
[glottalVolumeField setDoubleValue:temp];
[glottalVolumeSlider setDoubleValue:temp];
NSLog(@"Controller.m:498 glottalVolume is %f", *((double *) getGlotVol()));

NSMutableString *aspVolStr = [controlRatePostures objectAtIndex:index+aspVolOffset];
temp = [aspVolStr doubleValue];
*((double *) getAspVol()) = temp;
[aspVolField setDoubleValue:temp];
[aspVolSlider setDoubleValue:temp];
NSLog(@"Controller.m:505 aspVol is %f", *((double *) getAspVol()));

NSMutableString *fricVolStr = [controlRatePostures objectAtIndex:index+fricVolOffset];
temp = [fricVolStr doubleValue];
*((double *) getFricVol()) = temp;
[fricVolField setDoubleValue:temp];
[fricVolSlider setDoubleValue:temp];
NSLog(@"Controller.m:512 fricVol is %f", *((double *) getFricVol()));

NSMutableString *fricPosStr = [controlRatePostures objectAtIndex:index+fricPosOffset];
temp = [fricPosStr doubleValue];
*((double *) getFricPos()) = temp;
[fricPosField setDoubleValue:temp];
[fricPosSlider setDoubleValue:temp];
NSLog(@"Controller.m:519 fricPos is %f", *((double *) getFricPos()));
    
NSMutableString *fricCFStr = [controlRatePostures objectAtIndex:index+fricCFOffset];
temp = [fricCFStr doubleValue];
*((double *) getFricCF()) = temp;
[fricCFField setDoubleValue:temp];
[fricCFSlider setDoubleValue:temp];
NSLog(@"Controller.m:526 fricCF is %f", *((double *) getFricCF()));
    
NSMutableString *fricBWStr = [controlRatePostures objectAtIndex:index+fricBWOffset];
temp = [fricBWStr doubleValue];
*((double *) getFricBW()) = temp;
[fricBWField setDoubleValue:temp];
[fricBWSlider setDoubleValue:temp];
    // NOTIFY THE DISPLAY
    //NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    //NSLog(@"Sending fricParamChanged notification");
    //[nc postNotificationName:@"fricParamChanged" object:self];
//NSLog(@"Controller.m:513 fricBW is %f", *((double *) getFricBW()));
    
    
    NSMutableString *r1Str = [controlRatePostures objectAtIndex:index+r1Offset];
    temp = [r1Str doubleValue];
    *((double *) getRadius(0)) = temp;
    [rS1 setValue:temp];
    NSLog(@"Tube section 1 has radius %f", *((double *) getRadius(0)));
    
    NSMutableString *r2Str = [controlRatePostures objectAtIndex:index+r2Offset];
    temp = [r2Str doubleValue];
    *((double *) getRadius(1)) = temp;
    [rS2 setValue:temp];
    NSLog(@"Tube section 2 has radius %f", *((double *) getRadius(1)));

    NSMutableString *r3Str = [controlRatePostures objectAtIndex:index+r3Offset];
    temp = [r3Str doubleValue];
    *((double *) getRadius(2))= temp;
    [rS3 setValue:temp];
    NSLog(@"Tube section 3 has radius %f", *((double *) getRadius(2)));
    
    NSMutableString *r4Str = [controlRatePostures objectAtIndex:index+r4Offset];
    temp = [r4Str doubleValue];
    *((double *) getRadius(3))=temp;
    [rS4 setValue:temp];
    NSLog(@"Tube section 4 has radius %f", *((double *) getRadius(3)));
    
    NSMutableString *r5Str = [controlRatePostures objectAtIndex:index+r5Offset];
    temp = [r5Str doubleValue];
    *((double *) getRadius(4)) = temp;
    [rS5 setValue:temp];
    NSLog(@"Tube section 5 has radius %f", *((double *) getRadius(4)));

    NSMutableString *r6Str = [controlRatePostures objectAtIndex:index+r6Offset];
    temp = [r6Str doubleValue];
    *((double *) getRadius(5)) = temp;
    [rS6 setValue:temp];
    NSLog(@"Tube section 6 has radius %f", *((double *) getRadius(5)));

    NSMutableString *r7Str = [controlRatePostures objectAtIndex:index+r7Offset];
    temp = [r7Str doubleValue];
    *((double *) getRadius(6)) = temp;
    [rS7 setValue:temp];
    NSLog(@"Tube section 7 has radius %f", *((double *) getRadius(6)));
    
    NSMutableString *r8Str = [controlRatePostures objectAtIndex:index+r8Offset];
    temp = [r8Str doubleValue];
    *((double *) getRadius(7)) = temp;
    [rS8 setValue:temp];
    NSLog(@"Tube section 8 has radius %f", *((double *) getRadius(7)));

    NSMutableString *velumStr = [controlRatePostures objectAtIndex:index+velumOffset];
    temp = [velumStr doubleValue];
    *((double *) getVelumRadius()) = temp;
    [vS setValue:temp];
    NSLog(@"Velum has radius %f", *((double *) getVelumRadius()));

    
    NSString *postureName = [controlRatePostures objectAtIndex:index+nameOffset];
    [postureLabel setStringValue:postureName];
    NSLog(@"postureName is %@", postureName);
    
    /*
    NSMutableString *n1Str = [controlRatePostures objectAtIndex:index+n1Offset];
    temp = [n1Str doubleValue];
    *((double *) getNoseRadius(0)) = temp;
    [n1 setValue:temp];
    NSLog(@"Nose section 1 has radius %f", *((double *) getNoseRadius(0)));
    
    NSMutableString *n2Str = [controlRatePostures objectAtIndex:index+n2Offset];
    temp = [n2Str doubleValue];
    *((double *) getNoseRadius(1)) = temp;
    [n2 setValue:temp];
    NSLog(@"Nose section 2 has radius %f", *((double *) getNoseRadius(1)));
    
    NSMutableString *n3Str = [controlRatePostures objectAtIndex:index+n3Offset];
    temp = [n3Str doubleValue];
    *((double *) getNoseRadius(2))= temp;
    [n4 setValue:temp];
    NSLog(@"Nose section 3 has radius %f", *((double *) getNoseRadius(2)));
    
    NSMutableString *n4Str = [controlRatePostures objectAtIndex:index+r4Offset];
    temp = [n4Str doubleValue];
    *((double *) getNoseRadius(3))=temp;
    [n4 setValue:temp];
    NSLog(@"Nose section 4 has radius %f", *((double *) getNoseRadius(3)));
    
    NSMutableString *n5Str = [controlRatePostures objectAtIndex:index+n5Offset];
    temp = [n5Str doubleValue];
    *((double *) getNoseRadius(4)) = temp;
    [rS5 setValue:temp];
    NSLog(@"Nose section 5 has radius %f", *((double *) getNoseRadius(4)));
*/
    
    initializeSynthesizer();

    // NOTIFY THE NOISE SOURCE DISPLAY TO UPDATE
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    NSLog(@"Sending fricParamChanged notification");
    [nc postNotificationName:@"fricParamChanged" object:self];
    NSLog(@"Controller.m:513 fricBW is %f", *((double *) getFricBW()));

    
    //[TubeSection setSection:temp :81 :YES];
//[Slider setDoubleValue:temp];
//NSLog(@"Controller.m:513  is %f", *((double *) ()));
    
    /*
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

    
    */
    
    



}


- (IBAction)loadTrmpFileButtonPushed:(id)sender;
{

    //NSNotificationCenter *nc;
    NSLog(@"Load file button pushed");
    // Loop counter.
    int i;
    NSURL *restoreURL;
    NSArray *trmpValues;
    
    // Create a File Open Dialog class.
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    // Set array of file types 
    NSArray *fileTypesArray;
    fileTypesArray = [NSArray arrayWithObjects:@"trmp", nil];
    
    // Enable options in the dialog.
    [openDlg setCanChooseFiles:YES];    
    [openDlg setAllowedFileTypes:fileTypesArray];
    [openDlg setAllowsMultipleSelection:TRUE];
    
    // Display the dialog box.  If the OK pressed,
    // process the files.
    if ( [openDlg runModal] == NSOKButton ) {
        
        // Gets list of all files selected
        NSArray *files = [openDlg URLs];
        
        // Loop through the files and process them.
        for( i = 0; i < [files count]; i++ ) {
            
            // Do something with the filename.
            restoreURL = [files objectAtIndex:0];
        }
    }
    
            trmpValues = [NSArray arrayWithContentsOfURL:restoreURL];
            
            NSLog (@"The array read in is %@", trmpValues);
            
            NSString *trmpLengthStr = [trmpValues objectAtIndex:0];
            NSLog(@"Controller m:516 The tube length in the array is %@", trmpLengthStr);
            double temp = [trmpLengthStr doubleValue];
            *((double *) getLength()) = temp;
            [tubeLengthField setDoubleValue:temp];
            [tubeLengthSlider setDoubleValue:temp];
            NSLog(@"Controller.m:520 tubeLength is %f", *((double *) getLength()));

            NSMutableString *trmpTemperatureStr = [trmpValues objectAtIndex:1];
            temp = [trmpTemperatureStr doubleValue];
            *((double *) getTemperature()) = temp;
            [temperatureField setDoubleValue:temp];
            [temperatureSlider setDoubleValue:temp];
            NSLog(@"Controller.m:520 temperature is %f", *((double *) getTemperature()));
            
            NSString *trmpBalanceStr = [trmpValues objectAtIndex:2];
            temp = [trmpBalanceStr doubleValue];
            *((double *) getBalance()) = temp;
            [stereoBalanceField setDoubleValue:temp];
            [stereoBalanceSlider setDoubleValue:temp];
            NSLog(@"Controller.m:520 balance is %f", *((double *) getBalance()));
            
            NSString *trmpBreathinessStr = [trmpValues objectAtIndex:3];
            temp = [trmpBreathinessStr doubleValue];
            *((double *) getBreathiness()) = temp;
            [breathinessField setDoubleValue:temp];
            [breathinessSlider setDoubleValue:temp];
            NSLog(@"Controller.m:520 breathiness is %f", *((double *) getBreathiness()));

            NSString *trmpLossFactorStr = [trmpValues objectAtIndex:4];
            temp = [trmpLossFactorStr doubleValue];
            *((double *) getLossFactor()) = temp;
            [lossFactorField setDoubleValue:temp];
            [lossFactorSlider setDoubleValue:temp];
            [dampingFactorField setDoubleValue:temp*100];
            NSLog(@"Controller.m:520 lossFactdor is %f", *((double *) getLossFactor()));
            
            NSString *trmpTpStr = [trmpValues objectAtIndex:5];
            temp = [trmpTpStr doubleValue];
            *((double *) getTp()) = temp;
            [tpField setDoubleValue:temp];
            [tpSlider setDoubleValue:temp];
            NSLog(@"Controller.m:520 Tp is %f", *((double *) getTp()));
            
            NSString *trmpTnMinStr = [trmpValues objectAtIndex:6];
            temp = [trmpTnMinStr doubleValue];
            *((double *) getTnMin()) = temp;
            [tnMinField setDoubleValue:temp];
            [tnMinSlider setDoubleValue:temp];
            NSLog(@"Controller.m:520 TnMin is %f", *((double *) getTnMin()));

            NSString *trmpTnMaxStr = [trmpValues objectAtIndex:7];
            temp = [trmpTnMaxStr doubleValue];
            *((double *) getTnMax()) = 35.0;
            NSLog(@"Controller.m:520 TnMax is %f", *((double *) getTnMax()));
            
            NSString *trmpThroatCutoffStr = [trmpValues objectAtIndex:8];
            temp = [trmpThroatCutoffStr doubleValue];
            *((double *) getThroatCutoff()) = temp;
            [tnMaxField setDoubleValue:temp];
            [tnMaxSlider setDoubleValue:temp];
            NSLog(@"Controller.m:520 throatCutoff is %f", *((double *) getThroatCutoff()));

            NSString *trmpThroatVolStr = [trmpValues objectAtIndex:9];
            temp = [trmpThroatVolStr doubleValue];
            *((double *) getThroatVol()) = temp;
            [throatVolumeField setDoubleValue:temp];
            [throatVolumeSlider setDoubleValue:temp];
            NSLog(@"Controller.m:520 throatVol is %f", *((double *) getThroatVol()));

            NSString *trmpApScaleStr = [trmpValues objectAtIndex:10];
            temp = [trmpApScaleStr doubleValue];
            *((double *) getApScale()) = temp;
            [apertureRadiusField setDoubleValue:temp/2];
            [apertureDiameterField setDoubleValue:temp];
            [apertureAreaField setDoubleValue:((temp/2)*(temp/2))*PI];
            NSLog(@"Controller.m:520 ApScale is %f", *((double *) getApScale()));

            NSString *trmpMouthCoefStr = [trmpValues objectAtIndex:11];
            temp = [trmpMouthCoefStr doubleValue];
            *((double *) getMouthCoef()) = temp;
            [mouthCoefField setDoubleValue:temp];
            [mouthCoefSlider setDoubleValue:temp];
            NSLog(@"Controller.m:520 mouthCoef is %f", *((double *) getMouthCoef()));
            
            NSString *trmpNoseCoefStr = [trmpValues objectAtIndex:12];
            temp = [trmpNoseCoefStr doubleValue];
            *((double *) getNoseCoef()) = temp;
            [noseCoefField setDoubleValue:temp];
            [noseCoefSlider setDoubleValue:temp];
            NSLog(@"Controller.m:520 noseCoef is %f", *((double *) getNoseCoef()));
            
            NSString *trmpMixOffsetStr = [trmpValues objectAtIndex:13];
            temp = [trmpMixOffsetStr doubleValue];
            *((double *) getMixOffset()) = temp;
            [mixOffsetField setDoubleValue:temp];
            NSLog(@"Controller.m:520 mixOffset is %f", *((double *) getMixOffset()));


            NSString *trmpGlotVolStr = [trmpValues objectAtIndex:14];
            temp = [trmpGlotVolStr doubleValue];
            *((double *) getGlotVol()) = temp;
            //double temp2 = temp;
            [glottalVolumeField setDoubleValue:temp];
            NSLog(@"Controller.m:520 glotVol is %f", *((double *) getGlotVol()));
            
            NSString *trmpGlotPitchStr = [trmpValues objectAtIndex:15];
            temp = [trmpGlotPitchStr doubleValue];
            *((double *) getGlotPitch()) = temp;
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            NSLog(@"Sending pitchChanged notification");
            [nc postNotificationName:@"pitchChanged" object:self];
            [pitchSlider setDoubleValue:temp];
            [pitchField setDoubleValue:temp];
            NSLog(@"Controller.m:520 glotPitch is %f", *((double *) getGlotPitch()));

            NSString *trmpAspVolStr = [trmpValues objectAtIndex:16];
            temp = [trmpAspVolStr doubleValue];
            *((double *) getAspVol()) = temp;
            [aspVolField setDoubleValue:temp];
            [aspVolSlider setDoubleValue:temp];
            NSLog(@"Controller.m:520 aspVol is %f", *((double *) getAspVol()));

            NSString *trmpFricVolStr = [trmpValues objectAtIndex:17];
            temp = [trmpFricVolStr doubleValue];
            *((double *) getFricVol()) = temp;
            [fricVolField setDoubleValue:temp];
            [fricVolSlider setDoubleValue:temp];
            NSLog(@"Controller.m:520 fricVol is %f", *((double *) getFricVol()));

            NSString *trmpFricPosStr = [trmpValues objectAtIndex:18];
            temp = [trmpFricPosStr doubleValue];
            *((double *) getFricPos()) = temp;
            [fricPosField setDoubleValue:temp];
            [fricPosSlider setDoubleValue:temp];
            NSLog(@"Controller.m:520 fricPos is %f", *((double *) getFricPos()));

            NSString *trmpFricCFStr = [trmpValues objectAtIndex:19];
            temp = [trmpFricCFStr doubleValue];
            *((double *) getFricCF()) = temp;
            [fricCFField setDoubleValue:temp];
            [fricCFSlider setDoubleValue:temp];
            NSLog(@"Controller.m:520 fricCF is %f", *((double *) getFricCF()));
     
            NSString *trmpFricBWStr = [trmpValues objectAtIndex:20];
            temp = [trmpFricBWStr doubleValue];
            *((double *) getFricBW()) = temp;
            [fricBWField setDoubleValue:temp];
            [fricBWSlider setDoubleValue:temp];
            // NOTIFY THE DISPLAY
            NSLog(@"Sending fricParamChanged notification");
            [nc postNotificationName:@"fricParamChanged" object:self];
            NSLog(@"Controller.m:520 fricBW is %f", *((double *) getFricBW()));
            
            NSString *trmprS1Str = [trmpValues objectAtIndex:21];
            temp = [trmprS1Str doubleValue];
            *((double *) getRadius(0)) = temp;
            [rS1 setValue:temp];
            NSLog(@"Controller.m:520 rS1 is %f", *((double *) getRadius(0)));
                           
            NSString *trmprS2Str = [trmpValues objectAtIndex:22];
            temp = [trmprS2Str doubleValue];
            *((double *) getRadius(1)) = temp;
            [rS2 setValue:temp];
            NSLog(@"Controller.m:520 rS2 is %f", *((double *) getRadius(1)));
            
            NSString *trmprS3Str = [trmpValues objectAtIndex:23];
            temp = [trmprS3Str doubleValue];
            *((double *) getRadius(2)) = temp;
            [rS3 setValue:temp];
            NSLog(@"Controller.m:520 rS3 is %f", *((double *) getRadius(2)));
          
            NSString *trmprS4Str = [trmpValues objectAtIndex:24];
            temp = [trmprS4Str doubleValue];
            *((double *) getRadius(3)) = temp;
            [rS4 setValue:temp];
            NSLog(@"Controller.m:520 rS4 is %f", *((double *) getRadius(3)));
            
            NSString *trmprS5Str = [trmpValues objectAtIndex:25];
            temp = [trmprS5Str doubleValue];
            *((double *) getRadius(4)) = temp;
            [rS5 setValue:temp];
            NSLog(@"Controller.m:520 rS5 is %f", *((double *) getRadius(4)));
            
            NSString *trmprS6Str = [trmpValues objectAtIndex:26];
            temp = [trmprS6Str doubleValue];
            *((double *) getRadius(5)) = temp;
            [rS6 setValue:temp];
            NSLog(@"Controller.m:520 rS6 is %f", *((double *) getRadius(5)));
            
            NSString *trmprS7Str = [trmpValues objectAtIndex:27];
            temp = [trmprS7Str doubleValue];
            *((double *) getRadius(6)) = temp;
            [rS7 setValue:temp];
            NSLog(@"Controller.m:520 rS7 is %f", *((double *) getRadius(6)));
        
            NSString *trmprS8Str = [trmpValues objectAtIndex:28];
            temp = [trmprS8Str doubleValue];
            *((double *) getRadius(7)) = temp;
            [rS8 setValue:temp];
            NSLog(@"Controller.m:520 rS8 is %f", *((double *) getRadius(7)));
            
            NSString *trmpvSStr = [trmpValues objectAtIndex:29];
            temp = [trmpvSStr doubleValue];
            *((double *) getVelumRadius()) = temp;
            [vS setValue:temp];
            NSLog(@"Controller.m:520 velum is %f", *((double *) getVelumRadius()));
            
            NSString *trmpN1Str = [trmpValues objectAtIndex:30];
            temp = [trmpN1Str doubleValue];
            *((double *) getNoseRadius(0)) = temp;
            [nS1 setValue:temp];
            NSLog(@"Controller.m:520 n1 is %f", *((double *) getNoseRadius(0)));

            NSString *trmpN2Str = [trmpValues objectAtIndex:31];
            temp = [trmpN2Str doubleValue];
            *((double *) getRadius(1)) = temp;
            [nS2 setValue:temp];
            NSLog(@"Controller.m:520 n2 is %f", *((double *) getNoseRadius(1)));

            NSString *trmpN3Str = [trmpValues objectAtIndex:32];
            temp = [trmpN3Str doubleValue];
            *((double *) getRadius(2)) = temp;
            [nS3 setValue:temp];
            NSLog(@"Controller.m:520 n3 is %f", *((double *) getNoseRadius(2)));

            NSString *trmpN4Str = [trmpValues objectAtIndex:33];
            temp = [trmpN4Str doubleValue];
            *((double *) getRadius(3)) = temp;
            [nS4 setValue:temp];
            NSLog(@"Controller.m:520 n4 is %f", *((double *) getNoseRadius(3)));

            NSString *trmpN5Str = [trmpValues objectAtIndex:34];
            temp = [trmpN5Str doubleValue];
            *((double *) getRadius(4)) = temp;
            [nS5 setValue:temp];
            NSLog(@"Controller.m:520 n5 is %f", *((double *) getRadius(4)));

            [postureLabel setStringValue:@"  "];
            NSLog(@"postureName is %@", @"  ");




            
            
            initializeSynthesizer();
            [self adjustSampleRate];
            
            NSLog(@"Re-initialised Synthesizer");
 
    

    initializeSynthesizer();
    [self adjustSampleRate];

    NSLog(@"Re-initialised Synthesizer");

    


}

- (IBAction)saveFileButtonPushed:(id)sender;

{
    NSLog(@"Save file button pushed");
    
    
    
    NSMutableArray *trmpValues = [[NSMutableArray alloc] init ];
   
    NSString *trmpLengthStr = [[NSNumber numberWithDouble:*((double *) getLength())] stringValue];
    [trmpValues addObject:trmpLengthStr];
    
    NSString *trmpTemperatureStr = [[NSNumber numberWithDouble:*((double *) getTemperature())] stringValue];
    [trmpValues addObject:trmpTemperatureStr];
    
    NSString *trmpBalanceStr = [[NSNumber numberWithDouble:*((double *) getBalance())] stringValue];
    [trmpValues addObject:trmpBalanceStr];
    
    NSString *trmpBreathinessStr = [[NSNumber numberWithDouble:*((double *) getBreathiness())] stringValue];
    [trmpValues addObject:trmpBreathinessStr];

    NSString *trmpLossFactorStr = [[NSNumber numberWithDouble:*((double *) getLossFactor())] stringValue];
    [trmpValues addObject:trmpLossFactorStr];
    
    NSString *trmpTpStr = [[NSNumber numberWithDouble:*((double *) getTp())] stringValue];
    [trmpValues addObject:trmpTpStr];
    
    NSString *trmpTnMinStr = [[NSNumber numberWithDouble:*((double *) getTnMin())] stringValue];
    [trmpValues addObject:trmpTnMinStr];

    NSString *trmpTnMaxStr = [[NSNumber numberWithDouble:*((double *) getTnMax())] stringValue];
    [trmpValues addObject:trmpTnMaxStr];

    NSString *trmpThroatCutoffStr = [[NSNumber numberWithDouble:*((double *) getThroatCutoff())] stringValue];
    [trmpValues addObject:trmpThroatCutoffStr];
    
    NSString *trmpThroatVolStr = [[NSNumber numberWithDouble:*((double *) getThroatVol())] stringValue];
    [trmpValues addObject:trmpThroatVolStr];
    
    NSString *trmpApScaleStr = [[NSNumber numberWithDouble:*((double *) getApScale())] stringValue];
    [trmpValues addObject:trmpApScaleStr];
    
    NSString *trmpMouthCoefStr = [[NSNumber numberWithDouble:*((double *) getMouthCoef())] stringValue];
    [trmpValues addObject:trmpMouthCoefStr];
    
    NSString *trmpNoseCoefStr = [[NSNumber numberWithDouble:*((double *) getNoseCoef())] stringValue];
    [trmpValues addObject:trmpNoseCoefStr];
    
    NSString *trmpMixOffsetStr = [[NSNumber numberWithDouble:*((double *) getMixOffset())] stringValue];
    [trmpValues addObject:trmpMixOffsetStr];
    
    NSString *trmpGlotVolStr = [[NSNumber numberWithDouble:*((double *) getGlotVol())] stringValue];
    [trmpValues addObject:trmpGlotVolStr];
    
    NSString *trmpGlotPitchStr = [[NSNumber numberWithDouble:*((double *) getGlotPitch())] stringValue];
    [trmpValues addObject:trmpGlotPitchStr];

    NSString *trmpAspVolStr = [[NSNumber numberWithDouble:*((double *) getAspVol())] stringValue];
    [trmpValues addObject:trmpAspVolStr];
    
    NSString *trmpFricVolStr = [[NSNumber numberWithDouble:*((double *) getFricVol())] stringValue];
    [trmpValues addObject:trmpFricVolStr];
    
    NSString *trmpFricPosStr = [[NSNumber numberWithDouble:*((double *) getFricPos())] stringValue];
    [trmpValues addObject:trmpFricPosStr];
    
    NSString *trmpFricCFStr = [[NSNumber numberWithDouble:*((double *) getFricCF())] stringValue];
    [trmpValues addObject:trmpFricCFStr];
    
    NSString *trmpFricBWStr = [[NSNumber numberWithDouble:*((double *) getFricBW())] stringValue];
    [trmpValues addObject:trmpFricBWStr];
    
    NSString *trmprS1Str = [[NSNumber numberWithDouble:(*((double *) getRadius(0)))] stringValue];
    [trmpValues addObject:trmprS1Str];
    
    NSString *trmprS2Str = [[NSNumber numberWithDouble:(*((double *) getRadius(1)))] stringValue];
    [trmpValues addObject:trmprS2Str];
    
    NSString *trmprS3Str = [[NSNumber numberWithDouble:(*((double *) getRadius(2)))] stringValue];
    [trmpValues addObject:trmprS3Str];
    
    NSString *trmprS4Str = [[NSNumber numberWithDouble:(*((double *) getRadius(3)))] stringValue];
    [trmpValues addObject:trmprS4Str];
    
    NSString *trmprS5Str = [[NSNumber numberWithDouble:(*((double *) getRadius(4)))] stringValue];
    [trmpValues addObject:trmprS5Str];
    
    NSString *trmprS6Str = [[NSNumber numberWithDouble:(*((double *) getRadius(5)))] stringValue];
    [trmpValues addObject:trmprS6Str];
    
    NSString *trmprS7Str = [[NSNumber numberWithDouble:(*((double *) getRadius(6)))] stringValue];
    [trmpValues addObject:trmprS7Str];
    
    NSString *trmprS8Str = [[NSNumber numberWithDouble:(*((double *) getRadius(7)))] stringValue];
    [trmpValues addObject:trmprS8Str];
   
    NSString *trmpvSStr = [[NSNumber numberWithDouble:(*((double *) getVelumRadius()))] stringValue];
    [trmpValues addObject:trmpvSStr];

    NSString *trmpnS1Str = [[NSNumber numberWithDouble:(*((double *) getNoseRadius(1)))] stringValue];
    [trmpValues addObject:trmpnS1Str];

    NSString *trmpnS2Str = [[NSNumber numberWithDouble:(*((double *) getNoseRadius(2)))] stringValue];
    [trmpValues addObject:trmpnS2Str];
    
    NSString *trmpnS3Str = [[NSNumber numberWithDouble:(*((double *) getNoseRadius(3)))] stringValue];
    [trmpValues addObject:trmpnS3Str];
    
    NSString *trmpnS4Str = [[NSNumber numberWithDouble:(*((double *) getNoseRadius(4)))] stringValue];
    [trmpValues addObject:trmpnS4Str];
    
    NSString *trmpnS5Str = [[NSNumber numberWithDouble:(*((double *) getNoseRadius(5)))] stringValue];
    [trmpValues addObject:trmpnS5Str];






        
        // Create a File Open Dialog class.
        // create the save panel
        NSSavePanel *panel = [NSSavePanel savePanel];
        

        // set a new file name
        [panel setNameFieldStringValue:@"trmp4.trmp"];
        
        // display the panel
        [panel beginWithCompletionHandler:^(NSInteger result) {
            
            if (result == NSFileHandlingPanelOKButton) {
                
                // create a file manager and grab the save panel's returned URL
                NSFileManager *manager = [NSFileManager defaultManager];
                NSURL *saveURL = [panel URL];
                path = [saveURL absoluteString];
                NSLog(@"Controller m:644 The file path is %@", path);
                
                // then copy the trmpValues array to that location
                NSLog(@"Controller m:647 The first element in the array is %@", [trmpValues objectAtIndex:0]);
                
                NSLog(@"Controller m:650 The array trmpValues is of length %lu", [trmpValues count]);
                

               [self saveArrayToURL:saveURL:trmpValues];
                            
            // then copy the trmpValues array to that location
            
            }
            
            


        }];
        }


- (IBAction)glottalWaveformSelected:(id)sender;
{
}

- (IBAction)noisePulseModulationSelected:(id)sender;
{
}

- (IBAction)samplingRateSelected:(id)sender;
{
}

- (IBAction)monoStereoSelected:(id)sender;
{
}

#if 0
- (IBAction)tpFieldEntered:(id)sender;
{
}

- (IBAction)tnMinFieldEntered:(id)sender;
{
}

- (IBAction)tnMaxFieldEntered:(id)sender;
{
}
#endif

- (IBAction)tubeLengthFieldEntered:(id)sender;
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

	//[fricCFSlider setMaxValue:(*((double *) getSampleRate()) / 2.0)];
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
    //Enabling this notification kills the ability of any Tools to appear
    //even though they are apparently running, and in the "Windows" list
    //NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    //[nc postNotificationName:@"fricParamChanged" object:self];
	
	if (error == 1) NSBeep();
	

}

- (IBAction)temperatureFieldEntered:(id)sender;
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
	
	//if (error == 1) NSBeep();
}

- (IBAction)stereoBalanceFieldEntered:(id)sender;
{
}

- (IBAction)breathinessFieldEntered:(id)sender;
{
	BOOL rangeError = NO;
	
    /*  GET CURRENT ROUNDED VALUE FROM FIELD  */
    double currentValue = ([sender doubleValue]);
	
    /*  MAKE SURE VALUE IS IN RANGE  */
    if (currentValue < BREATHINESS_MIN) {
		rangeError = YES;
		currentValue = BREATHINESS_MIN;
    }
    else if (currentValue > LOSS_FACTOR_MAX) {
		rangeError = YES;
		currentValue = BREATHINESS_MAX;
    }
	
    /*  SET THE FIELD TO THE ROUNDED, CORRECTED VALUE  */
    [sender setFloatValue:currentValue];
	
    /*  IF CURRENT VALUE IS DIFFERENT FROM PREVIOUS VALUE, DEAL WITH IT  */
    if (currentValue != *((double *) getBreathiness())) {
		
		/*  SET INSTANCE VARIABLE  */
		*((double *) getBreathiness()) = currentValue;
		
		initializeSynthesizer();
		
		/*  SET SLIDER TO NEW VALUE  */
		[breathinessSlider setFloatValue:*((double *) getBreathiness())];
		
		/*  SEND ASPIRATION VOLUME TO SYNTHESIZER  */
		//[synthesizer setAspirationVolume:aspirationVolume];
		//*((double *) getAspVol()) = rint(currentValue);
		NSLog(@"Controller.m:615 breathiness is %f", *((double *) getBreathiness()));
		
		/*  SET DIRTY BIT  */
		[self setDirtyBit];
		
	}
	
	
	// *((double *) getLossFactor()) = [lossFactorField floatValue];
	// [lossFactorSlider setDoubleValue:*((double *) getLossFactor())];
	// NSLog(@"Controller.m:625 lossFactor is %f", *((double *) getLossFactor()));
}

- (IBAction)lossFactorFieldEntered:(id)sender;
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
        [dampingFactorField setFloatValue:(1.00 - (currentValue/100.00))*100];
		
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

- (IBAction)throatCutoffFieldEntered:(id)sender;
{
    double value = [sender doubleValue];
    if (value > 10000) {value = 10000; NSBeep();
        [throatCutoffField setDoubleValue:value];
    }
    if (value < 50) {value = 50; NSBeep();
        [throatCutoffField setDoubleValue:value];
    }
    [throatCutoffSlider setDoubleValue:value];
    
    *((double *) getThroatCutoff()) = value;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    NSLog(@"Sending throatCutoffChanged notification");
    [nc postNotificationName:@"throatCutoffChanged" object:self];
    initializeSynthesizer();

}

- (IBAction)throatVolumeFieldEntered:(id)sender;
{
    double value = [sender doubleValue];
    if (value > 48) {value = 48; NSBeep();
        [throatVolumeField setDoubleValue:value];
    }
    if (value < 0) {value = 0; NSBeep();
    [throatVolumeField setDoubleValue:value];
        }
    [throatVolumeSlider setDoubleValue:value];
    
    *((double *) getThroatVol()) = value;
    initializeSynthesizer();

    
}

- (IBAction)throatScaleTypeChanged:sender;
{
    NSLog(@"Throat scale switch pushed");
    initializeSynthesizer();
}

- (IBAction)apertureScalingFieldEntered:(id)sender;
{
}

- (IBAction)mouthApertureCoefficientFieldEntered:(id)sender;
{
    double value = [sender doubleValue];
    if (value > 10000) value = 10000;
    if (value < 100) value = 100;
    [mouthCoefSlider setDoubleValue:value];
    [mouthCoefField setDoubleValue:value];
    *((double *) getMouthCoef()) = value;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    NSLog(@"Sending mouthCoefChanged notification");
    [nc postNotificationName:@"mouthCoefChanged" object:self];
    initializeSynthesizer();
}

- (IBAction)noseApertureCoefficientFieldEntered:(id)sender;
{
    double value = [sender doubleValue];
    if (value > 10000) value = 10000;
    if (value < 100) value = 100;
    [noseCoefSlider setDoubleValue:value];
    [noseCoefField setDoubleValue:value];
    *((double *) getNoseCoef()) = value;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    NSLog(@"Sending NoseCoefChanged notification");
    [nc postNotificationName:@"noseCoefChanged" object:self];
    initializeSynthesizer();
}

- (IBAction)mixOffsetFieldEntered:(id)sender;
{
    double value = [sender doubleValue];
    if (value > 60) {value = 60; NSBeep();}
    if (value < 30) {value = 30; NSBeep();}
    [mixOffsetField setDoubleValue:value];
    *((double *) getMixOffset()) = value;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    NSLog(@"Sending mixOffsetChanged notification");
    [nc postNotificationName:@"mixOffsetChanged" object:self];
    initializeSynthesizer();

}

- (IBAction)n1RadiusFieldEntered:(id)sender;
{
}

- (IBAction)n2RadiusFieldEntered:(id)sender;
{
}

- (IBAction)n3RadiusFieldEntered:(id)sender;
{
}

- (IBAction)n4RadiusFieldEntered:(id)sender;
{
}

- (IBAction)n5RadiusFieldEntered:(id)sender;
{
}

- (IBAction)glottalVolumeFieldEntered:(id)sender;
{
}

- (IBAction)pitchFieldEntered:(id)sender;
{
	//[pitchScale drawPitch:(int)pitch Cents:(int)cents Volume:(float)volume];
}

- (IBAction)aspVolFieldEntered:(id)sender;
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

- (IBAction)fricVolFieldEntered:(id)sender;
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

- (IBAction)fricPosFieldEntered:(id)sender;
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

- (IBAction)fricCFFieldEntered:(id)sender;
{
    BOOL rangeError = NO;
	
    /*  GET CURRENT ROUNDED VALUE FROM FIELD  */
    int currentValue = (int)rint([sender doubleValue]);
	double maxValue = (double)(*((int *) getSampleRate()) / 2.0);
	NSLog(@"In fricCFFieldEntered, value is %d, maxValue is %f, sample rate %d", currentValue, maxValue, *((int *) getSampleRate()));
	
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
		
		// NOTIFY THE DISPLAY
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        NSLog(@"Sending fricParamChanged notification");
        [nc postNotificationName:@"fricParamChanged" object:self];
        initializeSynthesizer();
		
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

- (IBAction)fricBWFieldEntered:(id)sender;
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
		
		// NOTIFY THE DISPLAY
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        NSLog(@"Sending fricParamChanged notification");
        [nc postNotificationName:@"fricParamChanged" object:self];
        initializeSynthesizer();
		
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


- (IBAction)r1RadiusFieldEntered:(id)sender;
{
}

- (IBAction)r2RadiusFieldEntered:(id)sender;
{
}

- (IBAction)r3RadiusFieldEntered:(id)sender;
{
}

- (IBAction)r4RadiusFieldEntered:(id)sender;
{
}

- (IBAction)r5RadiusFieldEntered:(id)sender;
{
}

- (IBAction)r6RadiusFieldEntered:(id)sender;
{
}

- (IBAction)r7RadiusFieldEntered:(id)sender;
{
}

- (IBAction)r8RadiusFieldEntered:(id)sender;
{
}

- (IBAction)vRadiusFieldEntered:(id)sender;
{
}

#if 0
- (IBAction)tpSliderMoved:(id)sender;
{
}

- (IBAction)tnMinSliderMoved:(id)sender;
{
}

- (IBAction)tnMaxSliderMoved:(id)sender;
{
}
#endif

- (IBAction)tubeLengthSliderMoved:(id)sender;
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

- (IBAction)temperatureSliderMoved:(id)sender;
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

- (IBAction)stereoBalanceSliderMoved:(id)sender;
{
}

- (IBAction)breathinessSliderMoved:(id)sender;
{
    NSLog(@"Breathiness slider moved");
    BOOL rangeError = NO;
	
    /*  GET CURRENT ROUNDED VALUE FROM FIELD  */
    double currentValue = ([sender doubleValue]);
	
    /*  MAKE SURE VALUE IS IN RANGE  */
    if (currentValue < BREATHINESS_MIN) {
		rangeError = YES;
		currentValue = BREATHINESS_MIN;
    }
    else if (currentValue > BREATHINESS_MAX) {
		rangeError = YES;
		currentValue = BREATHINESS_MAX;
    }
	
    /*  SET THE SLIDER TO THE ROUNDED, CORRECTED VALUE  */
    [sender setFloatValue:currentValue];
	
    /*  IF CURRENT VALUE IS DIFFERENT FROM PREVIOUS VALUE, DEAL WITH IT  */
    if (currentValue != *((double *) getBreathiness())) {
		
		/*  SET INSTANCE VARIABLE  */
		*((double *) getBreathiness()) = currentValue;
		
		initializeSynthesizer();
		
		/*  SET FIELD TO NEW VALUE  */
		[breathinessField setFloatValue:*((double *) getBreathiness())];
		
		/*  SEND ASPIRATION VOLUME TO SYNTHESIZER  */
		//[synthesizer setAspirationVolume:aspirationVolume];
		//*((double *) getAspVol()) = rint(currentValue);
		NSLog(@"Controller.m:615 breathiness is %f", *((double *) getBreathiness()));
		
		/*  SET DIRTY BIT  */
		[self setDirtyBit];
    }

}

- (IBAction)lossFactorSliderMoved:(id)sender;
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
        [dampingFactorField setFloatValue:(1.00 - currentValue/100.00)*100];

		
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

- (void)apertureFieldEntered:sender
{

    BOOL rangeError = NO;
    double diameter = 0.0;
    int fieldTag = [sender tag];
    double value = [sender floatValue];

    NSLog(@"Aperture Field Entered, tag value is %d", fieldTag);
    
    /*  DETERMINE EQUIVALENT DIAMETER VALUE  */
    if (fieldTag == 1)
    {
            diameter = 2.0 * value;
            NSLog(@"Radius %f entered for apScale", value);
    }
    if (fieldTag == 2)
    {
            diameter = value;
            NSLog(@"Diameter %f entered for apScale", diameter);
    }
    if (fieldTag == 3)
    {
            diameter = (2 * sqrt(value/PI));
            NSLog(@"Area %f entered for apScale", value);

    }
            
   
    
    /*  CORRECT OUT OF RANGE VALUES  */
    if (diameter < APERTURE_SCALING_MIN) {
        NSLog(@"Apparent diameter is %f", diameter);
        diameter = APERTURE_SCALING_MIN;
        rangeError = YES;
    }
    else if (diameter > APERTURE_SCALING_MAX) {
        NSLog(@"Apparent diameter is %f", diameter);
        diameter = APERTURE_SCALING_MAX;
        rangeError = YES;
    }
    if (rangeError) {
        NSBeep();
        diameter = *((double *) getApScale());
        NSLog(@"Diameter is reset to %f", diameter);
        [apertureRadiusField setStringValue:[NSString stringWithFormat:@"%g", diameter/2]];
        [apertureDiameterField setStringValue:[NSString stringWithFormat:@"%g", diameter]];
        [apertureAreaField setStringValue:[NSString stringWithFormat:@"%g", diameter / 2 * diameter / 2 * PI]];


    }
    else {
        (*((double *) getApScale())) = diameter; // WHICH IS THE APERTURE SCALING
        [apertureRadiusField setStringValue:[NSString stringWithFormat:@"%g", diameter/2]];
        [apertureDiameterField setStringValue:[NSString stringWithFormat:@"%g", diameter]];
        [apertureAreaField setStringValue:[NSString stringWithFormat:@"%g", diameter / 2 * diameter / 2 * PI]];


    }
    
}



- (IBAction)throatCutoffSliderMoved:(id)sender;
{
    double value = [sender doubleValue];
    if (value > 10000) {value = 10000; NSBeep();
        [throatCutoffSlider setDoubleValue:value];
    }
    if (value < 50) {value = 50; NSBeep();
        [throatCutoffSlider setDoubleValue:value];
    }
    [throatCutoffField setDoubleValue:value];
    *((double *) getThroatCutoff()) = value;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    NSLog(@"Sending throatCutoffChanged notification");
    [nc postNotificationName:@"throatCutoffChanged" object:self];
    initializeSynthesizer();

}

- (IBAction)throatVolumeSliderMoved:(id)sender;
{
    double value = [sender doubleValue];
    if (value > 48) {value = 48; NSBeep();
        [throatVolumeSlider setDoubleValue:value];
    }
    if (value < 0) {value = 0; NSBeep();
        [throatVolumeSlider setDoubleValue:value];
    }
    [throatVolumeField setDoubleValue:value];
    
    *((double *) getThroatVol()) = value;
    initializeSynthesizer();

}

- (IBAction)apertureScalingSliderMoved:(id)sender;
{
}

- (IBAction)mouthApertureCoefficientSliderMoved:(id)sender;
{
    double value = [sender doubleValue];
    if (value > 10000) value = 10000;
    if (value < 100) value = 100;
    [mouthCoefField setDoubleValue:value];
    [mouthCoefSlider setDoubleValue:value];
    *((double *) getMouthCoef()) = value;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    NSLog(@"Sending mouthCoefChanged notification");
    [nc postNotificationName:@"mouthCoefChanged" object:self];
    initializeSynthesizer();
        
}

- (IBAction)noseApertureCoefficientSliderMoved:(id)sender;
{
    double value = [sender doubleValue];
    if (value > 10000) value = 10000;
    if (value < 100) value = 100;
    [noseCoefField setDoubleValue:value];
    [noseCoefSlider setDoubleValue:value];
    *((double *) getNoseCoef()) = value;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    NSLog(@"Sending noseCoefChanged notification");
    [nc postNotificationName:@"noseCoefChanged" object:self];
    initializeSynthesizer();
}

- (IBAction)mixOffsetSliderMoved:(id)sender;
{
    double value = [sender doubleValue];
    if (value > 60) {value = 60; NSBeep();}
    if (value < 30) {value = 30; NSBeep();}
    [mixOffsetField setDoubleValue:value];
    [mixOffsetSlider setDoubleValue:value];
    *((double *) getMixOffset()) = value;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    NSLog(@"Sending mixOffsetChanged notification");
    [nc postNotificationName:@"mixOffsetChanged" object:self];
    initializeSynthesizer();

}

- (IBAction)n1RadiusSliderMoved:(id)sender;
{
}

- (IBAction)n2RadiusSliderMoved:(id)sender;
{
}

- (IBAction)n3RadiusSliderMoved:(id)sender;
{
}

- (IBAction)n4RadiusSliderMoved:(id)sender;
{
}

- (IBAction)n5RadiusSliderMoved:(id)sender;
{
}

- (IBAction)glottalVolumeSliderMoved:(id)sender;
{
}

#if 0
- (IBAction)pitchSliderMoved:(id)sender;
{
    /*
    NSNotificationCenter *nc;
    NSMutableDictionary *ident;
    NSNumber *identifier, *sectionRadius;
    nc = [NSNotificationCenter defaultCenter];
    NSLog(@"Sending Notification pitch slider changed");
     */
	*((double *) getGlotPitch()) = (double) [pitchSlider floatValue];
	NSLog(@"Pitch is now %f", *((double *) getGlotPitch()));
}
#endif

- (IBAction)aspVolSliderMoved:(id)sender;
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

- (IBAction)fricVolSliderMoved:(id)sender;
{
	BOOL rangeError = NO;
	
    /*  GET CURRENT VALUE FROM FIELD  */
    int currentValue = (int) rint([sender doubleValue]);
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

- (IBAction)fricPosSliderMoved:(id)sender;
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

- (IBAction)fricCFSliderMoved:(id)sender;
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
    NSLog(@"Current value to be used is %d", currentValue);
	
    /*  IF CURRENT VALUE IS DIFFERENT FROM PREVIOUS VALUE, DEAL WITH IT  */
    if (currentValue != (int)*((double *) getFricCF())) {
		/*  SET INSTANCE VARIABLE  */
		*((double *) getFricCF()) = currentValue;
		
		/*  SET FIELD TO NEW VALUE  */
		[fricCFField setDoubleValue:*((double *) getFricCF())];

        // NOTIFY THE DISPLAY
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        NSLog(@"Sending fricParamChanged notification");
        [nc postNotificationName:@"fricParamChanged" object:self];
        initializeSynthesizer();
		
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

- (IBAction)fricBWSliderMoved:(id)sender;
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
        
        // NOTIFY THE DISPLAY
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        NSLog(@"Sending fricParamChanged notification");
        [nc postNotificationName:@"fricParamChanged" object:self];
        initializeSynthesizer();
		
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

- (IBAction)r1RadiusSliderMoved:(id)sender;
{
}

- (IBAction)r2RadiusSliderMoved:(id)sender;
{
}

- (IBAction)r3RadiusSliderMoved:(id)sender;
{
}

- (IBAction)r4RadiusSliderMoved:(id)sender;
{
}

- (IBAction)r5RadiusSliderMoved:(id)sender;
{
}

- (IBAction)r6RadiusSliderMoved:(id)sender;
{
}

- (IBAction)r7RadiusSliderMoved:(id)sender;
{
}

- (IBAction)r8RadiusSliderMoved:(id)sender;
{
}

- (IBAction)vSliderMoved:(id)sender;
{
}

// This method handles the section sliders associated with nose, velum and oropharynx sections
// based on a notification from the associated slider object which also supplies tag info.  The
// slider objects that need attention (TubeSection and VelumSlider) post a notification and this
// method picks it up and deals with it.

- (void)sliderMoved:(NSNotification *)originator;
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
    [postureLabel setStringValue:@""];
}

- (void)setDirtyBit;
{
}

/*  Set methods to link Objective-C code and C modules  */

- (void)csetGlotPitch:(float)value;
{
	setGlotPitch(value);
}

- (void)csetGlotVol:(float)value;
{
}

- (void)csetAspVol:(float)value;
{
}

- (void)csetFricVol:(float)value;
{
}

- (void)csetfricPos:(float)value;
{
}

- (void)csetFricCF:(float)value;
{
}

- (void)csetFricBW:(float)value;
{
}

- (void)csetRadius:(float)value :(int)index;
{
}

- (void)csetVelum:(float)value;
{
}

- (void)csetVolume:(double)value;
{
}

- (void)csetWaveform:(int)value;
{
}

- (void)csetTp:(double)value;
{
}

- (void)csetTnMin:(double)value;
{
}

- (void)csetTnMax:(double)value;
{
}

- (void)csetBreathiness:(double)value;
{
}

- (void)csetLength:(double)value;
{
}

- (void)csetTemperature:(double)value;
{
}

- (void)csetLossFactor:(double)value;
{
}

- (void)csetApScale:(double)value;
{
}

- (void)csetMouthCoef:(double)value;
{
}

- (void)csetNoseCoef:(double)value;
{
}

- (void)csetNoseRadius:(double)value :(int)index;
{
}

- (void)csetThroatCoef:(double)value;
{
}

- (void)csetModulation:(int)value;
{
}

- (void)csetMixOffset:(double)value;
{
}

- (void)csetThroatCutoff:(double)value;
{
}

- (void)csetThroatVolume:(double)value;
{
}

- (void)adjustToNewSampleRate;
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



- (void)adjustSampleRate;
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


- (void)injectFricationAt:(float)position;
{
    /*  DRAW ARROW WHERE FRICATION IS TO BE INJECTED  */
    [fricativeArrow setFricationPosition:position]; 
}


- (void)setTitle:(NSString *)pathDescription;
{
    [_mainWindow setTitleWithRepresentedFilename:pathDescription];
}

- (void)calculateSampleRate;
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

- (void)handleFricArrowMoved:(NSNotification *)note;
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
	
- (BOOL)tubeRunState;
{
	return _isPlaying;
}

- (IBAction)saveOutputFile:(id)sender;
{
}

- (void) addObjectArray:(NSMutableArray *) array :(NSString *) string;
{
    int index = [array count];
    //NSLog(@"Controller m:557 The object just stored is %@", string);
    [array addObject:string];
    float test = [[array objectAtIndex:index] floatValue];
    NSLog(@"Controller m:1908 Value just stored at index %d is %f", index, test);
    NSLog(@"Controller m:1909 The array trmpValues is of length %lu", [array count]);
}

- (BOOL) saveArrayToURL:URL :array;
{
    NSLog(@"Controller m:647 The first element in the array is %@", [array objectAtIndex:0]);
    
    NSLog(@"Controller m:650 The array trmpValues is of length %lu", [array count]);
    
    NSLog(@"The array trmpValues consists of %@", array);
    BOOL success;
    NSLog(@"Controller m:680, path is %@", URL);
    NSLog(@"Controller m:680, path is %@", URL);
    success = [array writeToURL:URL atomically:YES];
    NSLog(@"Controller m:680, path is %@", URL);
    if (success == 0) NSLog(@"write file failed");                
    NSLog(@"Controller m:653 The first element in the array is %@", [array objectAtIndex:0]);
    return success;
}

- (void) setNewValues:URL :array;
{

}

- (IBAction)mixOffsetToggleChanged:sender;
{
    NSButtonCell *selCell = [sender selectedCell];
    
    NSLog(@"Selected cell is %ld", (long)[selCell tag]);
    
    modulation = (int)[selCell tag];
    
    NSLog(@"Modulation is now %d", modulation);
    
    *((int *) getModulation()) = modulation;
    NSLog(@"Modulation from tube is %d", *((int *) getModulation()));
    initializeSynthesizer();
    
}

- (IBAction)fricScaleTypeChanged:sender;
{
    NSLog(@"fricScaleype button pushed");
}




@end

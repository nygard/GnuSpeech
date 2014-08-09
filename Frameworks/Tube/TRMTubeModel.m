//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "TRMTubeModel.h"

#import <AudioToolbox/AudioToolbox.h>
#import "TRMParameters.h"
#import "TRMDataList.h"
#import "TRMInputParameters.h"
#import "TRMUtility.h"
#import "TRMSampleRateConverter.h"
#import "TRMWavetable.h"
#import "NSData-STExtensions.h"

#import "TRMFilters.h"

// Oropharynx scattering junction coefficients (between each region)
#define C1                        TRM_R1     // R1-R2 (S1-S2)
#define C2                        TRM_R2     // R2-R3 (S2-S3)
#define C3                        TRM_R3     // R3-R4 (S3-S4)
#define C4                        TRM_R4     // R4-R5 (S5-S6)
#define C5                        TRM_R5     // R5-R6 (S7-S8)
#define C6                        TRM_R6     // R6-R7 (S8-S9)
#define C7                        TRM_R7     // R7-R8 (S9-S10)
#define C8                        TRM_R8     // R8-AIR (S10-AIR)
#define TOTAL_COEFFICIENTS        TOTAL_REGIONS

// Oropharynx sections
#define S1                        0      // R1
#define S2                        1      // R2
#define S3                        2      // R3
#define S4                        3      // R4
#define S5                        4      // R4
#define S6                        5      // R5
#define S7                        6      // R5
#define S8                        7      // R6
#define S9                        8      // R7
#define S10                       9      // R8
#define TOTAL_SECTIONS            10

// Nasal tract coefficients
#define NC1                       TRM_N1     // N1-N2
#define NC2                       TRM_N2     // N2-N3
#define NC3                       TRM_N3     // N3-N4
#define NC4                       TRM_N4     // N4-N5
#define NC5                       TRM_N5     // N5-N6
#define NC6                       TRM_N6     // N6-AIR
#define TOTAL_NASAL_COEFFICIENTS  TOTAL_NASAL_SECTIONS

// Three-way junction alpha coefficients
#define LEFT                      0
#define RIGHT                     1
#define UPPER                     2
#define TOTAL_ALPHA_COEFFICIENTS  3

// Frication injection coefficients
#define FC1                       0      // S3
#define FC2                       1      // S4
#define FC3                       2      // S5
#define FC4                       3      // S6
#define FC5                       4      // S7
#define FC6                       5      // S8
#define FC7                       6      // S9
#define FC8                       7      // S10
#define TOTAL_FRIC_COEFFICIENTS   8


// Scaling constant for input to vocal tract and throat (matches DSP)
//#define VT_SCALE                  0.03125       // 2^(-5)

// this is a temporary fix only, to try to match dsp synthesizer
#define VT_SCALE                  0.125         // 2^(-3)

// Bi-directional transmission line pointers
#define TOP                       0
#define BOTTOM                    1

// 1 means to compile so that interpolation not done for some control rate parameters
#define MATCH_DSP 0

// Maximum sample value
#define TRMSampleValue_Maximum    32767.0

// Size in bits per output sample
#define TRMBitsPerSample          16

AudioFileTypeID TRMCoreAudioFormatFromSoundFileFormat(TRMSoundFileFormat format)
{
    switch (format) {
        case TRMSoundFileFormat_AU:   return kAudioFileNextType;
        case TRMSoundFileFormat_AIFF: return kAudioFileAIFFType;
        case TRMSoundFileFormat_WAVE: return kAudioFileWAVEType;
    }
    
    return 0;
}


NSString *STCoreAudioErrorDescription(OSStatus error)
{
    switch (error) {
        case kAudioFileUnspecifiedError:               return @"An unspecified error has occurred.";
        case kAudioFileUnsupportedFileTypeError:       return @"The file type is not supported.";
        case kAudioFileUnsupportedDataFormatError:     return @"The data format is not supported by this file type.";
        case kAudioFileUnsupportedPropertyError:       return @"The property is not supported.";
        case kAudioFileBadPropertySizeError:           return @"The size of the property data was not correct.";
        case kAudioFilePermissionsError:               return @"The operation violated the file permissions. For example, trying to write to a file opened with kAudioFileReadPermission.";
        case kAudioFileNotOptimizedError:              return @"There are chunks following the audio data chunk that prevent extending the audio data chunk.  The file must be optimized in order to write more audio data.";
        case kAudioFileInvalidChunkError:              return @"The chunk does not exist in the file or is not supported by the file.";
        case kAudioFileDoesNotAllow64BitDataSizeError: return @"The a file offset was too large for the file type. AIFF and WAVE have a 32 bit file size limit.";
        case kAudioFileInvalidPacketOffsetError:       return @"A packet offset was past the end of the file, or not at the end of the file when writing a VBR format, or a corrupt packet size was read when building the packet table.";
        case kAudioFileInvalidFileError:               return @"The file is malformed, or otherwise not a valid instance of an audio file of its type.";
        case kAudioFileOperationNotSupportedError:     return @"The operation cannot be performed. For example, setting kAudioFilePropertyAudioDataByteCount to increase the size of the audio data in a file is not a supported operation. Write the data instead.";
        case kAudioFileEndOfFileError:                 return @"End of file.";
        case kAudioFilePositionError:                  return @"Invalid file position.";
        case kAudioFileNotOpenError:                   return @"The file is closed.";
    }

    return @"Unknown";
}

#pragma mark -

@interface TRMTubeModel ()
@property (readonly) TRMDataList *inputData;
@property (nonatomic, readonly) TRMInputParameters *inputParameters;
@property (readonly) TRMSampleRateConverter *sampleRateConverter;
@end

#pragma mark -

@implementation TRMTubeModel
{
    // Derived values
    int32_t _controlPeriod;
    int32_t _sampleRate;
    double _actualTubeLength;            // actual length in cm

    double _dampingFactor;             // calculated damping factor
    double _crossmixFactor;              // calculated crossmix factor

    double _breathinessFactor;

    TRMNoiseGenerator _noiseGenerator;
    TRMLowPassFilter2 _noiseFilter;             // One-zero lowpass filter.

    // Mouth reflection filter: Is a variable, one-pole lowpass filter,            whose cutoff       is determined by the mouth aperture coefficient.
    // Mouth radiation filter:  Is a variable, one-zero, one-pole highpass filter, whose cutoff point is determined by the mouth aperture coefficient.
    TRMRadiationReflectionFilter _mouthFilterPair;

    // Nasal reflection filter: Is a one-pole lowpass filter,            used for terminating the end of            the nasal cavity.
    // Nasal radiation filter:  Is a one-zero, one-pole highpass filter, used for the radiation characteristic from the nasal cavity.
    TRMRadiationReflectionFilter _nasalFilterPair;

    TRMLowPassFilter _throatLowPassFilter;      // Simulates the radiation of sound through the walls of the throat.
    double _throatGain;

    TRMBandPassFilter _fricationBandPassFilter; // Frication bandpass filter, with variable center frequency and bandwidth.

    // Memory for tue and tube coefficients
    double _oropharynx[TOTAL_SECTIONS][2][2];
    double _oropharynx_coeff[TOTAL_COEFFICIENTS];

    double _nasal[TOTAL_NASAL_SECTIONS][2][2];
    double _nasal_coeff[TOTAL_NASAL_COEFFICIENTS];

    double _alpha[TOTAL_ALPHA_COEFFICIENTS];
    NSUInteger _currentIndex;
    NSUInteger _previousIndex;

    // Memory for frication taps
    double _fricationTap[TOTAL_FRIC_COEFFICIENTS];

    // Variables for interpolation
    TRMParameters *_currentParameters;
    TRMParameters *_currentDelta;

    TRMSampleRateConverter *_sampleRateConverter;
    TRMWavetable *_wavetable;

    TRMDataList *_inputData;

    BOOL _verbose;
}

- (id)initWithInputData:(TRMDataList *)inputData;
{
    if ((self = [super init])) {
        _inputData = inputData;

        double nyquist;
        
        _currentParameters = [[TRMParameters alloc] init];
        _currentDelta = [[TRMParameters alloc] init];
        
        // Calculate the sample rate, based on nominal tube length and speed of sound
        if (_inputData.inputParameters.length > 0.0) {
            double c = speedOfSound_mps(_inputData.inputParameters.temperature);
            
            _controlPeriod = rint((c * TOTAL_SECTIONS * 100.0) / (_inputData.inputParameters.length * _inputData.inputParameters.controlRate));
            _sampleRate = _inputData.inputParameters.controlRate * _controlPeriod;
            _actualTubeLength = (c * TOTAL_SECTIONS * 100.0) / _sampleRate;
            nyquist = (double)_sampleRate / 2.0;
        } else {
            fprintf(stderr, "Illegal tube length: %g\n", _inputData.inputParameters.length);
            return nil;
        }
        
        // Calculate the breathiness factor
        _breathinessFactor = _inputData.inputParameters.breathiness / 100.0;
        
        // Calculate crossmix factor
        _crossmixFactor = 1.0 / amplitude(_inputData.inputParameters.mixOffset);
        
        // Calculate the damping factor
        _dampingFactor = (1.0 - (_inputData.inputParameters.lossFactor / 100.0));
        
        // Initialize the wave table
        _wavetable = [[TRMWavetable alloc] initWithWaveform:_inputData.inputParameters.waveform throttlePulse:_inputData.inputParameters.tp tnMin:_inputData.inputParameters.tnMin tnMax:_inputData.inputParameters.tnMax sampleRate:_sampleRate];
        
        // Initialize reflection and radiation filter coefficients for mouth
        TRMRadiationReflectionFilter_InitWithCoefficient(&_mouthFilterPair, (nyquist - _inputData.inputParameters.mouthCoef) / nyquist);

        // Initialize reflection and radiation filter coefficients for nose
        TRMRadiationReflectionFilter_InitWithCoefficient(&_nasalFilterPair, (nyquist - _inputData.inputParameters.noseCoef) / nyquist);

        // Initialize nasal cavity fixed scattering coefficients
        [self initializeNasalCavity];
        
        // TODO (2004-05-07): nasal?

        TRMNoiseGenerator_Init(&_noiseGenerator);

        // Initialize the noise filter
        _noiseFilter.x = 0;

        // Initialize the throat lowpass filter
        TRMLowPassFilter_CalculateCoefficients(&_throatLowPassFilter, _sampleRate, self.inputParameters.throatCutoff);
        _throatGain = amplitude(self.inputParameters.throatVol);

        _sampleRateConverter = [[TRMSampleRateConverter alloc] initWithInputRate:_sampleRate outputRate:_inputData.inputParameters.outputRate];

        // TODO (2004-05-07): oropharynx
        // TODO (2004-05-07): alpha
        
        _currentIndex  = 1;
        _previousIndex = 0;
        
        // TODO (2004-05-07): fricationTap


        // Initialize parts of this filter.  The coefficients are set elsewhere.
        _fricationBandPassFilter.xn1 = 0;
        _fricationBandPassFilter.xn2 = 0;
        _fricationBandPassFilter.yn1 = 0;
        _fricationBandPassFilter.yn2 = 0;
    }

    return self;
}

#pragma mark -

- (TRMInputParameters *)inputParameters;
{
    return self.inputData.inputParameters;
}

#pragma mark -

// Performs the actual synthesis of sound samples.
- (void)synthesize;
{
    if ([self.inputData.values count] == 0) {
        // No data
        return;
    }
    
    // Control rate loop
    TRMParameters *previous = nil;
    
    for (TRMParameters *parameters in self.inputData.values) {
        if (previous == nil) {
            previous = parameters;
            continue;
        }
        
        // Set control rate parameters from input tables
        [self setControlRateParameters:parameters previous:previous];
        
        // Sample rate loop
        for (NSUInteger j = 0; j < _controlPeriod; j++) {
            // Convert parameters here
            double f0  = frequency(_currentParameters.glottalPitch);
            double ax  = amplitude(_currentParameters.glottalVolume);
            double ah1 = amplitude(_currentParameters.aspirationVolume);

            [self calculateTubeCoefficients];
            [self setFricationTaps];
            TRMBandPassFilter_CalculateCoefficients(&_fricationBandPassFilter, _sampleRate, _currentParameters.fricationCenterFrequency, _currentParameters.fricationBandwidth);
            
            
            // Do synthesis here
            // Create low-pass filtered noise
            double lp_noise = TRMLowPassFilter2_FilterInput(&_noiseFilter, TRMNoiseGenerator_GetSample(&_noiseGenerator));
            
            // Update the shape of the glottal pulse, if necessary
            if (self.inputParameters.waveform == TRMWaveFormType_Pulse)
                [_wavetable update:ax];
            
            // Create glottal pulse (or sine tone)
            double pulse = [_wavetable oscillator:f0];
            
            // Create pulsed noise
            double pulsed_noise = lp_noise * pulse;
            
            // Create noisy glottal pulse
            pulse = ax * ((pulse * (1.0 - _breathinessFactor)) + (pulsed_noise * _breathinessFactor));
            
            double signal;
            
            // Cross-mix pure noise with pulsed noise
            if (self.inputParameters.usesModulation) {
                double crossmix = ax * _crossmixFactor;
                crossmix = (crossmix < 1.0) ? crossmix : 1.0;
                signal = (pulsed_noise * crossmix) + (lp_noise * (1.0 - crossmix));
                if (_verbose) {
                    printf("\nSignal = %e", signal);
                    fflush(stdout);
                }
            } else {
                signal = lp_noise;
            }
            
            // Put signal through vocal tract
            signal = [self updateVocalTractWithGlottalPulse:((pulse + (ah1 * signal)) * VT_SCALE)
                                                  frication:TRMBandPassFilter_FilterInput(&_fricationBandPassFilter, signal)];
            
            
            // Put pulse through throat
            signal += TRMLowPassFilter_FilterInput(&_throatLowPassFilter, pulse * VT_SCALE) * _throatGain;
            if (_verbose)
                printf("\nDone throat\n");
            
            // Output sample
            [self.sampleRateConverter dataFill:signal];
            if (_verbose)
                printf("\nDone datafil\n");
            
            // Do sample rate interpolation of control parameters
            [self sampleRateInterpolation];
            if (_verbose)
                printf("\nDone sample rate interp\n");
        }
        
        previous = parameters;
    }
    
    // Be sure to flush source buffer
    [self.sampleRateConverter flush];
}

// Scales the samples stored in the temporary data stream, and writes them to the output file, with the appropriate
// header.  Also does master volume scaling, and stereo balance scaling, if 2 channels of output.
- (BOOL)saveOutputToFile:(NSString *)filename error:(NSError **)error;
{
    //printf("maximumSampleValue: %g\n", sampleRateConverter->maximumSampleValue);
    
    // Calculate scaling constant
    double scale = (TRMSampleValue_Maximum / self.sampleRateConverter.maximumSampleValue) * amplitude(self.inputParameters.volume);
    
    /*if (verbose)*/ {
        printf("\nnumber of samples:\t%-d\n", self.sampleRateConverter.numberSamples);
        printf("maximum sample value:\t%.4f\n", self.sampleRateConverter.maximumSampleValue);
        printf("scale:\t\t\t%.4f\n", scale);
    }
    
    // If stereo, calculate left and right scaling constants
    double leftScale = 1.0, rightScale = 1.0;
    if (self.inputParameters.channels == 2) {
		// Calculate left and right channel amplitudes
		leftScale = -((self.inputParameters.balance / 2.0) - 0.5) * scale * 2.0;
		rightScale = ((self.inputParameters.balance / 2.0) + 0.5) * scale * 2.0;
        
		if (_verbose) {
			printf("left scale:\t\t%.4f\n", leftScale);
			printf("right scale:\t\t%.4f\n", rightScale);
		}
    }
    
    NSData *resampledData = [self.sampleRateConverter resampledData];
    NSInputStream *inputStream = [NSInputStream inputStreamWithData:resampledData];
    [inputStream open];

    //NSString *filePath = [filename stringByAppendingPathExtension:TRMSoundFileFormatExtension(self.inputParameters.outputFileFormat)];
    NSURL *fileURL = [NSURL fileURLWithPath:filename];

    // WAV must be little endian
    AudioStreamBasicDescription asbd;
    memset(&asbd, 0, sizeof(asbd));
    asbd.mSampleRate       = self.inputParameters.outputRate;
    asbd.mFormatID         = kAudioFormatLinearPCM;
    asbd.mFormatFlags      = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    asbd.mBitsPerChannel   = 16;
    asbd.mChannelsPerFrame = (UInt32)self.inputParameters.channels;
    asbd.mFramesPerPacket  = 1; // Always 1 for uncompressed formats
    asbd.mBytesPerFrame    = 2*(UInt32)self.inputParameters.channels;
    asbd.mBytesPerPacket   = 2*(UInt32)self.inputParameters.channels;

    if (self.inputParameters.outputFileFormat == TRMSoundFileFormat_AU || self.inputParameters.outputFileFormat == TRMSoundFileFormat_AIFF) {
        asbd.mFormatFlags |= kAudioFormatFlagIsBigEndian;
    }
    
    AudioFileID audioFile;
    OSStatus audioError = AudioFileCreateWithURL((__bridge CFURLRef)(fileURL), TRMCoreAudioFormatFromSoundFileFormat(self.inputParameters.outputFileFormat), &asbd, kAudioFileFlags_EraseFile, &audioFile);
    //NSLog(@"Error: %@", STCoreAudioErrorDescription(audioError));
    assert(audioError == noErr);

    // Write the samples to file, scaling each sample
    if (self.inputParameters.channels == 1) {
        if (self.inputParameters.outputFileFormat == TRMSoundFileFormat_WAVE) {
            for (int32_t index = 0; index < self.sampleRateConverter.numberSamples; index++) {
                double sample;
                
                NSInteger result = [inputStream read:(void *)&sample maxLength:sizeof(sample)];
                NSCAssert(result == sizeof(sample), @"Error reading from input stream");
                
                UInt32 sampleByteCount = 2;
                int16_t sample2 = CFSwapInt16HostToLittle(rint(sample * scale));
                audioError = AudioFileWriteBytes(audioFile, false, index * 2, &sampleByteCount, &sample2);
                assert(audioError == noErr);
            }
        } else {
            for (int32_t index = 0; index < self.sampleRateConverter.numberSamples; index++) {
                double sample;
                
                NSInteger result = [inputStream read:(void *)&sample maxLength:sizeof(sample)];
                NSCAssert(result == sizeof(sample), @"Error reading from input stream");
                
                UInt32 sampleByteCount = 2;
                int16_t sample2 = CFSwapInt16HostToBig(rint(sample * scale));
                audioError = AudioFileWriteBytes(audioFile, false, index * 2, &sampleByteCount, &sample2);
                assert(audioError == noErr);
            }
        }
    } else {
        if (self.inputParameters.outputFileFormat == TRMSoundFileFormat_WAVE) {
            for (int32_t index = 0; index < self.sampleRateConverter.numberSamples; index++) {
                double sample;
                
                NSInteger result = [inputStream read:(void *)&sample maxLength:sizeof(sample)];
                NSCAssert(result == sizeof(sample), @"Error reading from input stream");
                
                int16_t left  = CFSwapInt16HostToLittle(rint(sample * leftScale));
                int16_t right = CFSwapInt16HostToLittle(rint(sample * rightScale));

                UInt32 sampleByteCount = 2;
                audioError = AudioFileWriteBytes(audioFile, false, index * 4, &sampleByteCount, &left);
                assert(audioError == noErr);

                sampleByteCount = 2;
                audioError = AudioFileWriteBytes(audioFile, false, index * 4 + 2, &sampleByteCount, &right);
                assert(audioError == noErr);
            }
        } else {
            for (int32_t index = 0; index < self.sampleRateConverter.numberSamples; index++) {
                double sample;
                
                NSInteger result = [inputStream read:(void *)&sample maxLength:sizeof(sample)];
                NSCAssert(result == sizeof(sample), @"Error reading from input stream");
                
                int16_t left  = CFSwapInt16HostToBig(rint(sample * leftScale));
                int16_t right = CFSwapInt16HostToBig(rint(sample * rightScale));
                
                UInt32 sampleByteCount = 2;
                audioError = AudioFileWriteBytes(audioFile, false, index * 4, &sampleByteCount, &left);
                assert(audioError == noErr);
                
                sampleByteCount = 2;
                audioError = AudioFileWriteBytes(audioFile, false, index * 4 + 2, &sampleByteCount, &right);
                assert(audioError == noErr);
            }
        }
    }

    audioError = AudioFileClose(audioFile);
    assert(audioError == noErr);

    return YES;
}

#pragma mark - WAV data generation

const uint16_t kWAVEFormat_Unknown         = 0x0000;
const uint16_t kWAVEFormat_UncompressedPCM = 0x0001;

// RIFF
#define WAV_CHUNK_ID        0x52494646

// WAVE
#define WAV_RIFF_TYPE       0x57415645

// fmt
#define WAV_FORMAT_CHUNK_ID 0x666d7420

// data
#define WAV_DATA_CHUNK_ID   0x64617461

- (NSData *)generateWAVData;
{
    NSParameterAssert(self.sampleRateConverter.maximumSampleValue != 0);
    
    NSMutableData *sampleData = [[NSMutableData alloc] init];
    
    double scale = (TRMSampleValue_Maximum / self.sampleRateConverter.maximumSampleValue) * amplitude(_inputData.inputParameters.volume);
    
    NSLog(@"number of samples:\t%-d\n", self.sampleRateConverter.numberSamples);
    NSLog(@"maximum sample value:\t%.4f\n", self.sampleRateConverter.maximumSampleValue);
    NSLog(@"scale:\t\t\t%.4f\n", scale);
    
    NSData *resampledData = [self.sampleRateConverter resampledData];
    NSInputStream *inputStream = [NSInputStream inputStreamWithData:resampledData];
    [inputStream open];
    
    if (_inputData.inputParameters.channels == 2) {
		// Calculate left and right channel amplitudes.
		//
		// leftScale = -((inputData->inputParameters.balance / 2.0) - 0.5) * scale * 2.0;
		// rightScale = ((inputData->inputParameters.balance / 2.0) + 0.5) * scale * 2.0;
        
        // This doesn't have the crackling when at all left or all right, but it's not as loud as Mono by default.
		double leftScale = -((_inputData.inputParameters.balance / 2.0) - 0.5) * scale;
		double rightScale = ((_inputData.inputParameters.balance / 2.0) + 0.5) * scale;
        
        printf("left scale:\t\t%.4f\n", leftScale);
        printf("right scale:\t\t%.4f\n", rightScale);
        
        for (NSUInteger index = 0; index < self.sampleRateConverter.numberSamples; index++) {
            double sample;
            
            NSInteger result = [inputStream read:(void *)&sample maxLength:sizeof(sample)];
            NSParameterAssert(result == sizeof(sample));
            
            uint16_t value = (short)rint(sample * leftScale);
            [sampleData appendBytes:&value length:sizeof(value)];
            
            value = (short)rint(sample * rightScale);
            [sampleData appendBytes:&value length:sizeof(value)];
        }
    } else {
        for (NSUInteger index = 0; index < self.sampleRateConverter.numberSamples; index++) {
            double sample;
            
            NSInteger result = [inputStream read:(void *)&sample maxLength:sizeof(sample)];
            NSParameterAssert(result == sizeof(sample));
            
            uint16_t value = (short)rint(sample * scale);
            [sampleData appendBytes:&value length:sizeof(value)];
        }
    }
    
    int frameSize = (int)ceil(_inputData.inputParameters.channels * ((double)TRMBitsPerSample / 8));
    int bytesPerSecond = (int)ceil(_inputData.inputParameters.outputRate * frameSize);
    
    NSMutableData *data = [NSMutableData data];
    uint32_t subChunk1Size = 18;
    uint32_t subChunk2Size = (uint32_t)[sampleData length]; // Loses precision...
    uint32_t chunkSize = 4 + (8 + subChunk1Size) + (8 + subChunk2Size);
    
    // Header - RIFF type chunk
    [data appendBigInt32:WAV_CHUNK_ID]; // RIFF
    [data appendLittleInt32:chunkSize];
    [data appendBigInt32:WAV_RIFF_TYPE]; // WAVE
    
    // Format chunk
    [data appendBigInt32:WAV_FORMAT_CHUNK_ID]; // fmt
    [data appendLittleInt32:subChunk1Size];
    [data appendLittleInt16:kWAVEFormat_UncompressedPCM];
    [data appendLittleInt16:_inputData.inputParameters.channels];
    [data appendLittleInt32:_inputData.inputParameters.outputRate];
    [data appendLittleInt32:bytesPerSecond];
    [data appendLittleInt16:frameSize];
    [data appendLittleInt16:TRMBitsPerSample];
    [data appendLittleInt16:0];
    
    // Data chunk
    [data appendBigInt32:WAV_DATA_CHUNK_ID];
    [data appendLittleInt32:subChunk2Size];
    
    [data appendData:sampleData];
    
    return [data copy];
}

- (void)printInputData;
{
    [self.inputData printInputParameters];
    
    // Print out derived values
    printf("\nactual tube length:\t%.4f cm\n", _actualTubeLength);
    printf("internal sample rate:\t%-d Hz\n", _sampleRate);
    printf("control period:\t\t%-d samples (%.4f seconds)\n\n", _controlPeriod, (float)_controlPeriod/(float)_sampleRate);

    [self.inputData printControlRateInputTable];
}

#pragma mark -

// Calculates the current table values, and their associated sample-to-sample delta values.

- (void)setControlRateParameters:(TRMParameters *)currentInput previous:(TRMParameters *)previousInput;
{
    // Glottal pitch
    _currentParameters.glottalPitch             = previousInput.glottalPitch;
    _currentDelta.glottalPitch                  = (currentInput.glottalPitch - _currentParameters.glottalPitch) / (double)_controlPeriod;
    
    // Glottal volume
    _currentParameters.glottalVolume            = previousInput.glottalVolume;
    _currentDelta.glottalVolume                 = (currentInput.glottalVolume - _currentParameters.glottalVolume) / (double)_controlPeriod;

#if MATCH_DSP
    // Aspiration volume
    m_currentParameters.aspirationVolume         = previousInput.aspirationVolume;
    m_currentDelta.aspirationVolume              = 0.0;
    
    // Frication volume
    m_currentParameters.fricationVolume          = previousInput.fricationVolume;
    m_currentDelta.fricationVolume               = 0.0;
    
    // Frication position
    m_currentParameters.fricationPosition        = previousInput.fricationPosition;
    m_currentDelta.fricationPosition             = 0.0;
    
    // Frication center frequency
    m_currentParameters.fricationCenterFrequency = previousInput.fricationCenterFrequency;
    m_currentDelta.fricationCenterFrequency      = 0.0;
    
    // Frication bandwidth
    m_currentParameters.fricationBandwidth       = previousInput.fricationBandwidth;
    m_currentDelta.fricationBandwidth            = 0.0;
#else
    // Aspiration volume
    _currentParameters.aspirationVolume         = previousInput.aspirationVolume;
    _currentDelta.aspirationVolume              = (currentInput.aspirationVolume - _currentParameters.aspirationVolume) / (double)_controlPeriod;
    
    // Frication volume
    _currentParameters.fricationVolume          = previousInput.fricationVolume;
    _currentDelta.fricationVolume               = (currentInput.fricationVolume - _currentParameters.fricationVolume) / (double)_controlPeriod;
    
    // Frication position
    _currentParameters.fricationPosition        = previousInput.fricationPosition;
    _currentDelta.fricationPosition             = (currentInput.fricationPosition - _currentParameters.fricationPosition) / (double)_controlPeriod;
    
    // Frication center frequency
    _currentParameters.fricationCenterFrequency = previousInput.fricationCenterFrequency;
    _currentDelta.fricationCenterFrequency      = (currentInput.fricationCenterFrequency - _currentParameters.fricationCenterFrequency) / (double)_controlPeriod;
    
    // Frication bandwidth
    _currentParameters.fricationBandwidth       = previousInput.fricationBandwidth;
    _currentDelta.fricationBandwidth            = (currentInput.fricationBandwidth - _currentParameters.fricationBandwidth) / (double)_controlPeriod;
#endif
    
    // Tube region radii
    for (NSUInteger index = 0; index < TOTAL_REGIONS; index++) {
        _currentParameters.radius[index]        = previousInput.radius[index];
        _currentDelta.radius[index]             = (currentInput.radius[index] - _currentParameters.radius[index]) / (double)_controlPeriod;
    }
    
    // Velum radius
    _currentParameters.velum                    = previousInput.velum;
    _currentDelta.velum                         = (currentInput.velum - _currentParameters.velum) / (double)_controlPeriod;
}

// Interpolates table values at the sample rate.

- (void)sampleRateInterpolation;
{
    _currentParameters.glottalPitch             += _currentDelta.glottalPitch;
    _currentParameters.glottalVolume            += _currentDelta.glottalVolume;
    _currentParameters.aspirationVolume         += _currentDelta.aspirationVolume;
    _currentParameters.fricationVolume          += _currentDelta.fricationVolume;
    _currentParameters.fricationPosition        += _currentDelta.fricationPosition;
    _currentParameters.fricationCenterFrequency += _currentDelta.fricationCenterFrequency;
    _currentParameters.fricationBandwidth       += _currentDelta.fricationBandwidth;
    for (NSUInteger index = 0; index < TOTAL_REGIONS; index++)
        _currentParameters.radius[index]        += _currentDelta.radius[index];
    _currentParameters.velum                    += _currentDelta.velum;
}

// Calculates the scattering coefficients for the fixed sections of the nasal cavity.

- (void)initializeNasalCavity;
{
    // Calculate coefficients for internal fixed sections of nasal cavity
    for (NSUInteger index = TRM_N2, j = NC2; index < TRM_N6; index++, j++) {
        double radA2 = self.inputParameters.noseRadius[index]   * self.inputParameters.noseRadius[index];
        double radB2 = self.inputParameters.noseRadius[index+1] * self.inputParameters.noseRadius[index+1];
        _nasal_coeff[j] = (radA2 - radB2) / (radA2 + radB2);
    }

    {
        // Calculate the fixed coefficient for the nose aperture
        double radA2 = self.inputParameters.noseRadius[TRM_N6] * self.inputParameters.noseRadius[TRM_N6];
        double radB2 = self.inputParameters.apScale            * self.inputParameters.apScale;
        _nasal_coeff[NC6] = (radA2 - radB2) / (radA2 + radB2);
    }
}

// Calculates the scattering coefficients for the vocal tract according to the current radii.  Also calculates
// the coefficients for the reflection/radiation filter pair for the mouth and nose.

- (void)calculateTubeCoefficients;
{
    // Calcualte coefficients for the oropharynx
    for (NSUInteger index = 0; index < (TOTAL_REGIONS-1); index++) {
        double radA2 = _currentParameters.radius[index]   * _currentParameters.radius[index];
        double radB2 = _currentParameters.radius[index+1] * _currentParameters.radius[index+1];
        _oropharynx_coeff[index] = (radA2 - radB2) / (radA2 + radB2);
    }

    {
        // Calculate the coefficient for the mouth aperture
        double radA2 = _currentParameters.radius[TRM_R8] * _currentParameters.radius[TRM_R8];
        double radB2 = self.inputParameters.apScale        * self.inputParameters.apScale;
        _oropharynx_coeff[C8] = (radA2 - radB2) / (radA2 + radB2);
    }
    
    // Calculate alpha coefficients for 3-way junction
    // Note: Since junction is in middle of region 4, r0_2 = r1_2
    double r0_2 = _currentParameters.radius[TRM_R4] * _currentParameters.radius[TRM_R4];
    double r1_2 = r0_2;
    double r2_2 = _currentParameters.velum * _currentParameters.velum;
    double sum = 2.0 / (r0_2 + r1_2 + r2_2);
    _alpha[LEFT]  = sum * r0_2;
    _alpha[RIGHT] = sum * r1_2;
    _alpha[UPPER] = sum * r2_2;

    {
        // And first nasal passage coefficient
        double radA2 = _currentParameters.velum              * _currentParameters.velum;
        double radB2 = self.inputParameters.noseRadius[TRM_N2] * self.inputParameters.noseRadius[TRM_N2];
        _nasal_coeff[NC1] = (radA2 - radB2) / (radA2 + radB2);
    }
}

// Sets the frication taps according to the current position and amplitude of frication.

- (void)setFricationTaps;
{
    double fricationAmplitude = amplitude(_currentParameters.fricationVolume);
    
    // Calculate position remainder and complement
    int32_t integerPart = (int32_t)_currentParameters.fricationPosition;
    double complement   = _currentParameters.fricationPosition - (double)integerPart;
    double remainder    = 1.0 - complement;
    
    // Set the frication taps
    for (NSUInteger index = FC1; index < TOTAL_FRIC_COEFFICIENTS; index++) {
        if (index == integerPart) {
            _fricationTap[index] = remainder * fricationAmplitude;
            if ((index+1) < TOTAL_FRIC_COEFFICIENTS)
                _fricationTap[++index] = complement * fricationAmplitude;
        } else
            _fricationTap[index] = 0.0;
    }
    
#if 0
    printf("fricationTaps:  ");
    for (NSUInteger index = FC1; index < TOTAL_FRIC_COEFFICIENTS; index++)
        printf("%.6f  ", m_fricationTap[index]);
    printf("\n");
#endif
}

// Updates the pressure wave throughout the vocal tract, and returns the summed output of the oral and nasal
// cavities.  Also injects frication appropriately.

- (double)updateVocalTractWithGlottalPulse:(double)input frication:(double)frication;
{
    // Increment current and previous pointers
    _currentIndex  = (_currentIndex + 1)  % 2;
    _previousIndex = (_previousIndex + 1) % 2;
    
    // copies to shorten code.  (Except they don't now.)
    NSUInteger currentIndex  = _currentIndex;
    NSUInteger previousIndex = _previousIndex;
    double dampingFactor     = _dampingFactor;
    
    // Update oropharynx
    // Input to top of tube
    
    _oropharynx[S1][TOP][currentIndex] = (_oropharynx[S1][BOTTOM][previousIndex] * dampingFactor) + input;
    
    // Calculate the scattering junctions for S1-S2
    
    double delta = _oropharynx_coeff[C1] * (_oropharynx[S1][TOP][previousIndex] - _oropharynx[S2][BOTTOM][previousIndex]);
    _oropharynx[S2][TOP][currentIndex]    = (_oropharynx[S1][TOP][previousIndex]    + delta) * dampingFactor;
    _oropharynx[S1][BOTTOM][currentIndex] = (_oropharynx[S2][BOTTOM][previousIndex] + delta) * dampingFactor;
    
    // Calculate the scattering junctions for S2-S3 and S3-S4
    if (_verbose)
        printf("\nCalc scattering\n");
    for (NSUInteger i = S2, j = C2, k = FC1; i < S4; i++, j++, k++) {
        delta = _oropharynx_coeff[j] * (_oropharynx[i][TOP][previousIndex] - _oropharynx[i+1][BOTTOM][previousIndex]);
        _oropharynx[i+1][TOP][currentIndex]  = ((_oropharynx[i][TOP][previousIndex]      + delta) * dampingFactor) + (_fricationTap[k] * frication);
        _oropharynx[i][BOTTOM][currentIndex] = ((_oropharynx[i+1][BOTTOM][previousIndex] + delta) * dampingFactor);
    }
    
    // Update 3-way junction between the middle of R4 and nasal cavity
    double junctionPressure = (_alpha[LEFT] * _oropharynx[S4][TOP][previousIndex]) + (_alpha[RIGHT] * _oropharynx[S5][BOTTOM][previousIndex]) + (_alpha[UPPER] * _nasal[TRM_VELUM][BOTTOM][previousIndex]);
    _oropharynx[S4][BOTTOM][currentIndex] = ((junctionPressure - _oropharynx[S4][TOP][previousIndex])      * dampingFactor);
    _oropharynx[S5][TOP][currentIndex]    = ((junctionPressure - _oropharynx[S5][BOTTOM][previousIndex])   * dampingFactor) + (_fricationTap[FC3] * frication);
    _nasal[TRM_VELUM][TOP][currentIndex]  = ((junctionPressure - _nasal[TRM_VELUM][BOTTOM][previousIndex]) * dampingFactor);
    
    // Calculate junction between R4 and R5 (S5-S6)
    delta = _oropharynx_coeff[C4] * (_oropharynx[S5][TOP][previousIndex] - _oropharynx[S6][BOTTOM][previousIndex]);
    _oropharynx[S6][TOP][currentIndex]    = ((_oropharynx[S5][TOP][previousIndex]    + delta) * dampingFactor) + (_fricationTap[FC4] * frication);
    _oropharynx[S5][BOTTOM][currentIndex] = ((_oropharynx[S6][BOTTOM][previousIndex] + delta) * dampingFactor);
    
    // Calculate junction inside R5 (S6-S7) (pure delay with damping)
    _oropharynx[S7][TOP][currentIndex]    = (_oropharynx[S6][TOP][previousIndex]    * dampingFactor) + (_fricationTap[FC5] * frication);
    _oropharynx[S6][BOTTOM][currentIndex] = (_oropharynx[S7][BOTTOM][previousIndex] * dampingFactor);
    
    // Calculate last 3 internal junctions (S7-S8, S8-S9, S9-S10)
    for (NSUInteger i = S7, j = C5, k = FC6; i < S10; i++, j++, k++) {
        delta = _oropharynx_coeff[j] * (_oropharynx[i][TOP][previousIndex] - _oropharynx[i+1][BOTTOM][previousIndex]);
        _oropharynx[i+1][TOP][currentIndex]  = ((_oropharynx[i][TOP][previousIndex]      + delta) * dampingFactor) + (_fricationTap[k] * frication);
        _oropharynx[i][BOTTOM][currentIndex] = ((_oropharynx[i+1][BOTTOM][previousIndex] + delta) * dampingFactor);
    }
    
    // Reflected signal at mouth goes through a lowpass filter
    _oropharynx[S10][BOTTOM][currentIndex] =  dampingFactor * TRMRadiationReflectionFilter_ReflectionFilterInput(&_mouthFilterPair, _oropharynx_coeff[C8] * _oropharynx[S10][TOP][previousIndex]);
    
    // Output from mouth goes through a highpass filter
    double output = TRMRadiationReflectionFilter_RadiationFilterInput(&_mouthFilterPair, (1.0 + _oropharynx_coeff[C8]) * _oropharynx[S10][TOP][previousIndex]);
    
    
    // Update nasal cavity
    for (NSUInteger i = TRM_VELUM, j = NC1; i < TRM_N6; i++, j++) {
        delta = _nasal_coeff[j] * (_nasal[i][TOP][previousIndex] - _nasal[i+1][BOTTOM][previousIndex]);
        _nasal[i+1][TOP][currentIndex]  = (_nasal[i][TOP][previousIndex]      + delta) * dampingFactor;
        _nasal[i][BOTTOM][currentIndex] = (_nasal[i+1][BOTTOM][previousIndex] + delta) * dampingFactor;
    }
    
    // Reflected signal at nose goes through a lowpass filter
    _nasal[TRM_N6][BOTTOM][currentIndex] = dampingFactor * TRMRadiationReflectionFilter_ReflectionFilterInput(&_nasalFilterPair, _nasal_coeff[NC6] * _nasal[TRM_N6][TOP][previousIndex]);
    
    // Output from nose goes through a highpass filter
    output += TRMRadiationReflectionFilter_RadiationFilterInput(&_nasalFilterPair, (1.0 + _nasal_coeff[NC6]) * _nasal[TRM_N6][TOP][previousIndex]);
    
    // Return summed output from mouth and nose
    return output;
}

@end

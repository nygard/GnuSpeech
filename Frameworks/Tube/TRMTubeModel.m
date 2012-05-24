//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "TRMTubeModel.h"

#import <AudioToolbox/AudioToolbox.h>
#import "TRMParameters.h"
#import "TRMDataList.h"
#import "TRMInputParameters.h"
#import "util.h"
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

NSString *TRMSoundFileFormatDescription(TRMSoundFileFormat format)
{
    switch (format) {
        case TRMSoundFileFormat_AU:   return @"AU";
        case TRMSoundFileFormat_AIFF: return @"AIFF";
        case TRMSoundFileFormat_WAVE: return @"WAVE";
    }

    return @"Unknown";
}

NSString *TRMSoundFileFormatExtension(TRMSoundFileFormat format)
{
    switch (format) {
        case TRMSoundFileFormat_AU:   return @"au";
        case TRMSoundFileFormat_AIFF: return @"aiff";
        case TRMSoundFileFormat_WAVE: return @"wav";
    }
    
    return @"Unknown";
}

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

- (void)setControlRateParameters:(TRMParameters *)current previous:(TRMParameters *)previous;
- (void)sampleRateInterpolation;
- (void)initializeNasalCavity;
- (void)calculateTubeCoefficients;
- (void)setFricationTaps;
- (double)updateVocalTractWithGlottalPulse:(double)input frication:(double)frication;

@end

#pragma mark -

@implementation TRMTubeModel
{
    // Derived values
    int32_t controlPeriod;
    int32_t sampleRate;
    double actualTubeLength;            // actual length in cm
    
    double m_dampingFactor;             // calculated damping factor
    double crossmixFactor;              // calculated crossmix factor
    
    double breathinessFactor;

    TRMLowPassFilter2 noiseFilter;             // One-zero lowpass filter.
    
    // Mouth reflection filter: Is a variable, one-pole lowpass filter,            whose cutoff       is determined by the mouth aperture coefficient.
    // Mouth radiation filter:  Is a variable, one-zero, one-pole highpass filter, whose cutoff point is determined by the mouth aperture coefficient.
    TRMRadiationReflectionFilter mouthFilterPair;

    // Nasal reflection filter: Is a one-pole lowpass filter,            used for terminating the end of            the nasal cavity.
    // Nasal radiation filter:  Is a one-zero, one-pole highpass filter, used for the radiation characteristic from the nasal cavity.
    TRMRadiationReflectionFilter nasalFilterPair;

    TRMLowPassFilter throatLowPassFilter;      // Simulates the radiation of sound through the walls of the throat.
    double m_throatGain;
    
    TRMBandPassFilter fricationBandPassFilter; // Frication bandpass filter, with variable center frequency and bandwidth.
    
    // Memory for tue and tube coefficients
    double oropharynx[TOTAL_SECTIONS][2][2];
    double oropharynx_coeff[TOTAL_COEFFICIENTS];
    
    double nasal[TOTAL_NASAL_SECTIONS][2][2];
    double nasal_coeff[TOTAL_NASAL_COEFFICIENTS];
    
    double alpha[TOTAL_ALPHA_COEFFICIENTS];
    NSUInteger m_currentIndex;
    NSUInteger m_previousIndex;
    
    // Memory for frication taps
    double fricationTap[TOTAL_FRIC_COEFFICIENTS];
    
    // Variables for interpolation
    TRMParameters *m_currentParameters;
    TRMParameters *m_currentDelta;

    TRMSampleRateConverter *m_sampleRateConverter;
    TRMWavetable *wavetable;

    TRMDataList *m_inputData;

    BOOL verbose;
}

- (id)initWithInputData:(TRMDataList *)inputData;
{
    if ((self = [super init])) {
        m_inputData = [inputData retain];

        double nyquist;
        
        m_currentParameters = [[TRMParameters alloc] init];
        m_currentDelta = [[TRMParameters alloc] init];
        
        // Calculate the sample rate, based on nominal tube length and speed of sound
        if (m_inputData.inputParameters.length > 0.0) {
            double c = speedOfSound(m_inputData.inputParameters.temperature);
            
            controlPeriod = rint((c * TOTAL_SECTIONS * 100.0) / (m_inputData.inputParameters.length * m_inputData.inputParameters.controlRate));
            sampleRate = m_inputData.inputParameters.controlRate * controlPeriod;
            actualTubeLength = (c * TOTAL_SECTIONS * 100.0) / sampleRate;
            nyquist = (double)sampleRate / 2.0;
        } else {
            fprintf(stderr, "Illegal tube length: %g\n", m_inputData.inputParameters.length);
            [self release];
            return nil;
        }
        
        // Calculate the breathiness factor
        breathinessFactor = m_inputData.inputParameters.breathiness / 100.0;
        
        // Calculate crossmix factor
        crossmixFactor = 1.0 / amplitude(m_inputData.inputParameters.mixOffset);
        
        // Calculate the damping factor
        m_dampingFactor = (1.0 - (m_inputData.inputParameters.lossFactor / 100.0));
        
        // Initialize the wave table
        wavetable = [[TRMWavetable alloc] initWithWaveform:m_inputData.inputParameters.waveform throttlePulse:m_inputData.inputParameters.tp tnMin:m_inputData.inputParameters.tnMin tnMax:m_inputData.inputParameters.tnMax sampleRate:sampleRate];
        
        // Initialize reflection and radiation filter coefficients for mouth
        TRMRadiationReflectionFilter_InitWithCoefficient(&mouthFilterPair, (nyquist - m_inputData.inputParameters.mouthCoef) / nyquist);

        // Initialize reflection and radiation filter coefficients for nose
        TRMRadiationReflectionFilter_InitWithCoefficient(&nasalFilterPair, (nyquist - m_inputData.inputParameters.noseCoef) / nyquist);

        // Initialize nasal cavity fixed scattering coefficients
        [self initializeNasalCavity];
        
        // TODO (2004-05-07): nasal?

        // Initialize the noise filter
        noiseFilter.x = 0;

        // Initialize the throat lowpass filter
        TRMLowPassFilter_CalculateCoefficients(&throatLowPassFilter, sampleRate, self.inputParameters.throatCutoff);
        m_throatGain = amplitude(self.inputParameters.throatVol);

        m_sampleRateConverter = [[TRMSampleRateConverter alloc] initWithInputRate:sampleRate outputRate:m_inputData.inputParameters.outputRate];

        // TODO (2004-05-07): oropharynx
        // TODO (2004-05-07): alpha
        
        m_currentIndex  = 1;
        m_previousIndex = 0;
        
        // TODO (2004-05-07): fricationTap


        // Initialize parts of this filter.  The coefficients are set elsewhere.
        fricationBandPassFilter.xn1 = 0;
        fricationBandPassFilter.xn2 = 0;
        fricationBandPassFilter.yn1 = 0;
        fricationBandPassFilter.yn2 = 0;
    }

    return self;
}

- (void)dealloc;
{
    [m_inputData release];

    [wavetable release];

    [m_currentParameters release];
    [m_currentDelta release];

    [m_sampleRateConverter release];

    [super dealloc];
}

#pragma mark -

@synthesize inputData = m_inputData;

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
        for (NSUInteger j = 0; j < controlPeriod; j++) {
            // Convert parameters here
            double f0  = frequency(m_currentParameters.glotPitch);
            double ax  = amplitude(m_currentParameters.glotVol);
            double ah1 = amplitude(m_currentParameters.aspVol);

            [self calculateTubeCoefficients];
            [self setFricationTaps];
            TRMBandPassFilter_CalculateCoefficients(&fricationBandPassFilter, sampleRate, m_currentParameters.fricCF, m_currentParameters.fricBW);
            
            
            // Do synthesis here
            // Create low-pass filtered noise
            double lp_noise = TRMLowPassFilter2_FilterInput(&noiseFilter, noise());
            
            // Update the shape of the glottal pulse, if necessary
            if (self.inputData.inputParameters.waveform == TRMWaveFormType_Pulse)
                [wavetable update:ax];
            
            // Create glottal pulse (or sine tone)
            double pulse = [wavetable oscillator:f0];
            
            // Create pulsed noise
            double pulsed_noise = lp_noise * pulse;
            
            // Create noisy glottal pulse
            pulse = ax * ((pulse * (1.0 - breathinessFactor)) + (pulsed_noise * breathinessFactor));
            
            double signal;
            
            // Cross-mix pure noise with pulsed noise
            if (self.inputData.inputParameters.modulation) {
                double crossmix = ax * crossmixFactor;
                crossmix = (crossmix < 1.0) ? crossmix : 1.0;
                signal = (pulsed_noise * crossmix) + (lp_noise * (1.0 - crossmix));
                if (verbose) {
                    printf("\nSignal = %e", signal);
                    fflush(stdout);
                }
            } else {
                signal = lp_noise;
            }
            
            // Put signal through vocal tract
            signal = [self updateVocalTractWithGlottalPulse:((pulse + (ah1 * signal)) * VT_SCALE)
                                                  frication:TRMBandPassFilter_FilterInput(&fricationBandPassFilter, signal)];
            
            
            // Put pulse through throat
            signal += TRMLowPassFilter_FilterInput(&throatLowPassFilter, pulse * VT_SCALE) * m_throatGain;
            if (verbose)
                printf("\nDone throat\n");
            
            // Output sample
            [self.sampleRateConverter dataFill:signal];
            if (verbose)
                printf("\nDone datafil\n");
            
            // Do sample rate interpolation of control parameters
            [self sampleRateInterpolation];
            if (verbose)
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
        
		if (verbose) {
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
    asbd.mChannelsPerFrame = self.inputParameters.channels;
    asbd.mFramesPerPacket  = 1; // Always 1 for uncompressed formats
    asbd.mBytesPerFrame    = 2*self.inputParameters.channels;
    asbd.mBytesPerPacket   = 2*self.inputParameters.channels;

    if (self.inputParameters.outputFileFormat == TRMSoundFileFormat_AU || self.inputParameters.outputFileFormat == TRMSoundFileFormat_AIFF) {
        asbd.mFormatFlags |= kAudioFormatFlagIsBigEndian;
    }
    
    AudioFileID audioFile;
    OSStatus audioError = AudioFileCreateWithURL((CFURLRef)(fileURL), TRMCoreAudioFormatFromSoundFileFormat(self.inputParameters.outputFileFormat), &asbd, kAudioFileFlags_EraseFile, &audioFile);
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
    
    NSMutableData *sampleData = [[[NSMutableData alloc] init] autorelease];
    
    double scale = (TRMSampleValue_Maximum / self.sampleRateConverter.maximumSampleValue) * amplitude(m_inputData.inputParameters.volume);
    
    NSLog(@"number of samples:\t%-d\n", self.sampleRateConverter.numberSamples);
    NSLog(@"maximum sample value:\t%.4f\n", self.sampleRateConverter.maximumSampleValue);
    NSLog(@"scale:\t\t\t%.4f\n", scale);
    
    NSData *resampledData = [self.sampleRateConverter resampledData];
    NSInputStream *inputStream = [NSInputStream inputStreamWithData:resampledData];
    [inputStream open];
    
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
    
    int frameSize = (int)ceil(m_inputData.inputParameters.channels * ((double)TRMBitsPerSample / 8));
    int bytesPerSecond = (int)ceil(m_inputData.inputParameters.outputRate * frameSize);
    
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

- (void)printInputData;
{
    [self.inputData printInputParameters];
    
    // Print out derived values
    printf("\nactual tube length:\t%.4f cm\n", actualTubeLength);
    printf("internal sample rate:\t%-d Hz\n", sampleRate);
    printf("control period:\t\t%-d samples (%.4f seconds)\n\n", controlPeriod, (float)controlPeriod/(float)sampleRate);

    [self.inputData printControlRateInputTable];
}

#pragma mark -

@synthesize sampleRateConverter = m_sampleRateConverter;


// Calculates the current table values, and their associated sample-to-sample delta values.

- (void)setControlRateParameters:(TRMParameters *)currentInput previous:(TRMParameters *)previousInput;
{
    // Glottal pitch
    m_currentParameters.glotPitch = previousInput.glotPitch;
    m_currentDelta.glotPitch      = (currentInput.glotPitch - m_currentParameters.glotPitch) / (double)controlPeriod;
    
    // Glottal volume
    m_currentParameters.glotVol   = previousInput.glotVol;
    m_currentDelta.glotVol        = (currentInput.glotVol - m_currentParameters.glotVol) / (double)controlPeriod;

#if MATCH_DSP
    // Aspiration volume
    m_currentParameters.aspVol    = previousInput.aspVol;
    m_currentDelta.aspVol         = 0.0;
    
    // Frication volume
    m_currentParameters.fricVol   = previousInput.fricVol;
    m_currentDelta.fricVol        = 0.0;
    
    // Frication position
    m_currentParameters.fricPos   = previousInput.fricPos;
    m_currentDelta.fricPos        = 0.0;
    
    // Frication center frequency
    m_currentParameters.fricCF    = previousInput.fricCF;
    m_currentDelta.fricCF         = 0.0;
    
    // Frication bandwidth
    m_currentParameters.fricBW    = previousInput.fricBW;
    m_currentDelta.fricBW         = 0.0;
#else
    // Aspiration volume
    m_currentParameters.aspVol    = previousInput.aspVol;
    m_currentDelta.aspVol         = (currentInput.aspVol - m_currentParameters.aspVol) / (double)controlPeriod;
    
    // Frication volume
    m_currentParameters.fricVol   = previousInput.fricVol;
    m_currentDelta.fricVol        = (currentInput.fricVol - m_currentParameters.fricVol) / (double)controlPeriod;
    
    // Frication position
    m_currentParameters.fricPos   = previousInput.fricPos;
    m_currentDelta.fricPos        = (currentInput.fricPos - m_currentParameters.fricPos) / (double)controlPeriod;
    
    // Frication center frequency
    m_currentParameters.fricCF    = previousInput.fricCF;
    m_currentDelta.fricCF         = (currentInput.fricCF - m_currentParameters.fricCF) / (double)controlPeriod;
    
    // Frication bandwidth
    m_currentParameters.fricBW    = previousInput.fricBW;
    m_currentDelta.fricBW         = (currentInput.fricBW - m_currentParameters.fricBW) / (double)controlPeriod;
#endif
    
    // Tube region radii
    for (NSUInteger index = 0; index < TOTAL_REGIONS; index++) {
        m_currentParameters.radius[index] = previousInput.radius[index];
        m_currentDelta.radius[index]      = (currentInput.radius[index] - m_currentParameters.radius[index]) / (double)controlPeriod;
    }
    
    // Velum radius
    m_currentParameters.velum     = previousInput.velum;
    m_currentDelta.velum          = (currentInput.velum - m_currentParameters.velum) / (double)controlPeriod;
}

// Interpolates table values at the sample rate.

- (void)sampleRateInterpolation;
{
    m_currentParameters.glotPitch += m_currentDelta.glotPitch;
    m_currentParameters.glotVol   += m_currentDelta.glotVol;
    m_currentParameters.aspVol    += m_currentDelta.aspVol;
    m_currentParameters.fricVol   += m_currentDelta.fricVol;
    m_currentParameters.fricPos   += m_currentDelta.fricPos;
    m_currentParameters.fricCF    += m_currentDelta.fricCF;
    m_currentParameters.fricBW    += m_currentDelta.fricBW;
    for (NSUInteger index = 0; index < TOTAL_REGIONS; index++)
        m_currentParameters.radius[index] += m_currentDelta.radius[index];
    m_currentParameters.velum     += m_currentDelta.velum;
}

// Calculates the scattering coefficients for the fixed sections of the nasal cavity.

- (void)initializeNasalCavity;
{
    // Calculate coefficients for internal fixed sections of nasal cavity
    for (NSUInteger index = TRM_N2, j = NC2; index < TRM_N6; index++, j++) {
        double radA2 = self.inputParameters.noseRadius[index]   * self.inputParameters.noseRadius[index];
        double radB2 = self.inputParameters.noseRadius[index+1] * self.inputParameters.noseRadius[index+1];
        nasal_coeff[j] = (radA2 - radB2) / (radA2 + radB2);
    }

    {
        // Calculate the fixed coefficient for the nose aperture
        double radA2 = self.inputParameters.noseRadius[TRM_N6] * self.inputParameters.noseRadius[TRM_N6];
        double radB2 = self.inputParameters.apScale            * self.inputParameters.apScale;
        nasal_coeff[NC6] = (radA2 - radB2) / (radA2 + radB2);
    }
}

// Calculates the scattering coefficients for the vocal tract according to the current radii.  Also calculates
// the coefficients for the reflection/radiation filter pair for the mouth and nose.

- (void)calculateTubeCoefficients;
{
    // Calcualte coefficients for the oropharynx
    for (NSUInteger index = 0; index < (TOTAL_REGIONS-1); index++) {
        double radA2 = m_currentParameters.radius[index]   * m_currentParameters.radius[index];
        double radB2 = m_currentParameters.radius[index+1] * m_currentParameters.radius[index+1];
        oropharynx_coeff[index] = (radA2 - radB2) / (radA2 + radB2);
    }

    {
        // Calculate the coefficient for the mouth aperture
        double radA2 = m_currentParameters.radius[TRM_R8] * m_currentParameters.radius[TRM_R8];
        double radB2 = self.inputParameters.apScale        * self.inputParameters.apScale;
        oropharynx_coeff[C8] = (radA2 - radB2) / (radA2 + radB2);
    }
    
    // Calculate alpha coefficients for 3-way junction
    // Note: Since junction is in middle of region 4, r0_2 = r1_2
    double r0_2 = m_currentParameters.radius[TRM_R4] * m_currentParameters.radius[TRM_R4];
    double r1_2 = r0_2;
    double r2_2 = m_currentParameters.velum * m_currentParameters.velum;
    double sum = 2.0 / (r0_2 + r1_2 + r2_2);
    alpha[LEFT]  = sum * r0_2;
    alpha[RIGHT] = sum * r1_2;
    alpha[UPPER] = sum * r2_2;

    {
        // And first nasal passage coefficient
        double radA2 = m_currentParameters.velum              * m_currentParameters.velum;
        double radB2 = self.inputParameters.noseRadius[TRM_N2] * self.inputParameters.noseRadius[TRM_N2];
        nasal_coeff[NC1] = (radA2 - radB2) / (radA2 + radB2);
    }
}

// Sets the frication taps according to the current position and amplitude of frication.

- (void)setFricationTaps;
{
    double fricationAmplitude = amplitude(m_currentParameters.fricVol);
    
    // Calculate position remainder and complement
    int32_t integerPart = (int32_t)m_currentParameters.fricPos;
    double complement   = m_currentParameters.fricPos - (double)integerPart;
    double remainder    = 1.0 - complement;
    
    // Set the frication taps
    for (NSUInteger index = FC1; index < TOTAL_FRIC_COEFFICIENTS; index++) {
        if (index == integerPart) {
            fricationTap[index] = remainder * fricationAmplitude;
            if ((index+1) < TOTAL_FRIC_COEFFICIENTS)
                fricationTap[++index] = complement * fricationAmplitude;
        } else
            fricationTap[index] = 0.0;
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
    m_currentIndex  = (m_currentIndex + 1)  % 2;
    m_previousIndex = (m_previousIndex + 1) % 2;
    
    // copies to shorten code.  (Except they don't now.)
    NSUInteger currentIndex  = m_currentIndex;
    NSUInteger previousIndex = m_previousIndex;
    double dampingFactor     = m_dampingFactor;
    
    // Update oropharynx
    // Input to top of tube
    
    oropharynx[S1][TOP][currentIndex] = (oropharynx[S1][BOTTOM][previousIndex] * dampingFactor) + input;
    
    // Calculate the scattering junctions for S1-S2
    
    double delta = oropharynx_coeff[C1] * (oropharynx[S1][TOP][previousIndex] - oropharynx[S2][BOTTOM][previousIndex]);
    oropharynx[S2][TOP][currentIndex]    = (oropharynx[S1][TOP][previousIndex]    + delta) * dampingFactor;
    oropharynx[S1][BOTTOM][currentIndex] = (oropharynx[S2][BOTTOM][previousIndex] + delta) * dampingFactor;
    
    // Calculate the scattering junctions for S2-S3 and S3-S4
    if (verbose)
        printf("\nCalc scattering\n");
    for (NSUInteger i = S2, j = C2, k = FC1; i < S4; i++, j++, k++) {
        delta = oropharynx_coeff[j] * (oropharynx[i][TOP][previousIndex] - oropharynx[i+1][BOTTOM][previousIndex]);
        oropharynx[i+1][TOP][currentIndex]  = ((oropharynx[i][TOP][previousIndex]      + delta) * dampingFactor) + (fricationTap[k] * frication);
        oropharynx[i][BOTTOM][currentIndex] = ((oropharynx[i+1][BOTTOM][previousIndex] + delta) * dampingFactor);
    }
    
    // Update 3-way junction between the middle of R4 and nasal cavity
    double junctionPressure = (alpha[LEFT] * oropharynx[S4][TOP][previousIndex]) + (alpha[RIGHT] * oropharynx[S5][BOTTOM][previousIndex]) + (alpha[UPPER] * nasal[TRM_VELUM][BOTTOM][previousIndex]);
    oropharynx[S4][BOTTOM][currentIndex] = ((junctionPressure - oropharynx[S4][TOP][previousIndex])      * dampingFactor);
    oropharynx[S5][TOP][currentIndex]    = ((junctionPressure - oropharynx[S5][BOTTOM][previousIndex])   * dampingFactor) + (fricationTap[FC3] * frication);
    nasal[TRM_VELUM][TOP][currentIndex]  = ((junctionPressure - nasal[TRM_VELUM][BOTTOM][previousIndex]) * dampingFactor);
    
    // Calculate junction between R4 and R5 (S5-S6)
    delta = oropharynx_coeff[C4] * (oropharynx[S5][TOP][previousIndex] - oropharynx[S6][BOTTOM][previousIndex]);
    oropharynx[S6][TOP][currentIndex]    = ((oropharynx[S5][TOP][previousIndex]    + delta) * dampingFactor) + (fricationTap[FC4] * frication);
    oropharynx[S5][BOTTOM][currentIndex] = ((oropharynx[S6][BOTTOM][previousIndex] + delta) * dampingFactor);
    
    // Calculate junction inside R5 (S6-S7) (pure delay with damping)
    oropharynx[S7][TOP][currentIndex]    = (oropharynx[S6][TOP][previousIndex]    * dampingFactor) + (fricationTap[FC5] * frication);
    oropharynx[S6][BOTTOM][currentIndex] = (oropharynx[S7][BOTTOM][previousIndex] * dampingFactor);
    
    // Calculate last 3 internal junctions (S7-S8, S8-S9, S9-S10)
    for (NSUInteger i = S7, j = C5, k = FC6; i < S10; i++, j++, k++) {
        delta = oropharynx_coeff[j] * (oropharynx[i][TOP][previousIndex] - oropharynx[i+1][BOTTOM][previousIndex]);
        oropharynx[i+1][TOP][currentIndex]  = ((oropharynx[i][TOP][previousIndex]      + delta) * dampingFactor) + (fricationTap[k] * frication);
        oropharynx[i][BOTTOM][currentIndex] = ((oropharynx[i+1][BOTTOM][previousIndex] + delta) * dampingFactor);
    }
    
    // Reflected signal at mouth goes through a lowpass filter
    oropharynx[S10][BOTTOM][currentIndex] =  dampingFactor * TRMRadiationReflectionFilter_ReflectionFilterInput(&mouthFilterPair, oropharynx_coeff[C8] * oropharynx[S10][TOP][previousIndex]);
    
    // Output from mouth goes through a highpass filter
    double output = TRMRadiationReflectionFilter_RadiationFilterInput(&mouthFilterPair, (1.0 + oropharynx_coeff[C8]) * oropharynx[S10][TOP][previousIndex]);
    
    
    // Update nasal cavity
    for (NSUInteger i = TRM_VELUM, j = NC1; i < TRM_N6; i++, j++) {
        delta = nasal_coeff[j] * (nasal[i][TOP][previousIndex] - nasal[i+1][BOTTOM][previousIndex]);
        nasal[i+1][TOP][currentIndex]  = (nasal[i][TOP][previousIndex]      + delta) * dampingFactor;
        nasal[i][BOTTOM][currentIndex] = (nasal[i+1][BOTTOM][previousIndex] + delta) * dampingFactor;
    }
    
    // Reflected signal at nose goes through a lowpass filter
    nasal[TRM_N6][BOTTOM][currentIndex] = dampingFactor * TRMRadiationReflectionFilter_ReflectionFilterInput(&nasalFilterPair, nasal_coeff[NC6] * nasal[TRM_N6][TOP][previousIndex]);
    
    // Output from nose goes through a highpass filter
    output += TRMRadiationReflectionFilter_RadiationFilterInput(&nasalFilterPair, (1.0 + nasal_coeff[NC6]) * nasal[TRM_N6][TOP][previousIndex]);
    
    // Return summed output from mouth and nose
    return output;
}

@end

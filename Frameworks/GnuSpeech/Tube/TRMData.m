//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "TRMData.h"

#import <math.h>


/*  LOCAL DEFINES  ***********************************************************/
#define CURRENT_FILE_VERSION  1

#define WAVEFORMTYPE_DEF      0
#define SHOWAMPLITUDE_DEF     1
#define HARMONICS_DEF         1
#define UNIT_DEF              0
#define PITCH_DEF             0
#define CENTS_MIN             (-50)
#define CENTS_MAX             50
#define CENTS_DEF             0
#define BREATHINESS_DEF       2.5
#define RISETIME_DEF          40.0
#define FALLTIMEMIN_DEF       12.0
#define FALLTIMEMAX_DEF       35.0

#define VOLUME_DEF            60.0

#define FRIC_VOLUME_DEF       0.0
#define ASP_VOLUME_DEF        0.0
#define POSITION_DEF          4.0
#define CENTER_FREQ_DEF       2000
#define BANDWIDTH_DEF         1000
#define RESPONSE_DEF          0
#define PULSE_MOD_DEF         1
#define CROSSMIX_DEF          60.0

#define THROAT_VOLUME_DEF     12.0
#define CUTOFF_DEF            1500.0

#define DIAMETER_MIN          0.0
#define DIAMETER_MAX          6.0
#define VELUM_DIAMETER_MAX    3.0
#define PHARYNX_SECTION1_DEF  1.6
#define PHARYNX_SECTION2_DEF  1.6
#define PHARYNX_SECTION3_DEF  1.6
#define VELUM_SECTION1_DEF    0.0
#define ORAL_SECTION1_DEF     1.6
#define ORAL_SECTION2_DEF     1.6
#define ORAL_SECTION3_DEF     1.6
#define ORAL_SECTION4_DEF     1.6
#define ORAL_SECTION5_DEF     1.6
#define NASAL_SECTION1_DEF    2.7
#define NASAL_SECTION2_DEF    3.4
#define NASAL_SECTION3_DEF    3.4
#define NASAL_SECTION4_DEF    2.6
#define NASAL_SECTION5_DEF    1.8
#define LOSS_FACTOR_DEF       2.0
#define APERTURE_SCALING_MIN  (DIAMETER_MAX + 0.1)
#define APERTURE_SCALING_MAX  (DIAMETER_MAX * 4.0)
#define APERTURE_SCALING_DEF  APERTURE_SCALING_MIN
#define FILTER_DEF            0.75
#define LENGTH_DEF            17.5
#define TEMPERATURE_DEF       32.0
#define CONTROL_PERIOD_DEF    160
#define SAMPLE_RATE_DEF       16000
#define ACTUAL_LENGTH_DEF     17.53

#define BALANCE_DEF           0.0
#define CHANNELS_DEF          2
#define CONTROL_RATE_DEF      500

#define NORMALIZE_INPUT_DEF   1
#define BIN_SIZE_DEF          256
#define WINDOW_TYPE_DEF       4
#define ALPHA_DEF             0.54
#define BETA_DEF              5.0
#define GRAY_LEVEL_DEF        0
#define MAGNITUDE_SCALE_DEF   1
#define UPPER_THRESH_LIN_DEF  0.15
#define LOWER_THRESH_LIN_DEF  0.0
#define UPPER_THRESH_LOG_DEF  (-18)
#define LOWER_THRESH_LOG_DEF  (-66)
#define SPECTROGRAPH_GRID_DEF 0
#define SPECTRUM_GRID_DEF     1

@implementation TRMData
{
    // Glottal source parameters
    int32_t _waveform;
    int32_t _showAmplitude;
    int32_t _harmonicsScale;
    int32_t _unit;
    int32_t _pitch;
    int32_t _cents;
    float _breathiness;
    int32_t _glotVol;
    float _tp;
    float _tnMin;
    float _tnMax;

    // Noise source parameters
    int32_t _fricVol;
    float _fricPos;
    int32_t _fricCF;
    int32_t _fricBW;
    int32_t _NoiseSourceResponseScale;
    int32_t _aspVol;
    int32_t _modulation;
    int32_t _mixOffset;

    // Throat parameters
    int32_t _throatVol;
    int32_t _throatCutoff;
    int32_t _throatResponseScale;

    // Resonant system parameters
    double _pharynxDiameter[PHARYNX_SECTIONS];
    double _velumDiameter[VELUM_SECTIONS];
    double _oralDiameter[ORAL_SECTIONS];
    double _nasalDiameter[NASAL_SECTIONS];
    double _lossFactor;
    double _apScale;
    double _mouthCoef;
    double _noseCoef;
    int32_t _mouthResponseScale;
    int32_t _noseResponseScale;
    double _temperature;
    double _length;
    double _sampleRate;
    double _actualLength;
    int32_t _controlPeriod;

    // Controller parameters
    int32_t _volume;
    double _balance;
    int32_t _channels;
    int32_t _controlRate;

    // analysis parameters
    BOOL _normalizeInput;
    int32_t _binSize;
    int32_t _windowType;
    float _alpha;
    float _beta;
    int32_t _grayLevel;
    int32_t _magnitudeScale;
    float _linearUpperThreshold;
    float _linearLowerThreshold;
    int32_t _logUpperThreshold;
    int32_t _logLowerThreshold;
    BOOL _spectrographGrid;
    BOOL _spectrumGrid;
}

- (id)init;
{
    if ((self = [super init])) {
        // Initialize instance variables to reasonable defaults

        // Glottal source paraemters
        _waveform       = WAVEFORMTYPE_DEF;
        _showAmplitude  = SHOWAMPLITUDE_DEF;
        _harmonicsScale = HARMONICS_DEF;
        _unit           = UNIT_DEF;
        _pitch          = PITCH_DEF;
        _cents          = CENTS_DEF;
        _breathiness    = BREATHINESS_DEF;
        _glotVol        = VOLUME_DEF;
        _tp             = RISETIME_DEF;
        _tnMin          = FALLTIMEMIN_DEF;
        _tnMax          = FALLTIMEMAX_DEF;
        
        // Noise source parameters
        _fricVol                  = FRIC_VOLUME_DEF;
        _fricPos                  = POSITION_DEF;
        _fricCF                   = CENTER_FREQ_DEF;
        _fricBW                   = BANDWIDTH_DEF;
        _NoiseSourceResponseScale = RESPONSE_DEF;
        _aspVol                   = ASP_VOLUME_DEF;
        _modulation               = PULSE_MOD_DEF;
        _mixOffset                = CROSSMIX_DEF;
        
        // Throat parameters
        _throatVol            = THROAT_VOLUME_DEF;
        _throatCutoff         = CUTOFF_DEF;
        _throatResponseScale  = RESPONSE_DEF;
        
        // Resonant system parameters
        _pharynxDiameter[0]   = PHARYNX_SECTION1_DEF;
        _pharynxDiameter[1]   = PHARYNX_SECTION2_DEF;
        _pharynxDiameter[2]   = PHARYNX_SECTION3_DEF;
        _velumDiameter[0]     = VELUM_SECTION1_DEF;
        _oralDiameter[0]      = ORAL_SECTION1_DEF;
        _oralDiameter[1]      = ORAL_SECTION2_DEF;
        _oralDiameter[2]      = ORAL_SECTION3_DEF;
        _oralDiameter[3]      = ORAL_SECTION4_DEF;
        _oralDiameter[4]      = ORAL_SECTION5_DEF;
        _nasalDiameter[0]     = NASAL_SECTION1_DEF;
        _nasalDiameter[1]     = NASAL_SECTION2_DEF;
        _nasalDiameter[2]     = NASAL_SECTION3_DEF;
        _nasalDiameter[3]     = NASAL_SECTION4_DEF;
        _nasalDiameter[4]     = NASAL_SECTION5_DEF;
        _lossFactor           = LOSS_FACTOR_DEF / 100.0;
        _apScale              = APERTURE_SCALING_DEF;
        _mouthCoef            = FILTER_DEF;
        _noseCoef             = FILTER_DEF;
        _mouthResponseScale   = RESPONSE_DEF;
        _noseResponseScale    = RESPONSE_DEF;
        _length               = LENGTH_DEF;
        _temperature          = TEMPERATURE_DEF;
        _controlPeriod        = CONTROL_PERIOD_DEF;
        _sampleRate           = SAMPLE_RATE_DEF;
        _actualLength         = ACTUAL_LENGTH_DEF;
        
        // Controller parameters
        _volume               = VOLUME_DEF;
        _balance              = BALANCE_DEF;
        _channels             = CHANNELS_DEF;
        _controlRate          = CONTROL_RATE_DEF;
        
        // Analysis parameters
        _normalizeInput       = NORMALIZE_INPUT_DEF;
        _binSize              = BIN_SIZE_DEF;
        _windowType           = WINDOW_TYPE_DEF;
        _alpha                = ALPHA_DEF;
        _beta                 = BETA_DEF;
        _grayLevel            = GRAY_LEVEL_DEF;
        _magnitudeScale       = MAGNITUDE_SCALE_DEF;
        _linearUpperThreshold = UPPER_THRESH_LIN_DEF;
        _linearLowerThreshold = LOWER_THRESH_LIN_DEF;
        _logUpperThreshold    = UPPER_THRESH_LOG_DEF;
        _logLowerThreshold    = LOWER_THRESH_LOG_DEF;
        _spectrographGrid     = SPECTROGRAPH_GRID_DEF;
        _spectrumGrid         = SPECTRUM_GRID_DEF;
    }
	
    return self;
}

- (float)glotPitch;
{
    return (float)_pitch + (float)_cents / 100.0;
}

- (void)setGlotPitch:(float)value;
{
    // Get the pitch and cents values
    _pitch = (int)value;
    _cents = (int)rint((value - (int)value) * 100);
	
    // Adjust pitch and cents if cents are out of range
    if (_cents > CENTS_MAX) {
		_pitch += 1;
		_cents -= 100;
    }
    if (_cents < CENTS_MIN) {
		_pitch -= 1;
		_cents += 100;
    }
}



- (float)glotVol;
{
    return (float)_glotVol;
}

- (void)setGlotVol:(float)value;
{
    _glotVol = (int)rint(value);
}



- (float)aspVol;
{
    return (float)_aspVol;
}

- (void)setAspVol:(float)value;
{
    _aspVol = (int32_t)rint(value);
}



- (float)fricVol;
{
    return (float)_fricVol;
}

- (void)setFricVol:(float)value;
{
    _fricVol = (int32_t)rint(value);
}





- (float)fricCF;
{
    return (float)_fricCF;
}

- (void)setFricCF:(float)value;
{
    _fricCF = (int32_t)rint(value);
}



- (float)fricBW;
{
    return (float)_fricBW;
}

- (void)setFricBW:(float)value;
{
    _fricBW = (int32_t)rint(value);
}



- (float)r1;
{
    return _pharynxDiameter[0] / 2.0;
}

- (void)setR1:(float)value;
{
    _pharynxDiameter[0] = value * 2.0;
}



- (float)r2;
{
    return _pharynxDiameter[1] / 2.0;
}

- (void)setR2:(float)value;
{
    _pharynxDiameter[1] = value * 2.0;
}



- (float)r3;
{
    return _pharynxDiameter[2] / 2.0;
}

- (void)setR3:(float)value;
{
    _pharynxDiameter[2] = value * 2.0;
}



- (float)r4;
{
    return _oralDiameter[0] / 2.0;
}

- (void)setR4:(float)value;
{
    _oralDiameter[0] = value * 2.0;
}



- (float)r5;
{
    return _oralDiameter[1] / 2.0;
}

- (void)setR5:(float)value;
{
    _oralDiameter[1] = value * 2.0;
}



- (float)r6;
{
    return _oralDiameter[2] / 2.0;
}

- (void)setR6:(float)value;
{
    _oralDiameter[2] = value * 2.0;
}



- (float)r7;
{
    return _oralDiameter[3] / 2.0;
}

- (void)setR7:(float)value;
{
    _oralDiameter[3] = value * 2.0;
}



- (float)r8;
{
    return _oralDiameter[4] / 2.0;
}

- (void)setR8:(float)value;
{
    _oralDiameter[4] = value * 2.0;
}



- (float)velum;
{
    return _velumDiameter[0] / 2.0;
}

- (void)setVelum:(float)value;
{
    _velumDiameter[0] = value * 2.0;
}



- (float)volume;
{
    return (float)_volume;
}

- (void)setVolume:(float)value;
{
    _volume = (int32_t)rint(value);
}



- (float)lossFactor;
{
    return _lossFactor * 100.0;
}

- (void)setLossFactor:(float)value;
{
    _lossFactor = value / 100.0;
}



- (float)apScale;
{
    return _apScale / 2.0;
}

- (void)setApScale:(float)value;
{
    _apScale = value * 2.0;
}



- (float)n1;
{
    return _nasalDiameter[0] / 2.0;
}

- (void)setN1:(float)value;
{
    _nasalDiameter[0] = value * 2.0;
}



- (float)n2;
{
    return _nasalDiameter[1] / 2.0;
}

- (void)setN2:(float)value;
{
    _nasalDiameter[1] = value * 2.0;
}



- (float)n3;
{
    return _nasalDiameter[2] / 2.0;
}

- (void)setN3:(float)value;
{
    _nasalDiameter[2] = value * 2.0;
}



- (float)n4;
{
    return _nasalDiameter[3] / 2.0;
}

- (void)setN4:(float)value;
{
    _nasalDiameter[3] = value * 2.0;
}



- (float)n5;
{
    return _nasalDiameter[4] / 2.0;
}

- (void)setN5:(float)value;
{
    _nasalDiameter[4] = value * 2.0;
}



- (float)throatCutoff;
{
    return (float)_throatCutoff;
}

- (void)setThroatCutoff:(float)value;
{
    _throatCutoff = (int32_t)rint(value);
}



- (float)throatVol;
{
    return (float)_throatVol;
}

- (void)setThroatVol:(float)value;
{
    _throatVol = (int32_t)rint(value);
}



- (float)mixOffset;
{
    return (float)_mixOffset;
}

- (void)setMixOffset:(float)value;
{
    _mixOffset = (int32_t)rint(value);
}

@end

//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "TRMInputParameters.h"

#import "TRMTubeModel.h"

#pragma mark - TRMSoundFileFormat

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

#pragma mark - TRMWaveFormType

NSString *TRMWaveFormTypeDescription(TRMWaveFormType type)
{
    switch (type) {
        case TRMWaveFormType_Pulse: return @"Pulse";
        case TRMWaveFormType_Sine:  return @"Sine";
    }
    
    return @"Unknown";
}

#pragma mark -

@implementation TRMInputParameters
{
    TRMSoundFileFormat _outputFileFormat;
    float _outputRate;
    float _controlRate;
    
    double _volume;
    NSUInteger _channels;
    double _balance;
    
    TRMWaveFormType _waveform;
    double _tp;
    double _tnMin;
    double _tnMax;
    double _breathiness;
    
    double _length;
    double _temperature;
    double _lossFactor;
    
    double _apScale;
    double _mouthCoef;
    double _noseCoef;
    
    double _noseRadius[TOTAL_NASAL_SECTIONS];
    
    double _throatCutoff;
    double _throatVol;
    
    BOOL _usesModulation;
    double _mixOffset;
}

- (double *)noseRadius;
{
    return _noseRadius;
}

@end

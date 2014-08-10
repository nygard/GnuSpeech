//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "TRMDataList.h"

#import "TRMInputParameters.h"
#import "TRMParameters.h"
#import "TRMTubeModel.h"
#import "TRMWaveTable.h"

@interface TRMDataList ()
@end

#pragma mark -

@implementation TRMDataList
{
    TRMInputParameters *_inputParameters;
    NSMutableArray *_values;
}

- (id)init;
{
    if ((self = [super init])) {
        _inputParameters = [[TRMInputParameters alloc] init];
        _values = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (id)initWithContentsOfFile:(NSString *)path error:(NSError **)error;
{
    if ((self = [self init])) {
        if (![self _parseInputFile:path error:error])
            return nil;
    }

    return self;
}

// TODO (2012-05-19): Turn fprintfs() into returned NSErrors, and return NSErrors in the other cases too.
- (BOOL)_parseInputFile:(NSString *)path error:(NSError **)error;
{
    FILE *fp = fopen([path UTF8String], "r");
    if (fp == NULL) {
        fprintf(stderr, "Can't open input file \"%s\".\n", [path UTF8String]);
        return NO;
    }
    
    char line[128];
    
    // Get the output file format
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read output file format.\n");
        return NO;
    } else
        self.inputParameters.outputFileFormat = strtol(line, NULL, 10);
    
    // Get the output sample rate
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read output sample rate.\n");
        return NO;
    } else
        self.inputParameters.outputRate = strtod(line, NULL);
    
    // Get the input control rate
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read input control rate.\n");
        return NO;
    } else
        self.inputParameters.controlRate = strtod(line, NULL);
    
    
    // Get the master volume
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read master volume.\n");
        return NO;
    } else
        self.inputParameters.volume = strtod(line, NULL);
    
    // Get the number of sound output channels
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read number of sound output channels.\n");
        return NO;
    } else
        self.inputParameters.channels = strtol(line, NULL, 10);
    
    // Get the stereo balance
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read stereo balance.\n");
        return NO;
    } else
        self.inputParameters.balance = strtod(line, NULL);
    
    
    // Get the glottal source waveform type
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read glottal source waveform type.\n");
        return NO;
    } else
        self.inputParameters.waveform = strtol(line, NULL, 10);
    
    // Get the glottal pulse rise time (tp)
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read glottal pulse rise time (tp).\n");
        return NO;
    } else
        self.inputParameters.tp = strtod(line, NULL);
    
    // Get the glottal pulse fall time minimum (tnMin)
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read glottal pulse fall time minimum (tnMin).\n");
        return NO;
    } else
        self.inputParameters.tnMin = strtod(line, NULL);
    
    // Get the glottal pulse fall time maximum (tnMax)
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read glottal pulse fall time maximum (tnMax).\n");
        return NO;
    } else
        self.inputParameters.tnMax = strtod(line, NULL);
    
    // Get the glottal source breathiness
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read glottal source breathiness.\n");
        return NO;
    } else
        self.inputParameters.breathiness = strtod(line, NULL);
    
    
    // Get the nominal tube length
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read nominal tube length.\n");
        return NO;
    } else
        self.inputParameters.length = strtod(line, NULL);
    
    // Get the tube temperature
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read tube temperature.\n");
        return NO;
    } else
        self.inputParameters.temperature = strtod(line, NULL);
    
    // Get the junction loss factor
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read junction loss factor.\n");
        return NO;
    } else
        self.inputParameters.lossFactor = strtod(line, NULL);
    
    
    // Get the aperture scaling radius
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read aperture scaling radius.\n");
        return NO;
    } else
        self.inputParameters.apScale = strtod(line, NULL);
    
    // Get the mouth aperture coefficient
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read mouth aperture coefficient\n");
        return NO;
    } else
        self.inputParameters.mouthCoef = strtod(line, NULL);
    
    // Get the nose aperture coefficient
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read nose aperture coefficient\n");
        return NO;
    } else
        self.inputParameters.noseCoef = strtod(line, NULL);
    
    
    // Get the nose radii
    for (NSUInteger i = 1; i < TOTAL_NASAL_SECTIONS; i++) {
        if (fgets(line, 128, fp) == NULL) {
            fprintf(stderr, "Can't read nose radius %-lu.\n", i);
            return NO;
        } else
            self.inputParameters.noseRadius[i] = strtod(line, NULL);
    }
    
    
    // Get the throat lowpass frequency cutoff
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read throat lowpass filter cutoff.\n");
        return NO;
    } else
        self.inputParameters.throatCutoff = strtod(line, NULL);
    
    // Get the throat volume
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read throat volume.\n");
        return NO;
    } else
        self.inputParameters.throatVol = strtod(line, NULL);
    
    
    // Get the pulse modulation of noise flag
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read pulse modulation of noise flag.\n");
        return NO;
    } else
        self.inputParameters.usesModulation = (strtol(line, NULL, 10) != 0);
    
    // Get the noise crossmix offset
    if (fgets(line, 128, fp) == NULL) {
        fprintf(stderr, "Can't read noise crossmix offset.\n");
        return NO;
    } else
        self.inputParameters.mixOffset = strtod(line, NULL);
    
    
    // Get the input table values
    while (fgets(line, 128, fp)) {
        char *ptr = line;
        TRMParameters *inputParameters = [[TRMParameters alloc] init];
        double *radius = inputParameters.radius;
        
        // Get each parameter
        inputParameters.glottalPitch             = strtod(ptr, &ptr);
        inputParameters.glottalVolume            = strtod(ptr, &ptr);
        inputParameters.aspirationVolume         = strtod(ptr, &ptr);
        inputParameters.fricationVolume          = strtod(ptr, &ptr);
        inputParameters.fricationPosition        = strtod(ptr, &ptr);
        inputParameters.fricationCenterFrequency = strtod(ptr, &ptr);
        inputParameters.fricationBandwidth       = strtod(ptr, &ptr);
        for (NSUInteger i = 0; i < TOTAL_REGIONS; i++)
            radius[i]                            = strtod(ptr, &ptr);
        inputParameters.velum                    = strtod(ptr, &ptr);
        
        [self.values addObject:inputParameters];
    }
    
    // Double up the last input table, to help interpolation calculations    if ([dataList.values count] > 0) {
    if ([self.values count] > 0) {
        [self.values addObject:[self.values lastObject]]; // TODO (201-04-28): Should copy object
    }
    
    // Close the input file
    fclose(fp);

    return YES;
}

#pragma mark -

- (void)printInputParameters;
{
    printf("outputFileFormat:\t%s\n",          [TRMSoundFileFormatDescription(self.inputParameters.outputFileFormat) UTF8String]);
    
    printf("outputRate:\t\t%.1f Hz\n",         self.inputParameters.outputRate);
    printf("controlRate:\t\t%.2f Hz\n\n",      self.inputParameters.controlRate);
    
    printf("volume:\t\t\t%.2f dB\n",           self.inputParameters.volume);
    printf("channels:\t\t%-lu\n",              self.inputParameters.channels);
    printf("balance:\t\t%+1.2f\n\n",           self.inputParameters.balance);
    
    printf("waveform:\t\t%s\n",                [TRMWaveFormTypeDescription(self.inputParameters.waveform) UTF8String]);
    printf("tp:\t\t\t%.2f%%\n",                self.inputParameters.tp);
    printf("tnMin:\t\t\t%.2f%%\n",             self.inputParameters.tnMin);
    printf("tnMax:\t\t\t%.2f%%\n",             self.inputParameters.tnMax);
    printf("breathiness:\t\t%.2f%%\n\n",       self.inputParameters.breathiness);
    
    printf("nominal tube length:\t%.2f cm\n",  self.inputParameters.length);
    printf("temperature:\t\t%.2f degrees C\n", self.inputParameters.temperature);
    printf("lossFactor:\t\t%.2f%%\n\n",        self.inputParameters.lossFactor);
    
    printf("apScale:\t\t%.2f cm\n",            self.inputParameters.apScale);
    printf("mouthCoef:\t\t%.1f Hz\n",          self.inputParameters.mouthCoef);
    printf("noseCoef:\t\t%.1f Hz\n\n",         self.inputParameters.noseCoef);
    
    for (NSUInteger index = 1; index < TOTAL_NASAL_SECTIONS; index++)
        printf("n%-ld:\t\t\t%.2f cm\n",        index, self.inputParameters.noseRadius[index]);
    
    printf("\nthroatCutoff:\t\t%.1f Hz\n",     self.inputParameters.throatCutoff);
    printf("throatVol:\t\t%.2f dB\n\n",        self.inputParameters.throatVol);
    
    printf("modulation:\t\t");
    printf("%s\n",                             self.inputParameters.usesModulation ? "on" : "off");
    printf("mixOffset:\t\t%.2f dB\n\n",        self.inputParameters.mixOffset);
    
#if DEBUG
    // Print out wave table values
    printf("\n");
    for (NSUInteger index = 0; index < TABLE_LENGTH; i++)
        printf("table[%-d] = %.4f\n", index, wavetable[index]);
#endif
}

- (void)printControlRateInputTable;
{
    // Echo table values
    printf("\n%-lu control rate input tables:\n\n", [self.values count]);
    
    // Header
    printf("glPitch");
    printf("\tglotVol");
    printf("\taspVol");
    printf("\tfricVol");
    printf("\tfricPos");
    printf("\tfricCF");
    printf("\tfricBW");
    for (NSUInteger index = 0; index < TOTAL_REGIONS; index++)
        printf("\tr%-lu", index + 1);
    printf("\tvelum\n");
    
    // Actual values
    for (TRMParameters *parameters in self.values) {
        printf("%.2f",   parameters.glottalPitch);
        printf("\t%.2f", parameters.glottalVolume);
        printf("\t%.2f", parameters.aspirationVolume);
        printf("\t%.2f", parameters.fricationVolume);
        printf("\t%.2f", parameters.fricationPosition);
        printf("\t%.2f", parameters.fricationCenterFrequency);
        printf("\t%.2f", parameters.fricationBandwidth);
        for (NSUInteger index = 0; index < TOTAL_REGIONS; index++)
            printf("\t%.2f", parameters.radius[index]);
        printf("\t%.2f\n", parameters.velum);
    }
    printf("\n");
}

@end

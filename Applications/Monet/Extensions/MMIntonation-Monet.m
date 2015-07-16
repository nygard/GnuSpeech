//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMIntonation-Monet.h"

#define MDK_ShouldUseMacroIntonation   @"ShouldUseMacroIntonation"
#define MDK_ShouldUseMicroIntonation   @"ShouldUseMicroIntonation"

#define MDK_ShouldUseDrift             @"ShouldUseDrift"
#define MDK_DriftDeviation             @"DriftDeviation"
#define MDK_DriftCutoff                @"DriftCutoff"

#define MDK_Tempo                      @"Tempo"

#define MDK_ShouldRandomlyPerturb                               @"ShouldRandomlyPerturb"
#define MDK_ShouldRandomlySelectFromToneGroup                   @"ShouldRandomlySelectFromToneGroup"
#define MDK_ShouldUseToneGroupIntonationParameters              @"ShouldUseToneGroupIntonationParameters"

#define MDK_ManualIntonationParameter_NotionalPitch             @"ManualNotionalPitch"
#define MDK_ManualIntonationParameter_PretonicPitchRange        @"ManualPretonicPitchRange"
#define MDK_ManualIntonationParameter_PretonicPerturbationRange @"ManualPretonicPerturbationRange"
#define MDK_ManualIntonationParameter_TonicPitchRange           @"ManualTonicPitchRange"
#define MDK_ManualIntonationParameter_TonicPerturbationRange    @"ManualTonicPerturbationRange"

//#define MDK_Manual

@implementation MMIntonation (Monet)

+ (void)setupUserDefaults;
{
    NSDictionary *defaults = @{
                               MDK_ShouldUseSmoothIntonation : @YES,
                               MDK_ShouldUseMacroIntonation  : @YES,
                               MDK_ShouldUseMicroIntonation  : @YES,

                               MDK_ShouldUseDrift            : @YES,
                               MDK_DriftDeviation            : @1.0,
                               MDK_DriftCutoff               : @4,

                               MDK_Tempo                     : @1.0,

                               MDK_ShouldRandomlyPerturb                               : @YES,
                               MDK_ShouldRandomlySelectFromToneGroup                   : @YES,
                               MDK_ShouldUseToneGroupIntonationParameters              : @YES,

                               MDK_ManualIntonationParameter_NotionalPitch             : @(2),
                               MDK_ManualIntonationParameter_PretonicPitchRange        : @(-2),
                               MDK_ManualIntonationParameter_PretonicPerturbationRange : @(4),
                               MDK_ManualIntonationParameter_TonicPitchRange           : @(-8),
                               MDK_ManualIntonationParameter_TonicPerturbationRange    : @(4),
                               };

    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (id)initFromUserDefaults;
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if ((self = [self init])) {
        self.shouldUseMacroIntonation  = [defaults boolForKey:MDK_ShouldUseMacroIntonation];
        self.shouldUseMicroIntonation  = [defaults boolForKey:MDK_ShouldUseMicroIntonation];
        self.shouldUseSmoothIntonation = [defaults boolForKey:MDK_ShouldUseSmoothIntonation];

        self.shouldUseDrift = [defaults boolForKey:MDK_ShouldUseDrift];
        self.driftDeviation = [defaults floatForKey:MDK_DriftDeviation];
        self.driftCutoff    = [defaults floatForKey:MDK_DriftCutoff];

        self.tempo          = [defaults doubleForKey:MDK_Tempo];

        self.shouldRandomlyPerturb                  = [defaults boolForKey:MDK_ShouldRandomlyPerturb];
        self.shouldRandomlySelectFromToneGroup      = [defaults boolForKey:MDK_ShouldRandomlySelectFromToneGroup];
        self.shouldUseToneGroupIntonationParameters = [defaults boolForKey:MDK_ShouldUseToneGroupIntonationParameters];

        self.manualIntonationParameters.notionalPitch             = [defaults floatForKey:MDK_ManualIntonationParameter_NotionalPitch];
        self.manualIntonationParameters.pretonicPitchRange        = [defaults floatForKey:MDK_ManualIntonationParameter_PretonicPitchRange];
        self.manualIntonationParameters.pretonicPerturbationRange = [defaults floatForKey:MDK_ManualIntonationParameter_PretonicPerturbationRange];
        self.manualIntonationParameters.tonicPitchRange           = [defaults floatForKey:MDK_ManualIntonationParameter_TonicPitchRange];
        self.manualIntonationParameters.tonicPerturbationRange    = [defaults floatForKey:MDK_ManualIntonationParameter_TonicPerturbationRange];
    }

    return self;
}

- (void)saveToUserDefaults;
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setBool:self.shouldUseMacroIntonation  forKey:MDK_ShouldUseMacroIntonation];
    [defaults setBool:self.shouldUseMicroIntonation  forKey:MDK_ShouldUseMicroIntonation];
    [defaults setBool:self.shouldUseSmoothIntonation forKey:MDK_ShouldUseSmoothIntonation];

    [defaults setBool:self.shouldUseDrift            forKey:MDK_ShouldUseDrift];
    [defaults setFloat:self.driftDeviation           forKey:MDK_DriftDeviation];
    [defaults setFloat:self.driftCutoff              forKey:MDK_DriftCutoff];

    [defaults setDouble:self.tempo                   forKey:MDK_Tempo];

    [defaults setBool:self.shouldRandomlyPerturb                  forKey:MDK_ShouldRandomlyPerturb];
    [defaults setBool:self.shouldRandomlySelectFromToneGroup      forKey:MDK_ShouldRandomlySelectFromToneGroup];
    [defaults setBool:self.shouldUseToneGroupIntonationParameters forKey:MDK_ShouldUseToneGroupIntonationParameters];

    [defaults setFloat:self.manualIntonationParameters.notionalPitch             forKey:MDK_ManualIntonationParameter_NotionalPitch];
    [defaults setFloat:self.manualIntonationParameters.pretonicPitchRange        forKey:MDK_ManualIntonationParameter_PretonicPitchRange];
    [defaults setFloat:self.manualIntonationParameters.pretonicPerturbationRange forKey:MDK_ManualIntonationParameter_PretonicPerturbationRange];
    [defaults setFloat:self.manualIntonationParameters.tonicPitchRange           forKey:MDK_ManualIntonationParameter_TonicPitchRange];
    [defaults setFloat:self.manualIntonationParameters.tonicPerturbationRange    forKey:MDK_ManualIntonationParameter_TonicPerturbationRange];
}

@end

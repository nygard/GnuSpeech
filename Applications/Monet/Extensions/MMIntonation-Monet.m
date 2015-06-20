//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMIntonation-Monet.h"

#define MDK_NotionalPitch              @"NotionalPitch"
#define MDK_PretonicRange              @"PretonicRange"
#define MDK_PretonicLift               @"PretonicLift"
#define MDK_TonicRange                 @"TonicRange"
#define MDK_TonicMovement              @"TonicMovement"

#define MDK_ShouldUseMacroIntonation   @"ShouldUseMacroIntonation"
#define MDK_ShouldUseMicroIntonation   @"ShouldUseMicroIntonation"

#define MDK_ShouldUseDrift             @"ShouldUseDrift"
#define MDK_DriftDeviation             @"DriftDeviation"
#define MDK_DriftCutoff                @"DriftCutoff"

#define MDK_Tempo                      @"Tempo"
#define MDK_RadiusMultiply             @"RadiusMultiply"

@implementation MMIntonation (Monet)

+ (void)setupUserDefaults;
{
    NSDictionary *defaults = @{
                               MDK_NotionalPitch             : @-1,
                               MDK_PretonicRange             : @2,
                               MDK_PretonicLift              : @-2,
                               MDK_TonicRange                : @-10,
                               MDK_TonicMovement             : @-6,

                               MDK_ShouldUseSmoothIntonation : @YES,
                               MDK_ShouldUseMacroIntonation  : @YES,
                               MDK_ShouldUseMicroIntonation  : @YES,

                               MDK_ShouldUseDrift            : @YES,
                               MDK_DriftDeviation            : @1.0,
                               MDK_DriftCutoff               : @4,

                               MDK_Tempo                     : @1.0,
                               MDK_RadiusMultiply            : @1.0,
                               };

    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (id)initFromUserDefaults;
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if ((self = [super init])) {
        self.notionalPitch = [defaults floatForKey:MDK_NotionalPitch];
        self.pretonicRange = [defaults floatForKey:MDK_PretonicRange];
        self.pretonicLift  = [defaults floatForKey:MDK_PretonicLift];
        self.tonicRange    = [defaults floatForKey:MDK_TonicRange];
        self.tonicMovement = [defaults floatForKey:MDK_TonicMovement];

        self.shouldUseMacroIntonation  = [defaults boolForKey:MDK_ShouldUseMacroIntonation];
        self.shouldUseMicroIntonation  = [defaults boolForKey:MDK_ShouldUseMicroIntonation];
        self.shouldUseSmoothIntonation = [defaults boolForKey:MDK_ShouldUseSmoothIntonation];

        self.shouldUseDrift = [defaults boolForKey:MDK_ShouldUseDrift];
        self.driftDeviation = [defaults floatForKey:MDK_DriftDeviation];
        self.driftCutoff    = [defaults floatForKey:MDK_DriftCutoff];

        self.tempo          = [defaults doubleForKey:MDK_Tempo];
        self.radiusMultiply = [defaults doubleForKey:MDK_RadiusMultiply];
    }

    return self;
}

- (void)saveToUserDefaults;
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setFloat:self.notionalPitch            forKey:MDK_NotionalPitch];
    [defaults setFloat:self.pretonicRange            forKey:MDK_PretonicRange];
    [defaults setFloat:self.pretonicLift             forKey:MDK_PretonicLift];
    [defaults setFloat:self.tonicRange               forKey:MDK_TonicRange];
    [defaults setFloat:self.tonicMovement            forKey:MDK_TonicMovement];

    [defaults setBool:self.shouldUseMacroIntonation  forKey:MDK_ShouldUseMacroIntonation];
    [defaults setBool:self.shouldUseMicroIntonation  forKey:MDK_ShouldUseMicroIntonation];
    [defaults setBool:self.shouldUseSmoothIntonation forKey:MDK_ShouldUseSmoothIntonation];

    [defaults setBool:self.shouldUseDrift            forKey:MDK_ShouldUseDrift];
    [defaults setFloat:self.driftDeviation           forKey:MDK_DriftDeviation];
    [defaults setFloat:self.driftCutoff              forKey:MDK_DriftCutoff];

    [defaults setDouble:self.tempo                   forKey:MDK_Tempo];
    [defaults setDouble:self.radiusMultiply          forKey:MDK_RadiusMultiply];
}

@end

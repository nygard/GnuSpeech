//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMIntonation-Monet.h"

#define MDK_NotionalPitch              @"NotionalPitch"
#define MDK_PretonicRange              @"PretonicRange"
#define MDK_PretonicLift               @"PretonicLift"
#define MDK_TonicRange                 @"TonicRange"
#define MDK_TonicMovement              @"TonicMovement"

#define MDK_ShouldUseSmoothIntonation  @"ShouldUseSmoothIntonation"
#define MDK_ShouldUseMacroIntonation   @"ShouldUseMacroIntonation"
#define MDK_ShouldUseMicroIntonation   @"ShouldUseMicroIntonation"

#define MDK_ShouldUseDrift             @"ShouldUseDrift"
#define MDK_DriftDeviation             @"DriftDeviation"
#define MDK_DriftCutoff                @"DriftCutoff"

#define MDK_Tempo                      @"Tempo"
#define MDK_RadiusMultiply             @"RadiusMultiply"

@implementation MMIntonation

+ (void)setupUserDefaults;
{
    NSLog(@"%s", __PRETTY_FUNCTION__);

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
        _notionalPitch = [defaults floatForKey:MDK_NotionalPitch];
        _pretonicRange = [defaults floatForKey:MDK_PretonicRange];
        _pretonicLift  = [defaults floatForKey:MDK_PretonicLift];
        _tonicRange    = [defaults floatForKey:MDK_TonicRange];
        _tonicMovement = [defaults floatForKey:MDK_TonicMovement];

        _shouldUseMacroIntonation        = [defaults boolForKey:MDK_ShouldUseMacroIntonation];
        _shouldUseMicroIntonation        = [defaults boolForKey:MDK_ShouldUseMicroIntonation];
        _shouldUseSmoothSmoothIntonation = [defaults boolForKey:MDK_ShouldUseSmoothIntonation];

        _shouldUseDrift = [defaults boolForKey:MDK_ShouldUseDrift];
        _driftDeviation = [defaults floatForKey:MDK_DriftDeviation];
        _driftCutoff    = [defaults floatForKey:MDK_DriftCutoff];

        _tempo          = [defaults doubleForKey:MDK_Tempo];
        _radiusMultiply = [defaults doubleForKey:MDK_RadiusMultiply];
    }

    return self;
}

- (void)saveToUserDefaults;
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setFloat:self.notionalPitch                  forKey:MDK_NotionalPitch];
    [defaults setFloat:self.pretonicRange                  forKey:MDK_PretonicRange];
    [defaults setFloat:self.pretonicLift                   forKey:MDK_PretonicLift];
    [defaults setFloat:self.tonicRange                     forKey:MDK_TonicRange];
    [defaults setFloat:self.tonicMovement                  forKey:MDK_TonicMovement];

    [defaults setBool:self.shouldUseMacroIntonation        forKey:MDK_ShouldUseMacroIntonation];
    [defaults setBool:self.shouldUseMicroIntonation        forKey:MDK_ShouldUseMicroIntonation];
    [defaults setBool:self.shouldUseSmoothSmoothIntonation forKey:MDK_ShouldUseSmoothIntonation];

    [defaults setBool:self.shouldUseDrift                  forKey:MDK_ShouldUseDrift];
    [defaults setFloat:self.driftDeviation                 forKey:MDK_DriftDeviation];
    [defaults setFloat:self.driftCutoff                    forKey:MDK_DriftCutoff];

    [defaults setDouble:self.tempo                         forKey:MDK_Tempo];
    [defaults setDouble:self.radiusMultiply                forKey:MDK_RadiusMultiply];
}

@end

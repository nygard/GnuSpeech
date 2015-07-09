//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMIntonation-Monet.h"

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

    if ((self = [self init])) {
        self.shouldUseMacroIntonation  = [defaults boolForKey:MDK_ShouldUseMacroIntonation];
        self.shouldUseMicroIntonation  = [defaults boolForKey:MDK_ShouldUseMicroIntonation];
        self.shouldUseSmoothIntonation = [defaults boolForKey:MDK_ShouldUseSmoothIntonation];

        self.shouldUseDrift = [defaults boolForKey:MDK_ShouldUseDrift];
        self.driftDeviation = [defaults floatForKey:MDK_DriftDeviation];
        self.driftCutoff    = [defaults floatForKey:MDK_DriftCutoff];

        self.tempo          = [defaults doubleForKey:MDK_Tempo];
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
}

@end

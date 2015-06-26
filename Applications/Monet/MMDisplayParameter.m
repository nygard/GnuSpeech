//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMDisplayParameter.h"

#import <GnuSpeech/GnuSpeech.h>

@implementation MMDisplayParameter
{
    MMParameter *_parameter;
    BOOL _isSpecial;
    NSUInteger _tag;
    BOOL _shouldDisplay;
}

- (id)initWithParameter:(MMParameter *)parameter;
{
    if ((self = [super init])) {
        _parameter = parameter;
        _isSpecial = NO;
        _tag = 0;
        _shouldDisplay = YES;
    }

    return self;
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p> name: %@",
            NSStringFromClass([self class]), self,
            self.name];
}

#pragma mark -

- (void)toggleShouldDisplay;
{
    self.shouldDisplay = !self.shouldDisplay;
}

- (NSString *)name;
{
    if (self.isSpecial)
        return [NSString stringWithFormat:@"%@ (special)", self.parameter.name];

    return self.parameter.name;
}

// Used in the EventList view
- (NSString *)label;
{
    if (self.isSpecial)
        return [NSString stringWithFormat:@"%@\n(special)", self.parameter.name];

    return self.parameter.name;
}

@end

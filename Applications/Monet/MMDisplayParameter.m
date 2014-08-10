//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMDisplayParameter.h"

#import <GnuSpeech/GnuSpeech.h>

@implementation MMDisplayParameter
{
    MMParameter *m_parameter;
    BOOL m_isSpecial;
    NSUInteger m_tag;
    BOOL m_shouldDisplay;
}

- (id)initWithParameter:(MMParameter *)aParameter;
{
    if ((self = [super init])) {
        m_parameter = aParameter;
        m_isSpecial = NO;
        m_tag = 0;
    }

    return self;
}


#pragma mark -

@synthesize parameter = m_parameter;
@synthesize isSpecial = m_isSpecial;
@synthesize tag = m_tag;
@synthesize shouldDisplay = m_shouldDisplay;

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

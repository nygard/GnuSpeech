//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMIntonationParameters.h"

@implementation MMIntonationParameters
{
    float m_notionalPitch;
    float m_pretonicRange;
    float m_pretonicLift;
    float m_tonicRange;
    float m_tonicMovement; // TODO (2004-03-30): Apparently not used.
}

- (id)init;
{
    if ((self = [super init])) {
        m_notionalPitch = -1;
        m_pretonicRange = 2;
        m_pretonicLift  = -2;
        m_tonicRange    = -10;
        m_tonicMovement = -6;
    }
    
    return self;
}

@synthesize notionalPitch = m_notionalPitch;
@synthesize pretonicRange = m_pretonicRange;
@synthesize pretonicLift  = m_pretonicLift;
@synthesize tonicRange    = m_tonicRange;
@synthesize tonicMovement = m_tonicMovement;

@end

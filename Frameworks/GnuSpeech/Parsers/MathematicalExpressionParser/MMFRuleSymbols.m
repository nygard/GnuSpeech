//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright (c) 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMFRuleSymbols.h"

@implementation MMFRuleSymbols
{
    double m_ruleDuration; // 0
    double m_beat;         // 1
    double m_mark1;        // 2
    double m_mark2;        // 3
    double m_mark3;        // 4
}

@synthesize ruleDuration = m_ruleDuration;
@synthesize beat = m_beat;
@synthesize mark1 = m_mark1;
@synthesize mark2 = m_mark2;
@synthesize mark3 = m_mark3;

@end


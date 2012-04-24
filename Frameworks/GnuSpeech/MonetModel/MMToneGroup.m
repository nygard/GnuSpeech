//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMToneGroup.h"

@implementation MMToneGroup
{
    NSUInteger m_startFootIndex;
    NSUInteger m_endFootIndex;
    MMToneGroupType m_type;
}

@synthesize startFootIndex = m_startFootIndex;
@synthesize endFootIndex = m_endFootIndex;
@synthesize type = m_type;

@end

NSString *MMToneGroupTypeName(MMToneGroupType type)
{
    switch (type) {
        case MMToneGroupType_Statement:    return @"Statement";
        case MMToneGroupType_Exclamation:  return @"Exclamation";
        case MMToneGroupType_Question:     return @"Question";
        case MMToneGroupType_Continuation: return @"Continuation";
        case MMToneGroupType_Semicolon:    return @"Semicolon";
    }
    
    return nil;
}

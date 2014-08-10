//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMToneGroup.h"

@implementation MMToneGroup
{
    NSUInteger _startFootIndex;
    NSUInteger _endFootIndex;
    MMToneGroupType _type;
}

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

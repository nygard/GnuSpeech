//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMToneGroup.h"

#import "MMIntonationParameters.h"

@implementation MMToneGroup

@end

NSString *MMToneGroupTypeName(MMToneGroupType type)
{
    switch (type) {
        case MMToneGroupType_Statement:    return @"Statement";
        case MMToneGroupType_Exclamation:  return @"Exclamation";
        case MMToneGroupType_Question:     return @"Question";
        case MMToneGroupType_Continuation: return @"Continuation";
        case MMToneGroupType_Semicolon:    return @"Semicolon";
        case MMToneGroupType_Unknown:      return @"Unknown";
    }
    
    return nil;
}

MMToneGroupType MMToneGroupTypeFromString(NSString *str)
{
    if ([str isEqualToString:@"Statement"])    return MMToneGroupType_Statement;
    if ([str isEqualToString:@"Exclamation"])  return MMToneGroupType_Exclamation;
    if ([str isEqualToString:@"Question"])     return MMToneGroupType_Question;
    if ([str isEqualToString:@"Continuation"]) return MMToneGroupType_Continuation;
    if ([str isEqualToString:@"Semicolon"])    return MMToneGroupType_Semicolon;

    return MMToneGroupType_Unknown;
}
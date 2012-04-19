//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

@class NSString;

typedef enum {
    MMPhoneTypeDiphone = 2,
    MMPhoneTypeTriphone = 3,
    MMPhoneTypeTetraphone = 4,
} MMPhoneType;

#define GSXMLEntityMaskNone 0x00
#define GSXMLEntityMaskAmpersand 0x01
#define GSXMLEntityMaskLessThan 0x02
#define GSXMLEntityMaskGreaterThan 0x04
#define GSXMLEntityMaskSingleQuote 0x08
#define GSXMLEntityMaskDoubleQuote 0x10

NSString *GSXMLEscapeGeneralEntities(NSString *aString, int entityMask);

NSString *GSXMLAttributeString(NSString *aString, BOOL isSingleQuoted);
NSString *GSXMLCharacterData(NSString *aString);
NSString *GSXMLBoolAttributeString(BOOL aFlag);
BOOL GSXMLBoolFromString(NSString *str);


NSString *MMStringFromPhoneType(MMPhoneType type);
MMPhoneType MMPhoneTypeFromString(NSString *str);

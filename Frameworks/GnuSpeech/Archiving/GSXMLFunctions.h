//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

enum {
    MMPhoneType_Diphone    = 2,
    MMPhoneType_Triphone   = 3,
    MMPhoneType_Tetraphone = 4,
};
typedef NSUInteger MMPhoneType;

#define GSXMLEntityMask_None        0x00
#define GSXMLEntityMask_Ampersand   0x01
#define GSXMLEntityMask_LessThan    0x02
#define GSXMLEntityMask_GreaterThan 0x04
#define GSXMLEntityMask_SingleQuote 0x08
#define GSXMLEntityMask_DoubleQuote 0x10

typedef NSUInteger GSXMLEntityMask;

NSString *GSXMLEscapeGeneralEntities(NSString *string, GSXMLEntityMask entityMask);

NSString *GSXMLAttributeString(NSString *string, BOOL isSingleQuoted);
NSString *GSXMLCharacterData(NSString *string);
NSString *GSXMLBoolAttributeString(BOOL flag);
BOOL GSXMLBoolFromString(NSString *str);


NSString *MMStringFromPhoneType(MMPhoneType type);
MMPhoneType MMPhoneTypeFromString(NSString *str);

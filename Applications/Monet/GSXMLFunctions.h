@class NSString;

#if 0
typedef enum {
    GSXMLAttributeQuoteStyleSingle = 0,
    GSXMLAttributeQuoteStyleDouble = 1,
} GSMXMLAttributeQuoteStyle;
#endif

// < & > " '

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

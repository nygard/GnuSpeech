@class NSString;

#if 0
typedef enum {
    GSXMLAttributeQuoteStyleSingle = 0,
    GSXMLAttributeQuoteStyleDouble = 1,
} GSMXMLAttributeQuoteStyle;
#endif

NSString *GSXMLAttributeString(NSString *aString, BOOL isSingleQuoted);
NSString *GSXMLCharacterData(NSString *aString);
NSString *GSXMLBoolAttributeString(BOOL aFlag);

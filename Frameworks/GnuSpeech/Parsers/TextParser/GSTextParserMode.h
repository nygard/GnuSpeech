
typedef enum : NSUInteger {
    GSTextParserMode_Normal    = 0,
    GSTextParserMode_Raw       = 1,
    GSTextParserMode_Letter    = 2,
    GSTextParserMode_Emphasis  = 3,
    GSTextParserMode_Tagging   = 4,
    GSTextParserMode_Silence   = 5,
    GSTextParserMode_Undefined = 6,
} GSTextParserMode;

NSString *GSTextParserModeDescription(GSTextParserMode mode);

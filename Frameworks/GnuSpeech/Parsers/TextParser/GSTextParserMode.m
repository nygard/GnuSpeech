#import "GSTextParserMode.h"

NSString *GSTextParserModeDescription(GSTextParserMode mode)
{
    switch (mode) {
        case GSTextParserMode_Normal:    return @"Normal";
        case GSTextParserMode_Raw:       return @"Raw";
        case GSTextParserMode_Letter:    return @"Letter";
        case GSTextParserMode_Emphasis:  return @"Emphasis";
        case GSTextParserMode_Tagging:   return @"Tagging";
        case GSTextParserMode_Silence:   return @"Silence";
        case GSTextParserMode_Undefined: return @"Undefined";
    }
}

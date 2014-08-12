@interface GSTextParser ()
- (NSString *)_conditionInputString:(NSString *)str;
- (NSAttributedString *)_markModesInString:(NSString *)str error:(NSError **)error;
@end

extern NSString *GSTextParserErrorDomain;

enum {
    GSTextParserError_UnbalancedPop = 1,
};

extern NSString *GSTextParserAttribute_Mode;
extern NSString *GSTextParserAttribute_TagValue;
extern NSString *GSTextParserAttribute_SilenceValue;


@interface GSTextParser ()
- (NSString *)_conditionInputString:(NSString *)str;
- (NSAttributedString *)_markModesInString:(NSString *)str;
@end

extern NSString *GSTextParserAttribute_Mode;
extern NSString *GSTextParserAttribute_TagValue;
extern NSString *GSTextParserAttribute_SilenceValue;


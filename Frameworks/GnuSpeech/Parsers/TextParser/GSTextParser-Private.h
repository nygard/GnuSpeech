@class GSTextGroup;

@interface GSTextParser ()
- (NSString *)_conditionInputString:(NSString *)str;
- (GSTextGroup *)_markModesInString:(NSString *)str error:(NSError **)error;
- (NSString *)punc1_replaceSingleCharacters:(NSString *)str;
- (NSString *)punc1_deleteSingleQuotes:(NSString *)str;
- (NSString *)punc1_deleteSingleCharacters:(NSString *)str;
@end

extern NSString *GSTextParserErrorDomain;

enum {
    GSTextParserError_UnbalancedPop = 1,
};

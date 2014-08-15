@class GSTextGroup;

@interface GSTextParser ()
- (NSString *)_conditionInputString:(NSString *)str;
- (GSTextGroup *)_markModesInString:(NSString *)str error:(NSError **)error;
@end

extern NSString *GSTextParserErrorDomain;

enum {
    GSTextParserError_UnbalancedPop = 1,
};

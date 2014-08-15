#import <Foundation/Foundation.h>

#import "GSTextParserMode.h"

@interface GSTextRun : NSObject

- (id)initWithMode:(GSTextParserMode)mode;

@property (readonly) GSTextParserMode mode;
@property (strong) NSMutableString *string;

- (void)stripPunctuation;

- (NSString *)_punc1_replaceSingleCharacters:(NSString *)str;
- (NSString *)_replaceIsolatedCharacters:(NSString *)str;
- (NSString *)_punc1_deleteSingleQuotes:(NSString *)str;
- (NSString *)_punc1_deleteSingleCharacters:(NSString *)str;

@end

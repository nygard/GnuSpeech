#import <Foundation/Foundation.h>

#import "GSTextParserMode.h"

@interface GSTextRun : NSObject

- (id)initWithMode:(GSTextParserMode)mode;

@property (readonly) GSTextParserMode mode;
@property (strong, readonly) NSMutableString *string;

- (void)stripPunctuation;

- (void)_punc1_replaceSingleCharacters;
- (void)_replaceIsolatedCharacters;
- (void)_punc1_deleteSingleQuotes;
- (void)_punc1_deleteSingleCharacters;

@end

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    GSPronunciationSource_NumberParser          = 1,
    GSPronunciationSource_UserDictionary        = 2,
    GSPronunciationSource_ApplicationDictionary = 3,
    GSPronunciationSource_MainDictionary        = 4,
    GSPronunciationSource_LetterToSound         = 5,
} GSPronunciationSource;

@class GSPronunciationDictionary;

/// This will replace the c-string based text parser.
@interface GSTextParser : NSObject

@property (strong) GSPronunciationDictionary *userDictionary;
@property (strong) GSPronunciationDictionary *applicationDictionary;
@property (strong) GSPronunciationDictionary *mainDictionary;
@property (strong) GSPronunciationDictionary *specialAcronymDictionary;

/// This contains an array of NSNumbers (GSPronunciationSource), to indicate the order of pronunciation lookup.
@property (strong) NSArray *pronunciationSourceOrder;

/// This defaults to "%".  Not sure what the valid values could be.
@property (strong) NSString *escapeCharacter;

/// Return the pronunciation for a word, looking through the dictionaries in the assigned dictionaryOrder.
/// If source is not NULL, returns where the word was found.
/// Returns nil if no pronunciation found.
- (NSString *)pronunciationForWord:(NSString *)word andReturnPronunciationSource:(GSPronunciationSource *)source;

@end

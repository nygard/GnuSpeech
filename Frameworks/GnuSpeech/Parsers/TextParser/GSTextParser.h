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
@property (nonatomic, strong) NSString *escapeCharacter;

/// Return the pronunciation for a word, looking through the dictionaries in the assigned dictionaryOrder.
/// If source is not NULL, returns where the word was found.
/// Returns nil if no pronunciation found.
- (NSString *)pronunciationForWord:(NSString *)word andReturnPronunciationSource:(GSPronunciationSource *)source;


/// Takes plain English input, and produces phonetic output suitable for further processing in the TTS system.
/// Return nil if a parse error occurs, and optionally set error.  The error userInfo will contain a key for
/// the position of the error in the input buffer, if possible, but in later stages of the parse positional
/// information is lost.
- (NSString *)parseString:(NSString *)string error:(NSError **)error;

@end

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    GSDict_NumberParser  = 1,
    GSDict_User          = 2,
    GSDict_Application   = 3,
    GSDict_Main          = 4,
    GSDict_LetterToSound = 5,
} GSDictionarySource;

@class GSPronunciationDictionary;

/// This will replace the c-string based text parser.
@interface GSTextParser : NSObject

@property (strong) GSPronunciationDictionary *userDictionary;
@property (strong) GSPronunciationDictionary *applicationDictionary;
@property (strong) GSPronunciationDictionary *mainDictionary;
@property (strong) GSPronunciationDictionary *specialAcronymDictionary;

/// This contains an array of NSNumbers (GSDictionarySource), to indicate the order of dictionary lookup.
@property (strong) NSArray *dictionaryOrder;

/// Return the pronunciation for a word, looking through the dictionaries in the assigned dictionaryOrder.
/// If source is not NULL, returns where the word was found.
/// Returns nil if no pronunciation found.
- (NSString *)pronunciationForWord:(NSString *)word andReturnSourceDictionary:(GSDictionarySource *)source;

@end

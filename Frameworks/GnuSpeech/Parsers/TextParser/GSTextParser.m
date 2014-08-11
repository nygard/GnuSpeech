#import "GSTextParser.h"

#import "GSPronunciationDictionary.h"
#import "GSDBMPronunciationDictionary.h"
#import "GSSimplePronunciationDictionary.h"

@implementation GSTextParser
{
    GSPronunciationDictionary *_userDictionary;
    GSPronunciationDictionary *_applicationDictionary;
    GSPronunciationDictionary *_mainDictionary;
    GSPronunciationDictionary *_specialAcronymDictionary;

    NSArray *_dictionaryOrder;
    NSString *_escapeCharacter;
}

- (id)init;
{
    if ((self = [super init])) {
        _mainDictionary           = [GSDBMPronunciationDictionary mainDictionary];
        _specialAcronymDictionary = [GSSimplePronunciationDictionary specialAcronymDictionary];
        
        _dictionaryOrder = @[ @(GSDict_NumberParser), @(GSDict_User), @(GSDict_Application), @(GSDict_Main)];
        _escapeCharacter = @"%";
    }

    return self;
}

#pragma mark -

- (NSString *)_pronunciationForWord:(NSString *)word inDictionarySource:(GSDictionarySource)source;
{
    switch (source) {
        case GSDict_NumberParser:  return nil; // number_parser()
        case GSDict_User:          return [self.userDictionary pronunciationForWord:word];
        case GSDict_Application:   return [self.applicationDictionary pronunciationForWord:word];
        case GSDict_Main:          return [self.mainDictionary pronunciationForWord:word];
        case GSDict_LetterToSound: return nil; // letter_to_sound()
        default:
            break;
    }

    return nil;
}

- (NSString *)pronunciationForWord:(NSString *)word andReturnSourceDictionary:(GSDictionarySource *)source;
{
    for (NSNumber *dictionarySource in self.dictionaryOrder) {
        NSString *pronunciation = [self _pronunciationForWord:word inDictionarySource:[dictionarySource unsignedIntegerValue]];

        if (pronunciation != nil) {
            if (source != NULL) *source = [dictionarySource unsignedIntegerValue];
            return pronunciation;
        }
    }

    // Fall back to letter-to-sound as a last resort, to guarantee pronunciation of some sort.
    NSString *pronunciation = [self _pronunciationForWord:word inDictionarySource:GSDict_LetterToSound];
    if (pronunciation != nil) {
        if (source != NULL) *source = GSDict_LetterToSound;
        return pronunciation;
    }

    // Use degenerate_string() / GSDict_LetterToSound.

    return nil;
}

@end

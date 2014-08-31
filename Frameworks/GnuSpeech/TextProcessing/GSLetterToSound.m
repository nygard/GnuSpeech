//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "GSLetterToSound.h"

#import "letter_to_sound.h"
#import "GSSuffixWordType.h"
#import "NSRegularExpression-GSExtensions.h"

static NSString *GSLTSWordType_Unknown = @"j";

@interface NSString (GSLetterToSound)
- (BOOL)gs_lts_isAllCaps;
- (BOOL)gs_lts_hasVowels;
@end

@implementation  NSString (GSLetterToSound)

/// Single quote is ignored.  Non-alpha forces YES.
- (BOOL)gs_lts_isAllCaps;
{
    NSCharacterSet *nonAlphaOrSingleQuoteCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'"] invertedSet];
    NSRange nonAlphaOrSingleQuoteRange = [self rangeOfCharacterFromSet:nonAlphaOrSingleQuoteCharacterSet];
    BOOL hasNonAlphaOrSingleQuote = nonAlphaOrSingleQuoteRange.length > 0;

    NSRange lowerCaseLetterRange = [self rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]];
    BOOL hasLowercaseLetter = lowerCaseLetterRange.length > 0;

    return hasNonAlphaOrSingleQuote || !hasLowercaseLetter;
}

- (BOOL)gs_lts_hasVowels;
{
    NSCharacterSet *vowels = [NSCharacterSet characterSetWithCharactersInString:@"aeiouyAEIOUY"];
    NSRange range = [self rangeOfCharacterFromSet:vowels];
    return range.location != NSNotFound;
}

@end

#pragma mark -

@implementation GSLetterToSound

+ (NSArray *)suffixToWordTypes;
{
    static NSArray *suffixToWordTypes;

    if (suffixToWordTypes == nil) {
        NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"SuffixToWordType" withExtension:@"xml"];

        NSError *error;
        NSXMLDocument *document = [[NSXMLDocument alloc] initWithContentsOfURL:url options:0 error:&error];
        if (document == nil) {
            NSLog(@"%s, error loading SuffixToWordType.xml: %@", __PRETTY_FUNCTION__, error);
        } else {
            NSMutableArray *a1 = [[NSMutableArray alloc] init];

            for (NSXMLElement *element in [[document rootElement] elementsForName:@"suffix"]) {
                NSString *suffix   = [[element attributeForName:@"name"] stringValue];
                NSString *wordType = [[element attributeForName:@"word-type"] stringValue];
                GSSuffixWordType *suffixWordType = [[GSSuffixWordType alloc] initWithSuffix:suffix wordType:wordType];
                [a1 addObject:suffixWordType];
            }

            suffixToWordTypes = [a1 copy];
            //NSLog(@"suffixToWordTypes: %@", suffixToWordTypes);
        }
    }
    
    return suffixToWordTypes;
}

+ (NSDictionary *)wordExceptions;
{
    static NSDictionary *exceptions;

    if (exceptions == nil) {
        NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"LetterToSound-Exceptions-Trillium" withExtension:@"xml"];

        NSError *error;
        NSXMLDocument *document = [[NSXMLDocument alloc] initWithContentsOfURL:url options:0 error:&error];
        if (document == nil) {
            NSLog(@"%s, error loading letter-to-sound exceptions: %@", __PRETTY_FUNCTION__, error);
        } else {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

            for (NSXMLElement *element in [[document rootElement] elementsForName:@"word"]) {
                NSString *key   = [[element attributeForName:@"key"] stringValue];
                NSString *value = [[element attributeForName:@"value"] stringValue];
                dict[key] = value;
            }

            exceptions = [dict copy];
            //NSLog(@"exceptions: %@", exceptions);
        }
    }

    return exceptions;
}

+ (NSDictionary *)letterPronunciations;
{
    static NSDictionary *letters;

    if (letters == nil) {
        NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"LetterPronunciations" withExtension:@"xml"];

        NSError *error;
        NSXMLDocument *document = [[NSXMLDocument alloc] initWithContentsOfURL:url options:0 error:&error];
        if (document == nil) {
            NSLog(@"%s, error loading letter pronunciations exceptions: %@", __PRETTY_FUNCTION__, error);
        } else {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

            for (NSXMLElement *element in [[document rootElement] elementsForName:@"letter"]) {
                NSString *key   = [[element attributeForName:@"key"] stringValue];
                NSString *value = [[element stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                dict[key] = value;
            }

            {
                NSXMLElement *element = [[[document rootElement] elementsForName:@"unknown"] firstObject];
                if (element != nil) {
                    NSString *value = [[element stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    dict[@"unknown"] = value;
                }
            }

            letters = [dict copy];
            //NSLog(@"letters: %@", letters);
        }
    }

    return letters;
}

#pragma mark -

- (NSString *)pronunciationForWord:(NSString *)word;
{
    const char *result = letter_to_sound((char *)[word cStringUsingEncoding:NSASCIIStringEncoding]);
    if (result != nil) {
        return [[NSString alloc] initWithUTF8String:result];
    }

    return nil;
}

#pragma mark -

- (NSString *)new_pronunciationForWord:(NSString *)word;
{
//    [GSLetterToSound suffixToWordTypes];
//    [GSLetterToSound wordExceptions];
//    [GSLetterToSound letterPronunciations];

//    NSMutableString *str = [NSMutableString stringWithFormat:@"#%@#", word];
    NSMutableString *pronunciation = [[NSMutableString alloc] init];


    NSUInteger syllableCount = 0;


    // Preprocess input.  We'll wait before surrounding the word with # -- regular expression ^ and $ should work instead.
    BOOL isPronunciation;
    NSString *s1 = [self patPhoneFromWord:word isPronunciation:&isPronunciation]; // Take the original word.
    if (!isPronunciation) {
    } else {
        [pronunciation appendString:s1];
    }

#if 0
    /*  CONVERT WORD TO PRONUNCIATION  */
    if (!word_to_patphone(buffer))
    {
        isp_trans(buffer, pronunciation);
        /*  ATTEMPT TO MARK SYLL/STRESS  */
        syllableCount = syllabify(pronunciation);
        if (apply_stress(pronunciation, word))
            return NULL;
    }
    else
    {
        strcpy(pronunciation, buffer);
    }
#endif

    [pronunciation appendString:@"%"]; // Word type delimiter.

    // Guess the type of word.
    [pronunciation appendString:(syllableCount == 1) ? GSLTSWordType_Unknown : [self typeOfWord:word]];

    return [pronunciation copy];
}

#pragma mark -

/// Return a word type based on the suffix of a word.
- (NSString *)typeOfWord:(NSString *)word;
{
    for (GSSuffixWordType *suffixWordType in [GSLetterToSound suffixToWordTypes]) {
        if ([word hasSuffix:suffixWordType.suffix])
            return suffixWordType.wordType;
    }

    return GSLTSWordType_Unknown;
}

#pragma mark -

- (NSString *)pronunciationBySpellingWord:(NSString *)word;
{
    NSMutableString *pronunciation = [NSMutableString string];

    NSDictionary *letters = [GSLetterToSound letterPronunciations];
    NSString *unknown = letters[@"unknown"];
    NSParameterAssert(unknown != nil);

    [word enumerateSubstringsInRange:NSMakeRange(0, [word length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        //NSLog(@"substring: '%@', substringRange: %@, enclosingRange: %@", substring, NSStringFromRange(substringRange), NSStringFromRange(enclosingRange));
        NSString *pr = letters[substring];
        if (pr == nil)
            pr = unknown;
        [pronunciation appendString:pr];
        [pronunciation appendString:@" "];
    }];

    return [pronunciation copy];
}

- (NSString *)exceptionPronunciationOfWord:(NSString *)word;
{
    return [[GSLetterToSound wordExceptions] objectForKey:word];
}

// I dunno what a patphone is, but nevertheless...
// Step 4: Preprocess input.
- (NSString *)patPhoneFromWord:(NSString *)word isPronunciation:(BOOL *)isPronunciation;
{
    NSParameterAssert(isPronunciation != NULL);
    NSLog(@"%s, word: '%@'", __PRETTY_FUNCTION__, word);

    if ([word gs_lts_isAllCaps]) {
        NSLog(@"%s, word is all caps", __PRETTY_FUNCTION__);
        *isPronunciation = YES;
        return [self pronunciationBySpellingWord:word];
    }

    word = [word lowercaseString];

    // Step 4(a): Reject a word consisting of one letter or a word without a vowel.
    if ([word length] == 1 || ![word gs_lts_hasVowels]) {
        NSLog(@"%s, word is one character, or has no vowels", __PRETTY_FUNCTION__);
        *isPronunciation = YES;
        return [self pronunciationBySpellingWord:word];
    }

    // Step 1: See if the whole word is in the exception list.
    NSString *pr1 = [self exceptionPronunciationOfWord:word];
    if (pr1 != nil) {
        NSLog(@"%s, word is in exception list", __PRETTY_FUNCTION__);
        *isPronunciation = YES;
        return pr1;
    }

    // Step 2: Map cpitals into small letters, strip punctuation, and try step 1 again.
    // Omitted?  Handled earlier?

    // Step (3): Strip trailing s.  Change final ie to y (regardless of trailing s).  Repeat step 1 if any changes.
    NSMutableString *modifiedWord = [word mutableCopy];

    NSError *error;
    NSRegularExpression *re_4_1a = [[NSRegularExpression alloc] initWithPattern:@"([^us])s$" options:0 error:&error];
    if (re_4_1a == nil) {
        NSLog(@"Error: re_4_1a, %@", error);
        return nil;
    }
    NSRegularExpression *re_4_1b = [[NSRegularExpression alloc] initWithPattern:@"'$" options:0 error:&error];
    if (re_4_1b == nil) {
        NSLog(@"Error: re_4_1b, %@", error);
        return nil;
    }
    NSRegularExpression *re_4_1c = [[NSRegularExpression alloc] initWithPattern:@"ie$" options:0 error:&error];
    if (re_4_1c == nil) {
        NSLog(@"Error: re_4_1c, %@", error);
        return nil;
    }

    // 2014-08-31: I almost think this should be [^cfkpt]'?s$ so that it ignores the apostrophe.
    NSRegularExpression *re_4_1d = [[NSRegularExpression alloc] initWithPattern:@"[^cfkpt]s$" options:0 error:&error];
    if (re_4_1d == nil) {
        NSLog(@"Error: re_4_1d, %@", error);
        return nil;
    }

    // 2014-08-31: The paper is unclear when 4(d) should be checked.
    BOOL hasFinalVoicedS = [re_4_1d firstMatchInString:modifiedWord options:0 range:NSMakeRange(0, [modifiedWord length])] != nil;
    BOOL hasFinalUnvoicedS = !hasFinalVoicedS && [modifiedWord hasSuffix:@"s"];

    NSLog(@"hasFinalVoicedS? %d, hasFinalUnvoicedS? %d", hasFinalVoicedS, hasFinalUnvoicedS);

    [re_4_1a replaceMatchesInString:modifiedWord options:0 withTemplate:@"$1"];
    [re_4_1b replaceMatchesInString:modifiedWord options:0 withTemplate:@""];
    [re_4_1c replaceMatchesInString:modifiedWord options:0 withTemplate:@"y"];

    NSLog(@"modifiedWord: %@", modifiedWord);

    // Repeating step 1, regardless of changes, because it's easier than tracking if there were changes.
    NSString *pr2 = [self exceptionPronunciationOfWord:modifiedWord];
    if (pr2 != nil) {
        NSLog(@"%s, modified word is in exception list", __PRETTY_FUNCTION__);
        *isPronunciation = YES;
        if (hasFinalVoicedS)   return [pr2 stringByAppendingString:@"_z"];
        if (hasFinalUnvoicedS) return [pr2 stringByAppendingString:@"_s"];
        return pr2;
    }


    *isPronunciation = NO;
    return [modifiedWord copy];
}

@end

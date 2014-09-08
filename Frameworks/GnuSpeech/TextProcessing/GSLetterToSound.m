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
- (BOOL)gs_lts_hasVowelsInRange:(NSRange)range;
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

- (BOOL)gs_lts_hasVowelsInRange:(NSRange)range;
{
    NSCharacterSet *vowels = [NSCharacterSet characterSetWithCharactersInString:@"aeiouyAEIOUY"];
    NSRange r1 = [self rangeOfCharacterFromSet:vowels options:0 range:range];
    return r1.location != NSNotFound;
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

static FILE *log_fp = NULL;

- (void)logToFP:(FILE *)fp;
{
    log_fp = fp;
}

- (NSString *)new_pronunciationForWord:(NSString *)word;
{
//    [GSLetterToSound suffixToWordTypes];
//    [GSLetterToSound wordExceptions];
//    [GSLetterToSound letterPronunciations];

//    NSMutableString *str = [NSMutableString stringWithFormat:@"#%@#", word];
    NSMutableString *pronunciation = [[NSMutableString alloc] init];


    NSUInteger syllableCount = 0;

    if (log_fp != NULL) fprintf(log_fp, "%-32s", [word cStringUsingEncoding:NSASCIIStringEncoding]);

    // Preprocess input.  We'll wait before surrounding the word with # -- regular expression ^ and $ should work instead.
    BOOL isPronunciation;
    NSString *s1 = [self patPhoneFromWord:word isPronunciation:&isPronunciation]; // Take the original word.
    if (!isPronunciation) {
        if (log_fp != NULL) fprintf(log_fp, "\t%-50s", [[NSString stringWithFormat:@"#%@#", s1] cStringUsingEncoding:NSASCIIStringEncoding]);
        if (log_fp != NULL) fprintf(log_fp, "\t%s\n", [@"???" cStringUsingEncoding:NSASCIIStringEncoding]);
    } else {
        if (log_fp != NULL) fprintf(log_fp, "\t%-50s\t%s\n", "n/a", [s1 cStringUsingEncoding:NSASCIIStringEncoding]);
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

    NSMutableString *modifiedWord = [word mutableCopy];

    NSString *finalSSuffix;

    // Step (3): Strip trailing s.  Change final ie to y (regardless of trailing s).  Repeat step 1 if any changes.
    {
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

        if (hasFinalVoicedS)   finalSSuffix = @"z";
        if (hasFinalUnvoicedS) finalSSuffix = @"s";

//        NSLog(@"hasFinalVoicedS? %d, hasFinalUnvoicedS? %d", hasFinalVoicedS, hasFinalUnvoicedS);

        [re_4_1a replaceMatchesInString:modifiedWord options:0 withTemplate:@"$1"];
        [re_4_1b replaceMatchesInString:modifiedWord options:0 withTemplate:@""];
        [re_4_1c replaceMatchesInString:modifiedWord options:0 withTemplate:@"y"];
        
//        NSLog(@"modifiedWord: %@", modifiedWord);
    }

    // Repeating step 1, regardless of changes, because it's easier than tracking if there were changes.
    NSString *pr2 = [self exceptionPronunciationOfWord:modifiedWord];
    if (pr2 != nil) {
        NSLog(@"%s, modified word is in exception list", __PRETTY_FUNCTION__);
        *isPronunciation = YES;
        if (finalSSuffix != nil) return [pr2 stringByAppendingFormat:@"_%@", finalSSuffix];
        return pr2;
    }

    // Step 4(b)?
    [self markFinalE:modifiedWord];

    // Step 4(c)
    [self longMedialVowels:modifiedWord];

    // Step 4(d)
    [self medialSilentE:modifiedWord];

    // Step 4(e)
    [self medialS:modifiedWord];

    if (finalSSuffix != nil) [modifiedWord appendString:finalSSuffix];

    *isPronunciation = NO;
    return [modifiedWord copy];
}

/// Mark potential silent 'e's with '|'.  And other stuff from rule 4.3.
- (void)markFinalE:(NSMutableString *)word;
{
    NSError *error;

    // 4.3a: If the final 'e' is the only vowel, replace with 'E'.
    NSRegularExpression *re_4_3a = [[NSRegularExpression alloc] initWithPattern:@"^[^aeiouyAEIOUY]*(e)$" options:0 error:&error];
    NSParameterAssert(re_4_3a != nil);

    {
        NSTextCheckingResult *match = [re_4_3a firstMatchInString:word options:0 range:NSMakeRange(0, [word length])];
        if (match != nil) {
            //[re_4_3a replaceMatchesInString:word options:0 withTemplate:@"$1E"];
            [word replaceCharactersInRange:[match rangeAtIndex:1] withString:@"E"];
            return;
        }
    }

    // This matches the old code, but the paper just says 4.3g needs to be before 4.3b.
    // 4.3g: Look for ^[^aeiouy]*[aeiouy][^aeiouywx](al | le | re | us | y)$
    //       if found, change     ------   to upper case.
    // TODO: (2014-09-07) Just lowercase vowels?
    NSRegularExpression *re_4_3g = [[NSRegularExpression alloc] initWithPattern:@"^[^aeiouy]*([aeiouy])[^aeiouywx](al|le|re|us|y)$" options:0 error:&error];
    NSParameterAssert(re_4_3g != nil);
    {
        NSTextCheckingResult *match = [re_4_3g firstMatchInString:word options:0 range:NSMakeRange(0, [word length])];
        if (match != nil)  {
            NSRange r1 = [match rangeAtIndex:1];
            [word replaceCharactersInRange:r1 withString:[[word substringWithRange:r1] uppercaseString]];
        }
    }

    // 4.3a continued... should move 4.3g above.
    NSArray *suffixes1 = @[ @"able", @"ably", @"ed", @"en", @"er", @"ery", @"est", @"ey", @"ing", @"less", @"ly", @"ment", @"ness", @"or", @"ful" ];
    BOOL hasReplacedSuffix = NO;
    NSRange searchRange = NSMakeRange(0, [word length]);
    do {
        //NSLog(@"--> searching: %@", [word substringWithRange:searchRange]);
        hasReplacedSuffix = NO;
        for (NSString *str in suffixes1) {
            NSRange r1 = [word rangeOfString:str options:NSAnchoredSearch|NSBackwardsSearch range:searchRange];
            //NSLog(@"suffix: %@, r1: %@", str, NSStringFromRange(r1));
            if (r1.location != NSNotFound && [word gs_lts_hasVowelsInRange:NSMakeRange(0, r1.location)]) {
                if ([str hasPrefix:@"e"]) {
                    [word insertString:@"|" atIndex:r1.location + 1];
                } else {
                    [word insertString:@"|" atIndex:r1.location];
                }
                //NSLog(@"word is now: %@", word);
                searchRange.length = r1.location;
                hasReplacedSuffix = YES;
                break;
            }
        }
    } while (hasReplacedSuffix);

    NSArray *suffixes2 = @[ @"ic", @"ical" ];
    for (NSString *str in suffixes2) {
        NSRange r1 = [word rangeOfString:str options:NSAnchoredSearch|NSBackwardsSearch range:searchRange];
        if (r1.location != NSNotFound && [word gs_lts_hasVowelsInRange:NSMakeRange(0, r1.location)]) {
            [word insertString:@"|" atIndex:r1.location];
            searchRange.length = r1.location;
            return; // And final 'e' processing ends.
        }
    }

    // Lastly, 'e' itself is located and marked under the same proviso.  However 'e' before 'e', as in 'indeed' is
    // not marked, and termiates final 'e' processing.

    NSRange endingRange = NSMakeRange(searchRange.length, [word length] - searchRange.length);

    NSRegularExpression *re_4_3a2 = [[NSRegularExpression alloc] initWithPattern:@"e$" options:0 error:&error];
    NSParameterAssert(re_4_3a2 != nil);

    {
        NSTextCheckingResult *beginningEndsWithE = [re_4_3a2 firstMatchInString:word options:0 range:searchRange];
        if (beginningEndsWithE != nil) {
            NSRegularExpression *re_4_3a3 = [[NSRegularExpression alloc] initWithPattern:@"^e" options:0 error:&error];
            NSParameterAssert(re_4_3a3 != nil);
            NSTextCheckingResult *endingStartsWithE = [re_4_3a3 firstMatchInString:word options:0 range:endingRange];
            if (endingStartsWithE != nil) {
                // Terminate without marking.
                return;
            }

            if (endingRange.length == 0) {
                [word appendString:@"|"];
                endingRange.location -= 1;
                endingRange.length += 2;
                searchRange.length -= 1;
                NSParameterAssert(endingRange.location >= 0);
            }
        }
    }

    // 4.3b:

}

- (void)longMedialVowels:(NSMutableString *)word;
{
}

- (void)medialSilentE:(NSMutableString *)word;
{
}

- (void)medialS:(NSMutableString *)word;
{
}

@end

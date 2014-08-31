//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "GSLetterToSound.h"

#import "letter_to_sound.h"
#import "GSSuffixWordType.h"

static NSString *GSLTSWordType_Unknown = @"j";


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
    NSMutableString *str = [NSMutableString stringWithFormat:@"#%@#", word];
    NSMutableString *pronunciation = [[NSMutableString alloc] init];

    [GSLetterToSound suffixToWordTypes];
    [GSLetterToSound wordExceptions];
    [GSLetterToSound letterPronunciations];

    NSUInteger syllableCount = 0;

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

@end

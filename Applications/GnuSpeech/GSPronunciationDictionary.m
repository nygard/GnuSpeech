//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "GSPronunciationDictionary.h"

#import <Foundation/Foundation.h>
#import "GSSuffix.h"

@implementation GSPronunciationDictionary

+ (GSPronunciationDictionary *)mainDictionary;
{
    static GSPronunciationDictionary *_mainDictionary = nil;

    if (_mainDictionary == nil) {
        NSString *path;

        _mainDictionary = [[GSPronunciationDictionary alloc] init];
        path = [[NSBundle bundleForClass:self] pathForResource:@"2.0eMainDictionary" ofType:@"dict"];
        [_mainDictionary readFile:path];
    }

    return _mainDictionary;
}

- (id)init;
{
    NSBundle *bundle;
    NSString *path;

    if ([super init] == nil)
        return nil;

    pronunciations = [[NSMutableDictionary alloc] init]; // This is a case where setting the capacity might be a good idea!
    suffixOrder = [[NSMutableArray alloc] init];
    suffixes = [[NSMutableDictionary alloc] init];

    bundle = [NSBundle bundleForClass:[self class]];
    path = [bundle pathForResource:@"TTSSuffixList" ofType:@"txt"];
    [self _readSuffixesFromFile:path];

    return self;
}

- (void)dealloc;
{
    [pronunciations release];
    [suffixOrder release];
    [suffixes release];

    [super dealloc];
}

- (void)readFile:(NSString *)filename;
{
    NSData *data;
    NSString *str;
    NSArray *lines;
    unsigned int count, index;

    NSLog(@" > %s", _cmd);

    data = [[NSData alloc] initWithContentsOfFile:filename];
    NSLog(@"data: %p", data);
    //str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]; // utf-8 fails
    str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSLog(@"str: %p", str);
    NSLog(@"str length: %d", [str length]);
    lines = [str componentsSeparatedByString:@"\n"];

    count = [lines count];
    NSLog(@"lines: %d", count);
    for (index = 0; index < count; index++) {
        NSString *line;
        NSArray *parts;

        line = [lines objectAtIndex:index];
        if ([line hasPrefix:@" "] == YES)
            continue;

        parts = [line componentsSeparatedByString:@" "];
        if ([parts count] >= 2) {
            NSString *key, *value, *partOfSpeech, *wordType;
            NSRange range;

            key = [parts objectAtIndex:0];
            value = [parts objectAtIndex:1];
            partOfSpeech = nil;

            range = [key rangeOfString:@"/"];
            if (range.location != NSNotFound) {
                partOfSpeech = [key substringFromIndex:NSMaxRange(range)];
                key = [key substringToIndex:range.location];
            }

            range = [value rangeOfString:@"%"];
            if (range.location != NSNotFound) {
                wordType = [value substringFromIndex:NSMaxRange(range)];
                value = [value substringToIndex:range.location];
            }

            //NSLog(@"word: %@, partOfSpeech: %@, pronunciation: %@, wordType: %@", key, partOfSpeech, value, wordType);
            [pronunciations setObject:value forKey:key];
        }
    }

    NSLog(@"pronunciation count: %d", [[pronunciations allKeys] count]);

    [str release];
    [data release];

    NSLog(@"<  %s", _cmd);
}

- (void)_readSuffixesFromFile:(NSString *)filename;
{
    NSData *data;
    NSString *str;
    NSArray *lines;
    unsigned int count, index;

    NSLog(@" > %s", _cmd);

    data = [[NSData alloc] initWithContentsOfFile:filename];
    NSLog(@"data: %p", data);
    //str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]; // utf-8 fails
    str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    lines = [str componentsSeparatedByString:@"\n"];

    count = [lines count];
    NSLog(@"lines: %d", count);
    for (index = 0; index < count; index++) {
        NSString *line;
        NSArray *parts;

        line = [lines objectAtIndex:index];
        if ([line hasPrefix:@"#"] == YES)
            continue;

        parts = [line componentsSeparatedByString:@"\t"];
        if ([parts count] >= 3) {
            GSSuffix *newSuffix;

            newSuffix = [[GSSuffix alloc] initWithSuffix:[parts objectAtIndex:0]
                                          replacementString:[parts objectAtIndex:1]
                                          appendedPronunciation:[parts objectAtIndex:2]];
            //NSLog(@"newSuffix: %@", newSuffix);
            [suffixOrder addObject:[newSuffix suffix]];
            [suffixes setObject:newSuffix forKey:[newSuffix suffix]];
            [newSuffix release];
        }
    }

    NSLog(@"Read %d suffixes.", [suffixOrder count]);

    NSLog(@"<  %s", _cmd);
}

- (NSString *)pronunciationForWord:(NSString *)aWord;
{
    NSString *pronunciation;

    pronunciation = [pronunciations objectForKey:aWord];
    if (pronunciation == nil) {
        unsigned int count, index;

        count = [suffixOrder count];
        for (index = 0; index < count; index++) {
            GSSuffix *suffix;
            NSRange range;

            suffix = [suffixes objectForKey:[suffixOrder objectAtIndex:index]];
            range = [aWord rangeOfString:[suffix suffix] options:NSAnchoredSearch|NSBackwardsSearch];
            if (range.location != NSNotFound) {
                NSString *newWord;
                NSString *newPronunciation;

                newWord = [[aWord substringToIndex:range.location] stringByAppendingString:[suffix replacementString]];
                newPronunciation = [pronunciations objectForKey:newWord];
                //NSLog(@"newWord: %@, newPronunciation: %@", newWord, newPronunciation);
                if (newPronunciation != nil)
                    return [newPronunciation stringByAppendingString:[suffix appendedPronunciation]];
            }
        }
    }

    return pronunciation;
}

- (void)testString:(NSString *)str;
{
    NSArray *words;
    unsigned int count, index;

    //NSLog(@" > %s", _cmd);

    words = [str componentsSeparatedByString:@" "];
    count = [words count];
    for (index = 0; index < count; index++) {
        NSString *word, *pronunciation;

        word = [[words objectAtIndex:index] lowercaseString];
        pronunciation = [self pronunciationForWord:word];
        NSLog(@"word: %@, pronunciation: %@", word, pronunciation);
    }

    //NSLog(@"<  %s", _cmd);
}

@end

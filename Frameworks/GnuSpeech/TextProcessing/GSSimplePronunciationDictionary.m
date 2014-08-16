//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "GSSimplePronunciationDictionary.h"

#import "GSSuffix.h"

@implementation GSSimplePronunciationDictionary
{
    NSMutableDictionary *_pronunciations;
}

+ (id)mainDictionary;
{
    static GSSimplePronunciationDictionary *_mainDictionary;

    if (_mainDictionary == nil) {
        NSString *path = [[NSBundle bundleForClass:self] pathForResource:@"2.0eMainDictionary" ofType:@"dict"];
        _mainDictionary = [[GSSimplePronunciationDictionary alloc] initWithFilename:path];
    }

    return _mainDictionary;
}

+ (id)specialAcronymDictionary;
{
    static GSSimplePronunciationDictionary *_dictionary;

    if (_dictionary == nil) {
        NSString *path = [[NSBundle bundleForClass:self] pathForResource:@"SpecialAcronyms" ofType:@"dict"];
        _dictionary = [[GSSimplePronunciationDictionary alloc] initWithFilename:path];
    }

    return _dictionary;
}

- (id)initWithFilename:(NSString *)filename;
{
    if ((self = [super initWithFilename:filename])) {
        _pronunciations = [[NSMutableDictionary alloc] init]; // This is a case where setting the capacity might be a good idea!
    }

    return self;
}

#pragma mark -

- (NSDate *)modificationDate;
{
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.filename error:NULL];
    return [attributes fileModificationDate];
}

- (BOOL)loadDictionary;
{
    NSData *data = [[NSData alloc] initWithContentsOfFile:self.filename];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]; // UTF-8 fails.
    NSArray *lines = [str componentsSeparatedByString:@"\n"];

    [lines enumerateObjectsUsingBlock:^(NSString *line, NSUInteger index, BOOL *stop) {
        if (index == 0) {
            self.version = [line substringFromIndex:1];
        } else {
            NSArray *parts = [line componentsSeparatedByString:@" "];
            if ([parts count] >= 2) {
                NSString *key = parts[0];
                NSString *value = parts[1];
                //NSString *partOfSpeech = nil;
                //NSString *wordType = nil;

                NSRange range = [key rangeOfString:@"/"];
                if (range.location != NSNotFound) {
                    //partOfSpeech = [key substringFromIndex:NSMaxRange(range)];
                    key = [key substringToIndex:range.location];
                }

                range = [value rangeOfString:@"%"];
                if (range.location != NSNotFound) {
                    //wordType = [value substringFromIndex:NSMaxRange(range)];
                    value = [value substringToIndex:range.location];
                }

                //NSLog(@"word: %@, partOfSpeech: %@, pronunciation: %@, wordType: %@", key, partOfSpeech, value, wordType);
                // Keep the first pronunciation, since that's supposed to be the most common.
                if (_pronunciations[key] == nil) {
                    _pronunciations[key] = value;
                } else {
                    //NSLog(@"Warning: Already have a value for %@", key);
                }
            }
        }
    }];

    //NSLog(@"pronunciation count: %d", [[pronunciations allKeys] count]);

    NSLog(@"%s, self: %@", __PRETTY_FUNCTION__, self);

    return YES;
}

- (NSDictionary *)pronunciations;
{
    [self loadDictionaryIfNecessary];
    return _pronunciations;
}

- (NSString *)lookupPronunciationForWord:(NSString *)word;
{
    [self loadDictionaryIfNecessary];
    return [_pronunciations objectForKey:word];
}

@end

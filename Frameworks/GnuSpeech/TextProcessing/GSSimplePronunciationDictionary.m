//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "GSSimplePronunciationDictionary.h"

#import <Foundation/Foundation.h>
#import "GSSuffix.h"

@implementation GSSimplePronunciationDictionary

+ (id)mainDictionary;
{
    static GSSimplePronunciationDictionary *_mainDictionary = nil;

    if (_mainDictionary == nil) {
        NSString *path;

        path = [[NSBundle bundleForClass:self] pathForResource:@"2.0eMainDictionary" ofType:@"dict"];
        _mainDictionary = [[GSSimplePronunciationDictionary alloc] initWithFilename:path];
    }

    return _mainDictionary;
}

- (id)initWithFilename:(NSString *)aFilename;
{
    if ([super initWithFilename:aFilename] == nil)
        return nil;

    pronunciations = [[NSMutableDictionary alloc] init]; // This is a case where setting the capacity might be a good idea!

    return self;
}

- (void)dealloc;
{
    [pronunciations release];

    [super dealloc];
}

- (NSDate *)modificationDate;
{
    NSDictionary *attributes;

    attributes = [[NSFileManager defaultManager] fileAttributesAtPath:filename traverseLink:YES];
    return [attributes fileModificationDate];
}

- (BOOL)loadDictionary;
{
    NSData *data;
    NSString *str;
    NSArray *lines;
    unsigned int count, index;

    data = [[NSData alloc] initWithContentsOfFile:filename];
    //NSLog(@"data: %p", data);
    //str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]; // utf-8 fails
    str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    //NSLog(@"str: %p", str);
    //NSLog(@"str length: %d", [str length]);
    lines = [str componentsSeparatedByString:@"\n"];

    count = [lines count];
    if (count > 0)
        [self setVersion:[[lines objectAtIndex:0] substringFromIndex:1]];

    //NSLog(@"lines: %d", count);
    for (index = 1; index < count; index++) {
        NSString *line;
        NSArray *parts;

        line = [lines objectAtIndex:index];
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
            // Keep the first pronunciation, since that's supposed to be the most common.
            if ([pronunciations objectForKey:key] == nil) {
                [pronunciations setObject:value forKey:key];
            } else {
                //NSLog(@"Warning: Already have a value for %@", key);
            }
        }
    }

    //NSLog(@"pronunciation count: %d", [[pronunciations allKeys] count]);

    [str release];
    [data release];

    NSLog(@"%s, self: %@", _cmd, self);


    return YES;
}

- (NSDictionary *)pronunciations;
{
    [self loadDictionaryIfNecessary];
    return pronunciations;
}

- (NSString *)lookupPronunciationForWord:(NSString *)aWord;
{
    [self loadDictionaryIfNecessary];
    return [pronunciations objectForKey:aWord];
}

@end

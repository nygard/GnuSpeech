//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "GSSimplePronunciationDictionary.h"

#import "GSSuffix.h"

@implementation GSSimplePronunciationDictionary
{
    NSMutableDictionary *_pronunciations;
}

+ (id)mainDictionary;
{
    static GSSimplePronunciationDictionary *_mainDictionary = nil;

    if (_mainDictionary == nil) {
        NSString *path = [[NSBundle bundleForClass:self] pathForResource:@"2.0eMainDictionary" ofType:@"dict"];
        _mainDictionary = [[GSSimplePronunciationDictionary alloc] initWithFilename:path];
    }

    return _mainDictionary;
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
    NSDictionary *attributes;

    attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.filename error:NULL];
    return [attributes fileModificationDate];
}

- (BOOL)loadDictionary;
{
    NSUInteger count, index;

    NSData *data = [[NSData alloc] initWithContentsOfFile:self.filename];
    //NSLog(@"data: %p", data);
    //str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]; // utf-8 fails
    NSString *str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    //NSLog(@"str: %p", str);
    //NSLog(@"str length: %d", [str length]);
    NSArray *lines = [str componentsSeparatedByString:@"\n"];

    count = [lines count];
    if (count > 0)
        [self setVersion:[[lines objectAtIndex:0] substringFromIndex:1]];

    //NSLog(@"lines: %d", count);
    for (index = 1; index < count; index++) {
        NSString *line = [lines objectAtIndex:index];
        NSArray *parts = [line componentsSeparatedByString:@" "];
        if ([parts count] >= 2) {
            NSString *key = [parts objectAtIndex:0];
            NSString *value = [parts objectAtIndex:1];
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
            if ([_pronunciations objectForKey:key] == nil) {
                [_pronunciations setObject:value forKey:key];
            } else {
                //NSLog(@"Warning: Already have a value for %@", key);
            }
        }
    }

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

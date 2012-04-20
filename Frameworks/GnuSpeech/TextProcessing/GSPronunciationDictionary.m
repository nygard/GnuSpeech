//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "GSPronunciationDictionary.h"

#import <Foundation/Foundation.h>
#import "GSSuffix.h"

@implementation GSPronunciationDictionary

+ (id)mainDictionary;
{
    return nil;
}

- (id)initWithFilename:(NSString *)aFilename;
{
    NSBundle *bundle;
    NSString *path;

    if ([super init] == nil)
        return nil;

    filename = [aFilename retain];
    NSLog(@"filename: %@", filename);
    version = nil;

    suffixOrder = [[NSMutableArray alloc] init];
    suffixes = [[NSMutableDictionary alloc] init];

    bundle = [NSBundle bundleForClass:[self class]];
    path = [bundle pathForResource:@"TTSSuffixList" ofType:@"txt"];
    [self _readSuffixesFromFile:path];

    hasBeenLoaded = NO;

    return self;
}

- (void)dealloc;
{
    [filename release];
    [version release];
    [suffixOrder release];
    [suffixes release];

    [super dealloc];
}

- (NSString *)filename;
{
    return filename;
}

- (NSString *)version;
{
    [self loadDictionaryIfNecessary];

    return version;
}

- (void)setVersion:(NSString *)newVersion;
{
    if (newVersion == version)
        return;

    [version release];
    version = [newVersion retain];
}

- (NSDate *)modificationDate;
{
    return nil;
}

- (void)loadDictionaryIfNecessary;
{
    if (hasBeenLoaded == NO) {
        hasBeenLoaded = [self loadDictionary];
        NSLog(@"%s, hasBeenLoaded: %d", __PRETTY_FUNCTION__, hasBeenLoaded);
    }
}

- (BOOL)loadDictionary;
{
    // Implement in subclases
    return NO;
}

- (void)_readSuffixesFromFile:(NSString *)aFilename;
{
    NSData *data;
    NSString *str;
    NSArray *lines;
    NSUInteger count, index;

    NSLog(@" > %s", __PRETTY_FUNCTION__);

    data = [[NSData alloc] initWithContentsOfFile:aFilename];
    NSLog(@"data: %p", data);
    //str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]; // utf-8 fails
    str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    lines = [str componentsSeparatedByString:@"\n"];

    count = [lines count];
    NSLog(@"lines: %lu", count);
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

    NSLog(@"Read %lu suffixes.", [suffixOrder count]);

    NSLog(@"<  %s", __PRETTY_FUNCTION__);
}

- (NSString *)lookupPronunciationForWord:(NSString *)aWord;
{
    // Implement in subclasses
    return nil;
}

- (NSString *)pronunciationForWord:(NSString *)aWord;
{
    NSString *pronunciation;

    pronunciation = [self lookupPronunciationForWord:aWord];
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
                newPronunciation = [self lookupPronunciationForWord:newWord];
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
    NSUInteger count, index;

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

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: suffix count: %d, version: %@", NSStringFromClass([self class]), self, [suffixOrder count], version];
}

@end

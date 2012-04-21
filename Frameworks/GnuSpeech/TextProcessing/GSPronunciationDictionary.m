//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "GSPronunciationDictionary.h"

#import "GSSuffix.h"

@implementation GSPronunciationDictionary
{
    NSString *m_filename;
    NSString *version;
    
    NSMutableArray *suffixOrder;
    NSMutableDictionary *suffixes;
    
    BOOL hasBeenLoaded;
}

+ (id)mainDictionary;
{
    return nil;
}

- (id)initWithFilename:(NSString *)aFilename;
{
    if ((self = [super init])) {
        m_filename = [aFilename retain];
        NSLog(@"filename: %@", m_filename);
        version = nil;
        
        suffixOrder = [[NSMutableArray alloc] init];
        suffixes = [[NSMutableDictionary alloc] init];
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSString *path = [bundle pathForResource:@"TTSSuffixList" ofType:@"txt"];
        [self _readSuffixesFromFile:path];
        
        hasBeenLoaded = NO;
    }

    return self;
}

- (void)dealloc;
{
    [m_filename release];
    [version release];
    [suffixOrder release];
    [suffixes release];

    [super dealloc];
}

@synthesize filename = m_filename;

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
    NSUInteger count, index;

    NSLog(@" > %s", __PRETTY_FUNCTION__);

    NSData *data = [[NSData alloc] initWithContentsOfFile:aFilename];
    NSLog(@"data: %p", data);
    //str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]; // utf-8 fails
    NSString *str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSArray *lines = [str componentsSeparatedByString:@"\n"];

    count = [lines count];
    NSLog(@"lines: %lu", count);
    for (index = 0; index < count; index++) {
        NSString *line = [lines objectAtIndex:index];
        if ([line hasPrefix:@"#"] == YES)
            continue;

        NSArray *parts = [line componentsSeparatedByString:@"\t"];
        if ([parts count] >= 3) {
            GSSuffix *newSuffix = [[GSSuffix alloc] initWithSuffix:[parts objectAtIndex:0]
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
    NSString *pronunciation = [self lookupPronunciationForWord:aWord];
    if (pronunciation == nil) {
        NSUInteger count, index;

        count = [suffixOrder count];
        for (index = 0; index < count; index++) {
            GSSuffix *suffix = [suffixes objectForKey:[suffixOrder objectAtIndex:index]];
            NSRange range = [aWord rangeOfString:[suffix suffix] options:NSAnchoredSearch|NSBackwardsSearch];
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
    NSUInteger count, index;

    //NSLog(@" > %s", _cmd);

    NSArray *words = [str componentsSeparatedByString:@" "];
    count = [words count];
    for (index = 0; index < count; index++) {
        NSString *word = [[words objectAtIndex:index] lowercaseString];
        NSString *pronunciation = [self pronunciationForWord:word];
        NSLog(@"word: %@, pronunciation: %@", word, pronunciation);
    }

    //NSLog(@"<  %s", _cmd);
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: suffix count: %lu, version: %@", NSStringFromClass([self class]), self, [suffixOrder count], version];
}

@end

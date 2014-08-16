//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "GSPronunciationDictionary.h"

#import "GSSuffix.h"

@implementation GSPronunciationDictionary
{
    NSString *_filename;
    NSString *_version;

    NSMutableArray *_suffixOrder;   // Strings.
    NSMutableDictionary *_suffixes; // Keyed by string, value is GSSuffix.

    BOOL _hasBeenLoaded;
}

- (id)initWithFilename:(NSString *)filename;
{
    if ((self = [super init])) {
        _filename = filename;
        _version = nil;
        
        _suffixOrder = [[NSMutableArray alloc] init];
        _suffixes = [[NSMutableDictionary alloc] init];
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSString *path = [bundle pathForResource:@"TTSSuffixList" ofType:@"txt"];
        [self _readSuffixesFromFile:path];
        
        _hasBeenLoaded = NO;
    }

    return self;
}

#pragma mark - Debugging

- (NSString *)description;
{
    if (_hasBeenLoaded) {
        return [NSString stringWithFormat:@"<%@: %p> filename: %@, suffix count: %lu, version: %@",
                NSStringFromClass([self class]), self,
                self.filename, [_suffixOrder count], self.version];
    }

    return [NSString stringWithFormat:@"<%@: %p> filename: %@, not loaded",
            NSStringFromClass([self class]), self,
            self.filename];
}

#pragma mark -

- (NSString *)version;
{
    [self loadDictionaryIfNecessary];

    return _version;
}

- (NSDate *)modificationDate;
{
    return nil;
}

- (void)loadDictionaryIfNecessary;
{
    if (_hasBeenLoaded == NO) {
        _hasBeenLoaded = [self loadDictionary];
    }
}

- (BOOL)loadDictionary;
{
    // Implement in subclases.
    return NO;
}

- (void)_readSuffixesFromFile:(NSString *)filename;
{
    //NSLog(@" > %s", __PRETTY_FUNCTION__);

    NSData *data = [[NSData alloc] initWithContentsOfFile:filename];
    //NSLog(@"data: %p", data);
    //str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]; // utf-8 fails
    NSString *str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSArray *lines = [str componentsSeparatedByString:@"\n"];

    for (NSString *line in lines) {
        if ([line hasPrefix:@"#"])
            continue;

        NSArray *parts = [line componentsSeparatedByString:@"\t"];
        if ([parts count] >= 3) {
            GSSuffix *newSuffix = [[GSSuffix alloc] initWithSuffix:parts[0]
                                                 replacementString:parts[1]
                                             appendedPronunciation:parts[2]];
            //NSLog(@"newSuffix: %@", newSuffix);
            [_suffixOrder addObject:newSuffix.suffix];
            _suffixes[newSuffix.suffix] = newSuffix;
        }
    }

    //NSLog(@"Read %lu suffixes.", [suffixOrder count]);

    //NSLog(@"<  %s", __PRETTY_FUNCTION__);
}

- (NSString *)lookupPronunciationForWord:(NSString *)word;
{
    // Implement in subclasses
    return nil;
}

- (NSString *)pronunciationForWord:(NSString *)word;
{
    NSString *pronunciation = [self lookupPronunciationForWord:word];
    if (pronunciation == nil) {
        for (NSString *suffixOrderKey in _suffixOrder) {
            GSSuffix *suffix = _suffixes[suffixOrderKey];
            NSRange range = [word rangeOfString:suffix.suffix options:NSAnchoredSearch|NSBackwardsSearch];
            if (range.location != NSNotFound) {
                NSString *newWord = [[word substringToIndex:range.location] stringByAppendingString:suffix.replacementString];
                NSString *newPronunciation = [self lookupPronunciationForWord:newWord];
                //NSLog(@"newWord: %@, newPronunciation: %@", newWord, newPronunciation);
                if (newPronunciation != nil)
                    return [newPronunciation stringByAppendingString:suffix.appendedPronunciation];
            }
        }
    }

    return pronunciation;
}

- (void)testString:(NSString *)str;
{
    //NSLog(@" > %s", _cmd);

    NSArray *words = [[str lowercaseString] componentsSeparatedByString:@" "];
    for (NSString *word in words) {
        NSString *pronunciation = [self pronunciationForWord:word];
        NSLog(@"word: %@, pronunciation: %@", word, pronunciation);
    }

    //NSLog(@"<  %s", _cmd);
}

@end

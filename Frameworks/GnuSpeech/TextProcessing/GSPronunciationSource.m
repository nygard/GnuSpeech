//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "GSPronunciationSource.h"

@implementation GSPronunciationSource

- (NSString *)pronunciationForWord:(NSString *)word;
{
    // Implement in subclasses.
    return nil;
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

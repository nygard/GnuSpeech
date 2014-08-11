//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMTextToPhone.h"

#import "GSDBMPronunciationDictionary.h"
#import "TTSParser.h"

@interface MMTextToPhone ()
@property (readonly) GSPronunciationDictionary *pronunciationDictionary;
@end

#pragma mark -

@implementation MMTextToPhone
{
    GSPronunciationDictionary *_pronunciationDictionary;
}

- (id)init;
{
    return [self initWithPronunciationDictionary:[GSDBMPronunciationDictionary mainDictionary]];
}

- (id)initWithPronunciationDictionary:(GSPronunciationDictionary *)pronunciationDictionary;
{
    if ((self = [super init])) {
        _pronunciationDictionary = pronunciationDictionary;
        [_pronunciationDictionary loadDictionaryIfNecessary];
    }

    return self;
}

- (NSString *)phoneStringFromText:(NSString *)text;
{
    NSString *inputString = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    TTSParser *parser = [[TTSParser alloc] initWithPronunciationDictionary:self.pronunciationDictionary];
    NSString *resultString = [parser parseString:inputString];

    return resultString;	
}

@end

//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <GnuSpeech/GnuSpeech.h>

/// This implements the rules described in "Synthetic English Speech by Rule", by M. Douglas McIlroy,
/// Technical Report CSTR 14, Bell Telephone Laboratories.
///
/// Currently it is unclear if it is the 1973, 1974, or 1977 version that is implemented.

@interface GSLetterToSound : GSPronunciationSource

// Just for testing right now.
- (NSString *)new_pronunciationForWord:(NSString *)word;
- (void)logToFP:(FILE *)fp;

- (NSString *)pronunciationBySpellingWord:(NSString *)word;

// Testing:
- (void)markFinalE:(NSMutableString *)word;

@end

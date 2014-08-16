//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

@interface GSPronunciationDictionary (Private)

// Just lookup the pronunciation in the dictionary.  Implemented by subclasses.
- (NSString *)_pronunciationForWord:(NSString *)word;

/// Return YES if the dictionary was loaded, NO otherwise.  Implemented by subclasses.
- (BOOL)loadDictionary;

@end

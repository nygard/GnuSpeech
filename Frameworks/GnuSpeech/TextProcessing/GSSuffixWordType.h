//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

@interface GSSuffixWordType : NSObject

- (id)initWithSuffix:(NSString *)suffix wordType:(NSString *)wordType;

@property (readonly) NSString *suffix;
@property (readonly) NSString *wordType;

@end

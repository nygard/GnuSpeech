//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

@class MMParameter;

@interface MMDisplayParameter : NSObject

- (id)initWithParameter:(MMParameter *)aParameter;
- (void)dealloc;

- (MMParameter *)parameter;

- (BOOL)isSpecial;
- (void)setIsSpecial:(BOOL)newFlag;

- (NSUInteger)tag;
- (void)setTag:(NSUInteger)newTag;

- (BOOL)shouldDisplay;
- (void)setShouldDisplay:(BOOL)newFlag;
- (void)toggleShouldDisplay;

- (NSString *)name;
- (NSString *)label;

@end

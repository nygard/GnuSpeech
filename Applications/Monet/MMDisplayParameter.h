//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/NSObject.h>

@class MMParameter;

@interface MMDisplayParameter : NSObject
{
    MMParameter *parameter;
    BOOL isSpecial;
    int tag;
    BOOL shouldDisplay;
}

- (id)initWithParameter:(MMParameter *)aParameter;
- (void)dealloc;

- (MMParameter *)parameter;

- (BOOL)isSpecial;
- (void)setIsSpecial:(BOOL)newFlag;

- (int)tag;
- (void)setTag:(int)newTag;

- (BOOL)shouldDisplay;
- (void)setShouldDisplay:(BOOL)newFlag;
- (void)toggleShouldDisplay;

- (NSString *)name;
- (NSString *)label;

@end

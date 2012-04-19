//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/NSObject.h>

@interface GSSuffix : NSObject
{
    NSString *suffix;
    NSString *replacementString;
    NSString *appendedPronunciation;
}

- (id)initWithSuffix:(NSString *)aSuffix replacementString:(NSString *)aReplacementString appendedPronunciation:(NSString *)anAppendedPronunciation;
- (void)dealloc;

- (NSString *)suffix;
- (NSString *)replacementString;
- (NSString *)appendedPronunciation;

- (NSString *)description;

@end

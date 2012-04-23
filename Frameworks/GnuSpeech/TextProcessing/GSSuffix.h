//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

@interface GSSuffix : NSObject

- (id)initWithSuffix:(NSString *)aSuffix replacementString:(NSString *)aReplacementString appendedPronunciation:(NSString *)anAppendedPronunciation;

- (NSString *)suffix;
- (NSString *)replacementString;
- (NSString *)appendedPronunciation;

@end

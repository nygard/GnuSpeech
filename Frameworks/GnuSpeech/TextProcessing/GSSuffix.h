//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

@interface GSSuffix : NSObject

- (id)initWithSuffix:(NSString *)suffix replacementString:(NSString *)replacementString appendedPronunciation:(NSString *)appendedPronunciation;

- (NSString *)suffix;
- (NSString *)replacementString;
- (NSString *)appendedPronunciation;

@end

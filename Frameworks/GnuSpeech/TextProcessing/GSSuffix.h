//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

@interface GSSuffix : NSObject

- (id)initWithSuffix:(NSString *)suffix replacementString:(NSString *)replacementString appendedPronunciation:(NSString *)appendedPronunciation;

@property (readonly) NSString *suffix;
@property (readonly) NSString *replacementString;
@property (readonly) NSString *appendedPronunciation;

@end

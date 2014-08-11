//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-1998, 2000-2001, 2004  Steve Nygard

#import <Foundation/Foundation.h>

@interface NSString (CDExtensions)

+ (NSString *)stringWithFileSystemRepresentation:(const char *)str;
+ (NSString *)spacesIndentedToLevel:(NSUInteger)level;
+ (NSString *)spacesIndentedToLevel:(NSUInteger)level spacesPerLevel:(NSUInteger)spacesPerLevel;
+ (NSString *)spacesOfLength:(NSUInteger)targetLength;
+ (NSString *)stringWithUnichar:(unichar)character;

- (BOOL)isFirstLetterUppercase;
- (BOOL)hasPrefix:(NSString *)aString ignoreCase:(BOOL)shouldIgnoreCase;

+ (NSString *)stringWithASCIICString:(const char *)bytes;

- (NSString *)leftJustifiedStringPaddedToLength:(NSUInteger)paddedLength;
- (NSString *)rightJustifiedStringPaddedToLength:(NSUInteger)paddedLength;

- (BOOL)startsWithLetter;
- (BOOL)isAllUpperCase;
- (BOOL)containsPrimaryStress;
- (NSString *)convertedStress;

- (NSString *)stringByReplacingCharactersInSet:(NSCharacterSet *)set withString:(NSString *)str;

@end

@interface NSMutableString (Extensions)

- (void)indentToLevel:(NSUInteger)level;

@end

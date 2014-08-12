//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-1998, 2000-2001, 2004  Steve Nygard

#import <Foundation/Foundation.h>

@interface NSScanner (CDExtensions)

+ (NSCharacterSet *)gsBooleanIdentifierCharacterSet;

- (NSString *)peekCharacter;
- (unichar)peekChar;
- (NSString *)remainingString;
- (BOOL)scanCharacter:(unichar *)value;
- (BOOL)scanCharacterIntoString:(NSString **)value;
- (BOOL)scanCharacterFromString:(NSString *)aString intoString:(NSString **)value;
- (BOOL)scanCharacterFromSet:(NSCharacterSet *)set intoString:(NSString **)value;
- (BOOL)my_scanCharactersFromSet:(NSCharacterSet *)set intoString:(NSString **)value;

- (BOOL)scanIdentifierIntoString:(NSString **)stringPointer;

@end

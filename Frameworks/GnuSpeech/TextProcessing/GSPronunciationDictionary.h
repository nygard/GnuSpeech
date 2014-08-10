//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

@interface GSPronunciationDictionary : NSObject

+ (id)mainDictionary;

- (id)initWithFilename:(NSString *)filename;

@property (readonly) NSString *filename;

- (NSString *)version;
- (void)setVersion:(NSString *)newVersion;

- (NSDate *)modificationDate;

- (void)loadDictionaryIfNecessary;
- (BOOL)loadDictionary;

- (NSString *)lookupPronunciationForWord:(NSString *)word;
- (NSString *)pronunciationForWord:(NSString *)word;

- (void)testString:(NSString *)str;

@end

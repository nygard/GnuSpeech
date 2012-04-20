//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

@interface GSPronunciationDictionary : NSObject

+ (id)mainDictionary;

- (id)initWithFilename:(NSString *)aFilename;
- (void)dealloc;

@property (readonly) NSString *filename;

- (NSString *)version;
- (void)setVersion:(NSString *)newVersion;

- (NSDate *)modificationDate;

- (void)loadDictionaryIfNecessary;
- (BOOL)loadDictionary;

- (void)_readSuffixesFromFile:(NSString *)aFilename;

- (NSString *)lookupPronunciationForWord:(NSString *)aWord;
- (NSString *)pronunciationForWord:(NSString *)aWord;

- (void)testString:(NSString *)str;

- (NSString *)description;

@end

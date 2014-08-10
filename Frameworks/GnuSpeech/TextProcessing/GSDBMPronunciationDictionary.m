//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "GSDBMPronunciationDictionary.h"

#include <fcntl.h>
#include <ndbm.h>
#import "GSSimplePronunciationDictionary.h"

@implementation GSDBMPronunciationDictionary
{
    DBM *_db;
}

+ (NSString *)mainFilename;
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = [paths firstObject];
    NSParameterAssert(basePath != nil);
    NSString *path = [[basePath stringByAppendingPathComponent:@"GnuSpeech"] stringByAppendingPathComponent:@"pronunciations.db"];

    return path;
}

+ (id)mainDictionary;
{
    static GSDBMPronunciationDictionary *_mainDictionary;

    if (_mainDictionary == nil) {
        _mainDictionary = [[GSDBMPronunciationDictionary alloc] initWithFilename:[self mainFilename]];
    }

    return _mainDictionary;
}

+ (BOOL)createDatabase:(NSString *)filename fromSimpleDictionary:(GSSimplePronunciationDictionary *)simpleDictionary;
{
    [[NSFileManager defaultManager] createDirectoryAtPath:[filename stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:NULL];

    DBM *newDB = dbm_open([[filename stringByDeletingPathExtension] UTF8String], O_RDWR | O_CREAT, 0660);
    if (newDB == NULL) {
        perror("dbm_open()");
        return NO;
    }

    NSDictionary *pronunciations = [simpleDictionary pronunciations];

    [[pronunciations allKeys] enumerateObjectsUsingBlock:^(NSString *key, NSUInteger index, BOOL *stop) {
        NSString *value = [pronunciations objectForKey:key];
        //NSLog(@"%5d: key: %@, value: %@", index, key, value);

        datum keyDatum;
        keyDatum.dptr = (char *)[key UTF8String];
        keyDatum.dsize = strlen(keyDatum.dptr);

        datum valueDatum;
        valueDatum.dptr = (char *)[value UTF8String];
        valueDatum.dsize = strlen(valueDatum.dptr) + 1; // Let's get the zero byte too.

        int result = dbm_store(newDB, keyDatum, valueDatum, DBM_REPLACE);
        if (result != 0)
            NSLog(@"Could not dbmstore(): index: %5lu, key: %@, value: %@", index, key, value);
    }];

    dbm_close(newDB);

    return YES;
}

- (id)initWithFilename:(NSString *)filename;
{
    if ((self = [super initWithFilename:filename])) {
        _db = NULL;
    }

    return self;
}

- (void)dealloc;
{
    if (_db != NULL) {
        dbm_close(_db);
        _db = NULL;
    }
}

- (NSDate *)modificationDate;
{
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self.filename stringByAppendingString:@".db"] error:NULL];
    return [attributes fileModificationDate];
}

- (BOOL)loadDictionary;
{
    //NSLog(@" > %s, db: %p", __PRETTY_FUNCTION__, db);
    NSParameterAssert(_db == NULL);
    NSParameterAssert(self.filename != nil);

    //NSLog(@"%s, filename: %@", __PRETTY_FUNCTION__, self.filename);
    _db = dbm_open([[self.filename stringByDeletingPathExtension] UTF8String], O_RDONLY, 0660);
    if (_db == NULL) {
        perror("dbm_open()");
        return NO;
    }

    //NSLog(@"<  %s, db: %p", __PRETTY_FUNCTION__, db);

    return YES;
}

- (NSString *)lookupPronunciationForWord:(NSString *)word;
{
    datum keyDatum, valueDatum;

    keyDatum.dptr = (char *)[word UTF8String];
    keyDatum.dsize = strlen(keyDatum.dptr);

    valueDatum = dbm_fetch(_db, keyDatum);
    if (valueDatum.dptr == NULL)
        return nil;

    return [NSString stringWithUTF8String:valueDatum.dptr];
}

@end

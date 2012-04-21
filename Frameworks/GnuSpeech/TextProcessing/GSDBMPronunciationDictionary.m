//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "GSDBMPronunciationDictionary.h"

#import "NSFileManager-Extensions.h"
#import "GSSimplePronunciationDictionary.h"

@implementation GSDBMPronunciationDictionary
{
    DBM *db;
}

+ (NSString *)mainFilename;
{
    return [@"~/Library/Application Support/GnuSpeech/pronunciations" stringByExpandingTildeInPath];
}

+ (id)mainDictionary;
{
    static GSDBMPronunciationDictionary *_mainDictionary = nil;

    NSLog(@" > %s", __PRETTY_FUNCTION__);

    if (_mainDictionary == nil) {
        //NSString *path;

        _mainDictionary = [[GSDBMPronunciationDictionary alloc] initWithFilename:[self mainFilename]];
        //path = [[NSBundle bundleForClass:self] pathForResource:@"2.0eMainDictionary" ofType:@"dict"];
        //[_mainDictionary loadFromFile:path];
        //[_mainDictionary loadDictionary];
    }

    NSLog(@"<  %s", __PRETTY_FUNCTION__);

    return _mainDictionary;
}

+ (BOOL)createDatabase:(NSString *)aFilename fromSimpleDictionary:(GSSimplePronunciationDictionary *)simpleDictionary;
{
    NSUInteger count, index;

    NSDictionary *pronunciations = [simpleDictionary pronunciations];
    NSArray *allKeys = [pronunciations allKeys];

    [[NSFileManager defaultManager] createDirectoryAtPath:[aFilename stringByDeletingLastPathComponent] attributes:nil createIntermediateDirectories:YES];

    DBM *newDB = dbm_open([aFilename UTF8String], O_RDWR | O_CREAT, 0660);
    if (newDB == NULL) {
        perror("dbm_open()");
        return NO;
    }

    count = [allKeys count];
    NSLog(@"%lu keys", count);

    for (index = 0; index < count; index++) {
        NSString *key = [allKeys objectAtIndex:index];
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
    }

    dbm_close(newDB);

    return YES;
}

- (id)initWithFilename:(NSString *)aFilename;
{
    if ((self = [super initWithFilename:aFilename])) {
        db = NULL;
    }

    return self;
}

- (void)dealloc;
{
    if (db != NULL) {
        dbm_close(db);
        db = NULL;
    }

    [super dealloc];
}

- (NSDate *)modificationDate;
{
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self.filename stringByAppendingString:@".db"] error:NULL];
    return [attributes fileModificationDate];
}

- (BOOL)loadDictionary;
{
    NSLog(@" > %s, db: %p", __PRETTY_FUNCTION__, db);
    NSParameterAssert(db == NULL);
    NSParameterAssert(self.filename != nil);

    NSLog(@"%s, filename: %@", __PRETTY_FUNCTION__, self.filename);
    db = dbm_open([self.filename UTF8String], O_RDONLY, 0660);
    if (db == NULL) {
        perror("dbm_open()");
        return NO;
    }

    NSLog(@"<  %s, db: %p", __PRETTY_FUNCTION__, db);

    return YES;
}

- (NSString *)lookupPronunciationForWord:(NSString *)aWord;
{
    datum keyDatum, valueDatum;

    keyDatum.dptr = (char *)[aWord UTF8String];
    keyDatum.dsize = strlen(keyDatum.dptr);

    valueDatum = dbm_fetch(db, keyDatum);
    if (valueDatum.dptr == NULL)
        return nil;

    return [NSString stringWithUTF8String:valueDatum.dptr];
}

@end

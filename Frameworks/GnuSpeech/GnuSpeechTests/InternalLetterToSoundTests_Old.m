#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "letter_to_sound_private.h"

#define BUFLEN (1000)

@interface InternalLetterToSoundTests_Old : XCTestCase
@end

@implementation InternalLetterToSoundTests_Old
{
    char buf[BUFLEN];
}

- (void)setUp;
{
    [super setUp];

    memset(buf, 0, BUFLEN);
}

- (void)tearDown;
{
    [super tearDown];
}

#pragma mark -

#define CHECK_MEDIAL_S(str, expected) {\
strlcpy(buf, str, BUFLEN);\
char *end = buf + strlen(buf);\
medial_s(buf, end);\
XCTAssert(strcmp(buf, expected) == 0);\
}

- (void)testMedialS;
{
    CHECK_MEDIAL_S("ease", "eaSe");
    CHECK_MEDIAL_S("ism",  "iSm"); // Check lower case m following.
    CHECK_MEDIAL_S("isM",  "isM"); // But not upper case.
    CHECK_MEDIAL_S("isn",  "isn");
    CHECK_MEDIAL_S("msi",  "msi");

    CHECK_MEDIAL_S("ese",  "eSe"); // Both lower case and capital vowels.
    CHECK_MEDIAL_S("ESE",  "ESE");

    CHECK_MEDIAL_S("as",   "as"); // Next to end of string.
    CHECK_MEDIAL_S("sa",   "sa");

    CHECK_MEDIAL_S("asy",  "aSy"); // fantasy.  Y is a vowel.

    CHECK_MEDIAL_S("",     "");  // empty string.
    CHECK_MEDIAL_S("a",    "a"); // single vowel
}

#pragma mark - Word Exception List

- (void)DISABLED_testWordExceptions_TrilliumMistakes;
{
    char *endOfWord;
    int found;

    // They had 'bath' instead of 'both'.
    strcpy(buf, "#bath#"); endOfWord = buf + strlen(buf) - 1;
    found = check_word_list(buf, &endOfWord);
    XCTAssert(found == 0, @"'bath'");

    strcpy(buf, "#both#"); endOfWord = buf + strlen(buf) - 1;
    found = check_word_list(buf, &endOfWord);
    XCTAssert(found == 1, @"'both'");

    // They had "dosn't" instead of "doesn't".
    strcpy(buf, "#dosn't#"); endOfWord = buf + strlen(buf) - 1;
    found = check_word_list(buf, &endOfWord);
    XCTAssert(found == 0, @"'dosn't'");

    strcpy(buf, "#doesn't#"); endOfWord = buf + strlen(buf) - 1;
    found = check_word_list(buf, &endOfWord);
    XCTAssert(found == 1, @"'doesn't'");

    // Perhaps these were intentional, but 'you' and 'your' were not in any of the three versions of the paper I've seen.
    strcpy(buf, "#you#"); endOfWord = buf + strlen(buf) - 1;
    found = check_word_list(buf, &endOfWord);
    XCTAssert(found == 0, @"'you'");

    strcpy(buf, "#your#"); endOfWord = buf + strlen(buf) - 1;
    found = check_word_list(buf, &endOfWord);
    XCTAssert(found == 0, @"'your'");
}

- (void)DISABLED_testWordExceptions_1977Updates;
{
    char *endOfWord;
    int result;

    strcpy(buf, "#eye#"); endOfWord = buf + strlen(buf) - 1;
    result = check_word_list(buf, &endOfWord);
    XCTAssert(result == 0, @"'eye'");
}

#pragma mark - Mark Final E

- (void)testSuffixMarkedOnlyIfVowelInRestOfWord;
{
    char *endOfWord;
    strcpy(buf, "#zzzly#"); endOfWord = buf + strlen(buf) - 1;
    mark_final_e(buf, &endOfWord);
    NSLog(@"result: %s", buf);
    XCTAssert(!strcmp(buf, "#zzzlY#"));
}

// cabal vs decabal (or decibel or decimal).

@end

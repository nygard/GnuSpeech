#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "letter_to_sound_private.h"

#define BUFLEN (1000)

@interface InternalLetterToSoundTests : XCTestCase
@end

@implementation InternalLetterToSoundTests
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
medial_s(buf, &end);\
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

@end

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "GSLetterToSound.h"

@interface LetterToSoundTests : XCTestCase
@end

@implementation LetterToSoundTests
{
    GSLetterToSound *_lts;
}

- (void)setUp;
{
    [super setUp];

    _lts = [[GSLetterToSound alloc] init];
}

- (void)tearDown;
{
    _lts = nil;

    [super tearDown];
}

#pragma mark -

- (void)testWordException;
{
    NSString *word = @"engine";
    NSString *expected = @"e_n_j_i_n%j";

    NSString *p1 = [_lts pronunciationForWord:word];
    NSString *p2 = [_lts new_pronunciationForWord:word];

    XCTAssertEqualObjects(p1, expected);
    XCTAssertEqualObjects(p2, expected);
}

- (void)testWordExceptionEndingInSSoundedAsS;
{
    NSString *word = @"thats";
    NSString *expected = @"dh_aa_t_s%ab";

    NSString *p1 = [_lts pronunciationForWord:word];
    NSString *p2 = [_lts new_pronunciationForWord:word];

    XCTAssertEqualObjects(p1, expected);
    XCTAssertEqualObjects(p2, expected);
}

- (void)DISABLED_testWordExceptionEndingInSSoundedAsZ;
{
    NSString *word = @"bricks";
    NSString *expected = @"b_r_i_k_s%j";

    NSString *p1 = [_lts pronunciationForWord:word];
    NSString *p2 = [_lts new_pronunciationForWord:word];

    XCTAssertEqualObjects(p1, expected);
    XCTAssertEqualObjects(p2, expected);
}


- (void)testWordExceptionEndingInApostropheS;
{
    NSString *word = @"engines";
    NSString *expected = @"e_n_j_i_n_z%ab";

    NSString *p1 = [_lts pronunciationForWord:word];
    NSString *p2 = [_lts new_pronunciationForWord:word];

    XCTAssertEqualObjects(p1, expected);
    XCTAssertEqualObjects(p2, expected);
}

- (void)testWordEngingInSSoundedAsS;
{
}

- (void)DISABLED_testTrailingSApostrophe;
{
    NSString *word = @"woods'";
    NSString *expected = @"w_u_d_z%j";

    NSString *p1 = [_lts pronunciationForWord:word];
    NSString *p2 = [_lts new_pronunciationForWord:word];

    XCTAssertEqualObjects(p1, expected);
    XCTAssertEqualObjects(p2, expected);
}

#pragma mark - Internal -

#pragma mark - Mark Final E

- (void)testSuffixMarkedOnlyIfVowelInRestOfWord;
{
    NSMutableString *word = [@"zzzly" mutableCopy];
    NSString *expected = @"zzzlY";

    [_lts markFinalE:word];

    XCTAssertEqualObjects(word, expected);
}

// Rule 4.3g
- (void)testStable;
{
}

// Rule 4.3g
- (void)testCapable;
{
}

- (void)testIndeed;
{
    NSMutableString *word = [@"indeed" mutableCopy];
    NSString *expected = @"indee|d";

    [_lts markFinalE:word];

    XCTAssertEqualObjects(word, expected);
}

- (void)testSame;
{
    NSMutableString *word = [@"same" mutableCopy];
    NSString *expected = @"same|";

    [_lts markFinalE:word];

    XCTAssertEqualObjects(word, expected);
}

@end

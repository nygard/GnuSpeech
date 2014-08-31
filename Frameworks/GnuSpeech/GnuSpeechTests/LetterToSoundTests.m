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

- (void)testWordExceptionEndingInSSoundedAsZ;
{
    NSString *word = @"engines";
    NSString *expected = @"e_n_j_i_n_z%ab";

    NSString *p1 = [_lts pronunciationForWord:word];
    NSString *p2 = [_lts new_pronunciationForWord:word];

    XCTAssertEqualObjects(p1, expected);
    XCTAssertEqualObjects(p2, expected);
}


- (void)testWordExceptionEndingInApostropheS;
{
}


@end

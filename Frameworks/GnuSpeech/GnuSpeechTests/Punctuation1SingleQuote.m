#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "GSTextParser.h"
#import "GSTextParser-Private.h"

@interface Punctuation1SingleQuote : XCTestCase
@end

@implementation Punctuation1SingleQuote
{
    GSTextParser *_parser;
}

- (void)setUp;
{
    [super setUp];

    _parser = [[GSTextParser alloc] init];
}

- (void)tearDown;
{
    _parser = nil;

    [super tearDown];
}

#pragma mark - Single Quote

- (void)testAtStart;
{
    NSString *str = @"'one";
    NSString *result = [_parser punc1_deleteSingleQuotes:str];
    XCTAssertEqualObjects(result, @"one");
}

- (void)testAtEnd;
{
    NSString *str = @"two'";
    NSString *result = [_parser punc1_deleteSingleQuotes:str];
    XCTAssertEqualObjects(result, @"two");
}

- (void)testIsolated;
{
    NSString *str = @"three ' four";
    NSString *result = [_parser punc1_deleteSingleQuotes:str];
    XCTAssertEqualObjects(result, @"three  four");
}

- (void)testBeforeNonAlpha;
{
    NSString *str = @"five' ";
    NSString *result = [_parser punc1_deleteSingleQuotes:str];
    XCTAssertEqualObjects(result, @"five ");
}

- (void)testAfterNonAlpha;
{
    NSString *str = @" 'six";
    NSString *result = [_parser punc1_deleteSingleQuotes:str];
    XCTAssertEqualObjects(result, @" six");
}

- (void)testBetweenAlpha;
{
    NSString *str = @"her's";
    NSString *result = [_parser punc1_deleteSingleQuotes:str];
    XCTAssertEqualObjects(result, @"her's");
}

#pragma mark - Delete single character

- (void)testDeleteSingleCharacter;
{
    NSString *str = @"1 \" 2 ` 3 # 4 * 5 \\ 6 ^ 7 _ 8 | 9 ~ 10 { 11 } 12";
    NSString *result = [_parser punc1_deleteSingleCharacters:str];
    NSString *expected = @"1  2  3  4  5  6  7  8  9  10  11  12";
    NSLog(@"  result: '%@'", result);
    NSLog(@"expected: '%@'", expected);
    XCTAssertEqualObjects(result, expected);
}

@end

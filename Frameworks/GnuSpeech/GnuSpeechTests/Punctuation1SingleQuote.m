#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "GSTextParser.h"
#import "GSTextParser-Private.h"
#import "GSTextRun.h"

@interface Punctuation1SingleQuote : XCTestCase
@end

@implementation Punctuation1SingleQuote
{
    GSTextRun *_textRun;
}

- (void)setUp;
{
    [super setUp];

    _textRun = [[GSTextRun alloc] initWithMode:GSTextParserMode_Normal];
}

- (void)tearDown;
{
    _textRun = nil;

    [super tearDown];
}

#pragma mark - Single Quote

- (void)testAtStart;
{
    NSString *str = @"'one";
    [_textRun.string appendString:str];
    [_textRun _punc1_deleteSingleQuotes];
    NSString *result = _textRun.string;
    XCTAssertEqualObjects(result, @"one");
}

- (void)testAtEnd;
{
    NSString *str = @"two'";
    [_textRun.string appendString:str];
    [_textRun _punc1_deleteSingleQuotes];
    NSString *result = _textRun.string;
    XCTAssertEqualObjects(result, @"two");
}

- (void)testIsolated;
{
    NSString *str = @"three ' four";
    [_textRun.string appendString:str];
    [_textRun _punc1_deleteSingleQuotes];
    NSString *result = _textRun.string;
    XCTAssertEqualObjects(result, @"three  four");
}

- (void)testBeforeNonAlpha;
{
    NSString *str = @"five' ";
    [_textRun.string appendString:str];
    [_textRun _punc1_deleteSingleQuotes];
    NSString *result = _textRun.string;
    XCTAssertEqualObjects(result, @"five ");
}

- (void)testAfterNonAlpha;
{
    NSString *str = @" 'six";
    [_textRun.string appendString:str];
    [_textRun _punc1_deleteSingleQuotes];
    NSString *result = _textRun.string;
    XCTAssertEqualObjects(result, @" six");
}

- (void)testBetweenAlpha;
{
    NSString *str = @"her's";
    [_textRun.string appendString:str];
    [_textRun _punc1_deleteSingleQuotes];
    NSString *result = _textRun.string;
    XCTAssertEqualObjects(result, @"her's");
}

#pragma mark - Delete single character

- (void)testDeleteSingleCharacter;
{
    NSString *str = @"1 \" 2 ` 3 # 4 * 5 \\ 6 ^ 7 _ 8 | 9 ~ 10 { 11 } 12";
    [_textRun.string appendString:str];
    [_textRun _punc1_deleteSingleCharacters];
    NSString *result = _textRun.string;
    NSString *expected = @"1  2  3  4  5  6  7  8  9  10  11  12";
    NSLog(@"  result: '%@'", result);
    NSLog(@"expected: '%@'", expected);
    XCTAssertEqualObjects(result, expected);
}

@end

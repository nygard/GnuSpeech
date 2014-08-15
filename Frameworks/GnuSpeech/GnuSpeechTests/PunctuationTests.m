#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "GSTextParser.h"
#import "GSTextParser-Private.h"
#import "GSTextRun.h"

@interface PunctuationTests : XCTestCase
@end

// These are better unit tests, just testing the API, not the internal methods.
@implementation PunctuationTests
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

#pragma mark - General punctuation tests.

- (void)testReplaceIsolatedCharactersBeforePlusMinusCheck;
{
    NSString *str = @"+ one +";
    [_textRun.string appendString:str];
    [_textRun stripPunctuation];
    NSString *result = _textRun.string;
    XCTAssertEqualObjects(result, @"plus one plus");
}

// And this is why we're not going to use a regex for that part.
- (void)testOverlappingRegexMatch;
{
    NSString *str = @"one a+ +a two";
    [_textRun.string appendString:str];
    [_textRun stripPunctuation];
    NSString *result = _textRun.string;
    XCTAssertEqualObjects(result, @"one a a two");
}

@end

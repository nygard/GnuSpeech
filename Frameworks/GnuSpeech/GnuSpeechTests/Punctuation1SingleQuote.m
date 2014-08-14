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

#pragma mark -

- (void)testAtStart;
{
    NSString *str = @"'one";
    NSString *result = [_parser punc1_singleQuote:str];
    XCTAssertEqualObjects(result, @"one");
}

- (void)testAtEnd;
{
    NSString *str = @"two'";
    NSString *result = [_parser punc1_singleQuote:str];
    XCTAssertEqualObjects(result, @"two");
}

- (void)testIsolated;
{
    NSString *str = @"three ' four";
    NSString *result = [_parser punc1_singleQuote:str];
    XCTAssertEqualObjects(result, @"three  four");
}

- (void)testBeforeNonAlpha;
{
    NSString *str = @"five' ";
    NSString *result = [_parser punc1_singleQuote:str];
    XCTAssertEqualObjects(result, @"five ");
}

- (void)testAfterNonAlpha;
{
    NSString *str = @" 'six";
    NSString *result = [_parser punc1_singleQuote:str];
    XCTAssertEqualObjects(result, @" six");
}

- (void)testBetweenAlpha;
{
    NSString *str = @"her's";
    NSString *result = [_parser punc1_singleQuote:str];
    XCTAssertEqualObjects(result, @"her's");
}

@end

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "GSTextParser.h"
#import "GSTextParser-Private.h"
#import "GSTextParserModeStack.h"

@interface MarkModesTests : XCTestCase
@end

@implementation MarkModesTests
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

- (void)testNormal;
{
    NSString *inputString = @"This text is all normal";
    NSAttributedString *outputString = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(outputString != nil);

    NSRange range;
    NSDictionary *attrs = [outputString attributesAtIndex:0 longestEffectiveRange:&range inRange:NSMakeRange(0, [outputString length])];
    XCTAssert(range.location == 0);
    XCTAssert(range.length = [outputString length]);
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_Mode], @(GSTextParserMode_Normal));
}

- (void)testBeginModeEndsPrevious;
{
    NSString *inputString = @"one %eb two %tb 123 blah";
    NSAttributedString *outputString = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(outputString != nil);

    NSRange range = NSMakeRange(0, 0);
    NSDictionary *attrs;

    attrs = [outputString attributesAtIndex:NSMaxRange(range) longestEffectiveRange:&range inRange:NSMakeRange(0, [outputString length])];
    XCTAssert(range.location == 0);
    XCTAssert(range.length == 4);
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_Mode],     @(GSTextParserMode_Normal));

    attrs = [outputString attributesAtIndex:NSMaxRange(range) longestEffectiveRange:&range inRange:NSMakeRange(0, [outputString length])];
    XCTAssert(range.location == 4);
    XCTAssert(range.length == 5);
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_Mode],     @(GSTextParserMode_Emphasis));

    attrs = [outputString attributesAtIndex:NSMaxRange(range) longestEffectiveRange:&range inRange:NSMakeRange(0, [outputString length])];
    XCTAssert(range.location == 9);
    XCTAssert(range.length == 1);
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_Mode],     @(GSTextParserMode_Tagging));
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_TagValue], @(123));

    attrs = [outputString attributesAtIndex:NSMaxRange(range) longestEffectiveRange:&range inRange:NSMakeRange(0, [outputString length])];
    XCTAssert(range.location == 10);
    XCTAssert(range.length == 4);
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_Mode],     @(GSTextParserMode_Emphasis));
}

#pragma mark - Tagging

- (void)testTagging;
{
    NSString *inputString = @"%tb 1234 %te one";
    NSAttributedString *outputString = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(outputString != nil);

    NSRange range;
    NSDictionary *attrs = [outputString attributesAtIndex:0 longestEffectiveRange:&range inRange:NSMakeRange(0, [outputString length])];
    XCTAssert(range.location == 0);
    XCTAssert(range.length = 1);
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_Mode],     @(GSTextParserMode_Tagging));
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_TagValue], @(1234));
}

- (void)testTaggingImplicitEnd;
{
    NSString *inputString = @"%tb 1234 two";
    NSAttributedString *outputString = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(outputString != nil);

    NSRange range;
    NSDictionary *attrs = [outputString attributesAtIndex:0 longestEffectiveRange:&range inRange:NSMakeRange(0, [outputString length])];
    XCTAssert(range.location == 0);
    XCTAssert(range.length = 1);
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_Mode],     @(GSTextParserMode_Tagging));
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_TagValue], @(1234));
}

- (void)testDoubleTag;
{
    NSString *inputString = @"%tb 1234 %tb 5678";
    NSAttributedString *outputString = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(outputString != nil);

    NSRange range;
    NSDictionary *attrs = [outputString attributesAtIndex:0 longestEffectiveRange:&range inRange:NSMakeRange(0, [outputString length])];
    XCTAssert(range.location == 0);
    XCTAssert(range.length == 1);
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_Mode],     @(GSTextParserMode_Tagging));
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_TagValue], @(1234));

    attrs = [outputString attributesAtIndex:1 longestEffectiveRange:&range inRange:NSMakeRange(0, [outputString length])];
    XCTAssert(range.location == 1);
    XCTAssert(range.length == 1);
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_Mode],     @(GSTextParserMode_Tagging));
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_TagValue], @(5678));
}

- (void)testDoubleIdenticalTag;
{
    NSString *inputString = @"%tb 1234 %tb 1234";
    NSAttributedString *outputString = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(outputString != nil);

    NSRange range;
    NSDictionary *attrs = [outputString attributesAtIndex:0 longestEffectiveRange:&range inRange:NSMakeRange(0, [outputString length])];
    XCTAssert(range.location == 0);
    XCTAssert(range.length == 2);
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_Mode],     @(GSTextParserMode_Tagging));
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_TagValue], @(1234));
}

- (void)testNegativeTag;
{
    NSString *inputString = @"%tb -23 one";
    NSAttributedString *outputString = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(outputString != nil);

    NSRange range;
    NSDictionary *attrs = [outputString attributesAtIndex:0 longestEffectiveRange:&range inRange:NSMakeRange(0, [outputString length])];
    XCTAssert(range.location == 0);
    XCTAssert(range.length == 1);
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_Mode],     @(GSTextParserMode_Tagging));
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_TagValue], @(-23));
}

- (void)testPositiveTag;
{
    NSString *inputString = @"%tb +45 one";
    NSAttributedString *outputString = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(outputString != nil);

    NSRange range;
    NSDictionary *attrs = [outputString attributesAtIndex:0 longestEffectiveRange:&range inRange:NSMakeRange(0, [outputString length])];
    XCTAssert(range.location == 0);
    XCTAssert(range.length == 1);
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_Mode],     @(GSTextParserMode_Tagging));
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_TagValue], @(45));
}

- (void)testEmptyTag;
{
    NSString *inputString = @"%tb %te one";
    NSAttributedString *outputString = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(outputString != nil);

    NSRange range;
    NSDictionary *attrs = [outputString attributesAtIndex:0 longestEffectiveRange:&range inRange:NSMakeRange(0, [outputString length])];
    XCTAssert(range.location == 0);
    XCTAssert(range.length == 4);
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_Mode],     @(GSTextParserMode_Normal));
}

- (void)testEmptyTagImplicitEnd;
{
    NSString *inputString = @"%tb one";
    NSAttributedString *outputString = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(outputString != nil);

    NSRange range;
    NSDictionary *attrs = [outputString attributesAtIndex:0 longestEffectiveRange:&range inRange:NSMakeRange(0, [outputString length])];
    XCTAssert(range.location == 0);
    XCTAssert(range.length == 3);
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_Mode],     @(GSTextParserMode_Normal));
}

#pragma mark - Silence

- (void)testSilence;
{
    NSString *inputString = @"%sb 1234 %se one";
    NSAttributedString *outputString = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(outputString != nil);

    NSRange range;
    NSDictionary *attrs = [outputString attributesAtIndex:0 longestEffectiveRange:&range inRange:NSMakeRange(0, [outputString length])];
    XCTAssert(range.location == 0);
    XCTAssert(range.length = 1);
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_Mode],         @(GSTextParserMode_Silence));
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_SilenceValue], @(1234));
}

- (void)testSilenceImplicitEnd;
{
    NSString *inputString = @"%sb 1234 two";
    NSAttributedString *outputString = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(outputString != nil);

    NSRange range;
    NSDictionary *attrs = [outputString attributesAtIndex:0 longestEffectiveRange:&range inRange:NSMakeRange(0, [outputString length])];
    XCTAssert(range.location == 0);
    XCTAssert(range.length = 1);
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_Mode],         @(GSTextParserMode_Silence));
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_SilenceValue], @(1234));
}

- (void)testDoubleSilence;
{
    NSString *inputString = @"%sb 1234 %sb 5678";
    NSAttributedString *outputString = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(outputString != nil);

    NSRange range;
    NSDictionary *attrs = [outputString attributesAtIndex:0 longestEffectiveRange:&range inRange:NSMakeRange(0, [outputString length])];
    XCTAssert(range.location == 0);
    XCTAssert(range.length == 1);
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_Mode],         @(GSTextParserMode_Silence));
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_SilenceValue], @(1234));

    attrs = [outputString attributesAtIndex:1 longestEffectiveRange:&range inRange:NSMakeRange(0, [outputString length])];
    XCTAssert(range.location == 1);
    XCTAssert(range.length == 1);
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_Mode],         @(GSTextParserMode_Silence));
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_SilenceValue], @(5678));
}

- (void)testDoubleIdenticalSilence;
{
    NSString *inputString = @"%sb 1234 %sb 1234";
    NSAttributedString *outputString = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(outputString != nil);

    NSRange range;
    NSDictionary *attrs = [outputString attributesAtIndex:0 longestEffectiveRange:&range inRange:NSMakeRange(0, [outputString length])];
    XCTAssert(range.location == 0);
    XCTAssert(range.length == 2);
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_Mode],         @(GSTextParserMode_Silence));
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_SilenceValue], @(1234));
}

- (void)testNegativeSilence;
{
    NSString *inputString = @"%sb -23 one";
    NSAttributedString *outputString = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(outputString != nil);

    NSRange range;
    NSDictionary *attrs = [outputString attributesAtIndex:0 longestEffectiveRange:&range inRange:NSMakeRange(0, [outputString length])];
    XCTAssert(range.location == 0);
    XCTAssert(range.length == 1);
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_Mode],         @(GSTextParserMode_Silence));
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_SilenceValue], @(-23));
}

- (void)testPositiveSilence;
{
    NSString *inputString = @"%sb +45 one";
    NSAttributedString *outputString = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(outputString != nil);

    NSRange range;
    NSDictionary *attrs = [outputString attributesAtIndex:0 longestEffectiveRange:&range inRange:NSMakeRange(0, [outputString length])];
    XCTAssert(range.location == 0);
    XCTAssert(range.length == 1);
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_Mode],         @(GSTextParserMode_Silence));
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_SilenceValue], @(45));
}

- (void)testFractionalSilence;
{
    NSString *inputString = @"%sb 0.5 one";
    NSAttributedString *outputString = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(outputString != nil);

    NSRange range;
    NSDictionary *attrs = [outputString attributesAtIndex:0 longestEffectiveRange:&range inRange:NSMakeRange(0, [outputString length])];
    XCTAssert(range.location == 0);
    XCTAssert(range.length == 1);
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_Mode],         @(GSTextParserMode_Silence));
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_SilenceValue], @(0.5));
}

- (void)testEmptySilence;
{
    NSString *inputString = @"%sb %se one";
    NSAttributedString *outputString = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(outputString != nil);

    NSRange range;
    NSDictionary *attrs = [outputString attributesAtIndex:0 longestEffectiveRange:&range inRange:NSMakeRange(0, [outputString length])];
    XCTAssert(range.location == 0);
    XCTAssert(range.length == 4);
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_Mode],     @(GSTextParserMode_Normal));
}

- (void)testEmptySilenceImplicitEnd;
{
    NSString *inputString = @"%sb one";
    NSAttributedString *outputString = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(outputString != nil);

    NSRange range;
    NSDictionary *attrs = [outputString attributesAtIndex:0 longestEffectiveRange:&range inRange:NSMakeRange(0, [outputString length])];
    XCTAssert(range.location == 0);
    XCTAssert(range.length == 3);
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_Mode],     @(GSTextParserMode_Normal));
}

#pragma mark - Raw

- (void)testRaw;
{
    NSString *inputString = @"%rb one %re two";
    NSAttributedString *outputString = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(outputString != nil);

    NSRange range;
    NSDictionary *attrs = [outputString attributesAtIndex:0 longestEffectiveRange:&range inRange:NSMakeRange(0, [outputString length])];
    XCTAssert(range.location == 0);
    XCTAssert(range.length == 5);
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_Mode],     @(GSTextParserMode_Raw));
}

- (void)testRawIgnoresOtherBegins;
{
    NSString *inputString = @"%rb one %eb two";
    NSAttributedString *outputString = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(outputString != nil);

    NSRange range;
    NSDictionary *attrs = [outputString attributesAtIndex:0 longestEffectiveRange:&range inRange:NSMakeRange(0, [outputString length])];
    XCTAssert(range.location == 0);
    XCTAssert(range.length == 12);
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_Mode],     @(GSTextParserMode_Raw));
}

- (void)testRawIgnoresOtherEnds;
{
    NSString *inputString = @"%rb one %ee two";
    NSAttributedString *outputString = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(outputString != nil);

    NSRange range;
    NSDictionary *attrs = [outputString attributesAtIndex:0 longestEffectiveRange:&range inRange:NSMakeRange(0, [outputString length])];
    XCTAssert(range.location == 0);
    XCTAssert(range.length == 12);
    XCTAssertEqualObjects(attrs[GSTextParserAttribute_Mode],     @(GSTextParserMode_Raw));
}

#pragma mark - Failures

- (void)testMismatchEnd;
{
    NSString *inputString = @"%tb %se one";
    NSError *error;
    NSAttributedString *outputString = [_parser _markModesInString:inputString error:&error];

    XCTAssert(outputString == nil);
    XCTAssert(error != nil);
    XCTAssertEqualObjects(error.domain, GSTextParserErrorDomain);
    XCTAssert(error.code == GSTextParserError_UnbalancedPop);
}

- (void)testIgnoreError;
{
    NSString *inputString = @"%tb %se one";
    NSAttributedString *outputString = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(outputString == nil);
}

@end

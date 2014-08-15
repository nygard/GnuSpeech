#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "GSTextParser.h"
#import "GSTextParser-Private.h"
#import "GSTextGroupBuilder.h"
#import "GSTextGroup.h"
#import "GSTextRun.h"

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
    GSTextGroup *textGroup = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(textGroup != nil);
    XCTAssert([textGroup.textRuns count] == 1);

    GSTextRun *textRun = textGroup.textRuns[0];
    XCTAssert(textRun.mode == GSTextParserMode_Normal);
    XCTAssert([textRun.string isEqualToString:inputString]);
}

- (void)testBeginModeEndsPrevious;
{
    NSString *inputString = @"one %eb two %tb 123 blah";
    GSTextGroup *textGroup = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(textGroup != nil);
    XCTAssert([textGroup.textRuns count] == 4);

    GSTextRun *textRun;

    textRun = textGroup.textRuns[0];
    XCTAssert(textRun.mode == GSTextParserMode_Normal);
    XCTAssert([textRun.string isEqualToString:@"one "]);

    textRun = textGroup.textRuns[1];
    XCTAssert(textRun.mode == GSTextParserMode_Emphasis);
    XCTAssert([textRun.string isEqualToString:@" two "]);

    textRun = textGroup.textRuns[2];
    XCTAssert(textRun.mode == GSTextParserMode_Tagging);
    XCTAssert([textRun.string isEqualToString:@"123"]);

    textRun = textGroup.textRuns[3];
    XCTAssert(textRun.mode == GSTextParserMode_Emphasis);
    XCTAssert([textRun.string isEqualToString:@"blah"]);
}

#pragma mark - Tagging

- (void)testTagging;
{
    NSString *inputString = @"%tb 1234 %te one";
    GSTextGroup *textGroup = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(textGroup != nil);
    XCTAssert([textGroup.textRuns count] == 2);

    GSTextRun *textRun;

    textRun = textGroup.textRuns[0];
    XCTAssert(textRun.mode == GSTextParserMode_Tagging);
    XCTAssert([textRun.string isEqualToString:@"1234"]);

    textRun = textGroup.textRuns[1];
    XCTAssert(textRun.mode == GSTextParserMode_Normal);
    XCTAssert([textRun.string isEqualToString:@" one"]);
}

- (void)testTaggingImplicitEnd;
{
    NSString *inputString = @"%tb 1234 two";
    GSTextGroup *textGroup = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(textGroup != nil);
    XCTAssert([textGroup.textRuns count] == 2);

    GSTextRun *textRun;

    textRun = textGroup.textRuns[0];
    XCTAssert(textRun.mode == GSTextParserMode_Tagging);
    XCTAssert([textRun.string isEqualToString:@"1234"]);

    textRun = textGroup.textRuns[1];
    XCTAssert(textRun.mode == GSTextParserMode_Normal);
    XCTAssert([textRun.string isEqualToString:@"two"]);
}

- (void)testDoubleTag;
{
    NSString *inputString = @"%tb 1234 %tb 5678";
    GSTextGroup *textGroup = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(textGroup != nil);
    XCTAssert([textGroup.textRuns count] == 2);

    GSTextRun *textRun;

    textRun = textGroup.textRuns[0];
    XCTAssert(textRun.mode == GSTextParserMode_Tagging);
    XCTAssert([textRun.string isEqualToString:@"1234"]);

    textRun = textGroup.textRuns[1];
    XCTAssert(textRun.mode == GSTextParserMode_Tagging);
    XCTAssert([textRun.string isEqualToString:@"5678"]);
}

- (void)testDoubleIdenticalTag;
{
    NSString *inputString = @"%tb 1234 %tb 1234";
    GSTextGroup *textGroup = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(textGroup != nil);
    XCTAssert([textGroup.textRuns count] == 2);

    GSTextRun *textRun;

    textRun = textGroup.textRuns[0];
    XCTAssert(textRun.mode == GSTextParserMode_Tagging);
    XCTAssert([textRun.string isEqualToString:@"1234"]);

    textRun = textGroup.textRuns[1];
    XCTAssert(textRun.mode == GSTextParserMode_Tagging);
    XCTAssert([textRun.string isEqualToString:@"1234"]);
}

- (void)testNegativeTag;
{
    NSString *inputString = @"%tb -23 one";
    GSTextGroup *textGroup = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(textGroup != nil);
    XCTAssert([textGroup.textRuns count] == 2);

    GSTextRun *textRun;

    textRun = textGroup.textRuns[0];
    XCTAssert(textRun.mode == GSTextParserMode_Tagging);
    XCTAssert([textRun.string isEqualToString:@"-23"]);

    textRun = textGroup.textRuns[1];
    XCTAssert(textRun.mode == GSTextParserMode_Normal);
    XCTAssert([textRun.string isEqualToString:@"one"]);
}

- (void)testPositiveTag;
{
    NSString *inputString = @"%tb +45 one";
    GSTextGroup *textGroup = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(textGroup != nil);
    XCTAssert([textGroup.textRuns count] == 2);

    GSTextRun *textRun;

    textRun = textGroup.textRuns[0];
    XCTAssert(textRun.mode == GSTextParserMode_Tagging);
    XCTAssert([textRun.string isEqualToString:@"45"]);

    textRun = textGroup.textRuns[1];
    XCTAssert(textRun.mode == GSTextParserMode_Normal);
    XCTAssert([textRun.string isEqualToString:@"one"]);
}

- (void)testEmptyTag;
{
    NSString *inputString = @"%tb %te one";
    GSTextGroup *textGroup = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(textGroup != nil);
    XCTAssert([textGroup.textRuns count] == 1);

    GSTextRun *textRun;

    textRun = textGroup.textRuns[0];
    XCTAssert(textRun.mode == GSTextParserMode_Normal);
    XCTAssert([textRun.string isEqualToString:@" one"]);
}

- (void)testEmptyTagImplicitEnd;
{
    NSString *inputString = @"%tb one";
    GSTextGroup *textGroup = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(textGroup != nil);
    XCTAssert([textGroup.textRuns count] == 1);

    GSTextRun *textRun;

    textRun = textGroup.textRuns[0];
    XCTAssert(textRun.mode == GSTextParserMode_Normal);
    XCTAssert([textRun.string isEqualToString:@"one"]);
}

#pragma mark - Silence

- (void)testSilence;
{
    NSString *inputString = @"%sb 1234 %se one";
    GSTextGroup *textGroup = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(textGroup != nil);
    XCTAssert([textGroup.textRuns count] == 2);

    GSTextRun *textRun;

    textRun = textGroup.textRuns[0];
    XCTAssert(textRun.mode == GSTextParserMode_Silence);
    XCTAssert([textRun.string isEqualToString:@"1234"]);

    textRun = textGroup.textRuns[1];
    XCTAssert(textRun.mode == GSTextParserMode_Normal);
    XCTAssert([textRun.string isEqualToString:@" one"]);
}

- (void)testSilenceImplicitEnd;
{
    NSString *inputString = @"%sb 1234 two";
    GSTextGroup *textGroup = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(textGroup != nil);
    XCTAssert([textGroup.textRuns count] == 2);

    GSTextRun *textRun;

    textRun = textGroup.textRuns[0];
    XCTAssert(textRun.mode == GSTextParserMode_Silence);
    XCTAssert([textRun.string isEqualToString:@"1234"]);

    textRun = textGroup.textRuns[1];
    XCTAssert(textRun.mode == GSTextParserMode_Normal);
    XCTAssert([textRun.string isEqualToString:@"two"]);
}

- (void)testDoubleSilence;
{
    NSString *inputString = @"%sb 1234 %sb 5678";
    GSTextGroup *textGroup = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(textGroup != nil);
    XCTAssert([textGroup.textRuns count] == 2);

    GSTextRun *textRun;

    textRun = textGroup.textRuns[0];
    XCTAssert(textRun.mode == GSTextParserMode_Silence);
    XCTAssert([textRun.string isEqualToString:@"1234"]);

    textRun = textGroup.textRuns[1];
    XCTAssert(textRun.mode == GSTextParserMode_Silence);
    XCTAssert([textRun.string isEqualToString:@"5678"]);
}

- (void)testDoubleIdenticalSilence;
{
    NSString *inputString = @"%sb 1234 %sb 1234";
    GSTextGroup *textGroup = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(textGroup != nil);
    XCTAssert([textGroup.textRuns count] == 2);

    GSTextRun *textRun;

    textRun = textGroup.textRuns[0];
    XCTAssert(textRun.mode == GSTextParserMode_Silence);
    XCTAssert([textRun.string isEqualToString:@"1234"]);

    textRun = textGroup.textRuns[1];
    XCTAssert(textRun.mode == GSTextParserMode_Silence);
    XCTAssert([textRun.string isEqualToString:@"1234"]);
}

- (void)testNegativeSilence;
{
    NSString *inputString = @"%sb -23 one";
    GSTextGroup *textGroup = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(textGroup != nil);
    XCTAssert([textGroup.textRuns count] == 2);

    GSTextRun *textRun;

    textRun = textGroup.textRuns[0];
    XCTAssert(textRun.mode == GSTextParserMode_Silence);
    XCTAssert([textRun.string isEqualToString:@"-23"]);

    textRun = textGroup.textRuns[1];
    XCTAssert(textRun.mode == GSTextParserMode_Normal);
    XCTAssert([textRun.string isEqualToString:@"one"]);
}

- (void)testPositiveSilence;
{
    NSString *inputString = @"%sb +45 one";
    GSTextGroup *textGroup = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(textGroup != nil);
    XCTAssert([textGroup.textRuns count] == 2);

    GSTextRun *textRun;

    textRun = textGroup.textRuns[0];
    XCTAssert(textRun.mode == GSTextParserMode_Silence);
    XCTAssert([textRun.string isEqualToString:@"45"]);

    textRun = textGroup.textRuns[1];
    XCTAssert(textRun.mode == GSTextParserMode_Normal);
    XCTAssert([textRun.string isEqualToString:@"one"]);
}

- (void)testFractionalSilence;
{
    NSString *inputString = @"%sb 0.5 one";
    GSTextGroup *textGroup = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(textGroup != nil);
    XCTAssert([textGroup.textRuns count] == 2);

    GSTextRun *textRun;

    textRun = textGroup.textRuns[0];
    XCTAssert(textRun.mode == GSTextParserMode_Silence);
    XCTAssert([textRun.string isEqualToString:@"0.5"]);

    textRun = textGroup.textRuns[1];
    XCTAssert(textRun.mode == GSTextParserMode_Normal);
    XCTAssert([textRun.string isEqualToString:@"one"]);
}

- (void)testEmptySilence;
{
    NSString *inputString = @"%sb %se one";
    GSTextGroup *textGroup = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(textGroup != nil);
    XCTAssert([textGroup.textRuns count] == 1);

    GSTextRun *textRun;

    textRun = textGroup.textRuns[0];
    XCTAssert(textRun.mode == GSTextParserMode_Normal);
    XCTAssert([textRun.string isEqualToString:@" one"]);
}

- (void)testEmptySilenceImplicitEnd;
{
    NSString *inputString = @"%sb one";
    GSTextGroup *textGroup = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(textGroup != nil);
    XCTAssert([textGroup.textRuns count] == 1);

    GSTextRun *textRun;

    textRun = textGroup.textRuns[0];
    XCTAssert(textRun.mode == GSTextParserMode_Normal);
    XCTAssert([textRun.string isEqualToString:@"one"]);
}

#pragma mark - Raw

- (void)testRaw;
{
    NSString *inputString = @"%rb one %re two";
    GSTextGroup *textGroup = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(textGroup != nil);
    XCTAssert([textGroup.textRuns count] == 2);

    GSTextRun *textRun;

    textRun = textGroup.textRuns[0];
    XCTAssert(textRun.mode == GSTextParserMode_Raw);
    XCTAssert([textRun.string isEqualToString:@" one "]);

    textRun = textGroup.textRuns[1];
    XCTAssert(textRun.mode == GSTextParserMode_Normal);
    XCTAssert([textRun.string isEqualToString:@" two"]);
}

- (void)testRawIgnoresOtherBegins;
{
    NSString *inputString = @"%rb one %eb two";
    GSTextGroup *textGroup = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(textGroup != nil);
    XCTAssert([textGroup.textRuns count] == 1);

    GSTextRun *textRun;

    textRun = textGroup.textRuns[0];
    XCTAssert(textRun.mode == GSTextParserMode_Raw);
    XCTAssert([textRun.string isEqualToString:@" one %eb two"]);
}

- (void)testRawIgnoresOtherEnds;
{
    NSString *inputString = @"%rb one %ee two";
    GSTextGroup *textGroup = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(textGroup != nil);
    XCTAssert([textGroup.textRuns count] == 1);

    GSTextRun *textRun;

    textRun = textGroup.textRuns[0];
    XCTAssert(textRun.mode == GSTextParserMode_Raw);
    XCTAssert([textRun.string isEqualToString:@" one %ee two"]);
}

#pragma mark - Failures

- (void)testMismatchEnd;
{
    NSString *inputString = @"%tb %se one";
    NSError *error;
    GSTextGroup *textGroup = [_parser _markModesInString:inputString error:&error];

    XCTAssert(textGroup == nil);
    XCTAssert(error != nil);
    XCTAssertEqualObjects(error.domain, GSTextParserErrorDomain);
    XCTAssert(error.code == GSTextParserError_UnbalancedPop);
}

- (void)testIgnoreError;
{
    NSString *inputString = @"%tb %se one";
    GSTextGroup *textGroup = [_parser _markModesInString:inputString error:NULL];

    XCTAssert(textGroup == nil);
}

@end

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

@interface RegularExpressionTests : XCTestCase
@end

@implementation RegularExpressionTests

- (void)setUp;
{
    [super setUp];
}

- (void)tearDown;
{
    [super tearDown];
}

- (void)testPrintable;
{
    NSError *error;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"[:print:]" options:0 error:&error];
    XCTAssert(regex != nil);

    NSString *input = @"one\ntwo\n";
    NSString *output = [regex stringByReplacingMatchesInString:input options:0 range:NSMakeRange(0, [input length]) withTemplate:@""];

    XCTAssertEqualObjects(output, @"\n\n");
}

// I found on <http://www.perlmonks.org/bare/?node_id=446718> that [:^print:] is supposed to be a perl extension, but I tried it and it works here.
// [^:print:] was my first try, but that does not work.
- (void)testNotPrintable;
{
    NSError *error;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"[:^print:]" options:0 error:&error];
    XCTAssert(regex != nil);

    NSString *input = @"one\ntwo\n";
    NSString *output = [regex stringByReplacingMatchesInString:input options:0 range:NSMakeRange(0, [input length]) withTemplate:@""];

    XCTAssertEqualObjects(output, @"onetwo");
}

- (void)testSubtraction;
{
    NSError *error;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"[a-z --%]" options:0 error:&error];
    XCTAssert(regex != nil);

    NSString *input = @"one % two";
    NSString *output = [regex stringByReplacingMatchesInString:input options:0 range:NSMakeRange(0, [input length]) withTemplate:@""];

    XCTAssertEqualObjects(output, @"%");
}

// This doesn't work as I'd like.
- (void)DISABLED_testWhitespaceSubtraction;
{
    NSError *error;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"[:space:--\n]" options:0 error:&error];
    XCTAssert(regex != nil);

    NSString *input = @"one \n two";
    NSString *output = [regex stringByReplacingMatchesInString:input options:0 range:NSMakeRange(0, [input length]) withTemplate:@""];

    XCTAssertEqualObjects(output, @"one\ntwo");
}

- (void)testCaratMatchesBeginningOfRange;
{
    NSError *error;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"^e" options:0 error:&error];
    XCTAssert(regex != nil);

    NSString *input = @"ebel";
    NSTextCheckingResult *result = [regex firstMatchInString:input options:0 range:NSMakeRange(2, [input length] - 2)];
    XCTAssert(result != nil);
    XCTAssert(result.range.location == 2);
}

@end

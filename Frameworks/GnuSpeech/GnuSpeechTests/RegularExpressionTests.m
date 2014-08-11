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

@end

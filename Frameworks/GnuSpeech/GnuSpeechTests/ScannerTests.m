#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

@interface ScannerTests : XCTestCase
@end

@implementation ScannerTests
{
    NSScanner *_scanner;
}

- (void)setUp;
{
    [super setUp];
}

- (void)tearDown;
{
    _scanner = nil;
    [super tearDown];
}

- (void)testInteger;
{
    _scanner = [[NSScanner alloc] initWithString:@"123"];
    NSInteger value;
    BOOL result = [_scanner scanInteger:&value];
    XCTAssertTrue(result);
    XCTAssert(value == 123);
}

- (void)testPositiveInteger;
{
    _scanner = [[NSScanner alloc] initWithString:@"+123"];
    NSInteger value;
    BOOL result = [_scanner scanInteger:&value];
    XCTAssertTrue(result);
    XCTAssert(value == 123);
}

- (void)testNegativeInteger;
{
    _scanner = [[NSScanner alloc] initWithString:@"-123"];
    NSInteger value;
    BOOL result = [_scanner scanInteger:&value];
    XCTAssertTrue(result);
    XCTAssert(value == -123);
}

- (void)testDouble;
{
    _scanner = [[NSScanner alloc] initWithString:@"123.456"];
    double value;
    BOOL result = [_scanner scanDouble:&value];
    XCTAssertTrue(result);
    XCTAssert(value == 123.456);
}

- (void)testDoubleWithExponent;
{
    _scanner = [[NSScanner alloc] initWithString:@"1.23456e3"];
    double value;
    BOOL result = [_scanner scanDouble:&value];
    XCTAssertTrue(result);
    XCTAssert(value == 1234.56);
}

@end

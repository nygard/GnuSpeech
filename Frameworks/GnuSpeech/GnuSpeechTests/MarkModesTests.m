#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "GSTextParser.h"
#import "GSTextParser-Private.h"

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

- (void)testExample;
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSString *inputString = @"one and %eb two there %ee four %rb and then raw mode begins %re normal again %tb +12345 blah blah blah";
    NSAttributedString *outputString = [_parser _markModesInString:inputString];

    NSLog(@"inputString: %@", inputString);
    NSLog(@"outputString: %@", outputString);
}

- (void)testTagging;
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSString *inputString = @"one two %tb 1234 %te three four %tb 5678 five";
    NSAttributedString *outputString = [_parser _markModesInString:inputString];

    NSLog(@"inputString: %@", inputString);
    NSLog(@"outputString: %@", outputString);
}

@end

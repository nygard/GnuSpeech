#import "GSTextGroupBuilder.h"

#import "GSTextGroup.h"
#import "GSTextRun.h"

@interface GSTextGroupBuilder ()
@property (readwrite) GSTextParserMode currentMode;
@property (readonly) NSMutableArray *stack;
@end

@implementation GSTextGroupBuilder
{
    GSTextParserMode _currentMode;
    NSMutableArray *_stack;

    GSTextGroup *_textGroup;
    GSTextRun *_currentTextRun;
}

- (id)init;
{
    if ((self = [super init])) {
        _currentMode = GSTextParserMode_Normal;
        _stack = [[NSMutableArray alloc] init];
        [_stack addObject:@(_currentMode)];

        _textGroup = [[GSTextGroup alloc] init];
        _currentTextRun = [[GSTextRun alloc] initWithMode:_currentMode];
        [_textGroup addTextRun:_currentTextRun];
    }

    return self;
}

- (void)pushMode:(GSTextParserMode)mode;
{
    if ([_currentTextRun.string length] == 0) {
        [_textGroup removeTextRun:_currentTextRun];
        _currentTextRun = nil;
    }

    self.currentMode = mode;
    [self.stack addObject:@(mode)];

    _currentTextRun = [[GSTextRun alloc] initWithMode:self.currentMode];
    [_textGroup addTextRun:_currentTextRun];
}

- (BOOL)popMode:(GSTextParserMode)mode;
{
    if (self.currentMode == mode) {
        if ([_currentTextRun.string length] == 0) {
            [_textGroup removeTextRun:_currentTextRun];
            _currentTextRun = nil;
        }
        [self.stack removeLastObject];
        self.currentMode = [[self.stack lastObject] unsignedIntegerValue];
        _currentTextRun = [[GSTextRun alloc] initWithMode:self.currentMode];
        [_textGroup addTextRun:_currentTextRun];
        return YES;
    }

    return NO;
}

- (void)finish;
{
    if ([_currentTextRun.string length] == 0) {
        [_textGroup removeTextRun:_currentTextRun];
        _currentTextRun = nil;
    }
}

@end

#import "GSTextParserModeStack.h"

@interface GSTextParserModeStack ()
@property (readwrite) GSTextParserMode currentMode;
@property (readonly) NSMutableArray *stack;
@end

@implementation GSTextParserModeStack
{
    GSTextParserMode _currentMode;
    NSMutableArray *_stack;
}

- (id)init;
{
    if ((self = [super init])) {
        _currentMode = GSTextParserMode_Normal;
        _stack = [[NSMutableArray alloc] init];
        [_stack addObject:@(_currentMode)];
    }

    return self;
}

- (void)pushMode:(GSTextParserMode)mode;
{
    self.currentMode = mode;
    [self.stack addObject:@(mode)];
}

- (BOOL)popMode:(GSTextParserMode)mode;
{
    if (self.currentMode == mode) {
        [self.stack removeLastObject];
        self.currentMode = [[self.stack lastObject] unsignedIntegerValue];
        return YES;
    }

    return NO;
}

@end

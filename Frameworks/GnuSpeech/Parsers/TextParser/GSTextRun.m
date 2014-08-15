#import "GSTextRun.h"

@implementation GSTextRun
{
    GSTextParserMode _mode;
    NSMutableString *_string;
}

- (id)initWithMode:(GSTextParserMode)mode;
{
    if ((self = [super init])) {
        _mode = mode;
        _string = [[NSMutableString alloc] init];
    }

    return self;
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p> mode: %@, string: '%@'",
            NSStringFromClass([self class]), self,
            [GSTextParserModeDescription(self.mode) stringByPaddingToLength:8 withString:@" " startingAtIndex:0], self.string];
}

#pragma mark -


@end

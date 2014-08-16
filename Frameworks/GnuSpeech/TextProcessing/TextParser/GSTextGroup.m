#import "GSTextGroup.h"

#import "GSTextRun.h"

@implementation GSTextGroup
{
    NSMutableArray *_mutableTextRuns;
}

- (id)init;
{
    if ((self = [super init])) {
        _mutableTextRuns = [[NSMutableArray alloc] init];
    }

    return self;
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p> textRuns: %@",
            NSStringFromClass([self class]), self,
            _mutableTextRuns];
}

#pragma mark -

- (NSArray *)textRuns;
{
    return [_mutableTextRuns copy];
}

- (void)addTextRun:(GSTextRun *)textRun;
{
    [_mutableTextRuns addObject:textRun];
}

- (void)removeTextRun:(GSTextRun *)textRun;
{
    [_mutableTextRuns removeObject:textRun];
}

@end

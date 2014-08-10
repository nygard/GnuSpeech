#import "MMPhone.h"

#import "MMPosture.h"

@implementation MMPhone
{
    MMPosture *_posture;
    NSUInteger _syllable;
    double _onset;
    float _ruleTempo;
    double _tempo;
}

- (id)initWithPosture:(MMPosture *)posture;
{
    if ((self = [super init])) {
        _posture = posture;
        _syllable = 0;
        _onset = 0;
        _ruleTempo =  1.0;
        _tempo = 1.0;
    }

    return self;
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p>, syllable: %lu, onset: %f, ruleTempo: %f, tempo: %f, posture: %@",
            NSStringFromClass([self class]), self,
            self.syllable, self.onset, self.ruleTempo, self.tempo, [self.posture shortDescription]];
}

@end

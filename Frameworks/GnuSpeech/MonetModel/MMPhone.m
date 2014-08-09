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

@end

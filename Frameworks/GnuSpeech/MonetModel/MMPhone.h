#import <Foundation/Foundation.h>

@class MMPosture;

@interface MMPhone : NSObject

- (id)initWithPosture:(MMPosture *)posture;

@property (retain) MMPosture *posture;
@property (assign) NSUInteger syllable; // TODO (2004-08-12): This isn't used for anything right now.
@property (assign) double onset;
@property (assign) float ruleTempo;
@property (assign) double tempo; // formerly phoneTempo in EventList.

@end

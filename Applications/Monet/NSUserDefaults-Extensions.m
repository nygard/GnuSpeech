#import "NSUserDefaults-Extensions.h"

#import <Foundation/Foundation.h>

@implementation NSUserDefaults (Extensions)

- (double)doubleForKey:(NSString *)defaultName;
{
    id objectValue;

    objectValue = [self objectForKey:defaultName];
    if (objectValue == nil)
        return 0; // TODO (2004-03-02): Or should we use NaN?

    return [objectValue doubleValue];
}

- (void)setDouble:(double)value forKey:(NSString *)defaultName;
{
    [self setObject:[NSNumber numberWithDouble:value] forKey:defaultName];
}

@end

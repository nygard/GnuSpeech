#import <Foundation/NSUserDefaults.h>

@interface NSUserDefaults (Extensions)

- (double)doubleForKey:(NSString *)defaultName;
- (void)setDouble:(double)value forKey:(NSString *)defaultName;

@end

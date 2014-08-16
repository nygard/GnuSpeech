#import <Foundation/Foundation.h>

@class GSTextRun;

@interface GSTextGroup : NSObject

@property (nonatomic, readonly) NSArray *textRuns;

- (void)addTextRun:(GSTextRun *)textRun;
- (void)removeTextRun:(GSTextRun *)textRun;

@end

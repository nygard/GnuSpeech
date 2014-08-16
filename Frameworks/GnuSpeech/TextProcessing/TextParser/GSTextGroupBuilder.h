#import <Foundation/Foundation.h>

#import "GSTextParserMode.h"

@class GSTextGroup, GSTextRun;

@interface GSTextGroupBuilder : NSObject

@property (readonly) GSTextParserMode currentMode;

- (void)pushMode:(GSTextParserMode)mode;
- (BOOL)popMode:(GSTextParserMode)mode;
- (void)finish;

@property (readonly) GSTextGroup *textGroup;
@property (readonly) GSTextRun *currentTextRun;

@end

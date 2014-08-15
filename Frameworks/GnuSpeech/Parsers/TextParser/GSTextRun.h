#import <Foundation/Foundation.h>

#import "GSTextParserMode.h"

@interface GSTextRun : NSObject

- (id)initWithMode:(GSTextParserMode)mode;

@property (readonly) GSTextParserMode mode;
@property (strong) NSMutableString *string;

@end

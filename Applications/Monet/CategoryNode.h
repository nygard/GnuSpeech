
#import <Foundation/NSObject.h>
#ifdef NeXT
#import <objc/typedstream.h>
#endif

@interface CategoryNode:NSObject
{
	char *symbol;
	char *comment;
	int native;
}

- init;
- initWithSymbol:(const char *) newSymbol;

- (void)setSymbol:(const char *)newSymbol;
- (const char *)symbol;
- (void)setComment:(const char *)newComment;
- (const char *) comment;

- (void)setNative:(int)isNative;
- (int) native;

- (void)dealloc;
- (void)freeIfNative;

- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;
@end

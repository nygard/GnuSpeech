#import <Foundation/NSObject.h>

@interface MMCategory : NSObject
{
    NSString *name; // TODO (2004-03-18): Create named/commented object.
    NSString *comment;
    BOOL isNative;
}

- (id)init;
- (id)initWithName:(NSString *)aName;
- (void)dealloc;

- (NSString *)name;
- (void)setName:(NSString *)newName;

- (NSString *)comment;
- (void)setComment:(NSString *)newComment;
- (BOOL)hasComment;

- (BOOL)isNative;
- (void)setIsNative:(BOOL)newFlag;

- (NSComparisonResult)compareByAscendingName:(MMCategory *)otherCategory;

- (NSString *)description;

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
- (void)loadFromXMLElement:(NSXMLElement *)element context:(id)context;

@end

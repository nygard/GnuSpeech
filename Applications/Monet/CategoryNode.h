#import <Foundation/NSObject.h>

@interface CategoryNode : NSObject
{
    NSString *symbol;
    NSString *comment;
    BOOL isNative;
}

- (id)init;
- (id)initWithSymbol:(NSString *)newSymbol;
- (void)dealloc;

- (NSString *)symbol;
- (void)setSymbol:(NSString *)newSymbol;

- (NSString *)comment;
- (void)setComment:(NSString *)newComment;

- (BOOL)isNative;
- (void)setIsNative:(BOOL)newFlag;

// Archiving
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

- (NSString *)description;

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level useReferences:(BOOL)shouldUseReferences;

@end

#import "CategoryNode.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "GSXMLFunctions.h"

@implementation CategoryNode

- (id)init;
{
    if ([super init] == nil)
        return nil;

    symbol = nil;
    comment = nil;
    isNative = NO;

    return self;
}

- (id)initWithSymbol:(NSString *)newSymbol;
{
    if ([self init] == nil)
        return nil;

    [self setSymbol:newSymbol];

    return self;
}

- (void)dealloc;
{
    [symbol release];
    [comment release];

    [super dealloc];
}

#ifdef PORTING
- (void)freeIfNative;
{
    if (isNative)
        [self release];
}
#endif

- (NSString *)symbol;
{
    return symbol;
}

- (void)setSymbol:(NSString *)newSymbol;
{
    if (newSymbol == symbol)
        return;

    [symbol release];
    symbol = [newSymbol retain];
}

- (NSString *)comment;
{
    return comment;
}

- (void)setComment:(NSString *)newComment;
{
    if (newComment == comment)
        return;

    [comment release];
    comment = [newComment retain];
}

- (BOOL)isNative;
{
    return isNative;
}

- (void)setIsNative:(BOOL)newFlag;
{
    isNative = newFlag;
}

//
// Archiving
//

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    unsigned archivedVersion;
    char *c_symbol, *c_comment;

    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    //NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    archivedVersion = [aDecoder versionForClassName:NSStringFromClass([self class])];
    //NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

    [aDecoder decodeValuesOfObjCTypes:"**i", &c_symbol, &c_comment, &isNative];
    //NSLog(@"c_symbol: %s, c_comment: %s, isNative: %d", c_symbol, c_comment, isNative);

    symbol = [[NSString stringWithASCIICString:c_symbol] retain];
    comment = [[NSString stringWithASCIICString:c_comment] retain];

    //NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
#ifdef PORTING
    [aCoder encodeValuesOfObjCTypes:"**i", &symbol, &comment, &isNative];
#endif
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: symbol: %@, comment: %@, isNative: %d",
                     NSStringFromClass([self class]), self, symbol, comment, isNative];
}

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
{
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<category ptr=\"%p\" symbol=\"%@\" is-native=\"%@\"",
                  self, GSXMLAttributeString(symbol, NO), GSXMLBoolAttributeString(isNative)];

    if (comment == nil) {
        [resultString appendString:@"/>\n"];
    } else {
        [resultString appendString:@">\n"];
        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<comment>%@</comment>\n", GSXMLCharacterData(comment)];

        [resultString indentToLevel:level];
        [resultString appendString:@"</category>\n"];
    }
}

@end

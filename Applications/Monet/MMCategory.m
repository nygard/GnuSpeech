#import "MMCategory.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "GSXMLFunctions.h"

@implementation MMCategory

- (id)init;
{
    if ([super init] == nil)
        return nil;

    name = nil;
    comment = nil;
    isNative = NO;

    return self;
}

- (id)initWithName:(NSString *)aName;
{
    if ([self init] == nil)
        return nil;

    [self setName:aName];

    return self;
}

- (void)dealloc;
{
    [name release];
    [comment release];

    [super dealloc];
}

- (NSString *)name;
{
    return name;
}

- (void)setName:(NSString *)newName;
{
    if (newName == name)
        return;

    [name release];
    name = [newName retain];
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

- (BOOL)hasComment;
{
    return comment != nil && [comment length] > 0;
}

- (BOOL)isNative;
{
    return isNative;
}

- (void)setIsNative:(BOOL)newFlag;
{
    isNative = newFlag;
}

- (NSComparisonResult)compareByAscendingName:(MMCategory *)otherCategory;
{
    return [name compare:[otherCategory name]];
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: name: %@, comment: %@, isNative: %d",
                     NSStringFromClass([self class]), self, name, comment, isNative];
}

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
{
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<category name=\"%@\"", GSXMLAttributeString(name, NO)];

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

- (void)loadFromXMLElement:(NSXMLElement *)element context:(id)context;
{
    NSArray *comments;
    unsigned int count, index;

    [self setName:[[element attributeForName:@"name"] stringValue]];

    comments = [element elementsForName:@"comment"];
    count = [comments count];
    for (index = 0; index < count; index++) {
        NSXMLElement *commentElement;

        commentElement = [comments objectAtIndex:index];
        [self setComment:[commentElement stringValue]];
    }
}

@end

#import "NamedList.h"

#import <Foundation/Foundation.h>
#import "NSString-Extensions.h"
#import "MMTarget.h" // Just to get -appendXMLToString:level:, this is just a quick hack

#import "GSXMLFunctions.h"

/*===========================================================================


===========================================================================*/

@implementation NamedList

- (id)initWithCapacity:(unsigned)numSlots;
{
    if ([super initWithCapacity:numSlots] == nil)
        return nil;

    comment = nil;
    name = nil;

    return self;
}

- (void)dealloc;
{
    [comment release];
    [name release];

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

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    unsigned archivedVersion;
    char *c_name, *c_comment;
    unsigned int count, index;

    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    //NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    archivedVersion = [aDecoder versionForClassName:NSStringFromClass([self class])];
    //NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

    [aDecoder decodeValuesOfObjCTypes:"**", &c_name, &c_comment];
    [self setName:[NSString stringWithASCIICString:c_name]];
    [self setComment:[NSString stringWithASCIICString:c_comment]];

    count = [self count];
    for (index = 0; index < count; index++) {
        id anObject;

        anObject = [self objectAtIndex:index];
        if ([anObject respondsToSelector:@selector(setGroup:)] == YES)
            [anObject setGroup:self];
    }

    //NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [super encodeWithCoder:aCoder];

    [aCoder encodeObject:name];
    [aCoder encodeObject:comment];
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: name: %@, comment: %@",
                     NSStringFromClass([self class]), self, name, comment];
}

- (void)appendXMLToString:(NSMutableString *)resultString elementName:(NSString *)elementName level:(int)level;
{
    int count, index;

    count = [self count];
    if (count == 0)
        return;

    [resultString indentToLevel:level];
    [resultString appendFormat:@"<%@ name=\"%@\"", elementName, GSXMLAttributeString(name, NO)];

    if (comment != nil)
        [resultString appendFormat:@" comment=\"%@\"", GSXMLAttributeString(comment, NO)];

    [resultString appendString:@">\n"];

    for (index = 0; index < count; index++) {
        id anObject;

        anObject = [self objectAtIndex:index];
        [anObject appendXMLToString:resultString level:level+1];
    }

    [resultString indentToLevel:level];
    [resultString appendFormat:@"</%@>\n", elementName];
}

- (void)addObject:(id)anObject;
{
    [super addObject:anObject];

    if ([anObject respondsToSelector:@selector(setGroup:)] == YES)
        [anObject setGroup:self];
}

- (void)insertObject:(id)anObject atIndex:(unsigned)index;
{
    [super insertObject:anObject atIndex:index];

    if ([anObject respondsToSelector:@selector(setGroup:)] == YES)
        [anObject setGroup:self];
}

- (void)replaceObjectAtIndex:(unsigned)index withObject:(id)anObject;
{
    [super replaceObjectAtIndex:index withObject:anObject];

    if ([anObject respondsToSelector:@selector(setGroup:)] == YES)
        [anObject setGroup:self];
}


@end

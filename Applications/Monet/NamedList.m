#import "NamedList.h"

#import <Foundation/Foundation.h>
#import "NSString-Extensions.h"

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

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    char *c_name, *c_comment;

    //NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);

    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    [aDecoder decodeValuesOfObjCTypes:"**", &c_name, &c_comment];
    [self setName:[NSString stringWithASCIICString:c_name]];
    [self setComment:[NSString stringWithASCIICString:c_comment]];

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

@end

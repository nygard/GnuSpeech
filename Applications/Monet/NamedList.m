#import "NamedList.h"

#import <Foundation/Foundation.h>

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

#if PORTING
- (id)initWithCoder:(NSCoder *)aDecoder;
{
    [super initWithCoder:aDecoder];

    [aDecoder decodeValuesOfObjCTypes:"**", &name, &comment];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [super encodeWithCoder:aCoder];

    [aCoder encodeValuesOfObjCTypes:"**", &name, &comment];
}
#endif

#ifdef NeXT
- read:(NXTypedStream *)stream;
{
    [super read:stream];

    NXReadTypes(stream, "**", &name, &comment);

    return self;
}
#endif

@end


#import "NamedList.h"
#import <Foundation/NSCoder.h>
#import <Foundation/NSString.h>
#import <stdio.h>
#import <stdlib.h>

/*===========================================================================


===========================================================================*/

@implementation NamedList

- initWithCapacity: (unsigned) numSlots
{
	[super initWithCapacity:numSlots];
	comment = NULL;
	name = NULL;

	return self;
}

- init
{
	[super init];
	comment = NULL;
	name = NULL;

	return self;

}

- setName:(NSString *)newName
{
int len;
	if (name)
		free(name);

	len = [newName length];
	name = (char *) malloc(len+1);
	strcpy(name, [newName cString]);

	return self;
}

- (NSString *)name
{
	return [NSString stringWithCString:( (const char *) name)];
}

- (void)setComment:(const char *)newComment
{
int len;

	if (comment)
		free(comment);

	len = strlen(newComment);
	comment = (char *) malloc(len+1);
	strcpy(comment, newComment); 
}

- (const char *) comment
{
	return comment;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	[super initWithCoder:aDecoder];

	[aDecoder decodeValuesOfObjCTypes:"**", &name, &comment];

	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[super encodeWithCoder:aCoder];

	[aCoder encodeValuesOfObjCTypes:"**", &name, &comment];
}

#ifdef NeXT
- read:(NXTypedStream *)stream
{
        [super read:stream];

        NXReadTypes(stream, "**", &name, &comment);

        return self;
}
#endif

@end

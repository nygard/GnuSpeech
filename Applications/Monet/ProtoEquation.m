
#import "ProtoEquation.h"
#import <Foundation/NSString.h>
#import <Foundation/NSCoder.h>
#import <stdio.h>
#import <string.h>
#import <stdlib.h>

@implementation ProtoEquation

- init
{
	name = NULL;
	comment = NULL;
	expression = nil;
	return self;
}

- initWithName:(NSString *)newName
{
	[self setName:newName];
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

- (void)setExpression:newExpression
{
	expression = newExpression; 
}

- expression
{
	return expression;
}

- (double) evaluate: (double *) ruleSymbols tempos: (double * ) tempos phones: phones andCacheWith: (int) newCacheTag
{
	if (newCacheTag != cacheTag)
	{
		cacheTag = newCacheTag;
		cacheValue = [expression evaluate: ruleSymbols tempos: tempos phones: phones];
	}
	return cacheValue;

}
- (double) evaluate: (double *) ruleSymbols phones: phones andCacheWith: (int) newCacheTag
{
	if (newCacheTag != cacheTag)
	{
		cacheTag = newCacheTag;
		cacheValue = [expression evaluate: ruleSymbols phones: phones];
	}
	return cacheValue;
}

- (double) cacheValue
{
	return cacheValue;
}

- (void)dealloc
{
	if (name) 
		free(name);

	if (comment) 
		free(comment);

	if (expression)
		[expression release];

	[super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	cacheTag = 0;
	cacheValue = 0.0;

	[aDecoder decodeValuesOfObjCTypes:"**", &name, &comment];
	expression = [[aDecoder decodeObject] retain];

	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeValuesOfObjCTypes:"**", &name, &comment];
	[aCoder encodeObject:expression];
}

#ifdef NeXT
- read:(NXTypedStream *)stream
{

        cacheTag = 0;
        cacheValue = 0.0;

        NXReadTypes(stream, "**", &name, &comment);
        expression = NXReadObject(stream);

        return self;
}
#endif

@end


#import <Foundation/NSCoder.h>
#import "CategoryNode.h"
#import <stdio.h>
#import <string.h>
#import <stdlib.h>

@implementation CategoryNode

- init
{
	symbol = NULL;
	comment = NULL;
	native = 0;
	return self;
}

- initWithSymbol:(const char *) newSymbol
{
	[self setSymbol:newSymbol];
	return self;
}

- (void)setSymbol:(const char *)newSymbol
{
int len;
	if (symbol)
		free(symbol);

	len = strlen(newSymbol);
	symbol = (char *) malloc(len+1);
	strcpy(symbol, newSymbol); 
}

- (const char *)symbol
{
	return( (const char *) symbol);
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

- (void)dealloc
{
	if (symbol) 
		free(symbol);

	if (comment) 
		free(comment);

	[super dealloc];
}

- (void)freeIfNative
{
	if (native)
		[self release];
}

- (void)setNative:(int)isNative
{
	native = isNative; 
}

- (int) native
{
	return native;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	[aDecoder decodeValuesOfObjCTypes:"**i", &symbol, &comment, &native];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeValuesOfObjCTypes:"**i", &symbol, &comment, &native];
}

#ifdef NeXT
- read:(NXTypedStream *)stream
{
        NXReadTypes(stream, "**i", &symbol, &comment, &native);
        return self;
}
#endif

@end


#import "Parameter.h"
#import <Foundation/NSCoder.h>
#import <stdio.h>
#import <string.h>
#import <stdlib.h>

@implementation Parameter

- init
{
	parameterSymbol = NULL;
	comment = NULL;

	minimum = 0.0;
	maximum = 0.0;
	defaultValue = 0.0;
	
	return self;
}

- initWithSymbol:(const char *) newSymbol
{
	[self init];
	[self setSymbol:newSymbol];
	return self;
}

- (void)dealloc
{
	if (parameterSymbol) 
		free(parameterSymbol);

	if (comment)
		free(comment);

	[super dealloc];
}

- (void)setSymbol:(const char *)newSymbol
{
int len;

	if (parameterSymbol)
		free(parameterSymbol);

	len = strlen(newSymbol);
	parameterSymbol = (char *) malloc(len+1);
	strcpy(parameterSymbol, newSymbol); 
}

- (const char *)symbol
{
	return (parameterSymbol);
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

- (void)setMinimumValue:(double)newMinimum
{
	minimum = newMinimum; 
}

- (double) minimumValue
{
	return minimum;
}

- (void)setMaximumValue:(double)newMaximum
{
	maximum = newMaximum; 
}

- (double) maximumValue
{
	return maximum;
}

- (void)setDefaultValue:(double)newDefault
{
	defaultValue = newDefault; 
}

- (double) defaultValue
{
	return defaultValue;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	[aDecoder decodeValuesOfObjCTypes:"**ddd", &parameterSymbol, &comment, &minimum, &maximum, &defaultValue];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeValuesOfObjCTypes:"**ddd", &parameterSymbol, &comment, &minimum, &maximum, &defaultValue];
}

#ifdef NeXT
- read:(NXTypedStream *)stream
{
        NXReadTypes(stream, "**ddd", &parameterSymbol, &comment, &minimum, &maximum, &defaultValue);
        return self;
}
#endif


@end

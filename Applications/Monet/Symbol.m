
#import "Symbol.h"
#import "MyController.h"
#import <stdio.h>
#import <string.h>
#import <stdlib.h>

@implementation Symbol

- init
{
	symbol = NULL;
	comment = NULL;

	minimum = 0.0;
	maximum = 0.0;
	defaultValue = 0.0;

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
	[aDecoder decodeValuesOfObjCTypes:"**ddd", &symbol, &comment, &minimum, &maximum, &defaultValue];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeValuesOfObjCTypes:"**ddd", &symbol, &comment, &minimum, &maximum, &defaultValue];
}

#ifdef NeXT
- read:(NXTypedStream *)stream
{
//      NXReadTypes(stream, "**", &symbol, &comment);
        NXReadTypes(stream, "**ddd", &symbol, &comment, &minimum, &maximum, &defaultValue);
        return self;
}
#endif

@end

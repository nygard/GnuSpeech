
#import "Target.h"
#import <Foundation/NSCoder.h>
#ifdef NeXT
#import <objc/typedstream.h>
#endif
#import <stdio.h>
#import <string.h>
#import <stdlib.h>

@implementation Target

- init
{
	is_default = 1;
	value = 0.0;
	return self;
}

- initWithValue:(double) newValue isDefault:(int) isDefault
{
	[self setValue:newValue];
	[self setDefault:isDefault];
	return self;
}

- (void)setValue:(double)newValue
{
	value = newValue; 
}

- (double) value
{
	return(value);
}

- (void)setDefault:(int)isDefault
{
	is_default = isDefault; 
}

- (int)isDefault
{
	return (is_default);
}

- setValue:(double) newValue isDefault:(int) isDefault
{
	[self setValue:newValue];
	[self setDefault:isDefault];
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	[aDecoder decodeValuesOfObjCTypes:"id", &is_default, &value];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeValuesOfObjCTypes:"id", &is_default, &value];
}

#ifdef NeXT
- read:(NXTypedStream *)stream
{
        NXReadTypes(stream, "id", &is_default, &value);
        return self;
}
#endif

@end

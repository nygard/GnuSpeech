
#import "Phone.h"
#import "ParameterList.h"
#import "MyController.h"
#import <stdio.h>
#import <string.h>
#import <stdlib.h>
#import <AppKit/NSApplication.h>
#import <Foundation/NSCoder.h>

@implementation Phone

- init
{
	categoryList = [[CategoryList alloc] initWithCapacity:15];
	parameterList = [[TargetList alloc] initWithCapacity:15];
	metaParameterList = [[TargetList alloc] initWithCapacity:15];
	symbolList = [[TargetList alloc] initWithCapacity:15];

	phoneSymbol = NULL;
	comment = NULL;

	return self;
}

- initWithSymbol:(const char *) newSymbol
{
	[self init];
	[self setSymbol:newSymbol];
	return self;
}

- initWithSymbol:(const char *) newSymbol parmeters:parms metaParameters: metaparms symbols:symbols
{
int i;
id temp;

	categoryList = [[CategoryList alloc] initWithCapacity:15];

	parameterList = [[TargetList alloc] initWithCapacity:[parms count]];
	for (i = 0; i<[parms count]; i++)
	{
		temp = [[Target alloc] initWithValue: [[parms objectAtIndex:i] defaultValue] isDefault: YES];
		[parameterList addObject:temp];
	}

	metaParameterList = [[TargetList alloc] initWithCapacity:[metaparms count]];
	for (i = 0; i<[metaparms count]; i++)
	{
		temp = [[Target alloc] initWithValue: [[metaparms objectAtIndex:i] defaultValue] isDefault: YES];
		[metaParameterList addObject:temp];
	}

	symbolList = [[TargetList alloc] initWithCapacity:[symbols count]];
	for (i = 0; i<[symbols count]; i++)
	{
		temp = [[Target alloc] initWithValue: [[symbols objectAtIndex: i] defaultValue] isDefault: YES];
		[symbolList addObject:temp];
	}

	comment = NULL;
	phoneSymbol = NULL;
	[self setSymbol:newSymbol];

	return self;
}

- (void)dealloc
{
	if (phoneSymbol) 
		free(phoneSymbol);

	if (comment) 
		free(comment);

	[categoryList freeNativeCategories];
	[categoryList release];

	[parameterList release];
	[metaParameterList release];
	[symbolList release];

	[super dealloc];
}

- (void)setSymbol:(const char *)newSymbol
{
int len;
int i;
CategoryNode *tempCategory;

	if (phoneSymbol)
		free(phoneSymbol);

	len = strlen(newSymbol);
	phoneSymbol = (char *) malloc(len+1);
	strcpy(phoneSymbol, newSymbol);

	for(i = 0; i<[categoryList count]; i++)
	{
		tempCategory = [categoryList objectAtIndex: i];
		if ([tempCategory native])
		{
			[tempCategory setSymbol:newSymbol];
			return;
		}
	} 
}

- (const char *)symbol
{
	return (phoneSymbol);
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

- (void)addToCategoryList:(CategoryNode *)aCategory
{
	 
}

- categoryList
{
	return (categoryList);
}

- parameterList
{
	return (parameterList);
}

- metaParameterList
{
	return metaParameterList;
}

- symbolList
{
	return symbolList;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
int i, j;
CategoryList *temp;
CategoryNode *temp1;
char *string;

	temp = NXGetNamedObject("mainCategoryList", NSApp);

        [aDecoder decodeValuesOfObjCTypes:"**", &phoneSymbol, &comment];

	parameterList = [[aDecoder decodeObject] retain];
	metaParameterList = [[aDecoder decodeObject] retain];
	symbolList = [[aDecoder decodeObject] retain];

	if (categoryList)
		[categoryList release];

	[aDecoder decodeValueOfObjCType:"i" at:&i];
//	printf("TOTAL Categories for %s = %d\n", phoneSymbol, i);

	categoryList = [[CategoryList alloc] initWithCapacity:i];

	for (j = 0; j<i; j++)
	{
		[aDecoder decodeValueOfObjCType:"*" at:&string];
		if ((temp1 = [temp findSymbol:string]) )
		{
//			printf("Read category: %s\n", string);
			[categoryList addObject:temp1];
		}
		else
		{
//			printf("Read NATIVE category: %s\n", string);
			if (strcmp(phoneSymbol, string)!=0)
			{
				printf("NATIVE Category Wrong... correcting: %s -> %s", string, phoneSymbol);
				[categoryList addNativeCategory:phoneSymbol];
			}
			else
				[categoryList addNativeCategory:string];
		}
		free(string);
	}


        return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
int i;
const char *temp;

//	printf("\tSaving %s\n", phoneSymbol);
        [aCoder encodeValuesOfObjCTypes:"**", &phoneSymbol, &comment];

//	printf("\tSaving parameter, meta, and symbolList\n", phoneSymbol);
	[aCoder encodeObject:parameterList];
	[aCoder encodeObject:metaParameterList];
	[aCoder encodeObject:symbolList];

//	printf("\tSaving categoryList\n", phoneSymbol);
	/* Here's the tricky one! */
	i = [categoryList count];

	[aCoder encodeValueOfObjCType:"i" at:&i];
	for(i = 0; i<[categoryList count]; i++)
	{
		temp = [[categoryList objectAtIndex:i] symbol];
		[aCoder encodeValueOfObjCType:"*" at:&temp];
	}
}

#ifdef NeXT
- read:(NXTypedStream *)stream
{
int i, j;
CategoryList *temp;
CategoryNode *temp1;
char *string;

        temp = NXGetNamedObject("mainCategoryList", NSApp);

        NXReadTypes(stream, "**", &phoneSymbol, &comment);

        parameterList = NXReadObject(stream);
        metaParameterList = NXReadObject(stream);
        symbolList = NXReadObject(stream);

        if (categoryList)
                [categoryList release];

        NXReadType(stream,"i", &i);
//      printf("TOTAL Categories for %s = %d\n", phoneSymbol, i);

        categoryList = [[CategoryList alloc] initWithCapacity:i];

        for (j = 0; j<i; j++)
        {
                NXReadType(stream, "*", &string);
                if (temp1 = [temp findSymbol:string] )
                {
//                      printf("Read category: %s\n", string);
                        [categoryList addObject:temp1];
                }
                else
                {
//                      printf("Read NATIVE category: %s\n", string);
                        if (strcmp(phoneSymbol, string)!=0)
                        {
                                printf("NATIVE Category Wrong... correcting: %s -> %s", string, phoneSymbol);
                                [categoryList addNativeCategory:phoneSymbol];
                        }
                        else
                                [categoryList addNativeCategory:string];
                }
                free(string);
        }


        return self;
}
#endif

@end

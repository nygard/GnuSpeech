
#import "BooleanTerminal.h"
#import "PhoneList.h"
#import "MyController.h"
#import <AppKit/NSApplication.h>
#import <Foundation/NSCoder.h>
#import <stdio.h>
#import <string.h>

@implementation BooleanTerminal

- init
{
	category = nil;
	matchAll = 0;
	return self;
}

- (void)setCategory:newCategory
{
	category = newCategory; 
}
- category
{
	return category;
}

- (void)setMatchAll:(int)value
{
	matchAll = value; 
}
- (int) matchAll
{
	return matchAll;
}

- (int) evaluate: (CategoryList *) categories
{
char string[256];

	if ([categories indexOfObject: category] == NSNotFound)
	{
		if (matchAll)
		{
			sprintf(string,"%s", [category symbol]);
			if ([categories findSymbol:string])
				return 1;

			sprintf(string,"%s'", [category symbol]);
			if ([categories findSymbol:string])
				return 1;
		}
		return 0;
	}
	else
	{
		return 1;
	}
}

- (void)optimize
{
	 
}

- (void)optimizeSubExpressions
{
	 
}

- (int) maxExpressionLevels
{
	return 1;
}
- expressionString:(char *)string
{
	if (category == nil)
		return NULL;

//	printf("%s", [category symbol]);
	strcat(string, [category symbol]);
	if (matchAll)
		strcat(string, "*");
	return self;
}

- (BOOL) isCategoryUsed: aCategory
{
	if (category == aCategory)
		return YES;
	return NO;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
char *string;
CategoryList *temp;
PhoneList *phoneList;
CategoryNode *temp1;

	temp = NXGetNamedObject("mainCategoryList", NSApp);
	phoneList = NXGetNamedObject("mainPhoneList", NSApp);

	[aDecoder decodeValueOfObjCType:"i" at:&matchAll];

	[aDecoder decodeValueOfObjCType:"*" at:&string];

	temp1 = [temp findSymbol:string];
	if (!temp1)
	{
		temp1 = [[[phoneList findPhone:string] categoryList] findSymbol:string];
		category = temp1;
	}
	else
	{
		category = temp1;
	}

	free(string);
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
const char *temp;

	[aCoder encodeValueOfObjCType:"i" at:&matchAll];

	temp = [category symbol];
	[aCoder encodeValueOfObjCType:"*" at:&temp];
}

#ifdef NeXT
- read:(NXTypedStream *)stream
{
char *string;
CategoryList *temp;
PhoneList *phoneList;
CategoryNode *temp1;

        temp = NXGetNamedObject("mainCategoryList", NSApp);
        phoneList = NXGetNamedObject("mainPhoneList", NSApp);

        NXReadType(stream, "i", &matchAll);

        NXReadType(stream, "*", &string);

        temp1 = [temp findSymbol:string];
        if (!temp1)
        {
                temp1 = [[[phoneList findPhone:string] categoryList] findSymbol:string];
                category = temp1;
        }
        else
        {
                category = temp1;
        }

        free(string);
        return self;
}
#endif

@end

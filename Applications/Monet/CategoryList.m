
#import "CategoryList.h"
#import "MyController.h"

/*===========================================================================

	This Class currently adds no functionality to the List class.
	However, it is planned that this object will provide sorting functions
	to the CategoryNode class.

===========================================================================*/

@implementation CategoryList

- findSymbol:(const char *)searchSymbol
{
int i;
const char *temp;

//	printf("CategoryList searching for: %s\n", searchSymbol);
	for (i = 0; i<[self count]; i++)
	{
		temp = [[self objectAtIndex: i] symbol];
		if (strcmp(temp, searchSymbol)==0)
		{
//			printf("Found: %s\n", searchSymbol);
			return [self objectAtIndex: i];
		}
	}
//	printf("Could not find: %s\n", searchSymbol);
	return nil;
}

- addCategory:(const char *)newCategory
{
CategoryNode *tempCategory;

	tempCategory = [[CategoryNode alloc] initWithSymbol: newCategory];
	[self addObject: tempCategory];

	return tempCategory;
}

- (void)addNativeCategory:(const char *)newCategory
{
CategoryNode *tempCategory;

	tempCategory = [[CategoryNode alloc] initWithSymbol: newCategory];
	[tempCategory setNative:1];
	[self addObject: tempCategory]; 
}

- (void)freeNativeCategories
{

	[self makeObjectsPerform: (SEL)(@selector(freeIfNative))]; 
}

/* BrowserManager List delegate Methods */
- (void)addNewValue:(const char *)newValue
{
	[self addCategory:newValue]; 
}

- findByName:(const char *)name
{
	return [self findSymbol:name];
}

- (void)changeSymbolOf:temp to:(const char *)name
{
	[temp setSymbol:name]; 
}

#define SYMBOL_LENGTH_MAX 12
- (void)readDegasFileFormat:(FILE *)fp
{
int i, count;

CategoryNode *currentNode;
char tempString[SYMBOL_LENGTH_MAX+1];

	/* Load in the count */
	fread(&count,sizeof(int),1,fp);

	for (i = 0; i < count; i++)
	{
		fread(tempString,SYMBOL_LENGTH_MAX+1,1,fp);

		currentNode = [[CategoryNode alloc] initWithSymbol: tempString];
		[self addObject:currentNode];
	}

	if (![self findSymbol:"phone"])
		[self addCategory:"phone"]; 
}

- (void)printDataTo:(FILE *)fp
{
int i;

	fprintf(fp, "Categories\n");
	for (i = 0; i<[self count]; i++)
	{
		fprintf(fp, "%s\n", [[self objectAtIndex: i] symbol]);
		if ([[self objectAtIndex: i] comment])
			fprintf(fp,"%s\n", [[self objectAtIndex: i] comment]);
		fprintf(fp, "\n");
	}
	fprintf(fp, "\n"); 
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	[super initWithCoder:aDecoder];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[super encodeWithCoder:aCoder];
}

@end


#import "PhoneList.h"
#import "ParameterList.h"
#import "SymbolList.h"
#import "TRMData.h"
#import "MyController.h"
#import <AppKit/AppKit.h>
#import <strings.h>

/*===========================================================================


===========================================================================*/

@implementation PhoneList

- (Phone *) findPhone: (const char *) phone
{
int i;
const char *temp;

	for (i = 0; i< [self count]; i++)
	{
		temp = [[self objectAtIndex: i] symbol];
		if (strcmp(temp, phone)==0)
			return [self objectAtIndex: i];
	}
	return nil;

}

- (void)addPhone:(const char *)phone
{
Phone *tempPhone;
int index;
id symbols, parms, metaParms;


//	printf("Phone List adding phone \n");
	if ([self binarySearchPhone:phone index:&index])
		return;

	symbols = NXGetNamedObject("mainSymbolList", NSApp);
	parms = NXGetNamedObject("mainParameterList", NSApp);
	metaParms = NXGetNamedObject("mainMetaParameterList", NSApp);

	tempPhone = [[Phone alloc] initWithSymbol:phone parmeters:parms metaParameters: metaParms symbols:symbols];
	[[tempPhone categoryList] addNativeCategory:phone];

	[self insertObject: tempPhone atIndex:index]; 
}

- (void)addPhoneObject:(Phone *)phone
{
int index;

	if ([self binarySearchPhone:[phone symbol] index:&index])
		return;

	[self insertObject: phone atIndex:index]; 
}

- binarySearchPhone:(const char *) searchPhone index:(int *) index
{
int low, high, mid;
int test;

	low = 0;
	high = [self count]-1;
	*index = 0;
	if ([self count] == 0)	   /* Empty List */
		return nil;


	test = strcmp(searchPhone, [(Phone *) [self objectAtIndex: low] symbol]);

	if (test == 0)		  /* First word in List */
		return [self objectAtIndex: low];
	else
	if (test<0)		     /* Belongs at the head of the list */
		return nil;

	*index = 1;

	if ([self count] == 1)	   /* Only 1 item to test */
		return nil;

	*index = [self count];

	test = strcmp(searchPhone, [(Phone *) [self objectAtIndex: high] symbol]);
	if (test == 0)		  /* Last word in List */
	{
		*index = high;
		return [self objectAtIndex: high];
	}
	else
	if (test>0)		     /* Belongs at the end of the list */
		return nil;

	while(1)
	{
		if ( (low+1) == high)
		{
			*index = high;
			break;
		}

		mid = (low+high)/2;

		test = strcmp(searchPhone, [(Phone *) [self objectAtIndex: mid] symbol]);
		if (test == 0)
		{
			*index = mid;
			return [self objectAtIndex: mid];
		}
		else
		if (test > 0)
			low = mid;
		else
			high = mid;
	}
	return nil;
}

- (void)addNewValue:(const char *)newValue
{
	[self addPhone:newValue]; 
}

- findByName:(const char *)name
{
int dummy;
	if (name == NULL) return nil;
	return [self binarySearchPhone:name index:&dummy];
}

- (void)changeSymbolOf:temp to:(const char *)name
{

	[self removeObject: temp];
	[temp setSymbol:name];
	[self addPhoneObject:temp]; 
}

#define SYMBOL_LENGTH_MAX       12
- (void)readDegasFileFormat:(FILE *)fp
{
int i, j, symbolIndex;
int phoneCount, targetCount, categoryCount;

int tempDuration, tempType, tempFixed;
float tempProp;

int tempDefault;
float tempValue;

Phone *tempPhone;
CategoryNode *tempCategory;
CategoryList *categories;
SymbolList *symbols;
ParameterList *parms, *metaParms;
Target *tempTarget;
char tempSymbol[SYMBOL_LENGTH_MAX + 1];


	categories = NXGetNamedObject("mainCategoryList", NSApp);
	symbols = NXGetNamedObject("mainSymbolList", NSApp);
	parms = NXGetNamedObject("mainParameterList", NSApp);
	metaParms = NXGetNamedObject("mainMetaParameterList", NSApp);

	symbolIndex = [symbols findSymbolIndex:"duration"];

	if (symbolIndex == (-1))
	{
		[symbols addNewValue:"duration"];
		symbolIndex = [symbols findSymbolIndex:"duration"];
		[self addSymbol];
	}

	/* READ # OF PHONES AND TARGETS FROM FILE  */
	fread(&phoneCount, sizeof(int), 1, fp);
	fread(&targetCount, sizeof(int), 1, fp);

	/* READ PHONE DESCRIPTION FROM FILE  */
	for (i = 0; i < phoneCount; i++)
	{
		fread(tempSymbol, SYMBOL_LENGTH_MAX + 1, 1, fp);

		tempPhone = [[Phone alloc] initWithSymbol:tempSymbol parmeters:parms metaParameters: metaParms
					symbols: symbols];
		[self addPhoneObject:tempPhone];

		/* READ SYMBOL AND DURATIONS FROM FILE  */
		fread(&tempDuration, sizeof(int), 1, fp);
		fread(&tempType, sizeof(int), 1, fp);
		fread(&tempFixed, sizeof(int), 1, fp);
		fread(&tempProp, sizeof(int), 1, fp);

		tempTarget = [[tempPhone symbolList] objectAtIndex:symbolIndex];
		[tempTarget setValue:(double) tempDuration isDefault:NO];

		/* READ TARGETS IN FROM FILE  */
		for (j = 0; j < targetCount; j++)
		{
			tempTarget = [[tempPhone parameterList] objectAtIndex:j];

			/* READ IN DATA FROM FILE  */
			fread(&tempDefault, sizeof(int), 1, fp);
			fread(&tempValue, sizeof(float), 1, fp);

			[tempTarget setValue:tempValue];
			[tempTarget setDefault:tempDefault];

		}

		/* READ IN CATEGORIES FROM FILE  */
		fread(&categoryCount, sizeof(int), 1, fp);
		for (j = 0; j < categoryCount; j++)
		{
			/* READ IN DATA FROM FILE  */
			fread(tempSymbol, SYMBOL_LENGTH_MAX + 1, 1, fp);
			tempCategory = [categories findSymbol:tempSymbol];
			if (!tempCategory)
			{
				[[tempPhone categoryList] addNativeCategory:tempSymbol];
			}
			else
				[[tempPhone categoryList] addObject:tempCategory];

		}
	} 
}

- (void)printDataTo:(FILE *)fp
{
int i, j;
id temp;
id symbols, parms, metaParms;

	symbols = NXGetNamedObject("mainSymbolList", NSApp);
	parms = NXGetNamedObject("mainParameterList", NSApp);
	metaParms = NXGetNamedObject("mainMetaParameterList", NSApp);

	fprintf(fp, "Phones\n");
	for (i = 0; i<[self count]; i++)
	{
		fprintf(fp, "%s\n", [[self objectAtIndex: i] symbol]);
		temp = [[self objectAtIndex: i] categoryList];
		for (j = 0; j<[temp count]; j++)
		{
			if ([[temp objectAtIndex: j] native])
				fprintf(fp, "*%s ", [[temp objectAtIndex: j] symbol]);
			else
				fprintf(fp, "%s ", [[temp objectAtIndex: j] symbol]);
		}
		fprintf(fp, "\n\n");

		temp = [[self objectAtIndex: i] parameterList];
		for (j = 0; j<[temp count]/2; j++)
		{
			if ([[temp objectAtIndex: j] isDefault])
				fprintf(fp, "\t%s: *%f\t\t", [[parms objectAtIndex: j] symbol], [[temp objectAtIndex: j] value]);
			else
				fprintf(fp, "\t%s: %f\t\t", [[parms objectAtIndex: j] symbol], [[temp objectAtIndex: j] value]);

			if ([[temp objectAtIndex: j+8] isDefault])
				fprintf(fp, "%s: *%f\n", [[parms objectAtIndex: j+8] symbol], [[temp objectAtIndex: j+8] value]);
			else
				fprintf(fp, "%s: %f\n", [[parms objectAtIndex: j+8] symbol], [[temp objectAtIndex: j+8] value]);
		}
		fprintf(fp, "\n\n");

		temp = [[self objectAtIndex: i] symbolList];
		for (j = 0; j<[temp count]; j++)
		{
			if ([[temp objectAtIndex: j] isDefault])
				fprintf(fp, "%s: *%f ", [[symbols objectAtIndex: j] symbol], [[temp objectAtIndex: j] value]);
			else
				fprintf(fp, "%s: %f ", [[symbols objectAtIndex: j] symbol], [[temp objectAtIndex: j] value]);
		}
		fprintf(fp, "\n\n");

		if ([[self objectAtIndex: i] comment])
			fprintf(fp,"%s\n", [[self objectAtIndex: i] comment]);

		fprintf(fp, "\n");
	}
	fprintf(fp, "\n"); 
}

- (void)parameterDefaultChange:parameter to:(double)value
{
int i, index;
id temp;
id parms, metaParms;

	parms = NXGetNamedObject("mainParameterList", NSApp);
	index = [parms indexOfObject:parameter];
	if (index!=NSNotFound)
	{
		for(i = 0 ; i< [self count]; i++)
		{
			temp = [[[self objectAtIndex: i] parameterList] objectAtIndex:index];
			if ( [temp isDefault])
				[temp setValue:value];
		}
	}
	else
	{
		metaParms = NXGetNamedObject("mainMetaParameterList", NSApp);
		index = [metaParms indexOfObject:parameter];
		if (index!=NSNotFound)
			for(i = 0 ; i< [self count]; i++)
			{
				temp = [[[self objectAtIndex: i] metaParameterList] objectAtIndex:index];
				if ( [temp isDefault])
					[temp setValue:value];
			}
	} 
}

- (void)symbolDefaultChange:parameter to:(double)value
{
int i, index;
id temp;
id symbols;

	symbols = NXGetNamedObject("mainSymbolList", NSApp);
	index = [symbols indexOfObject:parameter];
	if (index!=NSNotFound)
	{
		for(i = 0 ; i< [self count]; i++)
		{
			temp = [[[self objectAtIndex: i] symbolList] objectAtIndex:index];
			if ( [temp isDefault])
				[temp setValue:value];
		}
	} 
}

- (void)addParameter
{
int i;
double value;
id temp;
	value = [[NXGetNamedObject("mainParameterList", NSApp) lastObject] defaultValue];
	for(i = 0 ; i< [self count]; i++)
	{
		temp = [[self objectAtIndex: i] parameterList];
		[temp addDefaultTargetWithValue:value];

	} 
}

- (void)removeParameter:(int)index
{
int i;
id temp;

	for(i = 0 ; i< [self count]; i++)
	{
		temp = [[self objectAtIndex: i] parameterList];
		[temp removeObjectAtIndex:index];

	} 
}

- (void)addMetaParameter
{
int i;
double value;
id temp;

	value = [[NXGetNamedObject("mainMetaParameterList", NSApp) lastObject] defaultValue];
	for(i = 0 ; i< [self count]; i++)
	{
		temp = [[self objectAtIndex: i] metaParameterList];
		[temp addDefaultTargetWithValue:value];

	} 
}

- (void)removeMetaParameter:(int)index
{
int i;
id temp;

	for(i = 0 ; i< [self count]; i++)
	{
		temp = [[self objectAtIndex: i] metaParameterList];
		[temp removeObjectAtIndex:index];

	} 
}

- (void)addSymbol
{
int i;
id temp;

	for(i = 0 ; i< [self count]; i++)
	{
		temp = [[self objectAtIndex: i] symbolList];
		[temp addDefaultTargetWithValue:(double)0.0];

	} 
}

- (void)removeSymbol:(int)index
{
int i;
id temp;

	for(i = 0 ; i< [self count]; i++)
	{
		temp = [[self objectAtIndex: i] symbolList];
		[temp removeObjectAtIndex:index];

	} 
}

- (void)importTRMData:sender
{
id symbols, parms, metaParms;
id myData = [[TRMData alloc] init];
NSArray *types;
NSArray *fnames;
char buffer[256], *tempBuffer;
char path[256];
Phone *tempPhone; 
TargetList *tempTargets;
ParameterList   *mainParameterList = NXGetNamedObject("mainParameterList", NSApp);
double tempValue;
int i, count;

	symbols = NXGetNamedObject("mainSymbolList", NSApp);
	parms = NXGetNamedObject("mainParameterList", NSApp);
	metaParms = NXGetNamedObject("mainMetaParameterList", NSApp);

	[[NSOpenPanel openPanel] setAllowsMultipleSelection:YES];
	if ([[NSOpenPanel openPanel] runModalForTypes:types])
		fnames = [[NSOpenPanel openPanel] filenames];
	else
		return;

	count = [fnames count];
	for (i = 0; i < count; i++)
	{
		sprintf(path, "%s/%s", [[[NSOpenPanel openPanel] directory] cString], [[fnames objectAtIndex: i] cString]);
		strcpy(buffer, [[fnames objectAtIndex: i] cString]);
		tempBuffer = index(buffer, '.');
		*tempBuffer = '\000';
		tempPhone = [[Phone alloc] initWithSymbol:buffer parmeters:parms 
				metaParameters: metaParms symbols:symbols];
		tempPhone = [self makePhoneUniqueName:tempPhone];
		[self addPhoneObject:tempPhone];
		[[tempPhone categoryList] addNativeCategory:buffer];

		/*  Read the file data and store it in the object  */
		if ([myData readFromFile:path] == NO)
		{
			NSBeep();
			return;
		}

		tempTargets = [tempPhone parameterList];

		/*  Get the values of the needed parameters  */	
		tempValue = [myData glotPitch];
		[[tempTargets objectAtIndex:0] setValue: tempValue
			 isDefault: ([[mainParameterList objectAtIndex:0] defaultValue] == tempValue)];
		tempValue = [myData glotVol];
		[[tempTargets objectAtIndex:1] setValue: tempValue 
			isDefault: ([[mainParameterList objectAtIndex:1] defaultValue] == tempValue)];
		tempValue = [myData aspVol];
		[[tempTargets objectAtIndex:2] setValue: tempValue
			isDefault: ([[mainParameterList objectAtIndex:2] defaultValue] == tempValue)];
		tempValue = [myData fricVol];
		[[tempTargets objectAtIndex:3] setValue: tempValue 
			isDefault: ([[mainParameterList objectAtIndex:3] defaultValue] == tempValue)];
		tempValue = [myData fricPos];
		[[tempTargets objectAtIndex:4] setValue: tempValue 
			isDefault: ([[mainParameterList objectAtIndex:4] defaultValue] == tempValue)];
		tempValue = [myData fricCF];
		[[tempTargets objectAtIndex:5] setValue: tempValue 
			isDefault: ([[mainParameterList objectAtIndex:5] defaultValue] == tempValue)];
		tempValue = [myData fricBW];
		[[tempTargets objectAtIndex:6] setValue: tempValue 
			isDefault: ([[mainParameterList objectAtIndex:6] defaultValue] == tempValue)];
		tempValue = [myData r1];
		[[tempTargets objectAtIndex:7] setValue: tempValue 
			isDefault: ([[mainParameterList objectAtIndex:7] defaultValue] == tempValue)];
		tempValue = [myData r2];
		[[tempTargets objectAtIndex:8] setValue: tempValue 
			isDefault: ([[mainParameterList objectAtIndex:8] defaultValue] == tempValue)];
		tempValue = [myData r3];
		[[tempTargets objectAtIndex:9] setValue: tempValue 
			isDefault: ([[mainParameterList objectAtIndex:9] defaultValue] == tempValue)];
		tempValue = [myData r4];
		[[tempTargets objectAtIndex:10] setValue: tempValue
			isDefault: ([[mainParameterList objectAtIndex:10] defaultValue] == tempValue)];
		tempValue = [myData r5];
		[[tempTargets objectAtIndex:11] setValue: tempValue
			isDefault: ([[mainParameterList objectAtIndex:11] defaultValue] == tempValue)];
		tempValue = [myData r6];
		[[tempTargets objectAtIndex:12] setValue: tempValue 
			isDefault: ([[mainParameterList objectAtIndex:12] defaultValue] == tempValue)];
		tempValue = [myData r7];
		[[tempTargets objectAtIndex:13] setValue: tempValue 
			isDefault: ([[mainParameterList objectAtIndex:13] defaultValue] == tempValue)];
		tempValue = [myData r8];
		[[tempTargets objectAtIndex:14] setValue: tempValue 
			isDefault: ([[mainParameterList objectAtIndex:14] defaultValue] == tempValue)];
		tempValue = [myData velum];
		[[tempTargets objectAtIndex:15] setValue: tempValue 
			isDefault: ([[mainParameterList objectAtIndex:15] defaultValue] == tempValue)];

	}
	/*  Free the TRMData object  */
	[myData release]; 
}

- makePhoneUniqueName:aPhone
{
Phone *tempPhone;
int dummy;
char buffer[64], add1, add2;

	tempPhone = [self binarySearchPhone: [aPhone symbol] index: &dummy];
	if (tempPhone)
	{
		add1 = 'A';
		while(add1<'Z')
		{
			sprintf(buffer, "%s%c", [aPhone symbol], add1);
			if (![self binarySearchPhone: buffer index: &dummy])
			{
				[aPhone setSymbol:buffer];
				return aPhone;
			}
			add1++;
		}
		add1 = 'A';
		add2 = 'A';
		while(add1<'Z')
		{
			while(add2<'Z')
			{
				sprintf(buffer, "%s%c%c", [aPhone symbol], add1, add2);
				if (![self binarySearchPhone: buffer index: &dummy])
				{
					[aPhone setSymbol:buffer];
					return aPhone;
				}
				add2++;
			}
			add1++;
			add2 = 'A';
		}
	}

	return aPhone;
}

@end

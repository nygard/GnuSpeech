
#import "RuleList.h"
#import "BooleanParser.h"
#import "MyController.h"
#import <AppKit/NSApplication.h>
#import <string.h>

/*===========================================================================

===========================================================================*/
//- findRule:(const char *) searchSymbol;


@implementation RuleList

/*-findSymbol:(const char *) searchSymbol
{
	return self;
}*/

- seedListWith: expression1 : expression2
{
Rule *tempRule;

	tempRule = [[Rule alloc] init];
	[tempRule setExpression: expression1 number:0];
	[tempRule setExpression: expression2 number:1];

	[tempRule setDefaultsTo:[tempRule numberExpressions]];

	[self addObject: tempRule];

	return self;
}

- addRuleExp1: exp1 exp2: exp2 exp3: exp3 exp4: exp4;
{
Rule *tempRule;

	tempRule = [[Rule alloc] init];
	[tempRule setExpression: exp1 number:0];
	[tempRule setExpression: exp2 number:1];
	[tempRule setExpression: exp3 number:2];
	[tempRule setExpression: exp4 number:3];

	[tempRule setDefaultsTo:[tempRule numberExpressions]];

	[self insertObject: tempRule atIndex: [self count] - 1 ];

	return self;
}

- changeRuleAt: (int) index exp1: exp1 exp2: exp2 exp3: exp3 exp4: exp4
{
Rule *tempRule;
int i;

	tempRule = [self objectAtIndex: index];
	i = [tempRule numberExpressions];

	[tempRule setExpression: exp1 number:0];
	[tempRule setExpression: exp2 number:1];
	[tempRule setExpression: exp3 number:2];
	[tempRule setExpression: exp4 number:3];

	if (i!=[tempRule numberExpressions])
		[tempRule setDefaultsTo:[tempRule numberExpressions]];

	return self;
}

- findRule: (MonetList *) categories index:(int *) index
{
int i;
	for(i = 0 ; i < [self count] ; i++)
	{
		if ([(Rule *) [self objectAtIndex: i] numberExpressions]<=[categories count])
			if ([(Rule *) [self objectAtIndex: i] matchRule: categories])
			{
				*index = i;
				return [self objectAtIndex: i];
			}
	}
	return [self lastObject];
}



#define SYMBOL_LENGTH_MAX 12
- (void)readDegasFileFormat:(FILE *)fp
{
int numRules;
int i, j, k, l;
int j1, k1, l1;
int dummy;
int tempLength;
char buffer[1024];
char buffer1[1024];
BooleanParser *boolParser;
id temp, temp1;


	boolParser = [[BooleanParser alloc] init];
	[boolParser setCategoryList:NXGetNamedObject("mainCategoryList", NSApp)];
	[boolParser setPhoneList:NXGetNamedObject("mainPhoneList", NSApp)];

	/* READ FROM FILE  */
	NXRead(fp, &numRules, sizeof(int));
	for (i = 0; i < numRules; i++)
	{
		/* READ SPECIFIER CATEGORY #1 FROM FILE  */
		NXRead(fp, &tempLength, sizeof(int));
		bzero(buffer,1024);
		NXRead(fp, buffer, tempLength+1);
		temp = [boolParser parseString:buffer];

		/* READ SPECIFIER CATEGORY #2 FROM FILE  */
		NXRead(fp, &tempLength, sizeof(int));
		bzero(buffer1,1024);
		NXRead(fp, buffer1, tempLength+1);
		temp1 = [boolParser parseString:buffer1];
//		printf("%s >> %s\n", buffer, buffer1);

		[self addRuleExp1: temp exp2: temp1 exp3: nil exp4: nil];

		/* READ TRANSITION INTERVALS FROM FILE  */	
		NXRead(fp, &k1, sizeof(int));
		for (j = 0; j < k1; j++)
		{
			NXRead(fp, &dummy, sizeof(short int));
			NXRead(fp, &dummy, sizeof(short int));
			NXRead(fp, &dummy, sizeof(int));
			NXRead(fp, &dummy, sizeof(float));
			NXRead(fp, &dummy, sizeof(float));
		}

		/* READ TRANSITION INTERVAL MODE FROM FILE  */
		NXRead(fp, &dummy, sizeof(short int));

		/* READ SPLIT MODE FROM FILE  */
		NXRead(fp, &dummy, sizeof(short int));

		/* READ SPECIAL EVENTS FROM FILE  */
		NXRead(fp, &j1, sizeof(int));
		for (j = 0; j < j1; j++)
		{
			/* READ SPECIAL EVENT SYMBOL FROM FILE  */
			NXRead(fp, buffer, SYMBOL_LENGTH_MAX + 1);
			/* READ SPECIAL EVENT INTERVALS FROM FILE  */
			for (k = 0; k < k1; k++)
			{

				/* READ SUB-INTERVALS FROM FILE  */
				NXRead(fp, &l1, sizeof(int));
				for (l = 0; l < l1; l++)
				{
					/* READ SUB-INTERVAL PARAMETERS FROM FILE  */
					NXRead(fp, &dummy, sizeof(short int));
					NXRead(fp, &dummy, sizeof(int));
					NXRead(fp, &dummy, sizeof(float));
				}
			}
		}
		/* READ DURATION RULE INFORMATION FROM FILE  */
		NXRead(fp, &dummy, sizeof(int));
		NXRead(fp, &dummy, sizeof(int));
	}

	[boolParser release]; 
}

- (BOOL) isCategoryUsed: aCategory
{
int i;
	for (i = 0; i<[self count]; i++)
	{
		if ([[self objectAtIndex: i] isCategoryUsed:aCategory])
			return YES;
	}
	return NO;
}

- (BOOL) isEquationUsed: anEquation
{
int i;
	for (i = 0; i<[self count]; i++)
	{
		if ([[self objectAtIndex: i] isEquationUsed:anEquation])
			return YES;
	}
	return NO;

}

- findEquation: anEquation andPutIn: aList
{
int i;
	for (i = 0; i<[self count]; i++)
	{
		if ([[self objectAtIndex: i] isEquationUsed:anEquation])
			[aList addObject: [self objectAtIndex: i]];
	}
	return self;
}

- findTemplate: aTemplate andPutIn: aList
{
int i;

	for (i = 0 ; i<[self count]; i++)
	{
		if ([[self objectAtIndex: i] isTransitionUsed:aTemplate])
			[aList addObject: [self objectAtIndex: i]];
	}
	return self;
}

- (BOOL) isTransitionUsed: aTransition
{
int i;
	for (i = 0; i<[self count]; i++)
	{
		if ([[self objectAtIndex: i] isTransitionUsed:aTransition])
			return YES;
	}
	return NO;

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

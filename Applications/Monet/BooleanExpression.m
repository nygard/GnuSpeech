
#import "BooleanExpression.h"
#import <Foundation/NSCoder.h>
#import <string.h>
#import <stdlib.h>

@implementation BooleanExpression

- init
{
	numExpressions = 0;
	operation = NO_OP;

	/* Set up 4 sub expressions as the default.  Realloc later to increase */
	maxExpressions = 4;
	expressions = (id *) malloc (sizeof (id *) *4);

	/* Set all Sub-Expressions to nil */
	bzero(expressions, sizeof (id *) *4);

	return self;
}

- (void)dealloc
{
int i;

	for (i = 0; i<numExpressions; i++)
		[expressions[i] release];
	free(expressions);
	[super dealloc];
}



- (int) evaluate: (CategoryList *) categories
{
	switch(operation)
	{
		case NOT_OP: 
			return (![expressions[0] evaluate:categories]);
			break;

		case AND_OP: 
			if (![expressions[0] evaluate:categories]) return (0);
			return [expressions[1] evaluate:categories];
			break;

		case OR_OP: 
			if ([expressions[0] evaluate:categories]) return (1);
			return [expressions[1] evaluate:categories];
			break;

		case XOR_OP: 
			return ([expressions[0] evaluate:categories] ^ [expressions[1] evaluate:categories]);
			break;

		default: return 1;
	}
	return 0;
}



- (void)setOperation:(int)newOp
{
	operation = newOp; 
}


- (int) operation
{
	return operation;
}


- (void)addSubExpression:newExpression
{
	expressions[numExpressions] = newExpression;
	numExpressions++; 
}

- operandOne
{
	return expressions[0];
}

- (void)optimize
{
	 
}


- (void)optimizeSubExpressions
{
int i;
	for (i = 0 ; i<numExpressions; i++)
		[expressions[i] optimizeSubExpressions];

	[self optimize]; 
}


- (int) maxExpressionLevels
{
int i, max = 0;
int temp;

	for (i = 0 ; i<numExpressions; i++)
	{
		temp = [ expressions[i] maxExpressionLevels];
		if (temp>max)
			max = temp;
	}
	return max+1;
}


- expressionString:(char *)string
{
char buffer[1024];
char *opString;
int i;

	bzero(buffer, 1024);
	opString = [self opString];

//	printf("( ");
	strcat(string,"(");
	if (operation == NOT_OP)
	{
		strcat(string, "not ");
//		printf("not ");
		[expressions[0] expressionString:string];

	}
	else
	for (i = 0 ; i<numExpressions; i++)
	{
		if (i!=0)
			strcat(string, opString);
//			printf(" %s ", opString);
		[expressions[i] expressionString:string];

	}
	strcat(string,")"); 
	return self;
}

- (char *) opString 
{
	switch(operation)
	{
		default:
		case NO_OP: return ("");
		case NOT_OP: return (" not ");
		case OR_OP: return (" or ");
		case AND_OP: return (" and ");
		case XOR_OP: return (" xor ");

	}
}

- (BOOL) isCategoryUsed: aCategory
{
int i;
	for (i = 0; i<numExpressions; i++)
	{
		if ([ expressions[i] isCategoryUsed:aCategory])
			return YES;
	}
	return NO;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
int i;

	[aDecoder decodeValuesOfObjCTypes:"iii", &operation, &numExpressions, &maxExpressions];
	expressions = (id *) malloc (sizeof (id *) *maxExpressions);


	for (i = 0; i<numExpressions; i++)
		expressions[i] = [[aDecoder decodeObject] retain];

	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
int i;

	[aCoder encodeValuesOfObjCTypes:"iii", &operation, &numExpressions, &maxExpressions];
	for (i = 0; i<numExpressions; i++)
		[aCoder encodeObject:expressions[i]];
}

#ifdef NeXT
- read:(NXTypedStream *)stream
{
int i;

        NXReadTypes(stream, "iii", &operation, &numExpressions, &maxExpressions);
        expressions = (id *) malloc (sizeof (id *) *maxExpressions);


        for (i = 0; i<numExpressions; i++)
                expressions[i] = NXReadObject(stream);

        return self;
}
#endif

@end

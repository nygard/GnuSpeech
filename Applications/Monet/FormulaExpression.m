
#import "FormulaExpression.h"
#import <Foundation/NSCoder.h>
#import <string.h>
#import <stdlib.h>

@implementation FormulaExpression

- init
{
	numExpressions = 0;
	operation = END;

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
	[super dealloc];
}

- (void)setPrecedence:(int)newPrec
{
	precedence = newPrec; 
}

- (int) precedence
{
	return precedence;
}

- (double) evaluate: (double *) ruleSymbols phones: phones
{
double tempos[4] = {1.0, 1.0, 1.0, 1.0};

	return [self evaluate: ruleSymbols tempos: tempos phones: phones];
}

- (double) evaluate: (double *) ruleSymbols tempos: (double *) tempos phones: phones
{
	switch(operation)
	{
		case ADD: 
			return ([expressions[0] evaluate:ruleSymbols tempos: tempos phones: phones] + 
				[expressions[1] evaluate:ruleSymbols tempos: tempos phones:phones]);
			break;

		case SUB: 
			return ([expressions[0] evaluate:ruleSymbols tempos: tempos phones:phones] - 
				[expressions[1] evaluate:ruleSymbols tempos: tempos phones:phones]);
			break;

		case MULT: 
			return ([expressions[0] evaluate:ruleSymbols tempos: tempos phones:phones] *
				[expressions[1] evaluate:ruleSymbols tempos: tempos phones:phones]);
			break;

		case DIV: 
			return ([expressions[0] evaluate:ruleSymbols tempos: tempos phones:phones] /
				[expressions[1] evaluate:ruleSymbols tempos: tempos phones:phones]);
			break;

		default: return 1.0;
	}
	return 0.0;
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

- (void)setOperandOne:operand
{
	expressions[0] = operand;
	if (expressions[0] == nil)
		numExpressions = 0;
	else 
	if (expressions[1] != nil)
		numExpressions = 2;
	else
		numExpressions = 1; 
}

- operandOne
{
	return expressions[0];
}

- (void)setOperandTwo:operand
{
	expressions[1] = operand;
	if (operand!=nil)
		numExpressions = 2; 
}

- operandTwo
{
	return expressions[1];
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

- (int) maxPhone
{
int i, max = 0;
int temp;

	for (i = 0 ; i<numExpressions; i++)
	{
		temp = [ expressions[i] maxPhone];
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

	if (precedence == 3)
		strcat(string,"(");
	for (i = 0 ; i<numExpressions; i++)
	{
		if (i!=0)
			strcat(string, opString);
		[expressions[i] expressionString:string];

	}
	if (precedence == 3)
		strcat(string,")"); 
	return self;
}

- (char *) opString 
{
	switch(operation)
	{
		default:
		case END: return ("");
		case ADD: return (" + ");
		case SUB: return (" - ");
		case MULT: return (" * ");
		case DIV: return (" / ");

	}
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
int i;

	[aDecoder decodeValuesOfObjCTypes:"iiii", &operation, &numExpressions, &maxExpressions, &precedence];
	expressions = (id *) malloc (sizeof (id *) *maxExpressions);


	for (i = 0; i<numExpressions; i++)
		expressions[i] = [[aDecoder decodeObject] retain];

	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
int i;

	[aCoder encodeValuesOfObjCTypes:"iiii", &operation, &numExpressions, &maxExpressions, &precedence];
	for (i = 0; i<numExpressions; i++)
		[aCoder encodeObject:expressions[i]];
}

#ifdef NeXT
- read:(NXTypedStream *)stream
{
int i;

        NXReadTypes(stream, "iiii", &operation, &numExpressions, &maxExpressions, &precedence);
        expressions = (id *) malloc (sizeof (id *) *maxExpressions);


        for (i = 0; i<numExpressions; i++)
                expressions[i] = NXReadObject(stream);

        return self;
}
#endif

@end

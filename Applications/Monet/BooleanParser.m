
#import "BooleanParser.h"
#import <ctype.h>
#import <stdlib.h>
#import <string.h>
#import <stdio.h>
#import <AppKit/NSTextField.h>

@implementation BooleanParser

- init
{
	errorTextField = nil;
	return self;
}

- (void)setCategoryList: (CategoryList *)aList
{
	categoryList = aList; 
}

- (CategoryList *)categoryList
{
	return categoryList;
}

- (void)setPhoneList: (PhoneList *)aList
{
	phoneList = aList; 
}

- (PhoneList *)phoneList
{
	return phoneList;
}

- (void)setErrorOutput:aTextObject
{
	errorTextField = aTextObject; 
}

- (id)categorySymbol:(const char *)symbol
{
char temp[256], *temp1;
Phone *tempPhone;
int dummy;

	bzero(temp, 256);
	if (index(symbol, '*'))
	{
		strcpy(temp, symbol);
		temp1 = index(temp, '*');
		*temp1 = '\000';
	}
	else
		strcpy(temp, symbol);

	tempPhone = [phoneList binarySearchPhone:temp index:&dummy];

	if (tempPhone)
	{
//		printf("%s: native category\n", symbol);
		return [[tempPhone categoryList] findSymbol:temp];
	}
//		printf("%s: NON native category\n", symbol);
	return [categoryList findSymbol:symbol];
}

- (int) nextToken
{
int i, j;

	consumed = 0;
	i = stringIndex;
	j = 0;
	bzero(symbolString, 256);

	while( (parseString[i] == ' ') || (parseString[i] =='\t')) i++;

	lastStringIndex = i;

	if (parseString[i] == '(')
	{
		symbolString[0] = '(';
		stringIndex = i+1;
		return LPAREN;
	}
	else
	if (parseString[i] == ')')
	{
		symbolString[0] = ')';
		stringIndex = i+1;
		return RPAREN;
	}
	else
	while( ( isalpha(parseString[i])) || (parseString[i] =='*') || (parseString[i] == '\''))
	{
		symbolString[j++] = parseString[i++];
		if (parseString[i-1] == '*') break;
	}

	stringIndex = i;

	if (!strcmp(symbolString, "and"))
		return AND;
	else
	if (!strcmp(symbolString, "or"))
		return OR;
	else
	if (!strcmp(symbolString, "not"))
		return NOT;
	else
	if (!strcmp(symbolString, "xor"))
		return XOR;

	if (strlen(symbolString)==0)
		return END;
	else
	{
		if (![self categorySymbol:symbolString]);
//			printf("Category Not Found!\n");
		return CATEGORY;
	}
}

- (void)consumeToken
{
	consumed = 1; 
}

- parseString:(const char *)string
{
BooleanExpression *temp;

	lastStringIndex = stringIndex = 0;
	parseString = string;

	temp = [self beginParseString];
	return temp;
}

- beginParseString
{
BooleanTerminal *tempTerminal = nil;
CategoryNode *tempCategory;
id tempExpression = nil;
int tempToken;

	tempToken = [self nextToken];
	switch(tempToken)
	{
		default:
		case END: [self outputError:"Error, unexpected End."];
			  return nil;

		case OR:
		case AND:
		case XOR: [self outputError: "Error, unexpected %s operation." with: symbolString];
			  return nil;

		case NOT: tempExpression = [self notOperation];
			  break;

		case LPAREN: 
			tempExpression = [self leftParen]; 
			break;

		case RPAREN: 
			[self outputError:"Error, unexpected ')'."];
			break;

		case CATEGORY:
			tempCategory = [self categorySymbol:symbolString];
			if (tempCategory == nil)
			{
				[self outputError: "Error, unknown category %s." with: symbolString];
				return nil;
			}
			else
			{
				tempTerminal = [[BooleanTerminal alloc] init];
				[tempTerminal setCategory:tempCategory];
				if (index(symbolString,'*'))
					[tempTerminal setMatchAll:1];
				tempExpression = tempTerminal;
			}
			break;

	}
	if (tempExpression == nil) return nil;

	tempExpression = [self continueParse:tempExpression];

	return tempExpression;
}

- continueParse:currentExpression
{

int tempToken;

	while( (tempToken = [self nextToken])!=END)
	{
		switch(tempToken)
		{
			default:
			case END:[self outputError:"Error, unexpected End."];
				 [currentExpression release];
				 return nil;

			case OR: currentExpression = [self orOperation:currentExpression];
				 break;

			case AND:currentExpression = [self andOperation:currentExpression];
				 break;

			case XOR:currentExpression = [self xorOperation:currentExpression];
				 break;

			case NOT:[self outputError:"Error, unexpected NOT operation."];
				[currentExpression release];
				return nil;

			case LPAREN: [self outputError:"Error, unexpected '('."];
				[currentExpression release];
				return nil;

			case RPAREN: [self outputError:"Error, unexpected ')'."];
				[currentExpression release];
				return nil;

			case CATEGORY:
				[currentExpression release];
				[self outputError: "Error, unexpected category %s." with: symbolString];
				return nil;
		}
		if (currentExpression == nil) return nil;
	}
	return currentExpression;
}

- notOperation
{
BooleanExpression *temp = nil, *temp1;
BooleanTerminal *tempTerminal;
CategoryNode *tempCategory;

	temp = [[BooleanExpression alloc] init];
	[temp setOperation:NOT_OP];

	switch([self nextToken])
	{
		case AND:
		case XOR:
		case OR:
		case NOT:
			[temp release];
			[self outputError: "Error, unexpected %s operation." with: symbolString];
			return nil;

		case CATEGORY:
			tempCategory = [self categorySymbol:symbolString];
			if (tempCategory == nil)
			{
				[self outputError: "Error, unknown category %s." with: symbolString];
				[temp release];
				return nil;
			}
			else
			{
				tempTerminal = [[BooleanTerminal alloc] init];
				[tempTerminal setCategory:tempCategory];
				if (index(symbolString,'*'))
					[tempTerminal setMatchAll:1];
				[temp addSubExpression:tempTerminal];
			}
			break;

		case LPAREN:
			temp1 = [self leftParen];
			if (temp1!=nil)
				[temp addSubExpression:temp1];

	}


	return temp;
}

- andOperation:operand
{
BooleanExpression *temp = nil;
BooleanTerminal *tempTerminal;
CategoryNode *tempCategory;

	temp = [[BooleanExpression alloc] init];
	[temp addSubExpression:operand];
	[temp setOperation:AND_OP];

	switch([self nextToken])
	{
		case END: [self outputError:"Error, unexpected End."];
			  [temp release];
			  return nil;

		case AND:
		case OR:
		case XOR:
			[temp release];
			[self outputError: "Error, unexpected %s operation." with: symbolString];
			return nil;

		case RPAREN: 
			[temp release];
			[self outputError:"Error, unexpected ')'."];
			return nil;

		case NOT:
			[self notOperation];
			[temp addSubExpression:self];
			break;

		case LPAREN:
			[self leftParen];
			[temp addSubExpression:self];
			break;

		case CATEGORY:
			tempCategory = [self categorySymbol:symbolString];
			if (tempCategory == nil)
			{
				[self outputError: "Error, unknown category %s." with: symbolString];
				[temp release];
				return nil;
			}
			else
			{
				tempTerminal = [[BooleanTerminal alloc] init];
				[tempTerminal setCategory:tempCategory];
				if (index(symbolString,'*'))
					[tempTerminal setMatchAll:1];
				[temp addSubExpression:tempTerminal];
			}
			break;
	}

	return temp;
}

- orOperation:operand
{
BooleanExpression *temp = nil;
BooleanTerminal *tempTerminal;
CategoryNode *tempCategory;

	temp = [[BooleanExpression alloc] init];
	[temp addSubExpression:operand];
	[temp setOperation:OR_OP];

	switch([self nextToken])
	{
		case END: [self outputError:"Error, unexpected End."];
			[temp release];
			  return nil;

		case AND:
		case OR:
		case XOR:
			[self outputError: "Error, unexpected %s operation." with: symbolString];
			[temp release];
			return nil;

		case RPAREN: 
			[self outputError:"Error, unexpected ')'."];
			[temp release];
			return nil;

		case NOT:
			[self notOperation];
			[temp addSubExpression:self];
			break;

		case LPAREN:
			[self leftParen];
			[temp addSubExpression:self];
			break;

		case CATEGORY:
			tempCategory = [self categorySymbol:symbolString];
			if (tempCategory == nil)
			{
				[self outputError: "Error, unknown category %s." with: symbolString];
				[temp release];
				return nil;
			}
			else
			{
				tempTerminal = [[BooleanTerminal alloc] init];
				[tempTerminal setCategory:tempCategory];
				if (index(symbolString,'*'))
					[tempTerminal setMatchAll:1];
				[temp addSubExpression:tempTerminal];
			}
			break;
	}

	return temp;

}

- xorOperation:operand
{
BooleanExpression *temp = nil;
BooleanTerminal *tempTerminal;
CategoryNode *tempCategory;


	temp = [[BooleanExpression alloc] init];
	[temp addSubExpression:operand];
	[temp setOperation:XOR_OP];

	switch([self nextToken])
	{
		case END: [self outputError:"Error, unexpected End."];
			[temp release];
			  return nil;

		case AND:
		case OR:
		case XOR:
			[self outputError: "Error, unexpected %s operation." with: symbolString];
			[temp release];
			return nil;

		case RPAREN: 
			[self outputError:"Error, unexpected ')'."];
			[temp release];
			return nil;

		case NOT:
			[self notOperation];
			[temp addSubExpression:self];
			break;

		case LPAREN:
			[self leftParen];
			[temp addSubExpression:self];
			break;

		case CATEGORY:
			tempCategory = [self categorySymbol:symbolString];
			if (tempCategory == nil)
			{
				[self outputError: "Error, unknown category %s." with: symbolString];
				[temp release];
				return nil;
			}
			else
			{
				tempTerminal = [[BooleanTerminal alloc] init];
				[tempTerminal setCategory:tempCategory];
				if (index(symbolString,'*'))
					[tempTerminal setMatchAll:1];
				[temp addSubExpression:tempTerminal];
			}
			break;
	}

	return temp;

}


- leftParen
{
id temp = nil;
BooleanTerminal *tempTerminal;
CategoryNode *tempCategory;
int tempToken;

	switch([self nextToken])
	{
		case END: [self outputError:"Error, unexpected End."];
			return nil;

		case RPAREN: return temp;

		case LPAREN: 
			temp = [self leftParen]; 
			break;

		case AND:
		case OR:
		case XOR:
			[self outputError: "Error, unexpected %s operation." with: symbolString];
			return nil;

		case NOT: temp = [self notOperation];
			break;

		case CATEGORY:
			tempCategory = [self categorySymbol:symbolString];
			if (tempCategory == nil)
			{
				[self outputError: "Error, unknown category %s." with: symbolString];
				return nil;
			}
			else
			{
				tempTerminal = [[BooleanTerminal alloc] init];
				[tempTerminal setCategory:tempCategory];
				if (index(symbolString,'*'))
					[tempTerminal setMatchAll:1];
				temp = tempTerminal;
			}
			break;
	}

	while( (tempToken=[self nextToken]) != RPAREN)
	{
		switch(tempToken)
		{
			case END: [self outputError:"Error, unexpected End."];
				[temp release];
				return nil;

			case RPAREN: return temp;

			case LPAREN: 
				[temp release];
				[self outputError:"Error, unexpected '('."];
				return nil;

			case AND: temp = [self andOperation:temp];
				break;

			case OR: temp = [self orOperation:temp];
				break;

			case XOR: temp = [self xorOperation:temp];
				break;

			case NOT:[self outputError:"Error, unexpected NOT operation."];
				[temp release];
				return nil;

			case CATEGORY:
				[temp release];
				[self outputError: "Error, unexpected category %s." with: symbolString];
				return nil;

		}
	}


	return temp;
}

- (void)outputError:(const char *)errorText
{
char outputString[1024];

	sprintf(outputString, "%s", errorText);
	[errorTextField setStringValue:[NSString stringWithCString:outputString]]; 
}

- (void)outputError: (const char *) errorText with:(const char *) string
{
char tempString[1024];

	sprintf(tempString, errorText, string);
//	sprintf(outputString, "%s", tempString);
	[errorTextField setStringValue:[NSString stringWithCString:tempString]];
}


@end


#import "FormulaParser.h"
#import <ctype.h>
#import <string.h>
#import <stdlib.h>
#import <AppKit/NSText.h>

static int operatorPrec[8] = {1, 1, 2, 2, 3, 0, 4, 4};

@implementation FormulaParser

- init
{
	return self;
}

- setSymbolList:(SymbolList *)newSymbolList
{
	symbolList = newSymbolList; 
	return self;
}
- symbolList
{
	return symbolList;
}

- (int) nextToken
{
int i;

	consumed = 0;
	i = stringIndex;
	bzero(symbolString, 256);

	while( (parseString[i] == ' ') || (parseString[i] =='\t')) i++;

	stringIndex = i;

	switch(parseString[i])
	{
		case '(':
			symbolString[0] = '(';
			stringIndex = i+1;
			return LPAREN;

		case ')':
			symbolString[0] = ')';
			stringIndex = i+1;
			return RPAREN;

		case '+':
			symbolString[0] = '+';
			stringIndex = i+1;
			return ADD;
			
		case '-':
			symbolString[0] = '-';
			stringIndex = i+1;
			return SUB;
			
		case '*':
			symbolString[0] = '*';
			stringIndex = i+1;
			return MULT;
			
		case '/':
			symbolString[0] = '/';
			stringIndex = i+1;
			return DIV;
			
		case '0':
		case '1':
		case '2':
		case '3':
		case '4':
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			if ([self scanNumber])
				return CONST;
			else
				return ERROR;
		case '\n':
		case '\000':
			return END;

		default:
			if ([self scanSymbol])
			{
				if (strlen(symbolString)==0)
					return END;
				else
					return SYMBOL;
			}
			else
				return ERROR;
	}
}

- (int) scanNumber
{
int i, j, decimal;

	decimal = 0;
	i = stringIndex;
	j = 0;

	while( isdigit(parseString[i]) || (parseString[i] == '.'))
	{
		if (parseString[i] == '.')
		{
			if (decimal == 1)
			{
				stringIndex = i;
				return 1;
			}
			decimal = 1;
		}
		symbolString[j++] = parseString[i++];
	}
	stringIndex = i;
	if (strlen(symbolString) == 0) 
		return 0;
	else
		return 1;
}

- (int) scanSymbol
{
int i, j;

	i = stringIndex;
	j = 0;

	if (!isalpha(parseString[i]))
		return 0;

	while( isalnum(parseString[i]))
	{
		symbolString[j++] = parseString[i++];
	}
	stringIndex = i;
	return 1;
}

- (void)consumeToken
{
	consumed = 1; 
}

- parseString:(const char *)string
{
id tempExpression = nil;
FormulaTerminal *tempTerminal;
int temp;

	[errorText setString:@""];
	stringIndex = 0;
	parseString = string;

	temp = [self nextToken];
	switch(temp)
	{
		case SUB: //printf("Sub\n");
			break;

		case ADD: [self outputError:"Unary + is the instrument of satan"];
			return nil;

		case MULT: [self outputError:"Unexpected * operator."];
			return nil;

		case DIV: [self outputError:"Unexpected / operator."];
			return nil;

		case LPAREN: tempExpression = [self leftParen];
			break;

		case RPAREN: [self outputError:"Unexpected ')'."];
			return nil;

		case SYMBOL: 
			tempTerminal = [self parseSymbol]; 
			if (tempTerminal)
			{
				tempExpression = tempTerminal;
			}
			else
			{
				return nil;
			}
			break;

		case CONST: 
			tempTerminal = [[FormulaTerminal alloc] init];
			[tempTerminal setValue:(double) atof(symbolString)];
			tempExpression = tempTerminal;
			break;

		case ERROR:
		case END:  [self outputError:"Unexpected End."];
			return nil;

		}
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
			case END: [self outputError:"Unexpected End."];
				return nil;

			case ADD: currentExpression = [self addOperation:currentExpression];
				 break;

			case SUB:currentExpression = [self subOperation:currentExpression];
				 break;

			case MULT:currentExpression = [self multOperation:currentExpression];
				 break;

			case DIV:currentExpression = [self divOperation:currentExpression];
				 break;

			case LPAREN:[self outputError:"Unexpected '('."];
				return nil;

			case RPAREN: [self outputError:"Unexpected ')'."];
				return nil;

			case SYMBOL:
				[self outputError:"Unexpected symbol %s." with: symbolString];
				return nil;

			case CONST:
				[self outputError:"Unexpected symbol %s." with: symbolString];
				return nil;
		}
	}
	return currentExpression;

}

- parseSymbol
{
FormulaTerminal *tempTerminal = nil;
Symbol *tempSymbol;
int whichPhone;
char tempSymbolString[256];

	printf("Symbol = |%s|\n", symbolString);
	if (strcmp(symbolString, "rd") ==0)
	{
		tempTerminal = [[FormulaTerminal alloc] init];
		[tempTerminal setWhichPhone:RULEDURATION];
	}
	else
	if (strcmp(symbolString, "beat") ==0)
	{
		tempTerminal = [[FormulaTerminal alloc] init];
		[tempTerminal setWhichPhone:BEAT];
	}
	else
	if (strcmp(symbolString, "mark1") ==0)
	{
		tempTerminal = [[FormulaTerminal alloc] init];
		[tempTerminal setWhichPhone:MARK1];
	}
	else
	if (strcmp(symbolString, "mark2") ==0)
	{
		tempTerminal = [[FormulaTerminal alloc] init];
		[tempTerminal setWhichPhone:MARK2];
	}
	else
	if (strcmp(symbolString, "mark3") ==0)
	{
		tempTerminal = [[FormulaTerminal alloc] init];
		[tempTerminal setWhichPhone:MARK3];
	}
	else
	if (strcmp(symbolString, "tempo1") ==0)
	{
		tempTerminal = [[FormulaTerminal alloc] init];
		[tempTerminal setWhichPhone:TEMPO0];
	}
	else
	if (strcmp(symbolString, "tempo2") ==0)
	{
		tempTerminal = [[FormulaTerminal alloc] init];
		[tempTerminal setWhichPhone:TEMPO1];
	}
	else
	if (strcmp(symbolString, "tempo3") ==0)
	{
		tempTerminal = [[FormulaTerminal alloc] init];
		[tempTerminal setWhichPhone:TEMPO2];
	}
	else
	if (strcmp(symbolString, "tempo4") ==0)
	{
		tempTerminal = [[FormulaTerminal alloc] init];
		[tempTerminal setWhichPhone:TEMPO3];
	}
	else
	{
		whichPhone = (int) symbolString[strlen(symbolString)-1]-'1';
		printf("Phone = %d\n", whichPhone);
		if ( (whichPhone<0) || (whichPhone>3))
		{
			printf("\tError, incorrect phone index %d\n", whichPhone);
			return nil;
		}

		bzero(tempSymbolString, 256);
		strcpy(tempSymbolString, symbolString);
		tempSymbolString[strlen(symbolString)-1] = '\000';

		tempSymbol = [symbolList findSymbol:tempSymbolString];
		if (tempSymbol)
		{
			tempTerminal = [[FormulaTerminal alloc] init];
			[tempTerminal setSymbol:tempSymbol];
			[tempTerminal setWhichPhone:whichPhone];
		}
		else
		{
			[self outputError:"Unknown symbol %s." with: symbolString];
//			printf("\t Error, Undefined Symbol %s\n", tempSymbolString);
			return nil;
		}
	}
	return tempTerminal;
}

- addOperation:operand
{
id temp = nil, temp1 = nil, returnExp = nil;
FormulaTerminal *tempTerminal;

//	printf("ADD\n");

	temp = [[FormulaExpression alloc] init];
	[temp setPrecedence:1];
	[temp setOperation:ADD];

	if ([operand precedence]>=1)
	{
		/* Current Sub Expression has higher precedence */
		[temp setOperandOne:operand];
		returnExp = temp;
	}
	else
	{
		/* Currend Sub Expression has lower Precedence.  Restructure Tree */
		temp1 = [operand operandTwo];
		[temp setOperandOne:temp1];
		[operand setOperandTwo:temp];
		returnExp = operand;
	}

	switch([self nextToken])
	{
		case END: printf("\tError, unexpected END at index %d\n", stringIndex);
			  return nil;

		case ADD:
		case SUB:
		case MULT:
		case DIV:
			printf("\tError, unexpected %s operation at index %d\n", symbolString, stringIndex);
			return nil;

		case RPAREN: 
			printf("\tError, unexpected ')' at index %d\n", stringIndex);
			return nil;

		case LPAREN:
			[temp setOperandTwo: [self leftParen]];
			break;

		case SYMBOL:
			tempTerminal = [self parseSymbol];
			if (tempTerminal)
			{
				[temp setOperandTwo:tempTerminal];
			}
			else
			{
				return nil;
			}
			break;

		case CONST:
			tempTerminal = [[FormulaTerminal alloc] init];
			[tempTerminal setValue:(double) atof(symbolString)];
			[temp setOperandTwo:tempTerminal];	
			break;
	}
	return returnExp;
}

- subOperation:operand
{
id temp = nil, temp1 = nil, returnExp = nil;
FormulaTerminal *tempTerminal;

//	printf("SUB\n");

	temp = [[FormulaExpression alloc] init];
	[temp setPrecedence:1];
	[temp setOperation:SUB];

	if ([operand precedence]>=1)
	{
		/* Current Sub Expression has higher precedence */
		[temp setOperandOne:operand];
		returnExp = temp;
	}
	else
	{
		/* Currend Sub Expression has lower Precedence.  Restructure Tree */
		temp1 = [operand operandTwo];
		[temp setOperandOne:temp1];
		[operand setOperandTwo:temp];
		returnExp = operand;
	}

	switch([self nextToken])
	{
		case END: printf("\tError, unexpected END at index %d\n", stringIndex);
			  return nil;

		case ADD:
		case SUB:
		case MULT:
		case DIV:
			printf("\tError, unexpected %s operation at index %d\n", symbolString, stringIndex);
			return nil;

		case RPAREN: 
			printf("\tError, unexpected ')' at index %d\n", stringIndex);
			return nil;

		case LPAREN:
			[temp setOperandTwo: [self leftParen]];
			break;

		case SYMBOL:
			tempTerminal = [self parseSymbol];
			if (tempTerminal)
			{
				[temp setOperandTwo:tempTerminal];
			}
			else
			{
				return nil;
			}
			break;

		case CONST:
			tempTerminal = [[FormulaTerminal alloc] init];
			[tempTerminal setValue:(double) atof(symbolString)];
			[temp setOperandTwo:tempTerminal];
			break;
	}
	return returnExp;
}

- multOperation:operand
{
id temp = nil, temp1 = nil, returnExp = nil;
FormulaTerminal *tempTerminal;

//	printf("MULT\n");

	temp = [[FormulaExpression alloc] init];
	[temp setPrecedence:2];
	[temp setOperation:MULT];

	if ([operand precedence]>=2)
	{
		/* Current Sub Expression has higher precedence */
		[temp setOperandOne:operand];
		returnExp = temp;
	}
	else
	{
		/* Currend Sub Expression has lower Precedence.  Restructure Tree */
		temp1 = [operand operandTwo];
		[temp setOperandOne:temp1];
		[operand setOperandTwo:temp];
		returnExp = operand;
	}

	switch([self nextToken])
	{
		case END: printf("\tError, unexpected END at index %d\n", stringIndex);
			  return nil;

		case ADD:
		case SUB:
		case MULT:
		case DIV:
			printf("\tError, unexpected %s operation at index %d\n", symbolString, stringIndex);
			return nil;

		case RPAREN: 
			printf("\tError, unexpected ')' at index %d\n", stringIndex);
			return nil;

		case LPAREN:
			[temp setOperandTwo: [self leftParen]];
			break;

		case SYMBOL:
			tempTerminal = [self parseSymbol];
			if (tempTerminal)
			{
				[temp setOperandTwo:tempTerminal];
			}
			else
			{
				return nil;
			}
			break;

		case CONST:
			tempTerminal = [[FormulaTerminal alloc] init];
			[tempTerminal setValue:(double) atof(symbolString)];
			[temp setOperandTwo:tempTerminal];
			break;
	}
	return returnExp;
}

- divOperation:operand
{
id temp = nil, temp1 = nil, returnExp = nil;
FormulaTerminal *tempTerminal;

//	printf("DIV\n");

	temp = [[FormulaExpression alloc] init];
	[temp setPrecedence:2];
	[temp setOperation:DIV];

	if ([operand precedence]>=2)
	{
		/* Current Sub Expression has higher precedence */
		[temp setOperandOne:operand];
		returnExp = temp;
	}
	else
	{
		/* Currend Sub Expression has lower Precedence.  Restructure Tree */
		temp1 = [operand operandTwo];
		[temp setOperandOne:temp1];
		[operand setOperandTwo:temp];
		returnExp = operand;
	}

	switch([self nextToken])
	{
		case END: printf("\tError, unexpected END at index %d\n", stringIndex);
			  return nil;

		case ADD:
		case SUB:
		case MULT:
		case DIV:
			printf("\tError, unexpected %s operation at index %d\n", symbolString, stringIndex);
			return nil;

		case RPAREN: 
			printf("\tError, unexpected ')' at index %d\n", stringIndex);
			return nil;

		case LPAREN:
			[self leftParen];
			[temp setOperandTwo: [self leftParen]];
			break;

		case SYMBOL:
			tempTerminal = [self parseSymbol];
			if (tempTerminal)
			{
				[temp setOperandTwo:tempTerminal];
			}
			else
			{
				return nil;
			}
			break;

		case CONST:
			tempTerminal = [[FormulaTerminal alloc] init];
			[tempTerminal setValue:(double) atof(symbolString)];
			[temp setOperandTwo:tempTerminal];
			break;
	}
	return returnExp;
}


- leftParen
{
id temp = nil;
FormulaTerminal *tempTerminal, *tempTerm;
int tempToken;

	switch([self nextToken])
	{
		case END: printf("\tError, unexpected end at index %d\n", stringIndex);
			return nil;

		case RPAREN: return temp;

		case LPAREN: 
			temp = [self leftParen]; 
			break;

		case ADD:
		case SUB:
		case MULT:
		case DIV:
			printf("\tError, unexpected %s operation at index %d\n", symbolString, stringIndex);
			break;

		case SYMBOL:
			tempTerm = [self parseSymbol];
			if (tempTerm)
			{
				temp = tempTerm;
			}
			else
			{
				return nil;
			}
			break;

		case CONST:
			temp = [[FormulaTerminal alloc] init];
			[temp setValue:(double) atof(symbolString)];
//			printf("%s = %f\n", symbolString, [temp value]);
			break;
	}

	while( (tempToken=[self nextToken]) != RPAREN)
	{
		switch(tempToken)
		{
			case END: printf("\tError, unexpected end at index %d\n", stringIndex);
				return nil;

			case RPAREN: return temp;

			case LPAREN: 
				printf("\tError, unexpected '(' at index %d\n", stringIndex);
				return nil;

			case ADD: temp = [self addOperation:temp];
				break;

			case SUB: temp = [self subOperation:temp];
				break;

			case MULT: temp = [self multOperation:temp];
				break;

			case DIV: temp = [self divOperation:temp];
				break;

			case SYMBOL:
				tempTerminal = [self parseSymbol];
				if (tempTerminal)
				{
					[temp setOperandTwo:tempTerminal];
				}
				else
				{
					return nil;
				}
				break;

			case CONST:
//				printf("Here!!\n");
				tempTerminal = [[FormulaTerminal alloc] init];
				[tempTerminal setValue:(double) atof(symbolString)];
				[temp setOperandTwo:tempTerminal];
				break;
		}
	}

	/* Set Paren precedence */
	[temp setPrecedence:3];

	return temp;
}

- (void)setErrorOutput:aTextObject
{
	errorText = aTextObject; 
}


- (void)outputError:(const char *)outputText
{
char outputString[2048];

	sprintf(outputString, "%s\n%s", [[errorText string] cString],
		 outputText);
	[errorText setString:[NSString stringWithCString:outputString]];
}

- (void)outputError: (const char *) outputText with:(const char *) string
{
char outputString[2048];
char tempString[1024];
int length;

	sprintf(tempString, outputText, string);

	length = [[errorText string] length];

	if (length==0)
	{
		[errorText setString:[NSString stringWithCString:tempString]];
	}
	else
	{
		sprintf(outputString, "%s\n%s", [[errorText string] cString],
			 tempString);
		[errorText setString:[NSString stringWithCString:outputString]];
	}
}


@end

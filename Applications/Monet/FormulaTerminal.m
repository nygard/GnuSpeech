
#import "FormulaTerminal.h"
#import "SymbolList.h"
#import "Target.h"
#import "Rule.h"
#import "MyController.h"
#import <stdio.h>
#import <string.h>
#import <AppKit/NSApplication.h>		// for NSApp
#import <Foundation/NSCoder.h>

@implementation FormulaTerminal

- init
{
	symbol = nil;
	value = 0.0;

	whichPhone = (-1);

	precedence = 4;

	return self;
}

- (void)setSymbol:newSymbol
{
	symbol = newSymbol; 
}

- symbol
{
	return symbol;
}

- (void)setValue:(double)newValue
{
	value = newValue; 
}

- (double) value
{
	return value;
}

- (void)setWhichPhone:(int)newValue
{
	whichPhone = newValue; 
}

- (int) whichPhone
{
	return whichPhone;
}

- (void)setPrecedence:(int)newPrec
{
	precedence = newPrec; 
}

- (int) precedence
{
	return precedence;
}

- (double) evaluate:(double *) ruleSymbols phones: phones
{
double tempos[4] = {1.0, 1.0, 1.0, 1.0};
	return [self evaluate: ruleSymbols tempos: tempos phones: phones];
}

- (double) evaluate:(double *) ruleSymbols tempos: (double *) tempos phones: phones
{
SymbolList *mainSymbolList;
Target *tempTarget;
int index;

	/* Duration of the rule itself */
	switch(whichPhone)
	{
		case RULEDURATION:
			return ruleSymbols[0];
		case BEAT:
			return ruleSymbols[1];
		case MARK1:
			return ruleSymbols[2];
		case MARK2:
			return ruleSymbols[3];
		case MARK3:
			return ruleSymbols[4];
		case TEMPO0:
			return tempos[0];
		case TEMPO1:
			return tempos[1];
		case TEMPO2:
			return tempos[2];
		case TEMPO3:
			return tempos[3];

		default:
			break;
	}

	/* Constant value */
	if (symbol==nil)
		return value;
	else
	/* Resolve the symbol*/
	{
		/* Get main symbolList to determine index of "symbol" */
		mainSymbolList = (SymbolList *) 		
			NXGetNamedObject(@"mainSymbolList", NSApp);
		index = [mainSymbolList indexOfObject:symbol];

		/* Use index to index the phone's symbol list */
		tempTarget = [[[phones objectAtIndex:whichPhone] symbolList] objectAtIndex:index];

//		printf("Evaluate: %s Index: %d  Value : %f\n", [[phones objectAtIndex: whichPhone] symbol], index, [tempTarget value]);

		/* Return the value */
		return [tempTarget value];
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

- (int) maxPhone
{
	return whichPhone;
}

- expressionString:(char *)string
{
char temp[256];

	switch(whichPhone)
	{
		case RULEDURATION:
			strcat(string, "rd");
			return self;
		case BEAT:
			strcat(string, "beat");
			return self;
		case MARK1:
			strcat(string, "mark1");
			return self;
		case MARK2:
			strcat(string, "mark2");
			return self;
		case MARK3:
			strcat(string, "mark3");
			return self;
		case TEMPO0:
			strcat(string, "tempo1");
			return self;
		case TEMPO1:
			strcat(string, "tempo2");
			return self;
		case TEMPO2:
			strcat(string, "tempo3");
			return self;
		case TEMPO3:
			strcat(string, "tempo4");
			return self;

		default:
			break;
	}
	if (symbol == nil)
	{
		sprintf(temp, "%f", value);
		strcat(string, temp);
	}
	else
	{
		sprintf(temp, "%s%d", [symbol symbol], whichPhone+1);
		strcat(string, temp);
	} 
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
char *string;
SymbolList *temp;

	temp = NXGetNamedObject(@"mainSymbolList", NSApp);

	[aDecoder decodeValuesOfObjCTypes:"dii", &value, &whichPhone, &precedence];

	[aDecoder decodeValueOfObjCType:"*" at:&string];
	if (!strcmp(string, "No Symbol"))
		symbol = nil;
	else
		symbol = [temp findSymbol:string];

	free(string);
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
const char *temp;

	[aCoder encodeValuesOfObjCTypes:"dii", &value, &whichPhone, &precedence];

	if (symbol)
	{
		temp = [symbol symbol];
		[aCoder encodeValueOfObjCType:"*" at:&temp];
	}
	else
	{
		temp = "No Symbol";
		[aCoder encodeValueOfObjCType:"*" at:&temp];
	}
}

#ifdef NeXT
- read:(NXTypedStream *)stream
{
char *string;
SymbolList *temp;


        temp = NXGetNamedObject(@"mainSymbolList", NSApp);

        NXReadTypes(stream, "dii", &value, &whichPhone, &precedence);

        NXReadType(stream, "*", &string);
        if (!strcmp(string, "No Symbol"))
                symbol = nil;
        else
                symbol = [temp findSymbol:string];

        free(string);
        return self;
}
#endif


@end


#import "Rule.h"
#import "MyController.h"
#import <stdio.h>
#import <string.h>
#import <stdlib.h>
#import <AppKit/NSApplication.h>
#import "PrototypeManager.h"
#import "ProtoEquation.h"

@implementation Rule


- init
{
id tempList;

	/* Alloc lists to point to prototype transition specifiers */
	tempList = NXGetNamedObject(@"mainParameterList", NSApp);
	parameterProfiles = [[MonetList alloc] initWithCapacity:[tempList count]];

	tempList = NXGetNamedObject(@"mainMetaParameterList", NSApp);
	metaParameterProfiles = [[MonetList alloc] initWithCapacity:[tempList count]];

	/* Set up list for Expression symbols */
	expressionSymbols = [[MonetList alloc] initWithCapacity: 5];

	/* Zero out expressions and special Profiles */
	bzero(expressions, sizeof(BooleanExpression *) * 4); 
	bzero(specialProfiles, sizeof(id) * 16);

	return self;
}

- (void)setDefaultsTo:(int)numPhones
{
id tempList, tempProto, tempEntry = nil, tempOnset = nil, tempDuration = nil;
int i;

	/* Empty out the lists */
	[parameterProfiles removeAllObjects];
	[metaParameterProfiles removeAllObjects];
	[expressionSymbols removeAllObjects];

	if ((numPhones<2) || (numPhones > 4))
		return;

	tempProto = NXGetNamedObject(@"prototypeManager", NSApp);
	switch(numPhones)
	{
		case 2: tempEntry = [tempProto findTransitionList: "Defaults" named: "Diphone"];
			break;
		case 3: tempEntry = [tempProto findTransitionList: "Defaults" named: "Triphone"];
			break;
		case 4: tempEntry = [tempProto findTransitionList: "Defaults" named: "Tetraphone"];
			break;
	}

	if (tempEntry == nil)
	{
		printf("CANNOT find temp entry\n");
	}

	tempList = NXGetNamedObject(@"mainParameterList", NSApp);
	for(i = 0;i<[tempList count]; i++)
	{
		[parameterProfiles addObject:tempEntry];
	}

	/* Alloc lists to point to prototype transition specifiers */
	tempList = NXGetNamedObject(@"mainMetaParameterList", NSApp);
	for(i = 0;i<[tempList count]; i++)
	{
		[metaParameterProfiles addObject:tempEntry];
	}

	switch(numPhones)
	{
		case 2: tempDuration = [tempProto findEquationList: "DefaultDurations" named: "DiphoneDefault"];
			[expressionSymbols addObject: tempDuration];

			tempOnset = [tempProto findEquationList: "SymbolDefaults" named: "Beat"];
			[expressionSymbols addObject: tempOnset];

			[expressionSymbols addObject: tempDuration]; /* Make the duration the mark1 value */

			break;
		case 3: tempDuration = [tempProto findEquationList: "DefaultDurations" named: "TriphoneDefault"];
			[expressionSymbols addObject: tempDuration];

			tempOnset = [tempProto findEquationList: "SymbolDefaults" named: "Beat"];
			[expressionSymbols addObject: tempOnset];

			tempEntry = [tempProto findEquationList: "SymbolDefaults" named: "Mark1"];
			[expressionSymbols addObject: tempEntry];
			[expressionSymbols addObject: tempDuration];	/* make the duration the mark2 value */

			break;
		case 4: tempDuration = [tempProto findEquationList: "DefaultDurations" named: "TetraphoneDefault"];
			[expressionSymbols addObject: tempDuration];

			tempOnset = [tempProto findEquationList: "SymbolDefaults" named: "Beat"];
			[expressionSymbols addObject: tempOnset];

			tempEntry = [tempProto findEquationList: "SymbolDefaults" named: "Mark1"];
			[expressionSymbols addObject: tempEntry];

			tempEntry = [tempProto findEquationList: "SymbolDefaults" named: "Mark2"];
			[expressionSymbols addObject: tempEntry];
			[expressionSymbols addObject: tempDuration];	/* make the duration the mark3 value */

			break;
	} 
}

- (void)addDefaultParameter
{
id tempProto, tempEntry;


	tempProto = NXGetNamedObject(@"prototypeManager", NSApp);
	switch([self numberExpressions])
	{
		case 2: tempEntry = [tempProto findTransitionList: "Defaults" named: "Diphone"];
			break;
		case 3: tempEntry = [tempProto findTransitionList: "Defaults" named: "Triphone"];
			break;
		case 4: tempEntry = [tempProto findTransitionList: "Defaults" named: "Tetraphone"];
			break;
	}

	[parameterProfiles addObject:tempEntry]; 
}

- (void)addDefaultMetaParameter
{
id tempProto, tempEntry;


	tempProto = NXGetNamedObject(@"prototypeManager", NSApp);
	switch([self numberExpressions])
	{
		case 2: tempEntry = [tempProto findTransitionList: "Defaults" named: "Diphone"];
			break;
		case 3: tempEntry = [tempProto findTransitionList: "Defaults" named: "Triphone"];
			break;
		case 4: tempEntry = [tempProto findTransitionList: "Defaults" named: "Tetraphone"];
			break;
	}

	[metaParameterProfiles addObject:tempEntry]; 
}

- (void)removeParameter:(int)index
{
	printf("Removing Object atIndex: %d\n", index);
	[parameterProfiles removeObjectAtIndex: index];
}

- (void)removeMetaParameter:(int)index
{
	[metaParameterProfiles removeObjectAtIndex: index]; 
}

- (void)dealloc
{
int i;
	for(i = 0 ; i<4; i++)
		if (expressions[i])
			[expressions[i] release];

	[super dealloc];
}

- setExpression: (BooleanExpression *) expression number:(int) index
{
	if ((index>3) || (index<0))
		return self;

	if (expressions[index])
		[expressions[index] release];

	expressions[index] = expression;

	return self;
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

- getExpressionNumber:(int)index
{
	if ((index>3) || (index<0))
		return nil;
	return (expressions[index]);
}

- (int) numberExpressions
{
int i;

	for (i = 0; i<4; i++)
		if (expressions[i] == nil)
			return (i);
	return i;
}

-(int)matchRule: (MonetList *) categories
{
int i;

	for (i = 0; i < [self numberExpressions]; i++)
	{
		if (![expressions[i] evaluate:[categories objectAtIndex:i]])
			return 0;
	}

	return 1;
}

- getExpressionSymbol:(int)index
{
	return [expressionSymbols objectAtIndex:index];
}

- evaluateExpressionSymbols:(double *) buffer tempos: (double *) tempos phones: phones withCache: (int) cache;
{

	buffer[0] = [(ProtoEquation *) [expressionSymbols objectAtIndex:0] evaluate: buffer tempos: tempos
		 phones: phones andCacheWith: cache];
	buffer[2] = [(ProtoEquation *) [expressionSymbols objectAtIndex:2] evaluate: buffer tempos: tempos
		phones: phones andCacheWith: cache];
	buffer[3] = [(ProtoEquation *) [expressionSymbols objectAtIndex:3] evaluate: buffer tempos: tempos
		phones: phones andCacheWith: cache];
	buffer[4] = [(ProtoEquation *) [expressionSymbols objectAtIndex:4] evaluate: buffer tempos: tempos
		phones: phones andCacheWith: cache];
	buffer[1] = [(ProtoEquation *) [expressionSymbols objectAtIndex:1] evaluate: buffer tempos: tempos
		phones: phones andCacheWith: cache];

	return self;
}

- parameterList
{
	return parameterProfiles;
}

- metaParameterList
{
	return metaParameterProfiles;
}

- symbols
{
	return expressionSymbols;
}

- getSpecialProfile:(int)index
{
	if ((index>15) || (index<0))
		return nil;
	else
		return specialProfiles[index];
}

- setSpecialProfile:(int) index to:special
{
	if ((index>15) || (index<0))
		return self;

	specialProfiles[index] = special;

	return self;
}

- (BOOL) isCategoryUsed: aCategory
{
int i;

	for (i = 0; i<[self numberExpressions]; i++)
	{
		if ([expressions[i] isCategoryUsed:aCategory])
			return YES;
	}
	return NO;
}

- (BOOL) isEquationUsed: anEquation
{
	if ([expressionSymbols indexOfObject: anEquation] !=NSNotFound)
		return YES;
	return NO;
}

- (BOOL) isTransitionUsed: aTransition
{
int i;

	if ([parameterProfiles indexOfObject: aTransition] !=NSNotFound)
		return YES;
	if ([metaParameterProfiles indexOfObject: aTransition] !=NSNotFound)
		return YES;

	for(i = 0; i<16; i++)
	{
		if (specialProfiles[i] == aTransition)
			return YES;
	}

	return NO;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
int i, j, k;
int parms, metaParms, symbols;
id tempProto = NXGetNamedObject(@"prototypeManager", NSApp);
id tempParameter, tempList;

	tempList = NXGetNamedObject(@"mainParameterList", NSApp);
	parameterProfiles = [[MonetList alloc] initWithCapacity:[tempList count]];

	tempList = NXGetNamedObject(@"mainMetaParameterList", NSApp);
	metaParameterProfiles = [[MonetList alloc] initWithCapacity:[tempList count]];

	expressionSymbols = [[MonetList alloc] initWithCapacity: 5];

	[aDecoder decodeValuesOfObjCTypes:"i*", &i, &comment];
	bzero(expressions, sizeof(BooleanExpression *) * 4); 
	for (j = 0; j<i; j++)
	{
		expressions[j] = [[aDecoder decodeObject] retain];
	}

	[expressionSymbols removeAllObjects];
	[parameterProfiles removeAllObjects];
	[metaParameterProfiles removeAllObjects];
	bzero(specialProfiles, sizeof(id) * 16);

	[aDecoder decodeValuesOfObjCTypes:"iii", &symbols, &parms, &metaParms];

	for (i = 0; i<symbols; i++)
	{
		[aDecoder decodeValuesOfObjCTypes:"ii", &j, &k];
		tempParameter = [tempProto findEquation: j andIndex: k];
		[expressionSymbols addObject: tempParameter];
	}

	for (i = 0; i<parms; i++)
	{
		[aDecoder decodeValuesOfObjCTypes:"ii", &j, &k];
		tempParameter = [tempProto findTransition: j andIndex: k];
		[parameterProfiles addObject: tempParameter];
	}

	for (i = 0; i<metaParms; i++)
	{
		[aDecoder decodeValuesOfObjCTypes:"ii", &j, &k];
		[metaParameterProfiles addObject: [tempProto findTransition: j andIndex: k]];
	}

	for(i = 0; i< 16; i++)
	{
		[aDecoder decodeValuesOfObjCTypes:"ii", &j, &k];
		if (i==(-1))
		{
			specialProfiles[i] = nil;
		}
		else
		{
			specialProfiles[i] = [tempProto findSpecial: j andIndex: k];
		}
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
int i, j, k, dummy;
int parms, metaParms, symbols;
id tempProto = NXGetNamedObject(@"prototypeManager", NSApp);

	i = [self numberExpressions];
	[aCoder encodeValuesOfObjCTypes:"i*", &i, &comment];

	for(j = 0; j<i; j++)
	{
		[aCoder encodeObject:expressions[j]];
	}

	symbols = [expressionSymbols count];
	parms = [parameterProfiles count];
	metaParms = [metaParameterProfiles count];
	[aCoder encodeValuesOfObjCTypes:"iii", &symbols, &parms, &metaParms];

	for (i = 0; i<symbols; i++)
	{
		[tempProto findList: &j andIndex: &k ofEquation: [expressionSymbols objectAtIndex: i]];
		[aCoder encodeValuesOfObjCTypes:"ii", &j, &k];
	}

	for (i = 0; i<parms; i++)
	{
		[tempProto findList: &j andIndex: &k ofTransition: [parameterProfiles objectAtIndex: i]];
		[aCoder encodeValuesOfObjCTypes:"ii", &j, &k];
	}

	for (i = 0; i<metaParms; i++)
	{
		[tempProto findList: &j andIndex: &k ofTransition: [metaParameterProfiles objectAtIndex: i]];
		[aCoder encodeValuesOfObjCTypes:"ii", &j, &k];
	}

	dummy = (-1);

	for(i = 0; i< 16; i++)
	{
		if (specialProfiles[i]!=nil)
		{
			[tempProto findList:&j andIndex: &k ofSpecial: specialProfiles[i]];
			[aCoder encodeValuesOfObjCTypes:"ii", &j, &k];
		}
		else
		{
			[aCoder encodeValuesOfObjCTypes:"ii", &dummy, &dummy];
		}
	}
}

#ifdef NeXT
- read:(NXTypedStream *)stream
{
int i, j, k;
int parms, metaParms, symbols;
id tempProto = NXGetNamedObject(@"prototypeManager", NSApp);
id tempParameter, tempList;

        tempList = NXGetNamedObject(@"mainParameterList", NSApp);
        parameterProfiles = [[MonetList alloc] initWithCapacity:[tempList count]];

        tempList = NXGetNamedObject(@"mainMetaParameterList", NSApp);
        metaParameterProfiles = [[MonetList alloc] initWithCapacity:[tempList count]];

        expressionSymbols = [[MonetList alloc] initWithCapacity: 5];

        NXReadTypes(stream,"i*", &i, &comment);
        bzero(expressions, sizeof(BooleanExpression *) * 4);
        for (j = 0; j<i; j++)
        {
                expressions[j] = NXReadObject(stream);
        }
        [expressionSymbols removeAllObjects];
        [parameterProfiles removeAllObjects];
        [metaParameterProfiles removeAllObjects];
        bzero(specialProfiles, sizeof(id) * 16);

        NXReadTypes(stream, "iii", &symbols, &parms, &metaParms);

        for (i = 0; i<symbols; i++)
        {
                NXReadTypes(stream, "ii", &j, &k);
                tempParameter = [tempProto findEquation: j andIndex: k];
                [expressionSymbols addObject: tempParameter];
        }

        for (i = 0; i<parms; i++)
        {
                NXReadTypes(stream, "ii", &j, &k);
                tempParameter = [tempProto findTransition: j andIndex: k];
                [parameterProfiles addObject: tempParameter];
        }

        for (i = 0; i<metaParms; i++)
        {
                NXReadTypes(stream, "ii", &j, &k);
                [metaParameterProfiles addObject: [tempProto findTransition: j andIndex: k]];
        }

        for(i = 0; i< 16; i++)
        {
                NXReadTypes(stream, "ii", &j, &k);
                if (i==(-1))
                {
                        specialProfiles[i] = nil;
                }
                else
                {
                        specialProfiles[i] = [tempProto findSpecial: j andIndex: k];
                }
        }
        return self;
}
#endif

@end

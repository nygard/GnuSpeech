
#import "ProtoTemplate.h"
#import "PrototypeManager.h"
#import "Point.h"
#import "SlopeRatio.h"
#import "MyController.h"
#import <stdio.h>
#import <string.h>
#import <stdlib.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSPanel.h>

@implementation ProtoTemplate

- init
{
Point *tempPoint;

	name = NULL;
	comment = NULL;
	type = DIPHONE;
	points = [[MonetList alloc] initWithCapacity:2];

	tempPoint = [[Point alloc] init];
	[tempPoint setType:DIPHONE];
	[tempPoint setFreeTime:0.0];
	[tempPoint setValue:0.0];
	[points addObject:tempPoint];

	return self;
}

- initWithName:(NSString *)newName
{
	[self init];
	[self setName:newName];
	return self;
}

- setName:(NSString *)newName
{
int len;
	if (name)
		free(name);

	len = [newName length];
	name = (char *) malloc(len+1);
	strcpy(name, [newName cString]);

	return self;
}

- (NSString *)name
{
	return [NSString stringWithCString:( (const char *) name)];
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

- (void)setPoints:newList
{
	points = newList; 
}

- points
{
	return points;
}

- insertPoint:aPoint
{
int i, j;
id temp, temp1, temp2;
double pointTime = [aPoint getTime];

	for(i = 0; i<[points count]; i++)
	{
		temp = [points objectAtIndex: i];
		if ([temp isKindOfClassNamed:"SlopeRatio"])
		{
			if (pointTime < [temp startTime])
			{
				[points insertObject: aPoint atIndex: i];
				return self;
			}
			else	/* Insert point into Slope Ratio */
			if (pointTime < [temp endTime])
			{
				if(NSRunAlertPanel(@"Insert Point", @"Insert Point into Slope Ratio?", @"Yes", @"Cancel", nil)
					== NSAlertDefaultReturn)
				{
					temp1 = [temp points];
					for(j = 1; j<[temp1 count]; j++)
					{
						temp2 = [temp1 objectAtIndex: j];
						if (pointTime < [temp2 getTime])
						{
							[temp1 insertObject: aPoint atIndex: j];
							[temp updateSlopes];
							return self;
						}
					}
					/* Should never get here, but if it does, signal error */
					return nil;
				}
				else
					return nil;
			}
		}
		else
		{
			if (pointTime<[temp getTime])
			{
				[points insertObject: aPoint atIndex: i];
				return self;
			}
		}
	}

	[points addObject: aPoint]; 
	return self;
}

- (void)setType:(int)newType
{
	type = newType;
}

- (int) type
{
	return type;
}

- (void)dealloc
{
	if (name) 
		free(name);

	if (comment) 
		free(comment);

	[points release];

	[super dealloc];
}

- (BOOL) isEquationUsed: anEquation
{
int i, j;
id temp;
	for(i = 0; i<[points count]; i++)
	{
		temp = [points objectAtIndex: i];
		if ([temp isKindOfClassNamed:"SlopeRatio"])
		{
			temp = [temp points];
			for (j = 0; j<[temp count]; j++)
				if (anEquation == [[temp objectAtIndex:j] expression])
					return YES;
		}
		else
			if (anEquation == [[points objectAtIndex:i] expression])
				return YES;
	}
	return NO;
}

- findEquation: anEquation andPutIn: aList
{
int i, j;
id temp, temp1;
	for(i = 0; i<[points count]; i++)
	{
		temp = [points objectAtIndex: i];
		if ([temp isKindOfClassNamed:"SlopeRatio"])
		{
			temp1 = [temp points];
			for (j = 0; j<[temp1 count]; j++)
				if (anEquation == [[temp1 objectAtIndex:j] expression])
				{
					[aList addObject: self];
					return self;
				}
		}
		else
			if (anEquation == [[points objectAtIndex:i] expression])
			{
				[aList addObject: self];
				return self;
			}
	}
	return self;

}

- (id)initWithCoder:(NSCoder *)aDecoder
{
Point *tempPoint;
id tempProto = NXGetNamedObject(@"prototypeManager", NSApp);

	[aDecoder decodeValuesOfObjCTypes:"**i", &name, &comment, &type];
	points = [[aDecoder decodeObject] retain];

//	printf("Points = %d\n", [points count]);

	if (points == nil)
	{
		points = [[MonetList alloc] initWithCapacity:3];

		tempPoint = [[Point alloc] init];
		[tempPoint setValue:0.0];
		[tempPoint setType:DIPHONE];
		[tempPoint setExpression:[tempProto findEquationList: "Test" named: "Zero"]];
		[points addObject: tempPoint];

		tempPoint = [[Point alloc] init];
		[tempPoint setValue:12.5];
		[tempPoint setType:DIPHONE];
		[tempPoint setExpression:[tempProto findEquationList: "Test" named: "diphoneOneThree"]];
		[points addObject: tempPoint];

		tempPoint = [[Point alloc] init];
		[tempPoint setValue:87.5];
		[tempPoint setType:DIPHONE];
		[tempPoint setExpression:[tempProto findEquationList: "Test" named: "diphoneTwoThree"]];
		[points addObject: tempPoint];

		tempPoint = [[Point alloc] init];
		[tempPoint setValue:100.0];
		[tempPoint setType:DIPHONE];
		[tempPoint setExpression:[tempProto findEquationList: "Defaults" named: "Mark1"]];
		[points addObject: tempPoint];

		if (type == DIPHONE)
			return self;

		tempPoint = [[Point alloc] init];
		[tempPoint setValue:12.5];
		[tempPoint setType:TRIPHONE];
		[tempPoint setExpression:[tempProto findEquationList: "Test" named: "triphoneOneThree"]];
		[points addObject: tempPoint];

		tempPoint = [[Point alloc] init];
		[tempPoint setValue:87.5];
		[tempPoint setType:TRIPHONE];
		[tempPoint setExpression:[tempProto findEquationList: "Test" named: "triphoneTwoThree"]];
		[points addObject: tempPoint];

		tempPoint = [[Point alloc] init];
		[tempPoint setValue:100.0];
		[tempPoint setType:TRIPHONE];
		[tempPoint setExpression:[tempProto findEquationList: "Defaults" named: "Mark2"]];
		[points addObject: tempPoint];

		if (type == TRIPHONE)
			return self;

		tempPoint = [[Point alloc] init];
		[tempPoint setValue:12.5];
		[tempPoint setType:TETRAPHONE];
		[tempPoint setExpression:[tempProto findEquationList: "Test" named: "tetraphoneOneThree"]];
		[points addObject: tempPoint];

		tempPoint = [[Point alloc] init];
		[tempPoint setValue:87.5];
		[tempPoint setType:TETRAPHONE];
		[tempPoint setExpression:[tempProto findEquationList: "Test" named: "tetraphoneTwoThree"]];
		[points addObject: tempPoint];

		tempPoint = [[Point alloc] init];
		[tempPoint setValue:100.0];
		[tempPoint setType:TETRAPHONE];
		[tempPoint setExpression:[tempProto findEquationList: "Durations" named: "TetraphoneDefault"]];
		[points addObject: tempPoint];


	}

	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeValuesOfObjCTypes:"**i", &name, &comment, &type];
	[aCoder encodeObject:points];
}

#ifdef NeXT
- read:(NXTypedStream *)stream
{
Point *tempPoint;
id tempProto = NXGetNamedObject(@"prototypeManager", NSApp);

        NXReadTypes(stream, "**i", &name, &comment, &type);
        points = NXReadObject(stream);

//      printf("Points = %d\n", [points count]);

        if (points == nil)
        {
                points = [[MonetList alloc] initWithCapacity:3];

                tempPoint = [[Point alloc] init];
                [tempPoint setValue: 0.0];
                [tempPoint setType: DIPHONE];
                [tempPoint setExpression: [tempProto findEquationList: "Test" named: "Zero"]];
                [points addObject: tempPoint];

                tempPoint = [[Point alloc] init];
                [tempPoint setValue: 12.5];
                [tempPoint setType: DIPHONE];
                [tempPoint setExpression: [tempProto findEquationList: "Test" named: "diphoneOneThree"]];
                [points addObject: tempPoint];

                tempPoint = [[Point alloc] init];
                [tempPoint setValue: 87.5];
                [tempPoint setType: DIPHONE];
                [tempPoint setExpression: [tempProto findEquationList: "Test" named: "diphoneTwoThree"]];
                [points addObject: tempPoint];

                tempPoint = [[Point alloc] init];
                [tempPoint setValue: 100.0];
                [tempPoint setType: DIPHONE];
                [tempPoint setExpression: [tempProto findEquationList: "Defaults" named: "Mark1"]];
                [points addObject: tempPoint];

                if (type == DIPHONE)
                        return self;

                tempPoint = [[Point alloc] init];
                [tempPoint setValue: 12.5];
                [tempPoint setType: TRIPHONE];
                [tempPoint setExpression: [tempProto findEquationList: "Test" named: "triphoneOneThree"]];
                [points addObject: tempPoint];

                tempPoint = [[Point alloc] init];
                [tempPoint setValue: 87.5];
                [tempPoint setType: TRIPHONE];
                [tempPoint setExpression: [tempProto findEquationList: "Test" named: "triphoneTwoThree"]];
                [points addObject: tempPoint];

                tempPoint = [[Point alloc] init];
                [tempPoint setValue: 100.0];
                [tempPoint setType: TRIPHONE];
                [tempPoint setExpression: [tempProto findEquationList: "Defaults" named: "Mark2"]];
                [points addObject: tempPoint];

                if (type == TRIPHONE)
                        return self;

                tempPoint = [[Point alloc] init];
                [tempPoint setValue: 12.5];
                [tempPoint setType: TETRAPHONE];
                [tempPoint setExpression: [tempProto findEquationList: "Test" named: "tetraphoneOneThree"]];
                [points addObject: tempPoint];

                tempPoint = [[Point alloc] init];
                [tempPoint setValue: 87.5];
                [tempPoint setType: TETRAPHONE];
                [tempPoint setExpression: [tempProto findEquationList: "Test" named: "tetraphoneTwoThree"]];
                [points addObject: tempPoint];

                tempPoint = [[Point alloc] init];
                [tempPoint setValue: 100.0];
                [tempPoint setType: TETRAPHONE];
                [tempPoint setExpression: [tempProto findEquationList: "Durations" named: "TetraphoneDefault"]];
                [points addObject: tempPoint];


        }

        return self;
}
#endif

@end

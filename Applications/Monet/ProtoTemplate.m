#import "ProtoTemplate.h"

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "MonetList.h"
#import "MyController.h"
#import "Point.h"
#import "PrototypeManager.h"
#import "SlopeRatio.h"

#ifdef PORTING
#import "SlopeRatio.h"
#import <stdio.h>
#import <string.h>
#import <stdlib.h>
#endif

@implementation ProtoTemplate

- (id)init;
{
    GSMPoint *aPoint;

    if ([super init] == nil)
        return nil;

    name = nil;
    comment = nil;
    type = DIPHONE;
    points = [[MonetList alloc] initWithCapacity:2];

    aPoint = [[GSMPoint alloc] init];
    [aPoint setType:DIPHONE];
    [aPoint setFreeTime:0.0];
    [aPoint setValue:0.0];
    [points addObject:aPoint];
    [aPoint release];

    return self;
}

- (id)initWithName:(NSString *)newName;
{
    if ([self init] == nil)
        return nil;

    [self setName:newName];

    return self;
}

- (void)dealloc;
{
    [name release];
    [comment release];
    [points release];

    [super dealloc];
}

- (NSString *)name;
{
    return name;
}

- (void)setName:(NSString *)newName;
{
    if (newName == name)
        return;

    [name release];
    name = [newName retain];
}

- (NSString *)comment;
{
    return comment;
}

- (void)setComment:(NSString *)newComment;
{
    if (newComment == comment)
        return;

    [comment release];
    comment = [newComment retain];
}

- (MonetList *)points;
{
    return points;
}

- (void)setPoints:(MonetList *)newList;
{
    if (newList == points)
        return;

    [points release];
    points = [newList retain];
}

- insertPoint:aPoint;
{
    int i, j;
    id temp, temp1, temp2;
    double pointTime = [aPoint getTime];

    for (i = 0; i < [points count]; i++) {
        temp = [points objectAtIndex:i];
        if ([temp isKindOfClass:[SlopeRatio class]]) {
            if (pointTime < [temp startTime]) {
                [points insertObject:aPoint atIndex:i];
                return self;
            } else	/* Insert point into Slope Ratio */
                if (pointTime < [temp endTime]) {
                    if (NSRunAlertPanel(@"Insert Point", @"Insert Point into Slope Ratio?", @"Yes", @"Cancel", nil) == NSAlertDefaultReturn) {
                        temp1 = [temp points];
                        for (j = 1; j < [temp1 count]; j++) {
                            temp2 = [temp1 objectAtIndex:j];
                            if (pointTime < [temp2 getTime]) {
                                [temp1 insertObject:aPoint atIndex:j];
                                [temp updateSlopes];
                                return self;
                            }
                        }

                        /* Should never get here, but if it does, signal error */
                        return nil;
                    } else
                        return nil;
                }
        } else {
            if (pointTime < [temp getTime]) {
                [points insertObject:aPoint atIndex:i];
                return self;
            }
        }
    }

    [points addObject:aPoint];

    return self;
}

- (int)type;
{
    return type;
}

- (void)setType:(int)newType;
{
    type = newType;
}

- (BOOL)isEquationUsed:anEquation;
{
    int i, j;
    id temp;

    for (i = 0; i < [points count]; i++) {
        temp = [points objectAtIndex: i];
        if ([temp isKindOfClass:[SlopeRatio class]]) {
            temp = [temp points];
            for (j = 0; j < [temp count]; j++)
                if (anEquation == [[temp objectAtIndex:j] expression])
                    return YES;
        } else
            if (anEquation == [[points objectAtIndex:i] expression])
                return YES;
    }

    return NO;
}

- findEquation:anEquation andPutIn:aList;
{
    int i, j;
    id temp, temp1;

    for (i = 0; i < [points count]; i++) {
        temp = [points objectAtIndex:i];
        if ([temp isKindOfClass:[SlopeRatio class]]) {
            temp1 = [temp points];
            for (j = 0; j < [temp1 count]; j++)
                if (anEquation == [[temp1 objectAtIndex:j] expression]) {
                    [aList addObject:self];
                    return self;
                }
        } else
            if (anEquation == [[points objectAtIndex:i] expression]) {
                [aList addObject: self];
                return self;
            }
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    GSMPoint *aPoint;
    id tempProto = NXGetNamedObject(@"prototypeManager", NSApp);

    [aDecoder decodeValuesOfObjCTypes:"**i", &name, &comment, &type];
    points = [[aDecoder decodeObject] retain];

    //NSLog(@"Points = %d", [points count]);

    if (points == nil) {
        points = [[MonetList alloc] initWithCapacity:3];

        aPoint = [[GSMPoint alloc] init];
        [aPoint setValue:0.0];
        [aPoint setType:DIPHONE];
        [aPoint setExpression:[tempProto findEquationList:@"Test" named:@"Zero"]];
        [points addObject:aPoint];
        [aPoint release];

        aPoint = [[GSMPoint alloc] init];
        [aPoint setValue:12.5];
        [aPoint setType:DIPHONE];
        [aPoint setExpression:[tempProto findEquationList:@"Test" named:@"diphoneOneThree"]];
        [points addObject:aPoint];
        [aPoint release];

        aPoint = [[GSMPoint alloc] init];
        [aPoint setValue:87.5];
        [aPoint setType:DIPHONE];
        [aPoint setExpression:[tempProto findEquationList:@"Test" named:@"diphoneTwoThree"]];
        [points addObject:aPoint];
        [aPoint release];

        aPoint = [[GSMPoint alloc] init];
        [aPoint setValue:100.0];
        [aPoint setType:DIPHONE];
        [aPoint setExpression:[tempProto findEquationList:@"Defaults" named:@"Mark1"]];
        [points addObject:aPoint];
        [aPoint release];

        if (type == DIPHONE)
            return self;

        aPoint = [[GSMPoint alloc] init];
        [aPoint setValue:12.5];
        [aPoint setType:TRIPHONE];
        [aPoint setExpression:[tempProto findEquationList:@"Test" named:@"triphoneOneThree"]];
        [points addObject:aPoint];
        [aPoint release];

        aPoint = [[GSMPoint alloc] init];
        [aPoint setValue:87.5];
        [aPoint setType:TRIPHONE];
        [aPoint setExpression:[tempProto findEquationList:@"Test" named:@"triphoneTwoThree"]];
        [points addObject:aPoint];
        [aPoint release];

        aPoint = [[GSMPoint alloc] init];
        [aPoint setValue:100.0];
        [aPoint setType:TRIPHONE];
        [aPoint setExpression:[tempProto findEquationList:@"Defaults" named:@"Mark2"]];
        [points addObject:aPoint];
        [aPoint release];

        if (type == TRIPHONE)
            return self;

        aPoint = [[GSMPoint alloc] init];
        [aPoint setValue:12.5];
        [aPoint setType:TETRAPHONE];
        [aPoint setExpression:[tempProto findEquationList:@"Test" named:@"tetraphoneOneThree"]];
        [points addObject:aPoint];
        [aPoint release];

        aPoint = [[GSMPoint alloc] init];
        [aPoint setValue:87.5];
        [aPoint setType:TETRAPHONE];
        [aPoint setExpression:[tempProto findEquationList:@"Test" named:@"tetraphoneTwoThree"]];
        [points addObject:aPoint];
        [aPoint release];

        aPoint = [[GSMPoint alloc] init];
        [aPoint setValue:100.0];
        [aPoint setType:TETRAPHONE];
        [aPoint setExpression:[tempProto findEquationList:@"Durations" named:@"TetraphoneDefault"]];
        [points addObject:aPoint];
        [aPoint release];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [aCoder encodeValuesOfObjCTypes:"**i", &name, &comment, &type];
    [aCoder encodeObject:points];
}

#ifdef NeXT
- read:(NXTypedStream *)stream;
{
    GSMPoint *tempPoint;
    id tempProto = NXGetNamedObject(@"prototypeManager", NSApp);

    NXReadTypes(stream, "**i", &name, &comment, &type);
    points = NXReadObject(stream);

//      printf("Points = %d\n", [points count]);

    if (points == nil)
    {
        points = [[MonetList alloc] initWithCapacity:3];

        tempPoint = [[GSMPoint alloc] init];
        [tempPoint setValue: 0.0];
        [tempPoint setType: DIPHONE];
        [tempPoint setExpression: [tempProto findEquationList:"Test" named: "Zero"]];
        [points addObject: tempPoint];

        tempPoint = [[GSMPoint alloc] init];
        [tempPoint setValue: 12.5];
        [tempPoint setType: DIPHONE];
        [tempPoint setExpression: [tempProto findEquationList: "Test" named: "diphoneOneThree"]];
        [points addObject: tempPoint];

        tempPoint = [[GSMPoint alloc] init];
        [tempPoint setValue: 87.5];
        [tempPoint setType: DIPHONE];
        [tempPoint setExpression: [tempProto findEquationList: "Test" named: "diphoneTwoThree"]];
        [points addObject: tempPoint];

        tempPoint = [[GSMPoint alloc] init];
        [tempPoint setValue: 100.0];
        [tempPoint setType: DIPHONE];
        [tempPoint setExpression: [tempProto findEquationList: "Defaults" named: "Mark1"]];
        [points addObject: tempPoint];

        if (type == DIPHONE)
            return self;

        tempPoint = [[GSMPoint alloc] init];
        [tempPoint setValue: 12.5];
        [tempPoint setType: TRIPHONE];
        [tempPoint setExpression: [tempProto findEquationList: "Test" named: "triphoneOneThree"]];
        [points addObject: tempPoint];

        tempPoint = [[GSMPoint alloc] init];
        [tempPoint setValue: 87.5];
        [tempPoint setType: TRIPHONE];
        [tempPoint setExpression: [tempProto findEquationList: "Test" named: "triphoneTwoThree"]];
        [points addObject: tempPoint];

        tempPoint = [[GSMPoint alloc] init];
        [tempPoint setValue: 100.0];
        [tempPoint setType: TRIPHONE];
        [tempPoint setExpression: [tempProto findEquationList: "Defaults" named: "Mark2"]];
        [points addObject: tempPoint];

        if (type == TRIPHONE)
            return self;

        tempPoint = [[GSMPoint alloc] init];
        [tempPoint setValue: 12.5];
        [tempPoint setType: TETRAPHONE];
        [tempPoint setExpression: [tempProto findEquationList: "Test" named: "tetraphoneOneThree"]];
        [points addObject: tempPoint];

        tempPoint = [[GSMPoint alloc] init];
        [tempPoint setValue: 87.5];
        [tempPoint setType: TETRAPHONE];
        [tempPoint setExpression: [tempProto findEquationList: "Test" named: "tetraphoneTwoThree"]];
        [points addObject: tempPoint];

        tempPoint = [[GSMPoint alloc] init];
        [tempPoint setValue: 100.0];
        [tempPoint setType: TETRAPHONE];
        [tempPoint setExpression: [tempProto findEquationList: "Durations" named: "TetraphoneDefault"]];
        [points addObject: tempPoint];


    }

    return self;
}
#endif

@end

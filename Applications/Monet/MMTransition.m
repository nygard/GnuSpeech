#import "MMTransition.h"

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "NSString-Extensions.h"

#import "AppController.h"
#import "GSXMLFunctions.h"
#import "MonetList.h"
#import "MMPoint.h"
#import "PrototypeManager.h"
#import "SlopeRatio.h"

#import "MModel.h"
#import "MUnarchiver.h"

@implementation MMTransition

- (id)init;
{
    MMPoint *aPoint;

    if ([super init] == nil)
        return nil;

    name = nil;
    comment = nil;
    type = DIPHONE;
    points = [[MonetList alloc] initWithCapacity:2];

    aPoint = [[MMPoint alloc] init];
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
                    // TODO (2004-03-12): Move this out of the model.
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

- (BOOL)isEquationUsed:(MMEquation *)anEquation;
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

- findEquation:anEquation andPutIn:(MonetList *)aList;
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
    unsigned archivedVersion;
    char *c_name, *c_comment;
    MonetList *archivedPoints;
    MModel *model;

    if ([self init] == nil)
        return nil;

    model = [(MUnarchiver *)aDecoder userInfo];

    //NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    archivedVersion = [aDecoder versionForClassName:NSStringFromClass([self class])];
    //NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

    [aDecoder decodeValuesOfObjCTypes:"**i", &c_name, &c_comment, &type];
    //NSLog(@"c_name: %s, c_comment: %s, type: %d", c_name, c_comment, type);
    [self setName:[NSString stringWithASCIICString:c_name]];
    [self setComment:[NSString stringWithASCIICString:c_comment]];

    archivedPoints = [aDecoder decodeObject];
    //NSLog(@"archivedPoints: %@", archivedPoints);

    //NSLog(@"Points = %d", [points count]);

    if (points == nil) {
        MonetList *defaultPoints;
        MMPoint *aPoint;

        defaultPoints = [[MonetList alloc] initWithCapacity:3];

        aPoint = [[MMPoint alloc] init];
        [aPoint setValue:0.0];
        [aPoint setType:DIPHONE];
        [aPoint setExpression:[model findEquationList:@"Test" named:@"Zero"]];
        [defaultPoints addObject:aPoint];
        [aPoint release];

        aPoint = [[MMPoint alloc] init];
        [aPoint setValue:12.5];
        [aPoint setType:DIPHONE];
        [aPoint setExpression:[model findEquationList:@"Test" named:@"diphoneOneThree"]];
        [defaultPoints addObject:aPoint];
        [aPoint release];

        aPoint = [[MMPoint alloc] init];
        [aPoint setValue:87.5];
        [aPoint setType:DIPHONE];
        [aPoint setExpression:[model findEquationList:@"Test" named:@"diphoneTwoThree"]];
        [defaultPoints addObject:aPoint];
        [aPoint release];

        aPoint = [[MMPoint alloc] init];
        [aPoint setValue:100.0];
        [aPoint setType:DIPHONE];
        [aPoint setExpression:[model findEquationList:@"Defaults" named:@"Mark1"]];
        [defaultPoints addObject:aPoint];
        [aPoint release];

        if (type != DIPHONE) {
            aPoint = [[MMPoint alloc] init];
            [aPoint setValue:12.5];
            [aPoint setType:TRIPHONE];
            [aPoint setExpression:[model findEquationList:@"Test" named:@"triphoneOneThree"]];
            [defaultPoints addObject:aPoint];
            [aPoint release];

            aPoint = [[MMPoint alloc] init];
            [aPoint setValue:87.5];
            [aPoint setType:TRIPHONE];
            [aPoint setExpression:[model findEquationList:@"Test" named:@"triphoneTwoThree"]];
            [defaultPoints addObject:aPoint];
            [aPoint release];

            aPoint = [[MMPoint alloc] init];
            [aPoint setValue:100.0];
            [aPoint setType:TRIPHONE];
            [aPoint setExpression:[model findEquationList:@"Defaults" named:@"Mark2"]];
            [defaultPoints addObject:aPoint];
            [aPoint release];

            if (type != TRIPHONE) {
                aPoint = [[MMPoint alloc] init];
                [aPoint setValue:12.5];
                [aPoint setType:TETRAPHONE];
                [aPoint setExpression:[model findEquationList:@"Test" named:@"tetraphoneOneThree"]];
                [defaultPoints addObject:aPoint];
                [aPoint release];

                aPoint = [[MMPoint alloc] init];
                [aPoint setValue:87.5];
                [aPoint setType:TETRAPHONE];
                [aPoint setExpression:[model findEquationList:@"Test" named:@"tetraphoneTwoThree"]];
                [defaultPoints addObject:aPoint];
                [aPoint release];

                aPoint = [[MMPoint alloc] init];
                [aPoint setValue:100.0];
                [aPoint setType:TETRAPHONE];
                [aPoint setExpression:[model findEquationList:@"Durations" named:@"TetraphoneDefault"]];
                [defaultPoints addObject:aPoint];
                [aPoint release];
            }
        }

        [self setPoints:defaultPoints];
        [defaultPoints release];
    } else
        [self setPoints:archivedPoints];

    //NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [aCoder encodeValuesOfObjCTypes:"**i", &name, &comment, &type];
    [aCoder encodeObject:points];
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: name: %@, comment: %@, type: %d, points: %@",
                     NSStringFromClass([self class]), self, name, comment, type, points];
}

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
{
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<transition name=\"%@\" type=\"%d\">\n",
                  GSXMLAttributeString(name, NO), type];

    if (comment != nil) {
        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<comment>%@</comment>\n", GSXMLCharacterData(comment)];
    }

    [points appendXMLToString:resultString elementName:@"points" level:level + 1];

    [resultString indentToLevel:level];
    [resultString appendFormat:@"</transition>\n"];
}

@end

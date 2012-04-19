//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMTransition.h"

#import <Foundation/Foundation.h>
#import "NSArray-Extensions.h"
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "GSXMLFunctions.h"
#import "MonetList.h"
#import "MMPoint.h"
#import "MMSlopeRatio.h"
#import "NamedList.h"

#import "MModel.h"
#import "MUnarchiver.h"

#import "MXMLParser.h"
#import "MXMLArrayDelegate.h"
#import "MXMLPCDataDelegate.h"

@implementation MMTransition

- (id)init;
{
    if ([super init] == nil)
        return nil;

    name = nil;
    comment = nil;
    type = MMPhoneTypeDiphone;
    points = [[NSMutableArray alloc] init];

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

- (void)addInitialPoint;
{
    MMPoint *aPoint;

    aPoint = [[MMPoint alloc] init];
    [aPoint setType:MMPhoneTypeDiphone];
    [aPoint setFreeTime:0.0];
    [aPoint setValue:0.0];
    [self addPoint:aPoint];
    [aPoint release];
}

- (NamedList *)group;
{
    return nonretained_group;
}

- (void)setGroup:(NamedList *)newGroup;
{
    nonretained_group = newGroup;
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

- (BOOL)hasComment;
{
    return comment != nil && [comment length] > 0;
}

- (NSMutableArray *)points;
{
    return points;
}

- (void)setPoints:(NSMutableArray *)newList;
{
    if (newList == points)
        return;

    [points release];
    points = [newList retain];
}

// Can be either an MMPoint or an MMSlopeRatio
- (void)addPoint:(id)newPoint;
{
    [points addObject:newPoint];
}

// pointTime = [aPoint cachedTime];
- (BOOL)isTimeInSlopeRatio:(double)aTime;
{
    unsigned pointCount, pointIndex;
    id currentPointOrSlopeRatio;

    pointCount = [points count];
    for (pointIndex = 0; pointIndex < pointCount; pointIndex++) {
        currentPointOrSlopeRatio = [points objectAtIndex:pointIndex];

        if ([currentPointOrSlopeRatio isKindOfClass:[MMSlopeRatio class]]) {
            if (aTime < [currentPointOrSlopeRatio startTime])
                return NO;
            else if (aTime < [currentPointOrSlopeRatio endTime]) /* Insert point into Slope Ratio */
                return YES;
        } else if (aTime < [currentPointOrSlopeRatio cachedTime]) {
            return NO;
        }
    }

    return NO;
}

- (void)insertPoint:(MMPoint *)aPoint;
{
    int i, j;
    id temp, temp1, temp2;
    double pointTime = [aPoint cachedTime];

    for (i = 0; i < [points count]; i++) {
        temp = [points objectAtIndex:i];
        if ([temp isKindOfClass:[MMSlopeRatio class]]) {
            if (pointTime < [temp startTime]) {
                [points insertObject:aPoint atIndex:i];
                return;
            } else if (pointTime < [temp endTime]) { /* Insert point into Slope Ratio */
                temp1 = [temp points];
                for (j = 1; j < [temp1 count]; j++) {
                    temp2 = [temp1 objectAtIndex:j];
                    if (pointTime < [temp2 cachedTime]) {
                        [temp1 insertObject:aPoint atIndex:j];
                        [temp updateSlopes];
                        return;
                    }
                }

                /* Should never get here */
                return;
            }
        } else {
            if (pointTime < [temp cachedTime]) {
                [points insertObject:aPoint atIndex:i];
                return;
            }
        }
    }

    [points addObject:aPoint];
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
        if ([temp isKindOfClass:[MMSlopeRatio class]]) {
            temp = [temp points];
            for (j = 0; j < [temp count]; j++)
                if (anEquation == [[temp objectAtIndex:j] timeEquation])
                    return YES;
        } else
            if (anEquation == [[points objectAtIndex:i] timeEquation])
                return YES;
    }

    return NO;
}

- (void)findEquation:(MMEquation *)anEquation andPutIn:(MonetList *)aList;
{
    unsigned count, index;
    int j;
    id pointOrSlopeRatio;

    count = [points count];
    for (index = 0; index < count; index++) {
        pointOrSlopeRatio = [points objectAtIndex:index];
        if ([pointOrSlopeRatio isKindOfClass:[MMSlopeRatio class]]) {
            NSArray *slopePoints;

            slopePoints = [pointOrSlopeRatio points];
            for (j = 0; j < [slopePoints count]; j++)
                if (anEquation == [[slopePoints objectAtIndex:j] timeEquation]) {
                    [aList addObject:self];
                    return;
                }
        } else {
            if (anEquation == [[points objectAtIndex:index] timeEquation]) {
                [aList addObject:self];
                return;
            }
        }
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    unsigned archivedVersion;
    char *c_name, *c_comment;
    MonetList *archivedPoints;
    MModel *model;

    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    name = nil;
    comment = nil;
    type = 2;
    points = [[NSMutableArray alloc] init];

    model = [(MUnarchiver *)aDecoder userInfo];

    //NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    archivedVersion = [aDecoder versionForClassName:NSStringFromClass([self class])];
    //NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

    [aDecoder decodeValuesOfObjCTypes:"**i", &c_name, &c_comment, &type];
    //NSLog(@"c_name: %s, c_comment: %s, type: %d", c_name, c_comment, type);
    [self setName:[NSString stringWithASCIICString:c_name]];
    [self setComment:[NSString stringWithASCIICString:c_comment]];
    free(c_name);
    free(c_comment);

    archivedPoints = [aDecoder decodeObject];
    points = [[NSMutableArray alloc] init];
    //NSLog(@"archivedPoints: %@", archivedPoints);

    //NSLog(@"Points = %d", [points count]);

    if (archivedPoints == nil) {
        MMPoint *aPoint;

        NSLog(@"Archived points were nil, using defaults.");

        aPoint = [[MMPoint alloc] init];
        [aPoint setValue:0.0];
        [aPoint setType:MMPhoneTypeDiphone];
        [aPoint setTimeEquation:[model findEquationList:@"Test" named:@"Zero"]];
        [points addObject:aPoint];
        [aPoint release];

        aPoint = [[MMPoint alloc] init];
        [aPoint setValue:12.5];
        [aPoint setType:MMPhoneTypeDiphone];
        [aPoint setTimeEquation:[model findEquationList:@"Test" named:@"diphoneOneThree"]];
        [points addObject:aPoint];
        [aPoint release];

        aPoint = [[MMPoint alloc] init];
        [aPoint setValue:87.5];
        [aPoint setType:MMPhoneTypeDiphone];
        [aPoint setTimeEquation:[model findEquationList:@"Test" named:@"diphoneTwoThree"]];
        [points addObject:aPoint];
        [aPoint release];

        aPoint = [[MMPoint alloc] init];
        [aPoint setValue:100.0];
        [aPoint setType:MMPhoneTypeDiphone];
        [aPoint setTimeEquation:[model findEquationList:@"Defaults" named:@"Mark1"]];
        [points addObject:aPoint];
        [aPoint release];

        if (type != MMPhoneTypeDiphone) {
            aPoint = [[MMPoint alloc] init];
            [aPoint setValue:12.5];
            [aPoint setType:MMPhoneTypeDiphone];
            [aPoint setTimeEquation:[model findEquationList:@"Test" named:@"triphoneOneThree"]];
            [points addObject:aPoint];
            [aPoint release];

            aPoint = [[MMPoint alloc] init];
            [aPoint setValue:87.5];
            [aPoint setType:MMPhoneTypeTriphone];
            [aPoint setTimeEquation:[model findEquationList:@"Test" named:@"triphoneTwoThree"]];
            [points addObject:aPoint];
            [aPoint release];

            aPoint = [[MMPoint alloc] init];
            [aPoint setValue:100.0];
            [aPoint setType:MMPhoneTypeTriphone];
            [aPoint setTimeEquation:[model findEquationList:@"Defaults" named:@"Mark2"]];
            [points addObject:aPoint];
            [aPoint release];

            if (type != MMPhoneTypeTriphone) {
                aPoint = [[MMPoint alloc] init];
                [aPoint setValue:12.5];
                [aPoint setType:MMPhoneTypeTetraphone];
                [aPoint setTimeEquation:[model findEquationList:@"Test" named:@"tetraphoneOneThree"]];
                [points addObject:aPoint];
                [aPoint release];

                aPoint = [[MMPoint alloc] init];
                [aPoint setValue:87.5];
                [aPoint setType:MMPhoneTypeTetraphone];
                [aPoint setTimeEquation:[model findEquationList:@"Test" named:@"tetraphoneTwoThree"]];
                [points addObject:aPoint];
                [aPoint release];

                aPoint = [[MMPoint alloc] init];
                [aPoint setValue:100.0];
                [aPoint setType:MMPhoneTypeTetraphone];
                [aPoint setTimeEquation:[model findEquationList:@"Durations" named:@"TetraphoneDefault"]];
                [points addObject:aPoint];
                [aPoint release];
            }
        }
    } else {
        [points addObjectsFromArray:[archivedPoints allObjects]];
    }

    //NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);

    return self;
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: name: %@, comment: %@, type: %d, points: %@",
                     NSStringFromClass([self class]), self, name, comment, type, points];
}

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
{
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<transition name=\"%@\" type=\"%@\">\n",
                  GSXMLAttributeString(name, NO), GSXMLAttributeString(MMStringFromPhoneType(type), NO)];

    if (comment != nil) {
        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<comment>%@</comment>\n", GSXMLCharacterData(comment)];
    }

    [points appendXMLToString:resultString elementName:@"point-or-slopes" level:level + 1];

    [resultString indentToLevel:level];
    [resultString appendFormat:@"</transition>\n"];
}

- (NSString *)transitionPath;
{
    return [NSString stringWithFormat:@"%@:%@", [[self group] name], name];
}

- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
{
    NSString *str;

    if ([self init] == nil)
        return nil;

    [self setName:[attributes objectForKey:@"name"]];

    str = [attributes objectForKey:@"type"];
    if (str != nil)
        [self setType:MMPhoneTypeFromString(str)];

    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    if ([elementName isEqualToString:@"comment"]) {
        MXMLPCDataDelegate *newDelegate;

        newDelegate = [[MXMLPCDataDelegate alloc] initWithElementName:elementName delegate:self setSelector:@selector(setComment:)];
        [(MXMLParser *)parser pushDelegate:newDelegate];
        [newDelegate release];
    } else if ([elementName isEqualToString:@"point-or-slopes"]) {
        MXMLArrayDelegate *newDelegate;
        NSDictionary *elementClassMapping;

        elementClassMapping = [[NSDictionary alloc] initWithObjectsAndKeys:[MMPoint class], @"point",
                                                    [MMSlopeRatio class], @"slope-ratio",
                                                    nil];
        newDelegate = [[MXMLArrayDelegate alloc] initWithChildElementToClassMapping:elementClassMapping delegate:self addObjectSelector:@selector(addPoint:)];
        [(MXMLParser *)parser pushDelegate:newDelegate];
        [newDelegate release];
        [elementClassMapping release];
    } else {
        NSLog(@"%@, Unknown element: '%@', skipping", [self shortDescription], elementName);
        [(MXMLParser *)parser skipTree];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    [(MXMLParser *)parser popDelegate];
}

@end

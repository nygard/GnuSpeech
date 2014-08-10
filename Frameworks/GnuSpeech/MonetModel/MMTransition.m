//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMTransition.h"

#import "NSArray-Extensions.h"
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "GSXMLFunctions.h"
#import "MMPoint.h"
#import "MMSlopeRatio.h"
#import "MMGroup.h"

#import "MModel.h"

@implementation MMTransition
{
    MMPhoneType _type;
    NSMutableArray *_points; // Of MMSlopeRatios and/or MMPoints
}

- (id)init;
{
    if ((self = [super init])) {
        _type = MMPhoneType_Diphone;
        _points = [[NSMutableArray alloc] init];
    }

    return self;
}

- (id)initWithModel:(MModel *)model XMLElement:(NSXMLElement *)element error:(NSError **)error;
{
    NSParameterAssert([@"transition" isEqualToString:element.name]);

    if ((self = [super initWithXMLElement:element error:error])) {
        _points = [[NSMutableArray alloc] init];

        NSString *str = [[element attributeForName:@"type"] stringValue];
        _type = (str != nil) ? MMPhoneTypeFromString(str) : MMPhoneType_Diphone;

        self.model = model;

        // Child element is: point-or-slopes
        if (![self _loadPointsOrSlopesFromXMLElement:[[element elementsForName:@"point-or-slopes"] firstObject] error:error]) return nil;
    }

    return self;
}

- (BOOL)_loadPointsOrSlopesFromXMLElement:(NSXMLElement *)element error:(NSError **)error;
{
    NSParameterAssert([@"point-or-slopes" isEqualToString:element.name]);

    NSArray *children = [element objectsForXQuery:@"point|slope-ratio" error:error];
    for (NSXMLElement *childElement in children) {
        if ([@"point" isEqualToString:childElement.name]) {
            MMPoint *point = [[MMPoint alloc] initWithModel:self.model XMLElement:childElement error:error];
            if (point != nil)
                [self addPoint:point];
        } else {
            MMSlopeRatio *slopeRatio = [[MMSlopeRatio alloc] initWithModel:self.model XMLElement:childElement error:error];
            if (slopeRatio != nil)
                [self addPoint:slopeRatio];
        }
    }

    return YES;
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p> name: %@, comment: %@, type: %lu, points: %@",
            NSStringFromClass([self class]), self, self.name, self.comment, _type, _points];
}

#pragma mark -

- (void)addInitialPoint;
{
    MMPoint *aPoint = [[MMPoint alloc] init];
    [aPoint setType:MMPhoneType_Diphone];
    [aPoint setFreeTime:0.0];
    [aPoint setValue:0.0];
    [self addPoint:aPoint];
}

// Can be either an MMPoint or an MMSlopeRatio
- (void)addPoint:(id)newPoint;
{
    [_points addObject:newPoint];
}

// pointTime = [aPoint cachedTime];
- (BOOL)isTimeInSlopeRatio:(double)aTime;
{
    NSUInteger pointCount, pointIndex;
    id currentPointOrSlopeRatio;

    pointCount = [_points count];
    for (pointIndex = 0; pointIndex < pointCount; pointIndex++) {
        currentPointOrSlopeRatio = [_points objectAtIndex:pointIndex];

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
    NSUInteger i, j;
    id temp, temp1, temp2;
    double pointTime = [aPoint cachedTime];

    for (i = 0; i < [_points count]; i++) {
        temp = [_points objectAtIndex:i];
        if ([temp isKindOfClass:[MMSlopeRatio class]]) {
            if (pointTime < [temp startTime]) {
                [_points insertObject:aPoint atIndex:i];
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
                [_points insertObject:aPoint atIndex:i];
                return;
            }
        }
    }

    [_points addObject:aPoint];
}

- (BOOL)isEquationUsed:(MMEquation *)anEquation;
{
    NSUInteger i, j;
    id temp;

    for (i = 0; i < [_points count]; i++) {
        temp = [_points objectAtIndex: i];
        if ([temp isKindOfClass:[MMSlopeRatio class]]) {
            temp = [temp points];
            for (j = 0; j < [temp count]; j++)
                if (anEquation == [[temp objectAtIndex:j] timeEquation])
                    return YES;
        } else
            if (anEquation == [[_points objectAtIndex:i] timeEquation])
                return YES;
    }

    return NO;
}

- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<transition name=\"%@\" type=\"%@\">\n",
                  GSXMLAttributeString(self.name, NO), GSXMLAttributeString(MMStringFromPhoneType(_type), NO)];

    if (self.comment != nil) {
        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<comment>%@</comment>\n", GSXMLCharacterData(self.comment)];
    }

    [_points appendXMLToString:resultString elementName:@"point-or-slopes" level:level + 1];

    [resultString indentToLevel:level];
    [resultString appendFormat:@"</transition>\n"];
}

- (NSString *)transitionPath;
{
    return [NSString stringWithFormat:@"%@:%@", self.group.name, self.name];
}

@end

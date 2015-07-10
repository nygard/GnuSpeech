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
            NSStringFromClass([self class]), self,
            self.name, self.comment, _type, _points];
}

#pragma mark -

- (void)addInitialPoint;
{
    MMPoint *point = [[MMPoint alloc] init];
    point.type     = MMPhoneType_Diphone;
    point.freeTime = 0.0;
    point.value    = 0.0;
    [self addPoint:point];
}

// Can be either an MMPoint or an MMSlopeRatio
- (void)addPoint:(id)newPoint;
{
    [_points addObject:newPoint];
}

// pointTime = [aPoint cachedTime];
- (BOOL)isTimeInSlopeRatio:(double)time;
{
    for (id currentPointOrSlopeRatio in _points) {
        if ([currentPointOrSlopeRatio isKindOfClass:[MMSlopeRatio class]]) {
            MMSlopeRatio *slopeRatio = currentPointOrSlopeRatio;
            if (time < slopeRatio.startTime)
                return NO;
            else if (time < slopeRatio.endTime) // Insert point into Slope Ratio
                return YES;
        } else {
            MMPoint *point = currentPointOrSlopeRatio;
            if (time < point.cachedTime) {
                return NO;
            }
        }
    }

    return NO;
}

- (void)insertPoint:(MMPoint *)point;
{
    double pointTime = point.cachedTime;

    for (NSUInteger index = 0; index < [_points count]; index++) {
        id currentPointOrSlopeRatio = _points[index];
        if ([currentPointOrSlopeRatio isKindOfClass:[MMSlopeRatio class]]) {
            MMSlopeRatio *slopeRatio = currentPointOrSlopeRatio;
            if (pointTime < slopeRatio.startTime) {
                [_points insertObject:point atIndex:index];
                return;
            } else if (pointTime < slopeRatio.endTime) { // Insert point into Slope Ratio
                NSMutableArray *points = slopeRatio.points;
                for (NSUInteger index2 = 1; index2 < [points count]; index2++) {
                    MMPoint *p2 = points[index2];
                    if (pointTime < p2.cachedTime) {
                        [points insertObject:p2 atIndex:index2];
                        [currentPointOrSlopeRatio updateSlopes];
                        return;
                    }
                }

                /* Should never get here */
                return;
            }
        } else {
            MMPoint *p2 = currentPointOrSlopeRatio;
            if (pointTime < p2.cachedTime) {
                [_points insertObject:p2 atIndex:index];
                return;
            }
        }
    }

    [_points addObject:point];
}

- (BOOL)isEquationUsed:(MMEquation *)equation;
{
    for (id currentPointOrSlopeRatio in _points) {
        if ([currentPointOrSlopeRatio isKindOfClass:[MMSlopeRatio class]]) {
            MMSlopeRatio *slopeRatio = currentPointOrSlopeRatio;
            for (MMPoint *point in slopeRatio.points) {
                if (equation == point.timeEquation)
                    return YES;
            }
        } else {
            MMPoint *point = currentPointOrSlopeRatio;
            if (equation == point.timeEquation)
                return YES;
        }
    }

    return NO;
}

- (NSString *)transitionPath;
{
    return [NSString stringWithFormat:@"%@:%@", self.group.name, self.name];
}

#pragma mark - XML Archiving

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

@end

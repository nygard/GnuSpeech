//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMTransition.h"

#import "NSArray-Extensions.h"
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "GSXMLFunctions.h"
#import "MMPoint.h"
#import "MMSlopeRatio.h"
#import "NamedList.h"

#import "MModel.h"

#import "MXMLParser.h"
#import "MXMLArrayDelegate.h"
#import "MXMLPCDataDelegate.h"

@implementation MMTransition
{
    __weak NamedList *nonretained_group;
    
    NSString *name;
    NSString *comment;
    MMPhoneType type;
    NSMutableArray *points; // Of MMSlopeRatios and/or MMPoints
}

- (id)init;
{
    if ((self = [super init])) {
        name = nil;
        comment = nil;
        type = MMPhoneType_Diphone;
        points = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void)dealloc;
{
    [name release];
    [comment release];
    [points release];

    [super dealloc];
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p> name: %@, comment: %@, type: %lu, points: %@",
            NSStringFromClass([self class]), self, name, comment, type, points];
}

#pragma mark -

- (void)addInitialPoint;
{
    MMPoint *aPoint = [[MMPoint alloc] init];
    [aPoint setType:MMPhoneType_Diphone];
    [aPoint setFreeTime:0.0];
    [aPoint setValue:0.0];
    [self addPoint:aPoint];
    [aPoint release];
}

@synthesize group = nonretained_group;

@synthesize name, comment;

- (BOOL)hasComment;
{
    return comment != nil && [comment length] > 0;
}

@synthesize points;

// Can be either an MMPoint or an MMSlopeRatio
- (void)addPoint:(id)newPoint;
{
    [points addObject:newPoint];
}

// pointTime = [aPoint cachedTime];
- (BOOL)isTimeInSlopeRatio:(double)aTime;
{
    NSUInteger pointCount, pointIndex;
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
    NSUInteger i, j;
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

@synthesize type;

- (BOOL)isEquationUsed:(MMEquation *)anEquation;
{
    NSUInteger i, j;
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

- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;
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
    if ((self = [self init])) {
        [self setName:[attributes objectForKey:@"name"]];
        
        NSString *str = [attributes objectForKey:@"type"];
        if (str != nil)
            [self setType:MMPhoneTypeFromString(str)];
    }

    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    if ([elementName isEqualToString:@"comment"]) {
        MXMLPCDataDelegate *newDelegate = [[MXMLPCDataDelegate alloc] initWithElementName:elementName delegate:self setSelector:@selector(setComment:)];
        [(MXMLParser *)parser pushDelegate:newDelegate];
        [newDelegate release];
    } else if ([elementName isEqualToString:@"point-or-slopes"]) {
        NSDictionary *elementClassMapping = [[NSDictionary alloc] initWithObjectsAndKeys:[MMPoint class], @"point",
                                             [MMSlopeRatio class], @"slope-ratio",
                                             nil];
        MXMLArrayDelegate *newDelegate = [[MXMLArrayDelegate alloc] initWithChildElementToClassMapping:elementClassMapping delegate:self addObjectSelector:@selector(addPoint:)];
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

#import "MMPoint.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "EventList.h"
#import "GSXMLFunctions.h"
#import "MMEquation.h"
#import "MMTransition.h"

#import "MModel.h"
#import "MUnarchiver.h"
#import "MXMLParser.h"

@implementation MMPoint

- (id)init;
{
    if ([super init] == nil)
        return nil;

    value = 0.0;
    freeTime = 0.0;
    expression = nil;
    isPhantom = NO;
    type = MMPhoneTypeDiphone;

    return self;
}

- (void)dealloc;
{
    [expression release];

    [super dealloc];
}

- (double)value;
{
    return value;
}

- (void)setValue:(double)newValue;
{
    value = newValue;
}

- (double)multiplyValueByFactor:(double)factor;
{
    value *= factor;
    return value;
}

- (double)addValue:(double)newValue;
{
    value += newValue;
    return value;
}

- (MMEquation *)expression;
{
    return expression;
}

- (void)setExpression:(MMEquation *)newExpression;
{
    if (newExpression == expression)
        return;

    [expression release];
    expression = [newExpression retain];
}

- (double)freeTime;
{
    return freeTime;
}

- (void)setFreeTime:(double)newTime;
{
    freeTime = newTime;
}

- (double)getTime;
{
    if (expression)
        return [expression cacheValue]; // TODO (2004-03-11): I think this is a little odd.

    return freeTime;
}

- (int)type;
{
    return type;
}

- (void)setType:(int)newType;
{
    type = newType;
}

- (BOOL)isPhantom;
{
    return isPhantom;
}

- (void)setIsPhantom:(BOOL)newFlag;
{
    isPhantom = newFlag;
}

- (void)calculatePoints:(double *)ruleSymbols tempos:(double *)tempos phones:phones andCacheWith:(int)newCacheTag toDisplay:(NSMutableArray *)displayList;
{
    float dummy;

    if (expression) {
        dummy = [expression evaluate:ruleSymbols tempos:tempos phones:phones andCacheWith:newCacheTag];
        //NSLog(@"expression %@ = %g", [[expression expression] expressionString], dummy);
    }
    //NSLog(@"Dummy %f", dummy);

    [displayList addObject:self];
}


- (double)calculatePoints:(double *)ruleSymbols tempos:(double *)tempos phones:phones andCacheWith:(int)newCacheTag
                 baseline:(double)baseline delta:(double)delta min:(double)min max:(double)max
              toEventList:(EventList *)eventList atIndex:(int)index;
{
    double time, returnValue;

    if (expression)
        time = [expression evaluate: ruleSymbols tempos: tempos phones: phones andCacheWith: (int) newCacheTag];
    else
        time = freeTime;

    //NSLog(@"|%@| = %f tempos: %f %f %f %f", [[phones objectAtIndex:0] symbol], time, tempos[0], tempos[1],tempos[2],tempos[3]);

    returnValue = baseline + ((value / 100.0) * delta);

    //NSLog(@"Inserting event %d atTime %f  withValue %f", index, time, returnValue);

    if (returnValue < min)
        returnValue = min;
    else if (returnValue > max)
        returnValue = max;

    if (!isPhantom)
        [eventList insertEvent:index atTime:time withValue:returnValue];

    return returnValue;
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    unsigned archivedVersion;
    int i, j;
    MMEquation *anExpression;
    MModel *model;
    int phantom;

    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    model = [(MUnarchiver *)aDecoder userInfo];
    //NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    archivedVersion = [aDecoder versionForClassName:NSStringFromClass([self class])];
    //NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

#if 1
    // TODO (2004-03-17): Check to make sure that isPhantom is being properly decoded.
    [aDecoder decodeValuesOfObjCTypes:"ddii", &value, &freeTime, &type, &phantom];
    isPhantom = phantom; // Can't decode an int into a BOOL
    //NSLog(@"isPhantom: %d", isPhantom);
#else
    // Hack to check "Play2.monet".
    {
        static int hack_count = 0;

        hack_count++;
        NSLog(@"hack_count: %d", hack_count);

        NS_DURING {
            if (hack_count >= 23) {
                double valueOne;
                int valueTwo;

                [aDecoder decodeValuesOfObjCTypes:"di", &valueOne, &valueTwo];
                NSLog(@"read: %g, %d", valueOne, valueTwo);
            } else {
                [aDecoder decodeValuesOfObjCTypes:"ddii", &value, &freeTime, &type, &isPhantom];
            }
        } NS_HANDLER {
            NSLog(@"Caught exception: %@", localException);
            return nil;
        } NS_ENDHANDLER;
    }
#endif
    //NSLog(@"value: %g, freeTime: %g, type: %d, isPhantom: %d", value, freeTime, type, isPhantom);

    [aDecoder decodeValuesOfObjCTypes:"ii", &i, &j];
    //NSLog(@"i: %d, j: %d", i, j);
    if (i != -1) {
        anExpression = [model findEquation:i andIndex:j];
        //NSLog(@"anExpression: %@", anExpression);
        [self setExpression:anExpression];
    }

    //NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);
    return self;
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: value: %g, freeTime: %g, expression: %@, type: %d, isPhantom: %d",
                     NSStringFromClass([self class]), self, value, freeTime, expression, type, isPhantom];
}

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
{
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<point type=\"%@\" value=\"%g\"", MMStringFromPhoneType(type), value];
    if (expression == nil) {
        [resultString appendFormat:@" free-time=\"%g\"", freeTime];
    } else {
        [resultString appendFormat:@" time-expression=\"%@\"", GSXMLAttributeString([expression name], NO)];
    }

    if (isPhantom == YES)
        [resultString appendFormat:@" is-phantom=\"%@\"", GSXMLBoolAttributeString(isPhantom)];

    [resultString appendString:@"/>\n"];
}

- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
{
    NSString *str;

    if ([self init] == nil)
        return nil;

    str = [attributes objectForKey:@"type"];
    if (str != nil)
        [self setType:MMPhoneTypeFromString(str)];

    str = [attributes objectForKey:@"value"];
    if (str != nil)
        [self setValue:[str doubleValue]];

    str = [attributes objectForKey:@"free-time"];
    if (str != nil)
        [self setFreeTime:[str doubleValue]];

    str = [attributes objectForKey:@"time-expression"];
    if (str != nil) {
        MMEquation *anEquation;

        anEquation = [context findEquationWithName:str];
        [self setExpression:anEquation];
    }

    str = [attributes objectForKey:@"is-phantom"];
    if (str != nil)
        [self setIsPhantom:GSXMLBoolFromString(str)];

    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    NSLog(@"%@, Unknown element: '%@', skipping", [self shortDescription], elementName);
    [(MXMLParser *)parser skipTree];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    [(MXMLParser *)parser popDelegate];
}

@end

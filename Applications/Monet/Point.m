#import "Point.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "AppController.h"
#import "EventList.h"
#import "FormulaExpression.h"
#import "GSXMLFunctions.h"
#import "ProtoEquation.h"
#import "PrototypeManager.h"
#import "ProtoTemplate.h"

#import "MModel.h"
#import "MUnarchiver.h"

@implementation MMPoint

- (id)init;
{
    if ([super init] == nil)
        return nil;

    value = 0.0;
    freeTime = 0.0;
    expression = nil;
    isPhantom = NO;
    type = DIPHONE;

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

- (ProtoEquation *)expression;
{
    return expression;
}

- (void)setExpression:(ProtoEquation *)newExpression;
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

- (void)calculatePoints:(double *)ruleSymbols tempos:(double *)tempos phones:phones andCacheWith:(int)newCacheTag toDisplay:(MonetList *)displayList;
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
    ProtoEquation *anExpression;
    MModel *model;

    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    model = [(MUnarchiver *)aDecoder userInfo];
    //NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    archivedVersion = [aDecoder versionForClassName:NSStringFromClass([self class])];
    //NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

#if 1
    // TODO (2004-03-17): Check to make sure that isPhantom is being properly decoded.
    [aDecoder decodeValuesOfObjCTypes:"ddii", &value, &freeTime, &type, &isPhantom];
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
    anExpression = [model findEquation:i andIndex:j];
    //NSLog(@"anExpression: %@", anExpression);
    [self setExpression:anExpression];

    //NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
#ifdef PORTING
    int i, j;
    PrototypeManager *prototypeManager = NXGetNamedObject(@"prototypeManager", NSApp);

    [aCoder encodeValuesOfObjCTypes:"ddii", &value, &freeTime, &type, &isPhantom];

    [prototypeManager findList:&i andIndex:&j ofEquation:expression];
    [aCoder encodeValuesOfObjCTypes:"ii", &i, &j];
#endif
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: value: %g, freeTime: %g, expression: %@, type: %d, isPhantom: %d",
                     NSStringFromClass([self class]), self, value, freeTime, expression, type, isPhantom];
}

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
{
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<point type=\"%d\" value=\"%g\"", type, value];
    if (expression == nil) {
        [resultString appendFormat:@" free-time=\"%g\"", freeTime];
    } else {
        [resultString appendFormat:@" time-expression=\"%@\"", GSXMLAttributeString([expression name], NO)];
    }

    if (isPhantom == YES)
        [resultString appendFormat:@" is-phantom=\"%@\"", GSXMLBoolAttributeString(isPhantom)];

    [resultString appendString:@"/>\n"];
}

@end

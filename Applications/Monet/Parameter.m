#import "Parameter.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "GSXMLFunctions.h"

@implementation Parameter

- (id)init;
{
    if ([super init] == nil)
        return nil;

    parameterSymbol = nil;
    comment = nil;

    minimum = 0.0;
    maximum = 0.0;
    defaultValue = 0.0;

    return self;
}

- (id)initWithSymbol:(NSString *)newSymbol;
{
    if ([self init] == nil)
        return nil;

    [self setSymbol:newSymbol];

    return self;
}

- (void)dealloc;
{
    [parameterSymbol release];
    [comment release];

    [super dealloc];
}

- (NSString *)symbol;
{
    return parameterSymbol;
}

- (void)setSymbol:(NSString *)newSymbol;
{
    if (newSymbol == parameterSymbol)
        return;

    [parameterSymbol release];
    parameterSymbol = [newSymbol retain];
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

- (double)minimumValue;
{
    return minimum;
}

- (void)setMinimumValue:(double)newMinimum;
{
    minimum = newMinimum;
}

- (double)maximumValue;
{
    return maximum;
}

- (void)setMaximumValue:(double)newMaximum;
{
    maximum = newMaximum;
}

- (double)defaultValue;
{
    return defaultValue;
}

- (void)setDefaultValue:(double)newDefault;
{
    defaultValue = newDefault;
}

//
// Archiving
//

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    unsigned archivedVersion;
    char *c_parameterSymbol, *c_comment;

    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    //NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    archivedVersion = [aDecoder versionForClassName:NSStringFromClass([self class])];
    //NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

    [aDecoder decodeValuesOfObjCTypes:"**ddd", &c_parameterSymbol, &c_comment, &minimum, &maximum, &defaultValue];
    //NSLog(@"c_parameterSymbol: %s, c_comment: %s, minimum: %g, maximum: %g, defaultValue: %g", c_parameterSymbol, c_comment, minimum, maximum, defaultValue);

    parameterSymbol = [[NSString stringWithASCIICString:c_parameterSymbol] retain];
    comment = [[NSString stringWithASCIICString:c_comment] retain];

    //NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
#ifdef PORTING
    [aCoder encodeValuesOfObjCTypes:"**ddd", &parameterSymbol, &comment, &minimum, &maximum, &defaultValue];
#endif
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: parameterSymbol: %@, comment: %@, minimum: %g, maximum: %g, defaultValue: %g",
                     NSStringFromClass([self class]), self, parameterSymbol, comment, minimum, maximum, defaultValue];
}


- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
{
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<parameter name=\"%@\" minimum=\"%g\" maximum=\"%g\" default=\"%g\"",
                  GSXMLAttributeString(parameterSymbol, NO), minimum, maximum, defaultValue];

    if (comment == nil) {
        [resultString appendString:@"/>\n"];
    } else {
        [resultString appendString:@">\n"];
        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<comment>%@</comment>\n", GSXMLCharacterData(comment)];

        [resultString indentToLevel:level];
        [resultString appendString:@"</parameter>\n"];
    }
}

@end

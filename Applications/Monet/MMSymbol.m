#import "MMSymbol.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "GSXMLFunctions.h"
#import "MModel.h"

#import "MXMLParser.h"
#import "MXMLPCDataDelegate.h"

#define DEFAULT_VALUE 100.0
#define DEFAULT_MIN 0.0
#define DEFAULT_MAX 500.0

@implementation MMSymbol

- (id)init;
{
    if ([super init] == nil)
        return nil;

    symbol = nil;
    comment = nil;

    minimum = DEFAULT_MIN;
    maximum = DEFAULT_MAX;
    defaultValue = DEFAULT_VALUE;

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
    [symbol release];
    [comment release];

    [super dealloc];
}

- (NSString *)symbol;
{
    return symbol;
}

- (void)setSymbol:(NSString *)newSymbol;
{
    if (newSymbol == symbol)
        return;

    [symbol release];
    symbol = [newSymbol retain];
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
    if (newDefault != defaultValue)
        [[self model] symbol:self willChangeDefaultValue:newDefault];

    defaultValue = newDefault;
}

//
// Archiving
//

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    unsigned archivedVersion;
    char *c_symbol, *c_comment;

    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    //NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    archivedVersion = [aDecoder versionForClassName:NSStringFromClass([self class])];
    //NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

    [aDecoder decodeValuesOfObjCTypes:"**ddd", &c_symbol, &c_comment, &minimum, &maximum, &defaultValue];

    symbol = [[NSString stringWithASCIICString:c_symbol] retain];
    comment = [[NSString stringWithASCIICString:c_comment] retain];

    //NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);
    return self;
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: symbol: %@, comment: %@, minimum: %g, maximum: %g, defaultValue: %g",
                     NSStringFromClass([self class]), self, symbol, comment, minimum, maximum, defaultValue];
}

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
{
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<symbol name=\"%@\" minimum=\"%g\" maximum=\"%g\" default=\"%g\"",
                  GSXMLAttributeString(symbol, NO), minimum, maximum, defaultValue];

    if (comment == nil) {
        [resultString appendString:@"/>\n"];
    } else {
        [resultString appendString:@">\n"];
        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<comment>%@</comment>\n", GSXMLCharacterData(comment)];

        [resultString indentToLevel:level];
        [resultString appendString:@"</symbol>\n"];
    }
}

- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
{
    id value;

    if ([self init] == nil)
        return nil;

    [self setSymbol:[attributes objectForKey:@"name"]];

    value = [attributes objectForKey:@"minimum"];
    if (value != nil)
        [self setMinimumValue:[value doubleValue]];

    value = [attributes objectForKey:@"maximum"];
    if (value != nil)
        [self setMaximumValue:[value doubleValue]];

    value = [attributes objectForKey:@"default"];
    if (value != nil)
        [self setDefaultValue:[value doubleValue]];

    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    if ([elementName isEqualToString:@"comment"]) {
        MXMLPCDataDelegate *newDelegate;

        newDelegate = [[MXMLPCDataDelegate alloc] initWithElementName:elementName delegate:self setSelector:@selector(setComment:)];
        [(MXMLParser *)parser pushDelegate:newDelegate];
        [newDelegate release];
    } else {
        NSLog(@"%@, Unknown element: '%@', skipping", [self shortDescription], elementName);
        [(MXMLParser *)parser skipTree];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    if ([elementName isEqualToString:@"symbol"])
        [(MXMLParser *)parser popDelegate];
    else
        [NSException raise:@"Unknown close tag" format:@"Unknown closing tag (%@) in %@", elementName, NSStringFromClass([self class])];
}

@end

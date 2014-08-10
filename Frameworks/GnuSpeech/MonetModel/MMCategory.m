//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMCategory.h"

#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "GSXMLFunctions.h"

@implementation MMCategory
{
    BOOL _isNative;
}

- (id)init;
{
    if ((self = [super init])) {
        _isNative = NO;
    }

    return self;
}

- (id)initWithXMLElement:(NSXMLElement *)element error:(NSError **)error;
{
    NSParameterAssert([@"category" isEqualToString:element.name]);

    if ((self = [super initWithXMLElement:element error:error])) {
        _isNative = NO;
    }

    return self;
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p> name: %@, comment: %@, isNative: %d",
            NSStringFromClass([self class]), self,
            self.name, self.comment, self.isNative];
}

#pragma mark -

- (NSComparisonResult)compareByAscendingName:(MMCategory *)other;
{
    return [self.name compare:other.name];
}

- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;
{
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<category name=\"%@\"", GSXMLAttributeString(self.name, NO)];

    if (self.comment == nil) {
        [resultString appendString:@"/>\n"];
    } else {
        [resultString appendString:@">\n"];

        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<comment>%@</comment>\n", GSXMLCharacterData(self.comment)];

        [resultString indentToLevel:level];
        [resultString appendString:@"</category>\n"];
    }
}

@end

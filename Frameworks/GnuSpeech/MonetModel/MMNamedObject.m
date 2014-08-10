//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMNamedObject.h"

#import "MModel.h"

@implementation MMNamedObject
{
    NSString *_name;
    NSString *_comment;
}

- (id)initWithXMLElement:(NSXMLElement *)element error:(NSError **)error;
{
    if ((self = [super initWithXMLElement:element error:error])) {
        _name = [[element attributeForName:@"name"] stringValue];
        NSXMLElement *commentElement = [[element elementsForName:@"comment"] firstObject];
        if (commentElement != nil) {
            _comment = [commentElement stringValue];
        }
    }

    return self;
}

#pragma mark -

- (BOOL)hasComment;
{
    return self.comment != nil && [self.comment length] > 0;
}

@end

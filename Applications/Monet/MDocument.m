//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MDocument.h"

#import <Foundation/Foundation.h>
#import "MModel.h"
#import "MXMLParser.h"

@implementation MDocument

- (void)dealloc;
{
    [model release];

    [super dealloc];
}

- (MModel *)model;
{
    return model;
}

- (void)setModel:(MModel *)newModel;
{
    if (newModel == model)
        return;

    [model release];
    model = [newModel retain];
}

- (BOOL)loadFromXMLFile:(NSString *)filename;
{
    NSURL *fileURL;
    MXMLParser *parser;
    BOOL result;

    NSLog(@" > %s", _cmd);

    fileURL = [NSURL fileURLWithPath:filename];
    parser = [[MXMLParser alloc] initWithContentsOfURL:fileURL];
    [parser pushDelegate:self];
    [parser setShouldResolveExternalEntities:YES];
    result = [parser parse];
    NSLog(@"result: %d", result);
    [parser release];

    NSLog(@"<  %s", _cmd);

    return result;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
}

- (void)parserDidEndDocument:(NSXMLParser *)parser;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    if ([elementName isEqualToString:@"root"]) {
        MModel *newModel;

        newModel = [[MModel alloc] init];
        [self setModel:newModel];
        [newModel release];

        [(MXMLParser *)parser setContext:model];
        [(MXMLParser *)parser pushDelegate:model];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    NSLog(@"</%@>", elementName);
    //NSLog(@" > %s", _cmd);
    //NSLog(@"<  %s", _cmd);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;
{
    //NSLog(@" > %s", _cmd);
    //NSLog(@"<  %s", _cmd);
}

- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString;
{
    //NSLog(@" > %s", _cmd);
    //NSLog(@"<  %s", _cmd);
}

- (void)parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
}

- (NSData *)parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)name systemID:(NSString *)systemID;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);

    return nil;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"parseError: %@", parseError);
    NSLog(@"[[parser parserError] localizedDescription]: %@", [[parser parserError] localizedDescription]);
    NSLog(@"line: %d, column: %d", [parser lineNumber], [parser columnNumber]);
    NSLog(@"<  %s", _cmd);
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
}

@end

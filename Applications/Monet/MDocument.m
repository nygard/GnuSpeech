//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MDocument.h"

#import <Foundation/Foundation.h>

@implementation MDocument

- (void)loadFromXMLFile:(NSString *)filename;
{
    NSURL *fileURL;
    NSXMLParser *parser;
    BOOL result;

    NSLog(@" > %s", _cmd);

    fileURL = [NSURL fileURLWithPath:filename];
    parser = [[NSXMLParser alloc] initWithContentsOfURL:fileURL];
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:YES];
    result = [parser parse];
    NSLog(@"result: %d", result);
    [parser release];

    NSLog(@"<  %s", _cmd);
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

- (void)parser:(NSXMLParser *)parser foundNotationDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
}

- (void)parser:(NSXMLParser *)parser foundUnparsedEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID notationName:(NSString *)notationName;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
}

- (void)parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
}

- (void)parser:(NSXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
}

- (void)parser:(NSXMLParser *)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(NSString *)value;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
}

- (void)parser:(NSXMLParser *)parser foundExternalEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    //NSLog(@" > %s", _cmd);
    //NSLog(@"<  %s", _cmd);
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    //NSLog(@" > %s", _cmd);
    //NSLog(@"<  %s", _cmd);
}

- (void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
}

- (void)parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
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

- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"comment: '%@'", comment);
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

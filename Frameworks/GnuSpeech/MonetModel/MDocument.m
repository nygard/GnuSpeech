//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MDocument.h"

#import "MModel.h"
#import "MXMLParser.h"

@implementation MDocument
{
    MModel *model;
}

- (void)dealloc;
{
    [model release];

    [super dealloc];
}

#pragma mark -

@synthesize model;

- (BOOL)loadFromXMLFile:(NSString *)filename;
{
    NSURL *fileURL;
    MXMLParser *parser;
    BOOL result;

    if (filename == nil)
        return NO;
    
    fileURL = [NSURL fileURLWithPath:filename];
    parser = [[MXMLParser alloc] initWithContentsOfURL:fileURL];
    [parser pushDelegate:self];
    [parser setShouldResolveExternalEntities:YES];
    result = [parser parse];
    if (result == NO) {
        NSLog(@"Error: Failed to load file %@, (%@)", filename, [[parser parserError] localizedDescription]);
        //NSRunAlertPanel(@"Error", @"Failed to load file %@, (%@)", @"OK", nil, nil, filename, [[parser parserError] localizedDescription]);
    }
    [parser release];

    return result;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser;
{
    //NSLog(@" > %s", __PRETTY_FUNCTION__);
    // As of 2004-05-20 these just return nil
    //NSLog(@"publicID: %@", [parser publicID]);
    //NSLog(@"systemID: %@", [parser systemID]);
    //NSLog(@"<  %s", __PRETTY_FUNCTION__);
}

- (void)parserDidEndDocument:(NSXMLParser *)parser;
{
    NSLog(@" > %s", __PRETTY_FUNCTION__);
    NSLog(@"<  %s", __PRETTY_FUNCTION__);
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
    //NSLog(@" > %s", __PRETTY_FUNCTION__);
    //NSLog(@"<  %s", __PRETTY_FUNCTION__);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;
{
    //NSLog(@" > %s", __PRETTY_FUNCTION__);
    //NSLog(@"<  %s", __PRETTY_FUNCTION__);
}

- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString;
{
    //NSLog(@" > %s", __PRETTY_FUNCTION__);
    //NSLog(@"<  %s", __PRETTY_FUNCTION__);
}

- (void)parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data;
{
    NSLog(@" > %s", __PRETTY_FUNCTION__);
    NSLog(@"<  %s", __PRETTY_FUNCTION__);
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock;
{
    NSLog(@" > %s", __PRETTY_FUNCTION__);
    NSLog(@"<  %s", __PRETTY_FUNCTION__);
}

- (NSData *)parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)name systemID:(NSString *)systemID;
{
    NSLog(@" > %s", __PRETTY_FUNCTION__);
    NSLog(@"<  %s", __PRETTY_FUNCTION__);

    return nil;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError;
{
    NSLog(@" > %s", __PRETTY_FUNCTION__);
    NSLog(@"parseError: %@", parseError);
    NSLog(@"[[parser parserError] localizedDescription]: %@", [[parser parserError] localizedDescription]);
    NSLog(@"line: %lu, column: %lu", [parser lineNumber], [parser columnNumber]);
    NSLog(@"<  %s", __PRETTY_FUNCTION__);
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError;
{
    NSLog(@" > %s", __PRETTY_FUNCTION__);
    NSLog(@"validationError: %@", validationError);
    NSLog(@"<  %s", __PRETTY_FUNCTION__);
}

@end

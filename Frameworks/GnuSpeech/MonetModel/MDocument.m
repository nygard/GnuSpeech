////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
//  
//  Contributors: Steve Nygard
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
////////////////////////////////////////////////////////////////////////////////
//
//  MDocument.m
//  GnuSpeech
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.9.1
//
////////////////////////////////////////////////////////////////////////////////

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
    NSLog(@"line: %d, column: %d", [parser lineNumber], [parser columnNumber]);
    NSLog(@"<  %s", __PRETTY_FUNCTION__);
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError;
{
    NSLog(@" > %s", __PRETTY_FUNCTION__);
    NSLog(@"validationError: %@", validationError);
    NSLog(@"<  %s", __PRETTY_FUNCTION__);
}

@end

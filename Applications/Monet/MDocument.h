//
// $Id: MDocument.h,v 1.1 2004/04/22 03:06:15 nygard Exp $
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>

@interface MDocument : NSObject
{
}

- (void)loadFromXMLFile:(NSString *)filename;

- (void)parserDidStartDocument:(NSXMLParser *)parser;
- (void)parserDidEndDocument:(NSXMLParser *)parser;
- (void)parser:(NSXMLParser *)parser foundNotationDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID;
- (void)parser:(NSXMLParser *)parser foundUnparsedEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID notationName:(NSString *)notationName;
- (void)parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue;
- (void)parser:(NSXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model;
- (void)parser:(NSXMLParser *)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(NSString *)value;
- (void)parser:(NSXMLParser *)parser foundExternalEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID;
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
- (void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI;
- (void)parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix;
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;
- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString;
- (void)parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data;
- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment;
- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock;
- (NSData *)parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)name systemID:(NSString *)systemID;
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError;
- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError;

@end

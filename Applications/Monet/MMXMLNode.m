//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MMXMLNode.h"

#import <Foundation/Foundation.h>
#import <libxml/parser.h>

@interface MMXMLNode (libxml)
+ (id)nodeWithXMLNode:(xmlNode *)aNode;
@end

@implementation MMXMLNode

+ (id)xmlTreeFromContentsOfFile:(NSString *)path;
{
    xmlParserCtxt *ctxt;
    xmlDoc *xmlDocument;
    MMXMLNode *tree = nil;

    ctxt = xmlNewParserCtxt();
    if (ctxt == NULL) {
        NSLog(@"Failed to allocate parser context");
        return nil;
    }

    //xmlDocument = xmlCtxtReadFile(ctxt, filename, "UTF-8", XML_PARSE_DTDVALID|XML_PARSE_NOBLANKS);
    xmlDocument = xmlCtxtReadFile(ctxt, [path UTF8String], "UTF-8", XML_PARSE_NOBLANKS);
    if (xmlDocument == NULL) {
        NSLog(@"Failed to parse file: %@", path);
    } else {
        xmlNode *currentNode;

        if (ctxt->valid == 0)
            NSLog(@"Failed to validate file: %@", path);

        for (currentNode = xmlDocument->children; currentNode != NULL; currentNode = currentNode->next) {
            if (currentNode->type == XML_ELEMENT_NODE) {
                tree = [MMXMLNode nodeWithXMLNode:currentNode];
                break;
            }
        }
        xmlFreeDoc(xmlDocument);
    }

    xmlFreeParserCtxt(ctxt);

    return tree;
}

- (id)init;
{
    if ([super init] == nil)
        return nil;

    children = [[NSMutableArray alloc] init];

    return self;
}

- (void)dealloc;
{
    [children release];

    [super dealloc];
}

- (NSArray *)children;
{
    return children;
}

- (void)addChild:(MMXMLNode *)aChild;
{
    [children addObject:aChild];
}

@end

#import "MMXMLElementNode.h"
#import "MMXMLTextNode.h"

@implementation MMXMLNode (libxml)

+ (id)nodeWithXMLNode:(xmlNode *)aNode;
{
    MMXMLNode *newNode = nil;

    if (aNode->type == XML_ELEMENT_NODE) {
        MMXMLElementNode *newElementNode;
        xmlAttribute *currentAttribute;
        xmlElement *elementNode = (xmlElement *)aNode;
        xmlNode *currentNode;

        newNode = newElementNode = [[[MMXMLElementNode alloc] init] autorelease];
        [newElementNode setName:[NSString stringWithUTF8String:aNode->name]];

#if 0
        NSLog(@"element: %s, attributes: %p", elementNode->name, elementNode->attributes);
        if (elementNode->attributes != NULL)
            NSLog(@"\t1st attribute name: %s, default value: %p, children: %s",
                  elementNode->attributes->name, elementNode->attributes->defaultValue, elementNode->attributes->children->content);
#else
        for (currentAttribute = elementNode->attributes; currentAttribute != NULL; currentAttribute = (xmlAttribute *)currentAttribute->next) {
            NSString *key, *value;

            key = [NSString stringWithUTF8String:currentAttribute->name];
            value = [NSString stringWithUTF8String:currentAttribute->children->content];
            if (key != nil && value != nil)
                [newElementNode addAttributeName:key value:value];
            //NSLog(@"element %@, attribute %s, value?: %s", [newElementNode name], currentAttribute->name, currentAttribute->children->content);
        }
#endif

        //NSLog(@"new element(1): %@", newNode);
        //NSLog(@"aNode->children: %p", aNode->children);
        for (currentNode = aNode->children; currentNode != NULL; currentNode = currentNode->next) {
            MMXMLNode *childNode;

            childNode = [MMXMLNode nodeWithXMLNode:currentNode];
            if (childNode != nil)
                [newNode addChild:childNode];
        }
        //NSLog(@"new element(2): %@", newNode);
    } else if (aNode->type == XML_TEXT_NODE) {
        MMXMLTextNode *newTextNode;

        newTextNode = [[[MMXMLTextNode alloc] init] autorelease];
        //NSLog(@"newTextNode: %@ (%p)", newTextNode, newTextNode);
        [newTextNode setContents:[NSString stringWithUTF8String:aNode->content]];
        //NSLog(@"new text: %@", newTextNode);
    } else {
        NSLog(@"%s, unknown node type: %d", _cmd, aNode->type);
    }

    return newNode;
}

@end

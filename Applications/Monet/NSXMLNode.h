//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>

typedef enum {
    NSXMLInvalidKind = 0,
    NSXMLDocumentKind = 1,
    NSXMLElementKind = 2,
    NSXMLAttributeKind = 3,
    NSXMLNamespaceKind = 4,
    NSXMLProcessingInstructionKind = 5,
    NSXMLCommentKind = 6,
    NSXMLTextKind = 7,
    NSXMLDTDKind = 8,
    NSXMLEntityDeclarationKind = 9,
    NSXMLAttributeDeclarationKind = 10,
    NSXMLElementDeclarationKind = 11,
    NSXMLNotationDeclarationKind = 12,
} NSXMLNodeKind;

enum {
    NSXMLNodeOptionsNone = 0,

    NSXMLNodePreserveCDATA = 1 << 24,
    NSXMLNodePreserveWhitespace = 1 << 25,
};

@class NSXMLDocument;

@interface NSXMLNode : NSObject
{
    NSXMLNodeKind _kind;
    NSXMLNode *_parent;
}

- (id)initWithKind:(NSXMLNodeKind)kind;

- (NSXMLNodeKind)kind;

- (id)children;
- (unsigned int)childCount;
- (NSXMLNode *)childAtIndex:(unsigned int)index;

- (NSString *)stringValue;

- (id)objectValue;
- (void)setObjectValue:(id)value;

- (NSXMLDocument *)rootDocument;

- (NSString *)XMLString;
- (void)_appendXMLToString:(NSMutableString *)resultString level:(int)level;

@end

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MDocument.h"

#import <Foundation/Foundation.h>
#import "MModel.h"

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
    NSXMLDocument *xmlDocument;
    NSError *error = nil;
    NSData *data;

    fileURL = [NSURL fileURLWithPath:filename];
    data = [NSData dataWithContentsOfURL:fileURL];
    // -initWithContentsOfURL:options:error: fails without explanation.
    //xmlDocument = [[NSXMLDocument alloc] initWithContentsOfURL:fileURL options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA) error:&error];
    xmlDocument = [[NSXMLDocument alloc] initWithData:data options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA) error:&error];
    if (xmlDocument == nil) {
        NSLog(@"error: %@", error);
        return NO;
    }

    NSLog(@"DTD: %@", [xmlDocument DTD]);
    [self loadFromRootElement:[xmlDocument rootElement]];

    return YES;
}

- (BOOL)loadFromRootElement:(NSXMLElement *)rootElement;
{
    NSXMLNode *versionAttribute;
    MModel *newModel;

    NSLog(@" > %s", _cmd);
    NSLog(@"root name: %@", [rootElement name]);
    versionAttribute = [rootElement attributeForName:@"version"];
    NSLog(@"versionAttribute: %@", versionAttribute);
    NSLog(@"string value: %@", [versionAttribute stringValue]);
    NSLog(@"object value: %@", [versionAttribute objectValue]);

    if ([[versionAttribute objectValue] intValue] != 1) {
        // TODO (2004-09-03): This would be responsible for upgrading from earlier versions.  Might need document node instead of root element.
        NSLog(@"wrong version.");
        return NO;
    }

    newModel = [[MModel alloc] init];
    [self setModel:newModel];
    [newModel release];

    [model loadFromRootElement:rootElement];

    NSLog(@"<  %s", _cmd);

    return YES;
}

#if 0
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
#endif
@end

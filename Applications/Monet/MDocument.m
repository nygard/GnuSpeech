//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MDocument.h"

#import <Foundation/Foundation.h>
#import "MModel.h"

#import "MMFileConverter.h"
#import "MMVersion2Upgrader.h"

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
    NSLog(@"xmlDocument:\n%@", [xmlDocument XMLString]);
    [self loadFromRootElement:[xmlDocument rootElement]];

    return YES;
}

- (BOOL)loadFromRootElement:(NSXMLElement *)rootElement;
{
    NSXMLNode *versionAttribute;
    MModel *newModel;
    //MMFileConverter *converter;
    //BOOL result;

    NSLog(@" > %s", _cmd);
    NSLog(@"root name: %@", [rootElement name]);
    versionAttribute = [rootElement attributeForName:@"version"];
    NSLog(@"versionAttribute: %@", versionAttribute);
    NSLog(@"string value: %@", [versionAttribute stringValue]);
    NSLog(@"object value: %@", [versionAttribute objectValue]);
#if 0
    converter = [[MMVersion2Upgrader alloc] init];
    result = [converter upgradeDocument:[rootElement rootDocument]];
    NSLog(@"upgrade result: %d", result);
    [converter release];
#endif
    if ([[versionAttribute objectValue] intValue] != [MModel currentVersion])
        [self upgradeDocument:[rootElement rootDocument]];

    if ([[versionAttribute objectValue] intValue] != [MModel currentVersion]) {
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

- (void)upgradeDocument:(NSXMLDocument *)document;
{
    Class converterClass;
    MMFileConverter *converter;
    int sourceVersion;
    BOOL result;

    NSLog(@" > %s", _cmd);

    do {
        sourceVersion = [[[[document rootElement] attributeForName:@"version"] stringValue] intValue];
        converterClass = [MMFileConverter fileConverterFromVersion:sourceVersion];
        converter = [[[converterClass alloc] init] autorelease];
        NSLog(@"converter: %@", converter);
        if (converter == nil)
            break;

        result = [converter upgradeDocument:document];
        if (result == YES)
            NSLog(@"Upgraded from version %d to %d", sourceVersion, [converter targetVersion]);
    } while (result == YES && [converter targetVersion] < [MModel currentVersion]);

    NSLog(@"<  %s", _cmd);
}

@end

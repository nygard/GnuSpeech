//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>

@class MModel;

@interface MDocument : NSObject
{
    MModel *model;
}

- (void)dealloc;

- (MModel *)model;
- (void)setModel:(MModel *)newModel;

- (BOOL)loadFromXMLFile:(NSString *)filename;
- (BOOL)loadFromRootElement:(NSXMLElement *)rootElement;

#if 0
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
#endif
@end

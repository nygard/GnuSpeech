//
// $Id: MMXMLNode.h,v 1.1 2004/04/21 22:25:21 nygard Exp $
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>

@interface MMXMLNode : NSObject
{
    NSMutableArray *children;
}

+ (id)xmlTreeFromContentsOfFile:(NSString *)path;

- (id)init;
- (void)dealloc;

- (NSArray *)children;
- (void)addChild:(MMXMLNode *)aChild;

@end

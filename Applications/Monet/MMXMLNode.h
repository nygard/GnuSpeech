//
// $Id: MMXMLNode.h,v 1.1 2004/04/21 22:25:21 nygard Exp $
//

//  This file is part of SNFoundation, a personal collection of Foundation extensions.
//  Copyright (C) 2004 Steve Nygard.  All rights reserved.

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

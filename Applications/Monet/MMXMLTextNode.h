//
// $Id: MMXMLTextNode.h,v 1.1 2004/04/21 22:25:21 nygard Exp $
//

//  This file is part of SNFoundation, a personal collection of Foundation extensions.
//  Copyright (C) 2004 Steve Nygard.  All rights reserved.

#import "MMXMLNode.h"

@interface MMXMLTextNode : MMXMLNode
{
    NSString *contents;
}

- (void)dealloc;

- (NSString *)contents;
- (void)setContents:(NSString *)newContents;

@end

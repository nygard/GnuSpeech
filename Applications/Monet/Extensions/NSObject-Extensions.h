//
// $Id: NSObject-Extensions.h,v 1.2 2004/04/22 19:00:19 nygard Exp $
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>

@interface NSObject (Extensions)

+ (id)objectWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;

- (id)initWithCoder:(NSCoder *)aDecoder;

- (NSString *)shortDescription;

@end

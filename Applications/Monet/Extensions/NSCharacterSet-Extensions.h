//
// $Id: NSCharacterSet-Extensions.h,v 1.3 2004/03/31 05:32:43 nygard Exp $
//

//  This file is part of SNFoundation, a personal collection of Foundation extensions.
//  Copyright (C) 2004 Steve Nygard.  All rights reserved.

#import <Foundation/NSCharacterSet.h>

@interface NSCharacterSet (Extensions)

+ (NSCharacterSet *)generalXMLEntityCharacterSet;
+ (NSCharacterSet *)phoneStringWhitespaceCharacterSet;
+ (NSCharacterSet *)phoneStringIdentifierCharacterSet;

@end

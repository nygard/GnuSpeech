//
// $Id: NSCharacterSet-Extensions.h,v 1.3 2004/03/31 05:32:43 nygard Exp $
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSCharacterSet.h>

@interface NSCharacterSet (Extensions)

+ (NSCharacterSet *)generalXMLEntityCharacterSet;
+ (NSCharacterSet *)phoneStringWhitespaceCharacterSet;
+ (NSCharacterSet *)phoneStringIdentifierCharacterSet;

@end

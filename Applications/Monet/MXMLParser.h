//
// $Id: MXMLParser.h,v 1.1 2004/04/22 17:48:10 nygard Exp $
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSXMLParser.h>

@protocol MXMLParserGenericInit
- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
@end

@interface MXMLParser : NSXMLParser
{
    NSMutableArray *delegateStack;
    id context;
}

- (id)initWithContentsOfURL:(NSURL *)url;
- (id)initWithData:(NSData *)data;
- (void)dealloc;

- (id)context;
- (void)setContext:(id)newContext;

- (void)pushDelegate:(id)newDelegate;
- (void)popDelegate;

- (void)skipTree;

@end

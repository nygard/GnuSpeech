//  This file is part of SNFoundation, a personal collection of Foundation extensions.
//  Copyright (C) 2004 Steve Nygard.  All rights reserved.

#import <Foundation/NSXMLParser.h>

@class NSMutableArray, NSData;

@protocol MXMLParserGenericInit
+ (id)objectWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
@end

@interface MXMLParser : NSXMLParser
{
    NSMutableArray *delegateStack;
    id context;
}

- (id)initWithData:(NSData *)data;
- (void)dealloc;

- (id)context;
- (void)setContext:(id)newContext;

- (void)pushDelegate:(id)newDelegate;
- (void)popDelegate;

- (void)skipTree;

@end

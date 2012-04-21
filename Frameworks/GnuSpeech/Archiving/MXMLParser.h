//  This file is part of SNFoundation, a personal collection of Foundation extensions.
//  Copyright (C) 2004-2012 Steve Nygard.  All rights reserved.

#import <Foundation/Foundation.h>

@protocol MXMLParserGenericInit
+ (id)objectWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
@end

@interface MXMLParser : NSXMLParser

- (id)initWithData:(NSData *)data;

@property (retain) id context;

- (void)pushDelegate:(id)newDelegate;
- (void)popDelegate;

- (void)skipTree;

@end

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>

@class MMParameter;

@interface MMDisplayParameter : NSObject
{
    MMParameter *parameter;
    BOOL isSpecial;
    int tag;
    BOOL shouldDisplay;
}

- (id)initWithParameter:(MMParameter *)aParameter;
- (void)dealloc;

- (MMParameter *)parameter;

- (BOOL)isSpecial;
- (void)setIsSpecial:(BOOL)newFlag;

- (int)tag;
- (void)setTag:(int)newTag;

- (BOOL)shouldDisplay;
- (void)setShouldDisplay:(BOOL)newFlag;

- (NSString *)name;
- (NSString *)label;

@end

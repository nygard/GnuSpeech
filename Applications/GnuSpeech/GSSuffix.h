//
// $Id: GSSuffix.h,v 1.1 2004/04/30 03:27:44 nygard Exp $
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>

@interface GSSuffix : NSObject
{
    NSString *suffix;
    NSString *replacementString;
    NSString *appendedPronunciation;
}

- (id)initWithSuffix:(NSString *)aSuffix replacementString:(NSString *)aReplacementString appendedPronunciation:(NSString *)anAppendedPronunciation;
- (void)dealloc;

- (NSString *)suffix;
- (NSString *)replacementString;
- (NSString *)appendedPronunciation;

- (NSString *)description;

@end

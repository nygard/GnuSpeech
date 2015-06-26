//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

@class MMParameter;

@interface MMDisplayParameter : NSObject

- (id)initWithParameter:(MMParameter *)parameter;

@property (readonly) MMParameter *parameter;

@property (assign) BOOL isSpecial;
@property (assign) NSUInteger tag;

@property (nonatomic, assign) BOOL shouldDisplay;
- (void)toggleShouldDisplay;

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *label;

@end

extern NSString *MMDisplayParameterNotification_DidChange;
extern NSString *MMDisplayParameterUserInfoKey_DisplayParameter;
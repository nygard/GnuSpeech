//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MModel.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "AppController.h"
#import "CategoryList.h"
#import "CategoryNode.h"
#import "MonetList.h"
#import "ParameterList.h"
#import "PhoneList.h"
#import "RuleList.h"
#import "SymbolList.h"

@implementation MModel

- (id)init;
{
    if ([super init] == nil)
        return nil;

    categories = [[CategoryList alloc] init];
    parameters = [[ParameterList alloc] init];
    metaParameters = [[ParameterList alloc] init];
    symbols = [[SymbolList alloc] init];
    phones = [[PhoneList alloc] init];

    equations = [[MonetList alloc] init];
    transitions = [[MonetList alloc] init];
    specialTransitions = [[MonetList alloc] init];

    rules = [[RuleList alloc] init];

    // And set up some default values:
    [symbols addNewValue:@"duration"];
    [[categories addCategory:@"phone"] setComment:@"This is the static phone category.  It cannot be changed or removed."];

    return self;
}

- (void)dealloc;
{
    [categories release];
    [parameters release];
    [metaParameters release];
    [symbols release];
    [phones release];
    [equations release];
    [transitions release];
    [specialTransitions release];
    [rules release];

    [super dealloc];
}

- (CategoryList *)categories;
{
    return categories;
}

- (ParameterList *)parameters;
{
    return parameters;
}

- (ParameterList *)metaParameters;
{
    return metaParameters;
}

- (SymbolList *)symbols;
{
    return symbols;
}

- (PhoneList *)phones;
{
    return phones;
}

- (MonetList *)equations;
{
    return equations;
}

- (MonetList *)transitions;
{
    return transitions;
}

- (MonetList *)specialTransitions;
{
    return specialTransitions;
}

- (RuleList *)rules;
{
    return rules;
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    /* Category list must be named immediately */
    categories = [[aDecoder decodeObject] retain];
    //NSLog(@"categories: %@", categories);
    NSLog(@"categories: %d", [categories count]);
    NXNameObject(@"mainCategoryList", categories, NSApp);

    symbols = [[aDecoder decodeObject] retain];
    //NSLog(@"symbols: %@", symbols);
    NSLog(@"symbols: %d", [symbols count]);

    parameters = [[aDecoder decodeObject] retain];
    //NSLog(@"parameters: %@", parameters);
    NSLog(@"parameters: %d", [parameters count]);

    metaParameters = [[aDecoder decodeObject] retain];
    //NSLog(@"metaParameters: %@", metaParameters);
    NSLog(@"metaParameters: %d", [metaParameters count]);

    phones = [[aDecoder decodeObject] retain];
    //NSLog(@"phones: %@", phones);
    NSLog(@"phones: %d", [phones count]);

    NXNameObject(@"mainSymbolList", symbols, NSApp);
    NXNameObject(@"mainParameterList", parameters, NSApp);
    NXNameObject(@"mainMetaParameterList", metaParameters, NSApp);
    NXNameObject(@"mainPhoneList", phones, NSApp);

    equations = [[MonetList alloc] init];
    transitions = [[MonetList alloc] init];
    specialTransitions = [[MonetList alloc] init];

    rules = [[RuleList alloc] init];

    return self;
}

@end

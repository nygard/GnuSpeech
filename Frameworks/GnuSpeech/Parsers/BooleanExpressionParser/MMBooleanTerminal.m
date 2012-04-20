//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright (c) 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMBooleanTerminal.h"

#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "CategoryList.h"
#import "MMCategory.h"
#import "MMPosture.h"

#import "MModel.h"
#import "MUnarchiver.h"

@implementation MMBooleanTerminal
{
    MMCategory *category;
    BOOL shouldMatchAll;
}

- (id)init;
{
    if ([super init] == nil)
        return nil;

    category = nil;
    shouldMatchAll = NO;

    return self;
}

- (void)dealloc;
{
    [category release];

    [super dealloc];
}

- (MMCategory *)category;
{
    return category;
}

- (void)setCategory:(MMCategory *)newCategory;
{
    if (newCategory == category)
        return;

    [category release];
    category = [newCategory retain];
}

- (BOOL)shouldMatchAll;
{
    return shouldMatchAll;
}

- (void)setShouldMatchAll:(BOOL)newFlag;
{
    shouldMatchAll = newFlag;
}

//
// Methods common to "BooleanNode" -- for both BooleanExpress, BooleanTerminal
//

- (BOOL)evaluateWithCategories:(CategoryList *)categories;
{
    // TODO (2004-08-02): This seems a little overkill, searching through the list once with -indexOfObject: and then again with findSymbol:.
    if ([categories indexOfObject:category] == NSNotFound) {
        if (shouldMatchAll) {
            if ([categories findSymbol:[category name]] != nil)
                return YES;

            if ([categories findSymbol:[NSString stringWithFormat:@"%@'", [category name]]] != nil)
                return YES;
        }

        return NO;
    }

    return YES;
}

- (void)expressionString:(NSMutableString *)resultString;
{
    if (category == nil)
        return;

    [resultString appendString:[category name]];
    if (shouldMatchAll)
        [resultString appendString:@"*"];
}

- (BOOL)isCategoryUsed:(MMCategory *)aCategory;
{
    if (category == aCategory)
        return YES;

    return NO;
}

//
// Archiving
//

- (id)initWithCoder:(NSCoder *)aDecoder
{
    unsigned archivedVersion;
    char *c_string;
    MMCategory *aCategory;
    NSString *str;
    MModel *model;
    int match;

    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    model = [(MUnarchiver *)aDecoder userInfo];

    //NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    archivedVersion = [aDecoder versionForClassName:NSStringFromClass([self class])];
    //NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

    [aDecoder decodeValueOfObjCType:@encode(int) at:&match]; // Can't decode an int into a BOOL
    //NSLog(@"match: %d", match);
    shouldMatchAll = match;

    [aDecoder decodeValueOfObjCType:@encode(char *) at:&c_string];
    //NSLog(@"c_string: %s", c_string);
    str = [NSString stringWithASCIICString:c_string];
    free(c_string);

    aCategory = [model categoryWithName:str];
    if (aCategory == nil) {
        category = [[[model postureWithName:str] nativeCategory] retain];
    } else {
        category = [aCategory retain];
    }

    //NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);
    return self;
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: category: %@, shouldMatchAll: %d",
                     NSStringFromClass([self class]), self, category, shouldMatchAll];
}

@end

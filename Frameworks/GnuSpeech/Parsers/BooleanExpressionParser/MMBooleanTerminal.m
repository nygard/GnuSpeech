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
    MMCategory *m_category;
    BOOL m_shouldMatchAll;
}

- (id)init;
{
    if ((self = [super init])) {
        m_category = nil;
        m_shouldMatchAll = NO;
    }

    return self;
}

- (void)dealloc;
{
    [m_category release];

    [super dealloc];
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p> category: %@, shouldMatchAll: %d",
            NSStringFromClass([self class]), self,
            self.category, self.shouldMatchAll];
}

#pragma mark -

@synthesize category = m_category;
@synthesize shouldMatchAll = m_shouldMatchAll;

#pragma mark - Superclass methods

- (BOOL)evaluateWithCategories:(CategoryList *)categories;
{
    // TODO (2004-08-02): This seems a little overkill, searching through the list once with -indexOfObject: and then again with findSymbol:.
    if ([categories indexOfObject:self.category] == NSNotFound) {
        if (self.shouldMatchAll) {
            if ([categories findSymbol:[self.category name]] != nil)
                return YES;

            if ([categories findSymbol:[NSString stringWithFormat:@"%@'", [self.category name]]] != nil)
                return YES;
        }

        return NO;
    }

    return YES;
}

- (void)appendExpressionToString:(NSMutableString *)resultString;
{
    if (self.category != nil) {
        [resultString appendString:[self.category name]];
        if (self.shouldMatchAll)
            [resultString appendString:@"*"];
    }
}

- (BOOL)isCategoryUsed:(MMCategory *)category;
{
    if (self.category == category)
        return YES;

    return NO;
}

#pragma mark - Archiving

- (id)initWithCoder:(NSCoder *)decoder;
{
    if ((self = [super initWithCoder:decoder])) {
        MModel *model = [(MUnarchiver *)decoder userInfo];
        
        [decoder versionForClassName:NSStringFromClass([self class])];

        uint32_t match;
        [decoder decodeValueOfObjCType:@encode(uint32_t) at:&match]; // Can't decode an int into a BOOL
        self.shouldMatchAll = match;

        // TODO (2012-04-20): Add - (NSString *)decodeCStringWithEncoding:
        char *c_string;
        [decoder decodeValueOfObjCType:@encode(char *) at:&c_string];
        NSString *str = [NSString stringWithASCIICString:c_string];
        free(c_string);
        
        MMCategory *category = [model categoryWithName:str];
        if (category == nil) {
            self.category = [[[model postureWithName:str] nativeCategory] retain];
        } else {
            self.category = [category retain];
        }
    }

    return self;
}

@end

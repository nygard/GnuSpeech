//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright (c) 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMBooleanTerminal.h"

#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "MMCategory.h"
#import "MMPosture.h"

#import "MModel.h"

@interface MMBooleanTerminal ()
- (MMCategory *)findSymbol:(NSString *)searchSymbol inCategories:(NSArray *)categories;
@end

#pragma mark -

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

- (MMCategory *)findSymbol:(NSString *)searchSymbol inCategories:(NSArray *)categories;
{
    for (MMCategory *category in categories) {
        if ([[category name] isEqual:searchSymbol]) {
            //NSLog(@"Found: %@\n", searchSymbol);
            return category;
        }
    }
    
    //NSLog(@"Could not find: %@\n", searchSymbol);
    return nil;
}

- (BOOL)evaluateWithCategories:(NSArray *)categories;
{
    // TODO (2004-08-02): This seems a little overkill, searching through the list once with -indexOfObject: and then again with findSymbol:.
    if ([categories indexOfObject:self.category] == NSNotFound) {
        if (self.shouldMatchAll) {
            if ([self findSymbol:[self.category name] inCategories:categories] != nil)
                return YES;

            if ([self findSymbol:[NSString stringWithFormat:@"%@'", [self.category name]] inCategories:categories] != nil)
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

- (BOOL)usesCategory:(MMCategory *)category;
{
    if (self.category == category)
        return YES;

    return NO;
}

@end

#import "BooleanTerminal.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "CategoryList.h"
#import "MMCategory.h"
#import "MMPosture.h"
#import "PhoneList.h"

#import "MModel.h"
#import "MUnarchiver.h"

@implementation BooleanTerminal

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

- (int)evaluateWithCategories:(CategoryList *)categories;
{
    if ([categories indexOfObject:category] == NSNotFound) {
        if (shouldMatchAll) {
            if ([categories findSymbol:[category symbol]] != nil)
                return 1;

            if ([categories findSymbol:[NSString stringWithFormat:@"%@'", [category symbol]]] != nil)
                return 1;
        }

        return 0;
    }

    return 1;
}

- (void)expressionString:(NSMutableString *)resultString;
{
    if (category == nil)
        return;

    [resultString appendString:[category symbol]];
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
    CategoryList *categoryList;
    PhoneList *phoneList;
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

    categoryList = [model categories];
    phoneList = [model postures];

    [aDecoder decodeValueOfObjCType:"i" at:&match]; // Can't decode an int into a BOOL
    //NSLog(@"match: %d", match);
    shouldMatchAll = match;

    //[aDecoder decodeValueOfObjCType:"i" at:&shouldMatchAll];
    //NSLog(@"shouldMatchAll: %d", shouldMatchAll);

    [aDecoder decodeValueOfObjCType:"*" at:&c_string];
    //NSLog(@"c_string: %s", c_string);
    str = [NSString stringWithASCIICString:c_string];

    aCategory = [categoryList findSymbol:str];
    if (aCategory == nil) {
        aCategory = [[[phoneList findPhone:str] categoryList] findSymbol:str];
        category = [aCategory retain];
    } else {
        category = [aCategory retain];
    }

    free(c_string);

    //NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);
    return self;
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: category: %@, shouldMatchAll: %d",
                     NSStringFromClass([self class]), self, category, shouldMatchAll];
}

@end

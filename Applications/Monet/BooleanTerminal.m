#import "BooleanTerminal.h"

#import <Foundation/Foundation.h>
#import "CategoryList.h"
#import "CategoryNode.h"

#ifdef PORTING
#import "PhoneList.h"
#import "MyController.h"
#import <AppKit/NSApplication.h>
#import <stdio.h>
#import <string.h>
#endif

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
    //[category release];

    [super dealloc];
}

- category;
{
    return category;
}

- (void)setCategory:newCategory;
{
    category = newCategory;
}

- (int)shouldMatchAll;
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

- (int)evaluate:(CategoryList *)categories;
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

- (void)optimize;
{
}

- (void)optimizeSubExpressions;
{
}

- (int)maxExpressionLevels;
{
    return 1;
}

- (NSString *)expressionString;
{
    NSMutableString *resultString;

    resultString = [NSMutableString string];
    [self expressionString:resultString];

    return resultString;
}

- (void)expressionString:(NSMutableString *)resultString;
{
    if (category == nil)
        return;

    [resultString appendString:[category symbol]];
    if (shouldMatchAll)
        [resultString appendString:@"*"];
}

- (BOOL)isCategoryUsed:aCategory;
{
    if (category == aCategory)
        return YES;

    return NO;
}

//
// Archiving methods
//

- (id)initWithCoder:(NSCoder *)aDecoder
{
#ifdef PORTING
    char *string;
    CategoryList *temp;
    PhoneList *phoneList;
    CategoryNode *temp1;

    temp = NXGetNamedObject(@"mainCategoryList", NSApp);
    phoneList = NXGetNamedObject(@"mainPhoneList", NSApp);

    [aDecoder decodeValueOfObjCType:"i" at:&matchAll];

    [aDecoder decodeValueOfObjCType:"*" at:&string];

    temp1 = [temp findSymbol:string];
    if (!temp1) {
        temp1 = [[[phoneList findPhone:string] categoryList] findSymbol:string];
        category = temp1;
    } else {
        category = temp1;
    }

    free(string);
    return self;
#endif
    return nil;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    const char *temp;

    [aCoder encodeValueOfObjCType:"i" at:&shouldMatchAll];

    temp = [category symbol];
    [aCoder encodeValueOfObjCType:"*" at:&temp];
}

@end

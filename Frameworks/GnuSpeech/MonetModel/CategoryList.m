//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock

#import "CategoryList.h"

#import <Foundation/Foundation.h>
#import "MMCategory.h"

// This Class currently adds no functionality to the List class.
// However, it is planned that this object will provide sorting functions
// to the MMCategory class.

@implementation CategoryList

- (MMCategory *)findSymbol:(NSString *)searchSymbol;
{
    int count, index;
    MMCategory *aCategory;

    //NSLog(@"CategoryList searching for: %@\n", searchSymbol);

    count = [self count];
    for (index = 0; index < count; index++) {
        aCategory = [self objectAtIndex:index];
        if ([[aCategory name] isEqual:searchSymbol] == YES) {
            //NSLog(@"Found: %@\n", searchSymbol);
            return aCategory;
        }
    }

    //NSLog(@"Could not find: %@\n", searchSymbol);
    return nil;
}

@end

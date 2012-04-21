//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "CategoryList.h"

#import "MMCategory.h"

// This Class currently adds no functionality to the List class.
// However, it is planned that this object will provide sorting functions
// to the MMCategory class.

@implementation CategoryList
{
}

- (MMCategory *)findSymbol:(NSString *)searchSymbol;
{
    //NSLog(@"CategoryList searching for: %@\n", searchSymbol);

    for (MMCategory *category in self.ilist) {
        if ([[category name] isEqual:searchSymbol]) {
            //NSLog(@"Found: %@\n", searchSymbol);
            return category;
        }
    }

    //NSLog(@"Could not find: %@\n", searchSymbol);
    return nil;
}

@end

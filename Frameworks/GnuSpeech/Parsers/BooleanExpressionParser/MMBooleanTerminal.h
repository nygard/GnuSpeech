//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright (c) 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMBooleanNode.h"

@class MMCategory;


// Leaf nodes in a boolean expression tree.
@interface MMBooleanTerminal : MMBooleanNode

@property (retain) MMCategory *category;

// Indicates whether the category should match all categories of this type.
// That is, categories "uh" and "uh'" are of the same class, but are different.
// (In the boolean expression, "uh*" will match both.  The "*" indicates that this flag is true.)
@property (assign) BOOL shouldMatchAll;

@end

//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright (c) 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "GSParser.h"

@class MModel;

// Terminals are MMCategory instances
// Some categories are native to a specific phone, and not found in the main category list.

@interface MMBooleanParser : GSParser

- (id)initWithModel:(MModel *)model;

@property (retain) MModel *model;

@end

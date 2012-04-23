//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright (c) 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMFormulaNode.h"

@class MMSymbol;

enum {
    MMPhoneIndex_RuleDuration = -2,
    MMPhoneIndex_Beat         = -3,
    MMPhoneIndex_Mark1        = -4,
    MMPhoneIndex_Mark2        = -5,
    MMPhoneIndex_Mark3        = -6,
    MMPhoneIndex_Tempo0       = -7,
    MMPhoneIndex_Tempo1       = -8,
    MMPhoneIndex_Tempo2       = -9,
    MMPhoneIndex_Tempo3       = -10,
};
typedef NSInteger MMPhoneIndex;

@interface MMFormulaTerminal : MMFormulaNode

@property (retain) MMSymbol *symbol;
@property (assign) double value;
@property (assign) MMPhoneIndex whichPhone;

@end

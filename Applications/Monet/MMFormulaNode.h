//
// $Id$
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>

@class PhoneList;

@interface MMFormulaNode : NSObject
{
}

- (int)precedence;

- (double)evaluate:(double *)ruleSymbols phones:(PhoneList *)phones;
- (double)evaluate:(double *)ruleSymbols phones:(PhoneList *)phones tempos:(double *)tempos;

- (int)maxPhone;

- (NSString *)expressionString;
- (void)expressionString:(NSMutableString *)resultString;

@end

//
// $Id$
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MMFormulaNode.h"

@interface MMOldFormulaNode : MMFormulaNode
{
    int precedence;
}

- (int)precedence;
- (void)setPrecedence:(int)newPrecedence;

@end

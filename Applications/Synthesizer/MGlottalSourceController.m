//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MGlottalSourceController.h"

@implementation MGlottalSourceController

- (id)init;
{
    if ([super initWithWindowNibName:@"GlottalSource"] == nil)
        return nil;

    [self setWindowFrameAutosaveName:@"GlottalSource"];

    return self;
}

@end

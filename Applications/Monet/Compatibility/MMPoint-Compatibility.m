//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MMPoint-Compatibility.h"

#import "NSObject-Extensions.h"
#import "MModel.h"
#import "MUnarchiver.h"

@implementation MMPoint (Compatibility)

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    unsigned archivedVersion;
    int i, j;
    MMEquation *anExpression;
    MModel *model;
    int phantom;

    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    model = [(MUnarchiver *)aDecoder userInfo];
    //NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    archivedVersion = [aDecoder versionForClassName:NSStringFromClass([self class])];
    //NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

#if 1
    // TODO (2004-03-17): Check to make sure that isPhantom is being properly decoded.
    [aDecoder decodeValuesOfObjCTypes:"ddii", &value, &freeTime, &type, &phantom];
    isPhantom = phantom; // Can't decode an int into a BOOL
    //NSLog(@"isPhantom: %d", isPhantom);
#else
    // Hack to check "Play2.monet".
    {
        static int hack_count = 0;

        hack_count++;
        NSLog(@"hack_count: %d", hack_count);

        NS_DURING {
            if (hack_count >= 23) {
                double valueOne;
                int valueTwo;

                [aDecoder decodeValuesOfObjCTypes:"di", &valueOne, &valueTwo];
                NSLog(@"read: %g, %d", valueOne, valueTwo);
            } else {
                [aDecoder decodeValuesOfObjCTypes:"ddii", &value, &freeTime, &type, &isPhantom];
            }
        } NS_HANDLER {
            NSLog(@"Caught exception: %@", localException);
            return nil;
        } NS_ENDHANDLER;
    }
#endif
    //NSLog(@"value: %g, freeTime: %g, type: %d, isPhantom: %d", value, freeTime, type, isPhantom);

    [aDecoder decodeValuesOfObjCTypes:"ii", &i, &j];
    //NSLog(@"i: %d, j: %d", i, j);
    if (i != -1) {
        anExpression = [model findEquation:i andIndex:j];
        //NSLog(@"anExpression: %@", anExpression);
        [self setTimeEquation:anExpression];
    }

    //NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);
    return self;
}

@end

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MMTransition-Compatibility.h"

#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "MModel.h"
#import "MMPoint.h"
#import "MonetList.h"
#import "MUnarchiver.h"

@implementation MMTransition (Compatibility)

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    unsigned archivedVersion;
    char *c_name, *c_comment;
    MonetList *archivedPoints;
    MModel *model;

    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    name = nil;
    comment = nil;
    type = 2;
    points = [[NSMutableArray alloc] init];

    model = [(MUnarchiver *)aDecoder userInfo];

    //NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    archivedVersion = [aDecoder versionForClassName:NSStringFromClass([self class])];
    //NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

    [aDecoder decodeValuesOfObjCTypes:"**i", &c_name, &c_comment, &type];
    //NSLog(@"c_name: %s, c_comment: %s, type: %d", c_name, c_comment, type);
    [self setName:[NSString stringWithASCIICString:c_name]];
    [self setComment:[NSString stringWithASCIICString:c_comment]];
    free(c_name);
    free(c_comment);

    archivedPoints = [aDecoder decodeObject];
    points = [[NSMutableArray alloc] init];
    //NSLog(@"archivedPoints: %@", archivedPoints);

    //NSLog(@"Points = %d", [points count]);

    if (archivedPoints == nil) {
        MMPoint *aPoint;

        NSLog(@"Archived points were nil, using defaults.");

        aPoint = [[MMPoint alloc] init];
        [aPoint setValue:0.0];
        [aPoint setType:MMPhoneTypeDiphone];
        [aPoint setTimeEquation:[model findEquationList:@"Test" named:@"Zero"]];
        [points addObject:aPoint];
        [aPoint release];

        aPoint = [[MMPoint alloc] init];
        [aPoint setValue:12.5];
        [aPoint setType:MMPhoneTypeDiphone];
        [aPoint setTimeEquation:[model findEquationList:@"Test" named:@"diphoneOneThree"]];
        [points addObject:aPoint];
        [aPoint release];

        aPoint = [[MMPoint alloc] init];
        [aPoint setValue:87.5];
        [aPoint setType:MMPhoneTypeDiphone];
        [aPoint setTimeEquation:[model findEquationList:@"Test" named:@"diphoneTwoThree"]];
        [points addObject:aPoint];
        [aPoint release];

        aPoint = [[MMPoint alloc] init];
        [aPoint setValue:100.0];
        [aPoint setType:MMPhoneTypeDiphone];
        [aPoint setTimeEquation:[model findEquationList:@"Defaults" named:@"Mark1"]];
        [points addObject:aPoint];
        [aPoint release];

        if (type != MMPhoneTypeDiphone) {
            aPoint = [[MMPoint alloc] init];
            [aPoint setValue:12.5];
            [aPoint setType:MMPhoneTypeDiphone];
            [aPoint setTimeEquation:[model findEquationList:@"Test" named:@"triphoneOneThree"]];
            [points addObject:aPoint];
            [aPoint release];

            aPoint = [[MMPoint alloc] init];
            [aPoint setValue:87.5];
            [aPoint setType:MMPhoneTypeTriphone];
            [aPoint setTimeEquation:[model findEquationList:@"Test" named:@"triphoneTwoThree"]];
            [points addObject:aPoint];
            [aPoint release];

            aPoint = [[MMPoint alloc] init];
            [aPoint setValue:100.0];
            [aPoint setType:MMPhoneTypeTriphone];
            [aPoint setTimeEquation:[model findEquationList:@"Defaults" named:@"Mark2"]];
            [points addObject:aPoint];
            [aPoint release];

            if (type != MMPhoneTypeTriphone) {
                aPoint = [[MMPoint alloc] init];
                [aPoint setValue:12.5];
                [aPoint setType:MMPhoneTypeTetraphone];
                [aPoint setTimeEquation:[model findEquationList:@"Test" named:@"tetraphoneOneThree"]];
                [points addObject:aPoint];
                [aPoint release];

                aPoint = [[MMPoint alloc] init];
                [aPoint setValue:87.5];
                [aPoint setType:MMPhoneTypeTetraphone];
                [aPoint setTimeEquation:[model findEquationList:@"Test" named:@"tetraphoneTwoThree"]];
                [points addObject:aPoint];
                [aPoint release];

                aPoint = [[MMPoint alloc] init];
                [aPoint setValue:100.0];
                [aPoint setType:MMPhoneTypeTetraphone];
                [aPoint setTimeEquation:[model findEquationList:@"Durations" named:@"TetraphoneDefault"]];
                [points addObject:aPoint];
                [aPoint release];
            }
        }
    } else {
        [points addObjectsFromArray:[archivedPoints allObjects]];
    }

    //NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);

    return self;
}

@end

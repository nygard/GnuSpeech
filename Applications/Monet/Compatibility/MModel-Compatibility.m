//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MModel-Compatibility.h"

#import "NSObject-Extensions.h"
#import "MUnarchiver.h"
#import "SymbolList.h"
#import "ParameterList.h"
#import "PhoneList.h"

@implementation MModel (Compatibility)

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    [(MUnarchiver *)aDecoder setUserInfo:self];

    /* Category list must be named immediately */
    categories = [[aDecoder decodeObject] retain];
    //[categories sortUsingSelector:@selector(compareByAscendingName:)];

    //NSLog(@"categories: %@", categories);
    //NSLog(@"categories: %d", [categories count]);

    {
        SymbolList *archivedSymbols;

        archivedSymbols = [aDecoder decodeObject];
        symbols = [[NSMutableArray alloc] init];
        [symbols addObjectsFromArray:[archivedSymbols allObjects]];

        //NSLog(@"symbols: %@", symbols);
        //NSLog(@"symbols: %d", [symbols count]);
        [symbols makeObjectsPerformSelector:@selector(setModel:) withObject:self];
    }

    {
        ParameterList *archivedParameters;

        archivedParameters = [aDecoder decodeObject];
        parameters = [[NSMutableArray alloc] init];
        [parameters addObjectsFromArray:[archivedParameters allObjects]];

        //NSLog(@"parameters: %@", parameters);
        //NSLog(@"parameters: %d", [parameters count]);
        [parameters makeObjectsPerformSelector:@selector(setModel:) withObject:self];
    }

    {
        ParameterList *archivedMetaParameters;

        archivedMetaParameters = [aDecoder decodeObject];
        metaParameters = [[NSMutableArray alloc] init];
        [metaParameters addObjectsFromArray:[archivedMetaParameters allObjects]];

        //NSLog(@"metaParameters: %@", metaParameters);
        //NSLog(@"metaParameters: %d", [metaParameters count]);
        [metaParameters makeObjectsPerformSelector:@selector(setModel:) withObject:self];
    }

    {
        PhoneList *archivedPostures;

        archivedPostures = [aDecoder decodeObject];
        postures = [[NSMutableArray alloc] init];
        [postures addObjectsFromArray:[archivedPostures allObjects]];

        //NSLog(@"postures: %@", postures);
        //NSLog(@"postures: %d", [postures count]);
        [postures makeObjectsPerformSelector:@selector(setModel:) withObject:self];
    }

    {
        MonetList *archivedEquations;

        archivedEquations = [aDecoder decodeObject];
        equations = [[NSMutableArray alloc] init];
        [equations addObjectsFromArray:[archivedEquations allObjects]];
        //NSLog(@"equations: %d", [equations count]);
    }

    {
        MonetList *archivedTransitions;

        archivedTransitions = [aDecoder decodeObject];
        transitions = [[NSMutableArray alloc] init];
        [transitions addObjectsFromArray:[archivedTransitions allObjects]];
        //NSLog(@"transitions: %d", [transitions count]);
    }

    {
        MonetList *archivedSpecialTransitions;

        archivedSpecialTransitions = [aDecoder decodeObject];
        specialTransitions = [[NSMutableArray alloc] init];
        [specialTransitions addObjectsFromArray:[archivedSpecialTransitions allObjects]];
        //NSLog(@"specialTransitions: %d", [specialTransitions count]);
    }

    {
        MonetList *archivedRules;

        archivedRules = [aDecoder decodeObject];
        rules = [[NSMutableArray alloc] init];
        [rules addObjectsFromArray:[archivedRules allObjects]];
    }
    //NSLog(@"rules: %d", [rules count]);
    [rules makeObjectsPerformSelector:@selector(setModel:) withObject:self];

    synthesisParameters = [[MMSynthesisParameters alloc] init];

    return self;
}

@end

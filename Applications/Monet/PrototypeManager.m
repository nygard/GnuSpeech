#import "PrototypeManager.h"

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "AppController.h"
#import "MonetList.h"
#import "NamedList.h"
#import "MMEquation.h"
#import "MMTransition.h"

#import "MModel.h"

@implementation PrototypeManager

- (id)init;
{
    if ([super init] == nil)
        return nil;

    model = nil;

    return self;
}

- (void)dealloc;
{
    [model release];

    [super dealloc];
}

- (MModel *)model;
{
    return model;
}

- (void)setModel:(MModel *)newModel;
{
    if (newModel == model)
        return;

    [model release];
    model = [newModel retain];
}

- (MonetList *)equationList;
{
    return [model equations];
}

- (MonetList *)transitionList;
{
    return [model transitions];
}

- (MonetList *)specialList;
{
    return [model specialTransitions];
}

// Keeping for compatibility, for now
- (MMEquation *)findEquationList:(NSString *)aListName named:(NSString *)anEquationName;
{
    return [[self model] findEquationList:aListName named:anEquationName];
}

- (void)findList:(int *)listIndex andIndex:(int *)equationIndex ofEquation:(MMEquation *)anEquation;
{
    [[self model] findList:listIndex andIndex:equationIndex ofEquation:anEquation];
}

- (MMEquation *)findEquation:(int)listIndex andIndex:(int)equationIndex;
{
    return [[self model] findEquation:listIndex andIndex:equationIndex];
}

- (MMEquation *)findTransitionList:(NSString *)aListName named:(NSString *)aTransitionName;
{
    return [[self model] findTransitionList:aListName named:aTransitionName];
}

- (void)findList:(int *)listIndex andIndex:(int *)transitionIndex ofTransition:(MMEquation *)aTransition;
{
    [[self model] findList:listIndex andIndex:transitionIndex ofTransition:aTransition];
}

- (MMEquation *)findTransition:(int)listIndex andIndex:(int)transitionIndex;
{
    return [[self model] findTransition:listIndex andIndex:transitionIndex];
}

- (MMTransition *)findSpecialList:(NSString *)aListName named:(NSString *)aSpecialName;
{
    return [[self model] findSpecialList:aListName named:aSpecialName];
}

- (void)findList:(int *)listIndex andIndex:(int *)specialIndex ofSpecial:(MMTransition *)aTransition;
{
    [[self model] findList:listIndex andIndex:specialIndex ofSpecial:aTransition];
}

- (MMTransition *)findSpecial:(int)listIndex andIndex:(int)specialIndex;
{
    return [[self model] findSpecial:listIndex andIndex:specialIndex];
}


@end

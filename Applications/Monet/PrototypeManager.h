#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class NSFont;
@class MonetList, MMEquation, MMTransition;
@class AppController, DelegateResponder;
@class MModel;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface PrototypeManager : NSObject
{
    IBOutlet AppController *controller;

    MModel *model;
}

- (id)init;
- (void)dealloc;

- (MModel *)model;
- (void)setModel:(MModel *)newModel;

- (MonetList *)equationList;
- (MonetList *)transitionList;
- (MonetList *)specialList;

- (MMEquation *)findEquationList:(NSString *)aListName named:(NSString *)anEquationName;
- (void)findList:(int *)listIndex andIndex:(int *)equationIndex ofEquation:(MMEquation *)anEquation;
- (MMEquation *)findEquation:(int)listIndex andIndex:(int)equationIndex;

- (MMEquation *)findTransitionList:(NSString *)aListName named:(NSString *)aTransitionName;
- (void)findList:(int *)listIndex andIndex:(int *)transitionIndex ofTransition:(MMEquation *)aTransition;
- (MMEquation *)findTransition:(int)listIndex andIndex:(int)transitionIndex;

- (MMTransition *)findSpecialList:(NSString *)aListName named:(NSString *)aSpecialName;
- (void)findList:(int *)listIndex andIndex:(int *)specialIndex ofSpecial:(MMTransition *)aTransition;
- (MMTransition *)findSpecial:(int)listIndex andIndex:(int)specialIndex;

@end

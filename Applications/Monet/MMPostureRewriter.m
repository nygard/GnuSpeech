//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MMPostureRewriter.h"

#import <Foundation/Foundation.h>
#import "EventList.h"
#import "MModel.h"
#import "MMPosture.h"

@implementation MMPostureRewriter

- (id)initWithModel:(MModel *)aModel;
{
    if ([super init] == nil)
        return nil;

    model = [aModel retain];
    currentState = 0;
    lastPosture = nil;

    [self _setup];

    return self;
}

- (void)dealloc;
{
    unsigned int index;

    [model release];

    for (index = 0; index < 15; index++)
        [category[index] release];

    for (index = 0; index < 7; index++)
        [returnPostures[index] release];

    [lastPosture release];

    [super dealloc];
}

- (void)_setup;
{
    unsigned int index;

    for (index = 0; index < 15; index++)
        [category[index] release];

    for (index = 0; index < 7; index++)
        [returnPostures[index] release];

    // TODO (2004-05-30): Rename these to "categoryNames"
    category[0] = [@"stopped" retain];
    category[1] = [@"affricate" retain];
    category[2] = [@"hlike" retain];
    category[3] = [@"vocoid" retain];
    category[14] = [@"whistlehack" retain];

    category[4] = [@"h" retain];
    category[5] = [@"h'" retain];

    category[6] = [@"hv" retain];
    category[7] = [@"hv'" retain];

    category[8] = [@"ll" retain];
    category[9] = [@"ll'" retain];

    category[10] = [@"s" retain];
    category[11] = [@"s'" retain];

    category[12] = [@"z" retain];
    category[13] = [@"z'" retain];

    // TODO (2004-05-30): Rename this to "returnPosture" or "insertPosture"
    returnPostures[0] = [[model postureWithName:@"qc"] retain];
    returnPostures[1] = [[model postureWithName:@"qt"] retain];
    returnPostures[2] = [[model postureWithName:@"qp"] retain];
    returnPostures[3] = [[model postureWithName:@"qk"] retain];
    returnPostures[4] = [[model postureWithName:@"gs"] retain];
    returnPostures[5] = [[model postureWithName:@"qs"] retain];
    returnPostures[6] = [[model postureWithName:@"qz"] retain];

    [self setLastPosture:nil];
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

    [self _setup];
}

- (MMPosture *)lastPosture;
{
    return lastPosture;
}

- (void)setLastPosture:(MMPosture *)newPosture;
{
    if (newPosture == lastPosture)
        return;

    [lastPosture release];
    lastPosture = [newPosture retain];
}

- (void)rewriteEventList:(EventList *)eventList withNextPosture:(MMPosture *)nextPosture wordMarker:(BOOL)followsWordMarker;
{
    int index;
    BOOL didMakeTransition = NO;
    MMPosture *insertPosture = nil;

    static int stateTable[17][15] =
        {
            { 1,  9,  0, 7, 0, 0, 0, 0, 5, 5, 13, 13, 15, 15,  0},	/* State 0 */
            { 3,  9,  0, 7, 2, 2, 2, 2, 5, 5, 13, 13, 15, 15,  0},	/* State 1 */
            { 1,  9,  0, 7, 0, 0, 0, 0, 5, 5, 13, 13, 15, 15,  0},	/* State 2 */
            { 4,  9,  0, 7, 0, 0, 0, 0, 5, 5, 13, 13, 15, 15,  0},	/* State 3 */
            { 1,  9,  0, 7, 0, 0, 0, 0, 5, 5, 13, 13, 15, 15,  0},	/* State 4 */
            { 1,  9,  0, 6, 0, 0, 0, 0, 5, 5, 13, 13, 15, 15,  0},	/* State 5 */
            { 1,  9,  0, 8, 0, 0, 0, 0, 5, 5, 13, 13, 15, 15,  0},	/* State 6 */
            { 1,  9,  0, 8, 0, 0, 0, 0, 5, 5, 13, 13, 15, 15,  0},	/* State 7 */
            { 1,  9,  0, 8, 0, 0, 0, 0, 5, 5, 13, 13, 15, 15,  0},	/* State 8 */
            {10, 12, 12, 0, 0, 0, 0, 0, 5, 5, 13, 13, 15, 15,  0},	/* State 9 */
            {11, 11, 11, 0, 0, 0, 0, 0, 5, 5, 13, 13, 15, 15,  0},	/* State 10 */
            { 1,  9,  0, 0, 0, 0, 0, 0, 5, 5, 13, 13, 15, 15,  0},	/* State 11 */
            { 1,  9,  0, 0, 0, 0, 0, 0, 5, 5, 13, 13, 15, 15,  0},	/* State 12 */
            { 1,  9,  0, 0, 0, 0, 0, 0, 5, 5, 13, 13, 15, 15, 14},	/* State 13 */
            { 1,  9,  0, 0, 0, 0, 0, 0, 5, 5, 13, 13, 15, 15,  0},	/* State 14 */
            { 1,  9,  0, 0, 0, 0, 0, 0, 5, 5, 13, 13, 15, 15, 16},	/* State 15 */
            { 1,  9,  0, 0, 0, 0, 0, 0, 5, 5, 13, 13, 15, 15,  0},	/* State 16 */
        };

    //NSLog(@" > %s", _cmd);

    //NSLog(@"currentState: %d", currentState);
    for (index = 0; index < 15; index++) {
        //NSLog(@"Checking posture %@ for category %@", [nextPosture symbol], category[index]);
        if ([nextPosture isMemberOfCategoryNamed:category[index]] == YES) {
            //NSLog(@"Found %@ %@ state %d -> %d", [nextPosture symbol], category[index], currentState, stateTable[currentState][index]);
            currentState = stateTable[currentState][index];
            didMakeTransition = YES;
            break;
        }
    }

    if (didMakeTransition == YES) {
        //NSLog(@"Made transition to state %d", currentState);
        switch (currentState) {
          default:
          case 0:
          case 1:
          case 3:
          case 5:
          case 7:
          case 9:
              //NSLog(@"No rewrite");
              break;

          case 2:
          case 4:
          case 11:
          {
              NSString *str;

              str = [lastPosture symbol];
              //NSLog(@"state 2, 4, 11: lastPosture symbol: %@", str);
              if ([str hasPrefix:@"d"] == YES || [str hasPrefix:@"t"] == YES) {
                  insertPosture = returnPostures[1];
              } else if ([str hasPrefix:@"p"] == YES || [str hasPrefix:@"b"] == YES) {
                  insertPosture = returnPostures[2];
              } else if ([str hasPrefix:@"k"] == YES || [str hasPrefix:@"g"] == YES) {
                  insertPosture = returnPostures[3];
              }

              break;
          }

          case 6:
          {
              MMPosture *replacementPosture;

              if ([[lastPosture symbol] hasSuffix:@"'"] == YES)
                  replacementPosture = [model postureWithName:@"l'"];
              else
                  replacementPosture = [model postureWithName:@"l"];

              //NSLog(@"Replace last posture (%@) with %@", [lastPosture symbol], [replacementPosture symbol]);

              [eventList replaceCurrentPhoneWith:replacementPosture];

              break;
          }

          case 8:
              //NSLog(@"vowels %@ -> %@   %d", [lastPosture symbol], [nextPosture symbol], followsWordMarker);
              if (nextPosture == lastPosture && followsWordMarker == YES) {
                  insertPosture = returnPostures[4];
              }
              break;

          case 10:
              insertPosture = returnPostures[0];
              break;

          case 12:
              insertPosture = returnPostures[0];
              break;

          case 14:
              insertPosture = returnPostures[5];
              break;

          case 16:
              insertPosture = returnPostures[6];
              break;
        }

        [self setLastPosture:nextPosture];
    } else {
        //NSLog(@"Returning to state 0");
        currentState = 0;
        [self setLastPosture:nil];
    }

    if (insertPosture != nil) {
        //NSLog(@"adding posture: %@", [insertPosture symbol]);
        [eventList newPhoneWithObject:insertPosture];
    }

    //NSLog(@"<  %s", _cmd);
}

@end

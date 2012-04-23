//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMPostureRewriter.h"

#import "EventList.h"
#import "MModel.h"
#import "MMPosture.h"

@interface MMPostureRewriter ()

- (void)_setupCategoryNames;
- (void)_setup;

@property (retain) MMPosture *lastPosture;

@end

#pragma mark -

@implementation MMPostureRewriter
{
    MModel *model;
    
    NSString *categoryNames[15];
    MMPosture *returnPostures[7];
    
    NSUInteger currentState;
    MMPosture *lastPosture;
}

- (id)initWithModel:(MModel *)aModel;
{
    if ((self = [super init])) {
        model = [aModel retain];
        currentState = 0;
        lastPosture = nil;

        [self _setupCategoryNames];
        [self _setup];
    }

    return self;
}

- (void)dealloc;
{
    [model release];

    for (NSUInteger index = 0; index < 15; index++)
        [categoryNames[index] release];

    for (NSUInteger index = 0; index < 7; index++)
        [returnPostures[index] release];

    [lastPosture release];

    [super dealloc];
}

- (void)_setupCategoryNames;
{
    categoryNames[0] = [@"stopped" retain];
    categoryNames[1] = [@"affricate" retain];
    categoryNames[2] = [@"hlike" retain];
    categoryNames[3] = [@"vocoid" retain];
    categoryNames[14] = [@"whistlehack" retain];

    categoryNames[4] = [@"h" retain];
    categoryNames[5] = [@"h'" retain];

    categoryNames[6] = [@"hv" retain];
    categoryNames[7] = [@"hv'" retain];

    categoryNames[8] = [@"ll" retain];
    categoryNames[9] = [@"ll'" retain];

    categoryNames[10] = [@"s" retain];
    categoryNames[11] = [@"s'" retain];

    categoryNames[12] = [@"z" retain];
    categoryNames[13] = [@"z'" retain];
}

- (void)_setup;
{
    for (NSUInteger index = 0; index < 7; index++)
        [returnPostures[index] release];

    returnPostures[0] = [[model postureWithName:@"qc"] retain];
    returnPostures[1] = [[model postureWithName:@"qt"] retain];
    returnPostures[2] = [[model postureWithName:@"qp"] retain];
    returnPostures[3] = [[model postureWithName:@"qk"] retain];
    returnPostures[4] = [[model postureWithName:@"gs"] retain];
    returnPostures[5] = [[model postureWithName:@"qs"] retain];
    returnPostures[6] = [[model postureWithName:@"qz"] retain];

    [self resetState];
}

- (MModel *)model;
{
    return model;
}

- (void)setModel:(MModel *)newModel;
{
    if (newModel != model) {
        [model release];
        model = [newModel retain];

        [self _setup];
    }
}

@synthesize lastPosture;

- (void)resetState;
{
    currentState = 0;
    self.lastPosture = nil;
}

- (void)rewriteEventList:(EventList *)eventList withNextPosture:(MMPosture *)nextPosture wordMarker:(BOOL)followsWordMarker;
{
    BOOL didMakeTransition = NO;

    static NSUInteger stateTable[17][15] =
    {
        //              h*,hv*      ll*   s*      z*
        //              ==========  ---------------------
        //0   1   2  3  4  5  6  7  8  9  10  11  12  13  14
        
        { 1,  9,  0, 7, 0, 0, 0, 0, 5, 5, 13, 13, 15, 15,  0},	// State 0
        { 3,  9,  0, 7, 2, 2, 2, 2, 5, 5, 13, 13, 15, 15,  0},	// State 1
        { 1,  9,  0, 7, 0, 0, 0, 0, 5, 5, 13, 13, 15, 15,  0},	// State 2
        { 4,  9,  0, 7, 0, 0, 0, 0, 5, 5, 13, 13, 15, 15,  0},	// State 3
        { 1,  9,  0, 7, 0, 0, 0, 0, 5, 5, 13, 13, 15, 15,  0},	// State 4
        { 1,  9,  0, 6, 0, 0, 0, 0, 5, 5, 13, 13, 15, 15,  0},	// State 5
        { 1,  9,  0, 8, 0, 0, 0, 0, 5, 5, 13, 13, 15, 15,  0},	// State 6
        { 1,  9,  0, 8, 0, 0, 0, 0, 5, 5, 13, 13, 15, 15,  0},	// State 7
        { 1,  9,  0, 8, 0, 0, 0, 0, 5, 5, 13, 13, 15, 15,  0},	// State 8
        {10, 12, 12, 0, 0, 0, 0, 0, 5, 5, 13, 13, 15, 15,  0},	// State 9
        {11, 11, 11, 0, 0, 0, 0, 0, 5, 5, 13, 13, 15, 15,  0},	// State 10
        { 1,  9,  0, 0, 0, 0, 0, 0, 5, 5, 13, 13, 15, 15,  0},	// State 11
        { 1,  9,  0, 0, 0, 0, 0, 0, 5, 5, 13, 13, 15, 15,  0},	// State 12
        { 1,  9,  0, 0, 0, 0, 0, 0, 5, 5, 13, 13, 15, 15, 14},	// State 13
        { 1,  9,  0, 0, 0, 0, 0, 0, 5, 5, 13, 13, 15, 15,  0},	// State 14
        { 1,  9,  0, 0, 0, 0, 0, 0, 5, 5, 13, 13, 15, 15, 16},	// State 15
        { 1,  9,  0, 0, 0, 0, 0, 0, 5, 5, 13, 13, 15, 15,  0},	// State 16
    };

    //NSLog(@" > %s", _cmd);

    //NSLog(@"currentState: %d", currentState);
    for (NSUInteger index = 0; index < 15; index++) {
        //NSLog(@"Checking posture %@ for category %@", [nextPosture symbol], categoryNames[index]);
        if ([nextPosture isMemberOfCategoryNamed:categoryNames[index]]) {
            //NSLog(@"Found %@ %@ state %d -> %d", [nextPosture symbol], categoryNames[index], currentState, stateTable[currentState][index]);
            currentState = stateTable[currentState][index];
            didMakeTransition = YES;
            break;
        }
    }

    MMPosture *insertPosture = nil;
    if (didMakeTransition) {
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
                NSString *str = [lastPosture name];
                //NSLog(@"state 2, 4, 11: lastPosture symbol: %@", str);
                if ([str hasPrefix:@"d"] || [str hasPrefix:@"t"])      insertPosture = returnPostures[1];
                else if ([str hasPrefix:@"p"] || [str hasPrefix:@"b"]) insertPosture = returnPostures[2];
                else if ([str hasPrefix:@"k"] || [str hasPrefix:@"g"]) insertPosture = returnPostures[3];
                
                break;
            }
                
            case 6:
            {
                MMPosture *replacementPosture = ([[lastPosture name] hasSuffix:@"'"]) ? [model postureWithName:@"l'"] : [model postureWithName:@"l"];
                //NSLog(@"Replace last posture (%@) with %@", [lastPosture symbol], [replacementPosture symbol]);
                [eventList replaceCurrentPhoneWith:replacementPosture];
                
                break;
            }
                
            case 8:
                //NSLog(@"vowels %@ -> %@   %d", [lastPosture symbol], [nextPosture symbol], followsWordMarker);
                if (nextPosture == lastPosture && followsWordMarker) insertPosture = returnPostures[4];
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
        
        self.lastPosture = nextPosture;
    } else {
        //NSLog(@"Returning to state 0");
        currentState = 0;
        self.lastPosture = nil;
    }
    
    if (insertPosture != nil) {
        //NSLog(@"adding posture: %@", [insertPosture symbol]);
        [eventList newPhoneWithObject:insertPosture];
    }
    
    //NSLog(@"<  %s", _cmd);
}

@end

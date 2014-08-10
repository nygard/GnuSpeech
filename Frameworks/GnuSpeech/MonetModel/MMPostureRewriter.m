//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMPostureRewriter.h"

#import "EventList.h"
#import "MModel.h"
#import "MMPosture.h"

@interface MMPostureRewriter ()

@property (strong) MMPosture *lastPosture;

@end

#pragma mark -

@implementation MMPostureRewriter
{
    MModel *_model;

    NSString *_categoryNames[15];
    MMPosture *_returnPostures[7];

    NSUInteger _currentState;
    MMPosture *_lastPosture;
}

- (id)initWithModel:(MModel *)aModel;
{
    if ((self = [super init])) {
        _model = aModel;
        _currentState = 0;
        _lastPosture = nil;

        [self _setupCategoryNames];
        [self _setup];
    }

    return self;
}

- (void)_setupCategoryNames;
{
    _categoryNames[0] = @"stopped";
    _categoryNames[1] = @"affricate";
    _categoryNames[2] = @"hlike";
    _categoryNames[3] = @"vocoid";
    _categoryNames[14] = @"whistlehack";

    _categoryNames[4] = @"h";
    _categoryNames[5] = @"h'";

    _categoryNames[6] = @"hv";
    _categoryNames[7] = @"hv'";

    _categoryNames[8] = @"ll";
    _categoryNames[9] = @"ll'";

    _categoryNames[10] = @"s";
    _categoryNames[11] = @"s'";

    _categoryNames[12] = @"z";
    _categoryNames[13] = @"z'";
}

- (void)_setup;
{
    _returnPostures[0] = [_model postureWithName:@"qc"];
    _returnPostures[1] = [_model postureWithName:@"qt"];
    _returnPostures[2] = [_model postureWithName:@"qp"];
    _returnPostures[3] = [_model postureWithName:@"qk"];
    _returnPostures[4] = [_model postureWithName:@"gs"];
    _returnPostures[5] = [_model postureWithName:@"qs"];
    _returnPostures[6] = [_model postureWithName:@"qz"];

    [self resetState];
}

- (MModel *)model;
{
    return _model;
}

- (void)setModel:(MModel *)newModel;
{
    if (newModel != _model) {
        _model = newModel;

        [self _setup];
    }
}

- (void)resetState;
{
    _currentState = 0;
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
        if ([nextPosture isMemberOfCategoryNamed:_categoryNames[index]]) {
            //NSLog(@"Found %@ %@ state %d -> %d", [nextPosture symbol], categoryNames[index], currentState, stateTable[currentState][index]);
            _currentState = stateTable[_currentState][index];
            didMakeTransition = YES;
            break;
        }
    }

    MMPosture *insertPosture = nil;
    if (didMakeTransition) {
        //NSLog(@"Made transition to state %d", currentState);
        switch (_currentState) {
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
                NSString *str = [_lastPosture name];
                //NSLog(@"state 2, 4, 11: lastPosture symbol: %@", str);
                if ([str hasPrefix:@"d"] || [str hasPrefix:@"t"])      insertPosture = _returnPostures[1];
                else if ([str hasPrefix:@"p"] || [str hasPrefix:@"b"]) insertPosture = _returnPostures[2];
                else if ([str hasPrefix:@"k"] || [str hasPrefix:@"g"]) insertPosture = _returnPostures[3];
                
                break;
            }
                
            case 6:
            {
                MMPosture *replacementPosture = ([[_lastPosture name] hasSuffix:@"'"]) ? [_model postureWithName:@"l'"] : [_model postureWithName:@"l"];
                //NSLog(@"Replace last posture (%@) with %@", [lastPosture symbol], [replacementPosture symbol]);
                [eventList replaceCurrentPhoneWith:replacementPosture];
                
                break;
            }
                
            case 8:
                //NSLog(@"vowels %@ -> %@   %d", [lastPosture symbol], [nextPosture symbol], followsWordMarker);
                if (nextPosture == _lastPosture && followsWordMarker) insertPosture = _returnPostures[4];
                break;
                
            case 10:
                insertPosture = _returnPostures[0];
                break;
                
            case 12:
                insertPosture = _returnPostures[0];
                break;
                
            case 14:
                insertPosture = _returnPostures[5];
                break;
                
            case 16:
                insertPosture = _returnPostures[6];
                break;
        }
        
        self.lastPosture = nextPosture;
    } else {
        //NSLog(@"Returning to state 0");
        _currentState = 0;
        self.lastPosture = nil;
    }
    
    if (insertPosture != nil) {
        //NSLog(@"adding posture: %@", [insertPosture symbol]);
        [eventList newPhoneWithObject:insertPosture];
    }
    
    //NSLog(@"<  %s", _cmd);
}

@end

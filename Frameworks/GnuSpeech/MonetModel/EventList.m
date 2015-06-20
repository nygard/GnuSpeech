//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "EventList.h"

#import "NSArray-Extensions.h"
#import "NSCharacterSet-Extensions.h"
#import "NSScanner-Extensions.h"
#import "NSString-Extensions.h"
#import "MMDriftGenerator.h"
#import "Event.h"
#import "MMEquation.h"
#import "MMFRuleSymbols.h"
#import "MMIntonationPoint.h"
#import "MMIntonation.h"
#import "MModel.h"
#import "MMParameter.h"
#import "MMPoint.h"
#import "MMPosture.h"
#import "MMPostureRewriter.h"
#import "MMRule.h"
#import "MMSlopeRatio.h"
#import "MMTarget.h"
#import "MMTransition.h"
#import "MMToneGroup.h"
#import "MMPhone.h"

#import "STLogger.h"

#define MAXPHONES	    1500
#define MAXFEET		    110

#define MAXRULES	    (MAXPHONES-1)

struct _foot {
    double onset1;
    double onset2;
    double tempo;
    NSUInteger startPhoneIndex; // index into phones
    NSUInteger endPhoneIndex;   // index into phones
    NSUInteger marked;
    NSUInteger last; // Is this the last foot of (the tone group?)
};

NSString *EventListDidChangeIntonationPoints = @"EventListDidChangeIntonationPoints";

@interface EventList ()
@property (assign) BOOL intonationPointsNeedSorting;
@property (nonatomic, assign) NSInteger zeroRef;

// Tone groups
@property (readonly) NSMutableArray *toneGroups;
@property (nonatomic, readonly) MMToneGroup *currentToneGroup;

@property (strong) NSString *phoneString;
@property (assign) NSUInteger duration;
@property (assign) NSUInteger timeQuantization;

@property (assign) double multiplier;

@end

#pragma mark -

@implementation EventList
{
    MModel *_model;

    NSString *_phoneString;

    NSInteger _zeroRef;
    NSInteger _zeroIndex; // Event index derived from zeroRef.

    NSUInteger _duration; // Move... somewhere else.
    NSUInteger _timeQuantization; // in msecs.  By default it generates parameters every 4 msec

//    BOOL _shouldUseMacroIntonation;
//    BOOL _shouldUseMicroIntonation;
//    BOOL _shouldUseDrift;
//    BOOL _shouldUseSmoothIntonation;
    BOOL _intonationPointsNeedSorting;

//    double _radiusMultiply; // Affects hard coded parameters, in this case r1 and r2.
    double _pitchMean;
//    double _globalTempo;
    double _multiplier; // Move... somewhere else.
    MMIntonation *_intonation;

    NSMutableArray *_phones;

    NSUInteger _footCount;
    struct _foot _feet[MAXFEET];

    NSMutableArray *_toneGroups;

    NSUInteger _currentRule;
    struct _rule _rules[MAXRULES];

    double _min[16]; // Min of each parameter value
    double _max[16]; // Max of each parameter value

    NSMutableArray *_events;
    NSMutableArray *_intonationPoints; // Sorted by absolute time

    __weak id <EventListDelegate> _delegate;
    
    // Hack for inflexible XML parsing.  I have plan to change how I parse XML.
    NSUInteger _parseState;

    MMDriftGenerator *_driftGenerator;
}

- (id)init;
{
    if ((self = [super init])) {
        _model = nil;
        _phoneString = nil;
        
        _events = [[NSMutableArray alloc] init];
        _intonationPoints = [[NSMutableArray alloc] init];
        _intonationPointsNeedSorting = NO;
        
        _intonation = [[MMIntonation alloc] init];
        
        _toneGroups = [[NSMutableArray alloc] init];
        
        _driftGenerator = [[MMDriftGenerator alloc] init];
        [_driftGenerator configureWithDeviation:1 sampleRate:500 lowpassCutoff:1000];

        _phones = [[NSMutableArray alloc] init];
        
        [self setUp];
    }
        
    return self;
}

#pragma mark -

- (MModel *)model;
{
    return _model;
}

- (void)setModel:(MModel *)newModel;
{
    if (newModel != _model) {
        // TODO (2004-08-19): Maybe it's better just to allocate a new one?  Or create it just before synthesis?
        [self setUp]; // So that we don't have stuff left over from the previous model, which can cause a crash.

        _model = newModel;
    }
}

// The zero reference is TIME.
// The zero index is the index of the last event whose time is before the zero reference.

- (NSInteger)zeroRef;
{
    return _zeroRef;
}

- (void)setZeroRef:(NSInteger)newValue;
{
    _zeroRef = newValue;
    _zeroIndex = 0;
    
    [_events enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(Event *event, NSUInteger index, BOOL *stop){
        if (event.time < newValue) {
            _zeroIndex = index;
            *stop = YES;
        }
    }];
}

#pragma mark -

- (void)setUp;
{
    [_events removeAllObjects];
    [self removeAllIntonationPoints];

    _zeroRef = 0;
    _zeroIndex = 0;
    _duration = 0;
    _timeQuantization = 4;

    _multiplier = 1.0;

    [_phones removeAllObjects];

    _footCount = 0;
    bzero(_feet, MAXFEET * sizeof(struct _foot));

    _currentRule = 0;
    bzero(_rules, MAXRULES * sizeof(struct _rule));

//    phoneTempo[0] = 1.0;
    _feet[0].tempo = 1.0;
    
    [self.toneGroups removeAllObjects];
}

- (void)setFullTimeScale;
{
    _zeroRef = 0;
    _zeroIndex = 0;
    _duration = [[_events lastObject] time] + 100;
}

#pragma mark - Rules

- (struct _rule *)getRuleAtIndex:(NSUInteger)ruleIndex;
{
    if (ruleIndex > _currentRule)
        return NULL;

    return &_rules[ruleIndex];
}

- (NSString *)ruleDescriptionAtIndex:(NSUInteger)ruleIndex;
{
    struct _rule *rule = [self getRuleAtIndex:ruleIndex];
    NSMutableString *str = [NSMutableString string];

    for (NSUInteger index = rule->firstPhone; index <= rule->lastPhone; index++) {
        [str appendString:[[self getPhoneAtIndex:index] name]];
        if (index == rule->lastPhone)
            break;
        [str appendString:@" > "];
    }

    return str;
}

- (double)getBeatAtIndex:(NSUInteger)ruleIndex;
{
    if (ruleIndex > _currentRule)
        return 0.0;

    return _rules[ruleIndex].beat;
}

- (NSUInteger)ruleCount;
{
    return _currentRule;
}

- (void)getRuleIndex:(NSUInteger *)ruleIndexPtr offsetTime:(double *)offsetTimePtr forAbsoluteTime:(double)absoluteTime;
{
    for (NSUInteger index = 0; index <= _currentRule; index++) {
        MMPhone *phone = _phones[_rules[index].firstPhone];
        double onset = phone.onset;
        if (absoluteTime >= onset && absoluteTime < onset + _rules[index].duration) {
            if (ruleIndexPtr != NULL)  *ruleIndexPtr  = index;
            if (offsetTimePtr != NULL) *offsetTimePtr = absoluteTime - _rules[index].beat;
            return;
        }
    }

    if (ruleIndexPtr != NULL)  *ruleIndexPtr = -1;
    if (offsetTimePtr != NULL) *offsetTimePtr = 0.0;
}

#pragma mark - Tone groups

- (MMToneGroup *)currentToneGroup;
{
    return [self.toneGroups lastObject];
}

// This is horribly ugly and is going to be full of bugs :(
// It would be easier if we just didn't allow the trailing // that produces an empty tone group.
- (void)endCurrentToneGroup;
{
    MMToneGroup *toneGroup = self.currentToneGroup;
    
    if (toneGroup != nil) {
        if (_footCount == 0) {
            [self.toneGroups removeLastObject]; // No feet in this tone group, so remove it.
        } else if (_feet[_footCount-1].startPhoneIndex >= [_phones count]) {
            _footCount--;                        // No posture in the foot, so remove it.
            [self.toneGroups removeLastObject]; // And remove the tone group too
        } else {
            toneGroup.endFootIndex = _footCount - 1; // TODO (2004-08-18): What if footCount == 0
            [self endCurrentFoot];
        }
    }
}

- (void)newToneGroup;
{
    [self endCurrentToneGroup];
    [self newFoot];
    
    MMToneGroup *toneGroup = [[MMToneGroup alloc] init];
    toneGroup.startFootIndex = _footCount - 1;
    toneGroup.endFootIndex = -1;
    [self.toneGroups addObject:toneGroup];
}

#pragma mark - Feet

- (void)endCurrentFoot;
{
    if (_footCount > 0)
        _feet[_footCount - 1].endPhoneIndex = [_phones count] - 1;
}

- (void)newFoot;
{
    [self endCurrentFoot];
    _feet[_footCount].startPhoneIndex = [_phones count]; // TODO (2004-08-18): And you better add that posture!
    _feet[_footCount].endPhoneIndex = -1;
    _feet[_footCount].tempo = 1.0;
    _footCount++;
}

- (void)setCurrentFootMarked;
{
    if (_footCount == 0) {
        NSLog(@"%s, footCount == 0", __PRETTY_FUNCTION__);
        return;
    }

    _feet[_footCount - 1].marked = 1;
}

- (void)setCurrentFootLast;
{
    if (_footCount == 0) {
        NSLog(@"%s, footCount == 0", __PRETTY_FUNCTION__);
        return;
    }

    _feet[_footCount - 1].last = 1;
}

- (void)setCurrentFootTempo:(double)tempo;
{
    if (_footCount == 0) {
        NSLog(@"%s, footCount == 0", __PRETTY_FUNCTION__);
        return;
    }

    _feet[_footCount - 1].tempo = tempo;
}

#pragma mark - Postures

- (MMPosture *)getPhoneAtIndex:(NSUInteger)phoneIndex;
{
    if (phoneIndex >= [_phones count])
        return nil;

    MMPhone *phone = _phones[phoneIndex];
    return phone.posture;
}

- (void)newPhoneWithObject:(MMPosture *)object;
{
    MMPhone *phone = [[MMPhone alloc] initWithPosture:object];
    [_phones addObject:phone];
}

- (void)replaceCurrentPhoneWith:(MMPosture *)object;
{
    if ([_phones count] == 0) {
        NSLog(@"%s, postureCount == 0", __PRETTY_FUNCTION__);
        return;
    }

    MMPhone *lastPhone = [_phones lastObject];

    NSLog(@"Replacing %@ with %@", [lastPhone.posture name], object.name);
    lastPhone.posture = object;
}

- (void)setCurrentPhoneTempo:(double)tempo;
{
    if ([_phones count] == 0) {
        NSLog(@"%s, postureCount == 0", __PRETTY_FUNCTION__);
        return;
    }

    MMPhone *lastPhone = [_phones lastObject];
    lastPhone.tempo = tempo;
}

- (void)setCurrentPhoneRuleTempo:(float)tempo;
{
    if ([_phones count] == 0) {
        NSLog(@"%s, postureCount == 0", __PRETTY_FUNCTION__);
        return;
    }

    MMPhone *lastPhone = [_phones lastObject];
    lastPhone.ruleTempo = tempo;
}

- (void)setCurrentPhoneSyllable;
{
    if ([_phones count] == 0) {
        NSLog(@"%s, postureCount == 0", __PRETTY_FUNCTION__);
        return;
    }

    MMPhone *lastPhone = [_phones lastObject];
    lastPhone.syllable = 1;
}

- (NSUInteger)ruleIndexForPostureAtIndex:(NSUInteger)postureIndex;
{
    for (NSUInteger index = 0; index < _currentRule; index++) {
        if ((postureIndex >= _rules[index].firstPhone) && (postureIndex <= _rules[index].lastPhone))
            return index;
    }

    return 0;
}

#pragma mark - Events

- (NSArray *)events;
{
    return _events;
}

/// Get the event a time "time".  Create and insert it into "events" array, if necessary.
/// Time is relative to zeroRef.
- (Event *)eventAtTimeOffset:(double)time;
{
    Event *newEvent = nil;

    time = time * self.multiplier;
    if (time < 0.0)
        return nil;
    if (time > (double)(_duration + _timeQuantization))
        return nil;

    NSInteger tempTime = _zeroRef + (int)time;
    tempTime = tempTime - (tempTime % _timeQuantization);

    // If there are no events yet, we can just add it.
    if ([_events count] == 0) {
        newEvent = [[Event alloc] initWithTime:tempTime];
        [_events addObject:newEvent];
        return newEvent;
    }

    // Otherwise we need to search through the events to find the correct place to insert it.
    NSInteger i;
    for (i = [_events count] - 1; i >= _zeroIndex; i--) {
        // If there is an Event at exactly this time, we can use that event.
        if ([[_events objectAtIndex:i] time] == tempTime)
            return [_events objectAtIndex:i];

        // Otherwise we'll need to create an Event at that time and insert it in the proper place.
        if ([[_events objectAtIndex:i] time] < tempTime) {
            newEvent = [[Event alloc] initWithTime:tempTime];
            [_events insertObject:newEvent atIndex:i+1];
            return newEvent;
        }
    }

    // In this case the event should come at the end of the list.
    newEvent = [[Event alloc] initWithTime:tempTime];
    [_events insertObject:newEvent atIndex:i+1];

    return newEvent;
}

// Time relative to zeroRef
- (void)insertEvent:(NSInteger)number atTimeOffset:(double)time withValue:(double)value;
{
    Event *event = [self eventAtTimeOffset:time];
    if (number >= 0) {
        // TODO (2012-04-23): This appears to be another hard-coded setting.  7 and 8 seems to be... parameters r1 and r2
        if ((number >= 7) && (number <= 8))
            [event setValue:value*self.intonation.radiusMultiply atIndex:number];
        else
            [event setValue:value atIndex:number];
    }
}

/// This represents the time exactly on a posture, not interpolated between them.
- (void)insertPostureEventAtTimeOffset:(double)time;
{
    Event *event = [self eventAtTimeOffset:time];
    event.isAtPosture = YES;
}

- (void)finalEvent:(NSUInteger)number withValue:(double)value;
{
    Event *lastEvent = [_events lastObject];
    [lastEvent setValue:value atIndex:number];
    lastEvent.isAtPosture = YES;
}

#pragma mark - Other

// EventList API used:
//  - newFoot
//  - setCurrentFooLast
//  - setCurrentFootMarked
//  - newToneGroup
//  - setCurrentFootTempo:
//  - setCurrentPhoneSyllable
//  - newPhoneWithObject:
//  - setCurrentPhoneTempo:
//  - setCurrentPhoneRuleTempo:
- (void)parsePhoneString:(NSString *)str;
{
    NSUInteger lastFoot = 0, markedFoot = 0;
    double footTempo = 1.0;
    double ruleTempo = 1.0;
    double aPhoneTempo = 1.0;
    NSCharacterSet *whitespaceCharacterSet = [NSCharacterSet phoneStringWhitespaceCharacterSet];
    NSCharacterSet *defaultCharacterSet = [NSCharacterSet phoneStringIdentifierCharacterSet];
    BOOL wordMarker = NO;

    self.phoneString = str;
    
    MMPostureRewriter *postureRewriter = [[MMPostureRewriter alloc] initWithModel:self.model];
    //[postureRewriter resetState];

    NSScanner *scanner = [[NSScanner alloc] initWithString:str];
    [scanner setCharactersToBeSkipped:nil];

    while ([scanner isAtEnd] == NO) {
        [scanner scanCharactersFromSet:whitespaceCharacterSet intoString:NULL];
        if ([scanner isAtEnd])
            break;
        
        double tempDouble;

        if ([scanner scanString:@"/" intoString:NULL])
        {
            // Handle "/" escape sequences
            if ([scanner scanString:@"0" intoString:NULL])                    // Tone group 0. Statement
            {
                //NSLog(@"Tone group 0. Statement");
                self.currentToneGroup.type = MMToneGroupType_Statement;
            }
            else if ([scanner scanString:@"1" intoString:NULL])               // Tone group 1. Exclamation
            {
                //NSLog(@"Tone group 1. Exclamation");
                self.currentToneGroup.type = MMToneGroupType_Exclamation;
            }
            else if ([scanner scanString:@"2" intoString:NULL])               // Tone group 2. Question
            {
                //NSLog(@"Tone group 2. Question");
                self.currentToneGroup.type = MMToneGroupType_Question;
            }
            else if ([scanner scanString:@"3" intoString:NULL])               // Tone group 3. Continuation
            {
                //NSLog(@"Tone group 3. Continuation");
                self.currentToneGroup.type = MMToneGroupType_Continuation;
            }
            else if ([scanner scanString:@"4" intoString:NULL])               // Tone group 4. Semi-colon
            {
                //NSLog(@"Tone group 4. Semi-colon");
                self.currentToneGroup.type = MMToneGroupType_Semicolon;
            }
            else if ([scanner scanString:@" " intoString:NULL] || [scanner scanString:@"_" intoString:NULL])   // New foot
            {
                //NSLog(@"New foot");
                [self newFoot];
                if (lastFoot)
                    [self setCurrentFootLast];
                footTempo = 1.0;
                lastFoot = 0;
                markedFoot = 0;
            }
            else if ([scanner scanString:@"*" intoString:NULL])               // New Marked foot
            {
                //NSLog(@"New Marked foot");
                [self newFoot];
                [self setCurrentFootMarked];
                if (lastFoot)
                    [self setCurrentFootLast];

                footTempo = 1.0;
                lastFoot = 0;
                markedFoot = 1;
            }
            else if ([scanner scanString:@"/" intoString:NULL])               // New Tone Group
            {
                //NSLog(@"New Tone Group");
                [self newToneGroup];
            }
            else if ([scanner scanString:@"c" intoString:NULL])               // New Chunk
            {
                //NSLog(@"New Chunk -- not sure that this is working.");
            }
            else if ([scanner scanString:@"w" intoString:NULL])               // Word Marker
            {
                wordMarker = YES;
            }
            else if ([scanner scanString:@"l" intoString:NULL])               // Last Foot in tone group marker
            {
                //NSLog(@"Last Foot in tone group");
                lastFoot = 1;
            }
            else if ([scanner scanString:@"f" intoString:NULL])               // Foot tempo indicator
            {
                //NSLog(@"Foot tempo indicator - 'f'");
                [scanner scanCharactersFromSet:whitespaceCharacterSet intoString:NULL];
                double aDouble;
                if ([scanner scanDouble:&aDouble] == YES) {
                    //NSLog(@"current foot tempo: %g", aDouble);
                    [self setCurrentFootTempo:aDouble];
                }
            }
            else if ([scanner scanString:@"r" intoString:NULL])               // Foot tempo indicator
            {
                //NSLog(@"Foot tempo indicator - 'r'");
                [scanner scanCharactersFromSet:whitespaceCharacterSet intoString:NULL];
                double aDouble;
                if ([scanner scanDouble:&aDouble] == YES) {
                    //NSLog(@"ruleTemp = %g", aDouble);
                    ruleTempo = aDouble;
                }
            }
            else
            {
                // Skip character
                [scanner scanCharacter:NULL];
            }
        }
        else if ([scanner scanString:@"." intoString:NULL])                   // Syllable Marker
        {
            //NSLog(@"Syllable Marker");
            [self setCurrentPhoneSyllable];
        }
        else if ([scanner scanDouble:&tempDouble])                               // Phone tempo
        {
            // TODO (2004-03-05): The original scanned digits and '.', and then used atof.
            //NSLog(@"aPhoneTempo = %g", aDouble);
            aPhoneTempo = tempDouble;
        }
        else {
            NSString *buffer;
            if ([scanner scanCharactersFromSet:defaultCharacterSet intoString:&buffer]) {
                //NSLog(@"Scanned this: '%@'", buffer);
                if (markedFoot)
                    buffer = [buffer stringByAppendingString:@"'"];
                MMPosture *aPhone = [_model postureWithName:buffer];
                //NSLog(@"aPhone: %p (%@), eventList: %p", aPhone, [aPhone name], self); // Each has the same event list
                if (aPhone) {
                    [postureRewriter rewriteEventList:self withNextPosture:aPhone wordMarker:wordMarker];

                    [self newPhoneWithObject:aPhone];
                    [self setCurrentPhoneTempo:aPhoneTempo];
                    [self setCurrentPhoneRuleTempo:(float)ruleTempo];
                }
                aPhoneTempo = 1.0;
                ruleTempo = 1.0;
                wordMarker = NO;
            } else {
                break;
            }
        }
    }

    [self endCurrentToneGroup];
}

// Adjust the tempos of each of the feet.  They start out at 1.0.
- (void)applyRhythm;
{
    for (NSUInteger i = 0; i < _footCount; i++) {
        double footTempo;

        // TODO (2012-04-23): What does "rus" mean?
        NSUInteger rus = _feet[i].endPhoneIndex - _feet[i].startPhoneIndex + 1;

        /* Apply rhythm model */
        if (_feet[i].marked) {
            double tempo = 117.7 - (19.36 * (double)rus);
            _feet[i].tempo -= tempo / 180.0;
            //NSLog(@"Rus = %d tempTempo = %f", rus, tempo);
            footTempo = self.intonation.tempo * _feet[i].tempo;
        } else {
            double tempo = 18.5 - (2.08 * (double)rus);
            _feet[i].tempo -= tempo / 140.0;
            //NSLog(@"Rus = %d tempTempo = %f", rus, tempTempo);
            footTempo = self.intonation.tempo * _feet[i].tempo;
        }

        // Adjust the posture tempos for postures in this foot, limiting it to a minimum of 0.2 and maximum of 2.0.
        //NSLog(@"Foot Tempo = %f", footTempo);
        for (NSUInteger j = _feet[i].startPhoneIndex; j < _feet[i].endPhoneIndex + 1; j++) {
            MMPhone *phone = _phones[j];
            double tempo = phone.tempo * footTempo;
            if (tempo < 0.2) tempo = 0.2;
            if (tempo > 2.0) tempo = 2.0;
            phone.tempo = tempo;

            //NSLog(@"PhoneTempo[%d] = %f, teed[%d].tempo = %f", j, phoneTempo[j], i, feet[i].tempo);
        }
    }

    //[self printDataStructures:@"Applied rhythm"];
}

- (void)applyRules;
{
    //[self printDataStructures:@"Start of generateEvents"];
    NSParameterAssert(_model != nil);

    // Record min/max values for each of the parameters
    {
        NSMutableArray *parameters = _model.parameters;

        //NSLog(@"parameters: %@", parameters);
        NSUInteger count = [parameters count];
        for (NSUInteger index = 0; index < count && index < 16; index++) {
            MMParameter *parameter = [parameters objectAtIndex:index];

            _min[index] = parameter.minimumValue;
            _max[index] = parameter.maximumValue;
            //NSLog(@"Min: %9.3f Max: %9.3f", min[index], max[index]);
        }
    }

    {
        NSMutableArray *tempPhones     = [[NSMutableArray alloc] init];
        NSMutableArray *tempCategoryList = [[NSMutableArray alloc] init];

        // Apply rules
        for (NSUInteger index = 0; index < [_phones count] - 1; ) {
            [tempPhones removeAllObjects];
            [tempCategoryList removeAllObjects];

            // Rules can match up to four phones.  Should be minimum of two phones.  (Hence [_phones count]-1 above.)
            for (NSUInteger rulePhoneIndex = 0; rulePhoneIndex < 4; rulePhoneIndex++) {
                NSUInteger actualIndex = index + rulePhoneIndex;
                if (actualIndex < [_phones count]) {
                    MMPhone *phone = _phones[actualIndex];
                    [tempPhones addObject:phone];
                    [tempCategoryList addObject:[phone.posture categories]];
                }
            }

            NSInteger ruleIndex;
            MMRule *matchedRule = [_model findRuleMatchingCategories:tempCategoryList ruleIndex:&ruleIndex];
            _rules[_currentRule].number = ruleIndex + 1;

            //NSLog(@"----------------------------------------------------------------------");
            //NSLog(@"Applying rule %d", ruleIndex + 1);
            [self _applyRule:matchedRule withPhones:tempPhones phoneIndex:index];

            index += [matchedRule numberExpressions] - 1;
        }
    }


//    if (currentPhone)
//        [self generateIntonationPoints];

    Event *lastEvent = [_events lastObject];
    lastEvent.isAtPosture = YES;

    [self printDataStructures:@"Applied rules"];

    //NSLog(@"%s, EventList count: %d", _cmd, [events count]);
}

// Use a 0.0 offset time for the first intonation point in each tone group, -40.0 for the rest.
- (void)generateIntonationPoints;
{
    double offsetTime = 0.0;

    _zeroRef = 0;
    _zeroIndex = 0;
    _duration = [[_events lastObject] time] + 100;

    [self removeAllIntonationPoints];
//    [self addIntonationPoint:-20.0 offsetTime:0.0 slope:0.0 ruleIndex:0];

    for (MMToneGroup *toneGroup in self.toneGroups) {
        NSUInteger firstFoot = toneGroup.startFootIndex;
        NSUInteger endFoot   = toneGroup.endFootIndex;

        MMPhone *startPhone = _phones[_feet[firstFoot].startPhoneIndex];
        MMPhone *endPhone   = _phones[_feet[endFoot].endPhoneIndex];

        double startTime = startPhone.onset;
        double endTime   = endPhone.onset;

        double pretonicDelta = (_intonation.pretonicRange) / (endTime - startTime);
        //NSLog(@"Pretonic Delta = %f time = %f", pretonicDelta, (endTime - startTime));

        /* Set up intonation boundary variables */
        for (NSUInteger j = firstFoot; j <= endFoot; j++) {
            NSUInteger phoneIndex = _feet[j].startPhoneIndex;
            while ([((MMPhone *)_phones[phoneIndex]).posture isMemberOfCategoryNamed:@"vocoid"] == NO) { // TODO (2004-08-16): Hardcoded category
                phoneIndex++;
                //NSLog(@"Checking phone %@ for vocoid", [phones[phoneIndex].phone name]);
                if (phoneIndex > _feet[j].endPhoneIndex) {
                    phoneIndex = _feet[j].startPhoneIndex;
                    break;
                }
            }

            if (!_feet[j].marked) {
                NSUInteger ruleIndex = [self ruleIndexForPostureAtIndex:phoneIndex];

                // randomSemitone is in range of +/- 1/2 of pretonicLift
                double randomSemitone = ((double)random() / (double)0x7fffffff) * (double)_intonation.pretonicLift - _intonation.pretonicLift / 2.0;
                // Slopes from 0.02 to 0.035
                double randomSlope = ((double)random() / (double)0x7fffffff) * 0.015 + 0.02;

                MMIntonationPoint *newIntonationPoint = [[MMIntonationPoint alloc] init];
                // TODO (2004-08-19): But this will generate extra change notifications.  Try setting the event list for the intonation point in -addIntonationPoint:.
                MMPhone *phone = _phones[phoneIndex];
                [newIntonationPoint setSemitone:((phone.onset-startTime) * pretonicDelta) + _intonation.notionalPitch + randomSemitone];
                [newIntonationPoint setOffsetTime:offsetTime];
                [newIntonationPoint setSlope:randomSlope];
                [newIntonationPoint setRuleIndex:ruleIndex];
                [self addIntonationPoint:newIntonationPoint];

//                NSLog(@"Calculated Delta = %f  time = %f", ((phones[phoneIndex].onset-startTime)*pretonicDelta),
//                       (phones[phoneIndex].onset-startTime));
            } else { /* Tonic */
                NSUInteger ruleIndex = [self ruleIndexForPostureAtIndex:phoneIndex];

                // Slopes from 0.02 to 0.05
                double randomSlope = ((double)random() / (double)0x7fffffff) * 0.03 + 0.02;

                MMIntonationPoint *newIntonationPoint = [[MMIntonationPoint alloc] init];
                [newIntonationPoint setSemitone:_intonation.pretonicRange + _intonation.notionalPitch];
                [newIntonationPoint setOffsetTime:offsetTime];
                [newIntonationPoint setSlope:randomSlope];
                [newIntonationPoint setRuleIndex:ruleIndex];
                [self addIntonationPoint:newIntonationPoint];

                phoneIndex = _feet[j].endPhoneIndex;
                ruleIndex = [self ruleIndexForPostureAtIndex:phoneIndex];

                newIntonationPoint = [[MMIntonationPoint alloc] init];
                [newIntonationPoint setSemitone:_intonation.pretonicRange + _intonation.notionalPitch + _intonation.tonicRange];
                [newIntonationPoint setOffsetTime:0.0];
                [newIntonationPoint setSlope:0.0];
                [newIntonationPoint setRuleIndex:ruleIndex];
                [self addIntonationPoint:newIntonationPoint];
            }

            offsetTime = -40.0;
        }
    }

    //[self printDataStructures:@"After applyIntonation generateEvents"];
}

// TODO (2012-04-24): Split out file output and delegate notification
- (void)generateOutput;
{
    //NSLog(@"%s, self: %@", _cmd, self);

    [self.delegate eventListWillGenerateOutput:self];
    
    if ([_events count] == 0)
        return;

    double controlRate = 250.0;
    double millisecondsPerInterval = 1000.0 / controlRate;
    NSParameterAssert(millisecondsPerInterval == 4.0);

    NSUInteger currentTime_ms = 0;
    
    
    // So it looks like this... uses the first value as the current value (makes sense), and then looks for the _next_ available value (skipping NaN) to calculate the deltas
    double currentValues[36];
    double currentDeltas[36];
    double temp;
    for (NSUInteger i = 0; i < 16; i++) {
        NSUInteger j = 1;
        while ( ( temp = [[_events objectAtIndex:j] getValueAtIndex:i]) == NaN)
            j++;

        currentValues[i] = [[_events objectAtIndex:0] getValueAtIndex:i];
        currentDeltas[i] = ((temp - currentValues[i]) / (double) ([[_events objectAtIndex:j] time])) * millisecondsPerInterval;
    }

    // Not sure what the next 16+4 values are
    for (NSUInteger i = 16; i < 36; i++)
        currentValues[i] = currentDeltas[i] = 0.0;

    if (self.intonation.shouldUseSmoothIntonation) {
        // Find the first value for "32", and use that as the current value[32], no delta
        NSUInteger j = 0;
        while ( (temp = [[_events objectAtIndex:j] getValueAtIndex:32]) == NaN) {
            j++;
            if (j >= [_events count])
                break;
        }

        currentValues[32] = [[_events objectAtIndex:j] getValueAtIndex:32];
        currentDeltas[32] = 0.0;
        //NSLog(@"Smooth intonation: %f %f j = %d", currentValues[32], currentDeltas[32], j);
    } else {
        // Find the first value for "32" (skipping the very first value).  Use the very first entry as the current value, and calculate delta from the other one
        NSUInteger j = 1;
        while ( (temp = [[_events objectAtIndex:j] getValueAtIndex:32]) == NaN) {
            j++;
            if (j >= [_events count])
                break;
        }

        currentValues[32] = [[_events objectAtIndex:0] getValueAtIndex:32];
        if (j < [_events count])
            currentDeltas[32] = ((temp - currentValues[32]) / (double) ([[_events objectAtIndex:j] time])) * millisecondsPerInterval;
        else
            currentDeltas[32] = 0;
    }

//    NSLog(@"Starting Values:");
//    for (i = 0; i < 32; i++)
//        NSLog(@"%d;  cv: %f  cd: %f", i, currentValues[i], currentDeltas[i]);

    NSUInteger i = 1;
    currentTime_ms = 0;
    NSUInteger nextTime = [[_events objectAtIndex:1] time];
    float table[16];

    while (i < [_events count]) {
        for (NSUInteger j = 0; j < 16; j++) {
            table[j] = (float)currentValues[j] + (float)currentValues[j+16];
        }
        if (!self.intonation.shouldUseMicroIntonation)
            table[0] = 0.0;
        if (self.intonation.shouldUseDrift)
            table[0] += self.driftGenerator.generateDrift;
        if (self.intonation.shouldUseMacroIntonation) {
            //NSLog(@"sumi, table[0]: %f, currentValues[32]: %f", table[0], currentValues[32]);
            table[0] += currentValues[32];
        }

        table[0] += self.pitchMean;

        [self.delegate eventList:self generatedOutputValues:table valueCount:16];

        for (NSUInteger j = 0; j < 32; j++) {
            if (currentDeltas[j]) // TODO (2012-04-23): Just add unconditionally
                currentValues[j] += currentDeltas[j];
        }
        if (self.intonation.shouldUseSmoothIntonation) {
            currentDeltas[34] += currentDeltas[35];
            currentDeltas[33] += currentDeltas[34];
            currentValues[32] += currentDeltas[33];
        } else {
            if (currentDeltas[32]) // TODO (2012-04-23): Just add unconditionally
                currentValues[32] += currentDeltas[32];
        }
        currentTime_ms += millisecondsPerInterval; // TODO (2012-04-23): 4 milliseconds?  Hardcoded?

        if (currentTime_ms >= nextTime) {
            i++;
            if (i == [_events count])
                break;

            nextTime = [[_events objectAtIndex:i] time];
            for (NSUInteger j = 0; j < 33; j++) {
                if ([[_events objectAtIndex:i-1] getValueAtIndex:j] != NaN) {
                    NSUInteger k = i;
                    while ((temp = [[_events objectAtIndex:k] getValueAtIndex:j]) == NaN) {
                        if (k >= [_events count] - 1) {
                            currentDeltas[j] = 0.0;
                            break;
                        }
                        k++;
                    }

                    if (temp != NaN) {
                        currentDeltas[j] = (temp - currentValues[j]) /
                            (double) ([[_events objectAtIndex:k] time] - currentTime_ms) * millisecondsPerInterval;
                    }
                }
            }
            if (self.intonation.shouldUseSmoothIntonation) {
                if ([[_events objectAtIndex:i-1] getValueAtIndex:33] != NaN) {
                    currentDeltas[32] = 0.0;
                    currentDeltas[33] = [[_events objectAtIndex:i-1] getValueAtIndex:33];
                    currentDeltas[34] = [[_events objectAtIndex:i-1] getValueAtIndex:34];
                    currentDeltas[35] = [[_events objectAtIndex:i-1] getValueAtIndex:35];
                }
            }
        }
    }

    // TODO (2004-03-25): There used to be some silence padding here.

    [self writeXMLToFile:@"/tmp/contour.xml" comment:nil];
}

// 1. Calculate the rule symbols (Rule Duration, Beat, Mark 1, Mark 2, Mark 3), given tempos and phones.
// 2.
// TODO: (2014-08-09) How is phoneIndex used?
- (void)_applyRule:(MMRule *)rule withPhones:(NSArray *)somePhones phoneIndex:(NSUInteger)phoneIndex;
{
    NSUInteger cache = [_model nextCacheTag];

    MMFRuleSymbols *ruleSymbols = [[MMFRuleSymbols alloc] init];
    [rule evaluateSymbolEquationsWithPhonesInArray:somePhones ruleSymbols:ruleSymbols withCacheTag:cache];

#if 0
    NSLog(@"Rule symbols, duration: %.2f, beat: %.2f, mark1: %.2f, mark2: %.2f, mark3: %.2f",
          ruleSymbols.ruleDuration, ruleSymbols.beat, ruleSymbols.mark1, ruleSymbols.mark2, ruleSymbols.mark3);
#endif

    // TODO (2004-08-14): Is this supposed to change the multiplier?  I suppose so, since setMultiplier: is never used.
    //NSLog(@"multiplier before: %f", multiplier);
    MMPhone *phone = _phones[phoneIndex];
    self.multiplier = 1.0 / (double)(phone.ruleTempo);
    //NSLog(@"multiplier after: %f", multiplier);

    NSUInteger type = [rule numberExpressions];
    [self setDuration:(int)(ruleSymbols.ruleDuration * self.multiplier)];

    _rules[_currentRule].firstPhone = phoneIndex;
    _rules[_currentRule].lastPhone  = phoneIndex + (type - 1);
    _rules[_currentRule].beat       = (ruleSymbols.beat * self.multiplier) + (double)_zeroRef;
    _rules[_currentRule++].duration = ruleSymbols.ruleDuration * self.multiplier;

    // This creates events (if necessary) at the posture times, and sets the "flag" on them to indicate this is for a posture.
    switch (type) {
            // Note: Tetraphone case should execute all of the below, Triphone case the last two.
        case MMPhoneType_Tetraphone: {
            MMPhone *phonePlus3 = _phones[phoneIndex+3];
            phonePlus3.onset = (double)_zeroRef + ruleSymbols.beat;
            [self insertPostureEventAtTimeOffset:ruleSymbols.mark2];
            // Fall through
        }
        case MMPhoneType_Triphone: {
            MMPhone *phonePlus2 = _phones[phoneIndex+2];
            phonePlus2.onset = (double)_zeroRef + ruleSymbols.beat;
            [self insertPostureEventAtTimeOffset:ruleSymbols.mark1];
            // Fall through
        }
        case MMPhoneType_Diphone: {
            MMPhone *phonePlus1 = _phones[phoneIndex+1];
            phonePlus1.onset = (double)_zeroRef + ruleSymbols.beat;
            [self insertPostureEventAtTimeOffset:0.0];
        }
            break;
    }

    NSArray *parameterTransitions = [rule parameterTransitions];

    /* Loop through the parameters */
    for (NSUInteger transitionIndex = 0; transitionIndex < [parameterTransitions count]; transitionIndex++) {
        NSUInteger index;

        double targets[4];
        /* Get actual parameter target values */
        NSUInteger count = [somePhones count];
        for (index = 0; index < 4 && index < count; index++) {
            MMPhone *phone = somePhones[index];
            targets[index] = [(MMTarget *)[[phone.posture parameterTargets] objectAtIndex:transitionIndex] value];
        }
        for (; index < 4; index++)
            targets[index] = 0.0;

        //NSLog(@"Targets %f %f %f %f", targets[0], targets[1], targets[2], targets[3]);

        // Optimization: Don't calculate if no changes occur.
        BOOL shouldCalculate = YES;
        switch (type) {
            case MMPhoneType_Diphone:
                if (targets[0] == targets[1])
                    shouldCalculate = NO;
                break;
            case MMPhoneType_Triphone:
                if ((targets[0] == targets[1]) && (targets[0] == targets[2]))
                    shouldCalculate = NO;
                break;
            case MMPhoneType_Tetraphone:
                if ((targets[0] == targets[1]) && (targets[0] == targets[2]) && (targets[0] == targets[3]))
                    shouldCalculate = NO;
                break;
        }

        if (shouldCalculate) {
            NSUInteger currentType = MMPhoneType_Diphone;
            double currentDelta = targets[1] - targets[0];

            MMTransition *transition = [parameterTransitions objectAtIndex:transitionIndex];
            double maxValue = 0.0;
            NSArray *points = [transition points];
            NSUInteger pointCount = [points count];

            /* Apply lists to parameter */
            for (NSUInteger pointIndex = 0; pointIndex < pointCount; pointIndex++) {
                MMPoint *currentPoint = [points objectAtIndex:pointIndex];

                if ([currentPoint isKindOfClass:[MMSlopeRatio class]]) {
                    if ([(MMPoint *)[[(MMSlopeRatio *)currentPoint points] objectAtIndex:0] type] != currentType) {
                        currentType = [(MMPoint *)[[(MMSlopeRatio *)currentPoint points] objectAtIndex:0] type];
                        targets[currentType - MMPhoneType_Diphone] = maxValue;
                        currentDelta = targets[currentType-1] - maxValue;
                    }
                } else {
                    if ([currentPoint type] != currentType) {
                        currentType = [currentPoint type];
                        targets[currentType - MMPhoneType_Diphone] = maxValue;
                        currentDelta = targets[currentType-1] - maxValue;
                    }

                    /* insert event into event list */
                    //tempEvent = [self insertEvent:i atTimeOffset:tempTime withValue:value];
                }
                // TODO (2004-03-01): I don't see how this works...
                maxValue = [currentPoint calculatePointsWithPhonesInArray:somePhones ruleSymbols:ruleSymbols andCacheWithTag:cache
                                                                 baseline:targets[currentType-2] delta:currentDelta min:_min[transitionIndex] max:_max[transitionIndex]
                                                        andAddToEventList:self atIndex:transitionIndex];
            }
        } else {
            // TODO (2004-08-15): This doesn't look right -- the time shouldn't be 0.
            [self insertEvent:transitionIndex atTimeOffset:0.0 withValue:targets[0]];
        }
    }

    /* Special Event Profiles */
    // TODO (2004-08-15): Does this support slope ratios?
    for (NSUInteger parameterIndex = 0; parameterIndex < 16; parameterIndex++) {
        MMTransition *transition = [rule getSpecialProfile:parameterIndex];
        if (transition != nil) {
            NSArray *points = [transition points];
            NSUInteger pointCount = [points count];

            for (NSUInteger pointIndex = 0; pointIndex < pointCount; pointIndex++) {
                MMPoint *currentPoint = [points objectAtIndex:pointIndex];

                double tempTime;
                /* calculate time of event */
                if ([currentPoint timeEquation] == nil)
                    tempTime = [currentPoint freeTime];
                else {
                    MMEquation *equation = [currentPoint timeEquation];
                    tempTime = [equation evaluateWithPhonesInArray:somePhones ruleSymbols:ruleSymbols andCacheWithTag:cache];
                }

                /* Calculate value of event */
                //value = (([currentPoint value]/100.0) * (max[parameterIndex] - min[parameterIndex])) + min[parameterIndex];
                double value = (([currentPoint value] / 100.0) * (_max[parameterIndex] - _min[parameterIndex]));
                //maxValue = value;

                /* insert event into event list */
                [self insertEvent:parameterIndex+16 atTimeOffset:tempTime withValue:value];
            }
        }
    }

    [self setZeroRef:(int)(ruleSymbols.ruleDuration * self.multiplier) + _zeroRef];
    [self insertPostureEventAtTimeOffset:0.0];

    [self.delegate eventListDidGenerateOutput:self];
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: postureCount: %lu, footCount: %lu, toneGroupCount: %lu, currentRule: %lu, + a bunch of other stuff, super: %@",
                     NSStringFromClass([self class]), self, [_phones count], _footCount, [self.toneGroups count], _currentRule, [super description]];
}

- (void)printDataStructures:(NSString *)comment;
{
    __block NSUInteger ruleIndex = 0;
    
    STLogger *logger = [[STLogger alloc] init];

    [logger log:@"----------------------------------------------------------------------"];

    //NSLog(@"toneGroupCount: %d", toneGroupCount);
    [self.toneGroups enumerateObjectsUsingBlock:^(MMToneGroup *toneGroup, NSUInteger toneGroupIndex, BOOL *stop1){
        [logger log:@"Tone Group %lu, type: %@", toneGroupIndex, MMToneGroupTypeName(toneGroup.type)];

        //NSLog(@"tg (%d -- %d)", toneGroups[toneGroupIndex].startFoot, toneGroups[toneGroupIndex].endFoot);
        for (NSUInteger footIndex = toneGroup.startFootIndex; footIndex <= toneGroup.endFootIndex; footIndex++) {
            [logger log:@"  Foot %lu  tempo: %.3f, marked: %lu, last: %lu, onset1: %.3f, onset2: %.3f  (%ld -- %ld)", footIndex, _feet[footIndex].tempo,
             _feet[footIndex].marked, _feet[footIndex].last, _feet[footIndex].onset1, _feet[footIndex].onset2, _feet[footIndex].startPhoneIndex, _feet[footIndex].endPhoneIndex];

            //NSLog(@"Foot (%d -- %d)", feet[footIndex].start, feet[footIndex].end);
            for (NSUInteger postureIndex = _feet[footIndex].startPhoneIndex; postureIndex <= _feet[footIndex].endPhoneIndex; postureIndex++) {
                MMPhone *phone = _phones[postureIndex];
                if (_rules[ruleIndex].firstPhone == postureIndex) {
                    [logger log:@"    Posture %2lu  tempo: %.3f, syllable: %lu, onset: %7.2f, ruleTempo: %.3f, %@ # Rule %2lu, duration: %7.2f, beat: %7.2f",
                     postureIndex, phone.tempo, phone.syllable, phone.onset,
                     phone.ruleTempo, [[phone.posture name] leftJustifiedStringPaddedToLength:18],
                     _rules[ruleIndex].number, _rules[ruleIndex].duration, _rules[ruleIndex].beat];
                    ruleIndex++;
                } else {
                    [logger log:@"    Posture %2lu  tempo: %.3f, syllable: %lu, onset: %7.2f, ruleTempo: %.3f, %@",
                     postureIndex, phone.tempo, phone.syllable, phone.onset,
                     phone.ruleTempo, [phone.posture name]];
                }
            }
        }
    }];

    NSLog(@"<  %s", __PRETTY_FUNCTION__);
}

#pragma mark - Intonation points

- (NSArray *)intonationPoints;
{
    if (self.intonationPointsNeedSorting) {
        [_intonationPoints sortUsingSelector:@selector(compareByAscendingAbsoluteTime:)];
        self.intonationPointsNeedSorting = NO;
    }

    return _intonationPoints;
}

- (void)addIntonationPoint:(MMIntonationPoint *)intonationPoint;
{
    [_intonationPoints addObject:intonationPoint];
    [intonationPoint setEventList:self];
    self.intonationPointsNeedSorting = YES;

    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:NSKeyValueChangeInsertion], NSKeyValueChangeKindKey, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:EventListDidChangeIntonationPoints object:self userInfo:userInfo];
}

- (void)removeIntonationPoint:(MMIntonationPoint *)intonationPoint;
{
    [intonationPoint setEventList:nil];
    [_intonationPoints removeObject:intonationPoint];

    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:NSKeyValueChangeRemoval], NSKeyValueChangeKindKey, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:EventListDidChangeIntonationPoints object:self userInfo:userInfo];
}

- (void)removeIntonationPointsFromArray:(NSArray *)array;
{
    for (MMIntonationPoint *intonationPoint in array) {
        intonationPoint.eventList = nil;
        [_intonationPoints removeObject:intonationPoint];
    }

    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:NSKeyValueChangeRemoval], NSKeyValueChangeKindKey, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:EventListDidChangeIntonationPoints object:self userInfo:userInfo];
}

- (void)removeAllIntonationPoints;
{
    for (MMIntonationPoint *intonationPoint in _intonationPoints) {
        intonationPoint.eventList = nil;
    }
    [_intonationPoints removeAllObjects];

    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:NSKeyValueChangeRemoval], NSKeyValueChangeKindKey, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:EventListDidChangeIntonationPoints object:self userInfo:userInfo];
}

#pragma mark - Intonation

- (void)applyIntonation;
{
    if (self.intonation.shouldUseSmoothIntonation)
        [self _applySmoothIntonation];
    else
        [self _applyFlatIntonation];
}

// This just add values for the semitone (event 32) for each of the intonation points, clearing the slope, 3rd, and 4th derivatives.
// Values with a semitone of -20 are added at the start and end (but their slopes, etc., aren't reset to 0.).
- (void)_applyFlatIntonation;
{
    NSLog(@" > %s", __PRETTY_FUNCTION__);

    [self setFullTimeScale];
    [self insertEvent:32 atTimeOffset:0.0 withValue:-20.0];

    NSUInteger count = [[self intonationPoints] count]; // This makes sure they get sorted
    NSLog(@"Applying intonation, %lu points", count);

    for (NSUInteger index = 0; index < count; index++) {
        MMIntonationPoint *intonationPoint = [_intonationPoints objectAtIndex:index];
        NSLog(@"Added Event at Time: %f withValue: %f", intonationPoint.absoluteTime, intonationPoint.semitone);
        [self insertEvent:32 atTimeOffset:intonationPoint.absoluteTime withValue:intonationPoint.semitone];
        [self insertEvent:33 atTimeOffset:intonationPoint.absoluteTime withValue:0.0];
        [self insertEvent:34 atTimeOffset:intonationPoint.absoluteTime withValue:0.0];
        [self insertEvent:35 atTimeOffset:intonationPoint.absoluteTime withValue:0.0];
    }

    [self finalEvent:32 withValue:-20.0];

    NSLog(@"<  %s", __PRETTY_FUNCTION__);
}

- (void)_applySmoothIntonation;
{
    //NSLog(@" > %s", _cmd);

    [self setFullTimeScale];

    if ([_intonationPoints count] == 0)
        return;

    MMIntonationPoint *firstIntonationPoint = [[MMIntonationPoint alloc] init];
    [firstIntonationPoint setSemitone:[[[self intonationPoints] objectAtIndex:0] semitone]]; // Make sure it's sorted
    [firstIntonationPoint setSlope:0.0];
    [firstIntonationPoint setRuleIndex:0];
    [firstIntonationPoint setOffsetTime:0];
    [self addIntonationPoint:firstIntonationPoint];

    NSUInteger count = [[self intonationPoints] count]; // Again, make sure it gets sorted since we just added a point.

    //[self insertEvent:32 atTimeOffset:0.0 withValue:-20.0];
    for (NSUInteger index = 0; index < count - 1; index++) {
        MMIntonationPoint *point1 = [_intonationPoints objectAtIndex:index];
        MMIntonationPoint *point2 = [_intonationPoints objectAtIndex:index + 1];

        double x1 = [point1 absoluteTime] / 4.0;
        double y1 = [point1 semitone] + 20.0;
        double m1 = [point1 slope];

        double x2 = [point2 absoluteTime] / 4.0;
        double y2 = [point2 semitone] + 20.0;
        double m2 = [point2 slope];

        double x1_2 = x1*x1;
        double x1_3 = x1_2*x1;

        double x2_2 = x2*x2;
        double x2_3 = x2_2*x2;

        double denominator = (x2 - x1);
        denominator = denominator * denominator * denominator;

        //double d = ( -(y2*x1_3) + 3*y2*x1_2*x2 + m2*x1_3*x2 + m1*x1_2*x2_2 - m2*x1_2*x2_2 - 3*x1*y1*x2_2 - m1*x1*x2_3 + y1*x2_3) / denominator;
        double c = ( -(m2*x1_3) - 6*y2*x1*x2 - 2*m1*x1_2*x2 - m2*x1_2*x2 + 6*x1*y1*x2 + m1*x1*x2_2 + 2*m2*x1*x2_2 + m1*x2_3) / denominator;
        double b = ( 3*y2*x1 + m1*x1_2 + 2*m2*x1_2 - 3*x1*y1 + 3*x2*y2 + m1*x1*x2 - m2*x1*x2 - 3*y1*x2 - 2*m1*x2_2 - m2*x2_2) / denominator;
        double a = ( -2*y2 - m1*x1 - m2*x1 + 2*y1 + m1*x2 + m2*x2) / denominator;

        [self insertEvent:32 atTimeOffset:[point1 absoluteTime] withValue:[point1 semitone]];

        double yTemp = (3.0 * a * x1_2) + (2.0 * b * x1) + c;
        //NSLog(@"time: %.2f", [point1 absoluteTime]);
        //NSLog(@"index: %d, inserting event 33: %7.3f", index, yTemp);
        [self insertEvent:33 atTimeOffset:[point1 absoluteTime] withValue:yTemp];

        yTemp = (6.0 * a * x1) + (2.0 * b);
        //NSLog(@"index: %d, inserting event 34: %7.3f", index, yTemp);
        [self insertEvent:34 atTimeOffset:[point1 absoluteTime] withValue:yTemp];

        yTemp = 6.0 * a;
        //NSLog(@"index: %d, inserting event 35: %7.3f", index, yTemp);
        [self insertEvent:35 atTimeOffset:[point1 absoluteTime] withValue:yTemp];
    }

    [self removeIntonationPoint:firstIntonationPoint];

    //NSLog(@"<  %s", _cmd);
}

// So that we can reapply the current intonation to the events.
- (void)clearIntonationEvents;
{
    for (Event *event in _events) {
        [event setValue:NaN atIndex:32];
        [event setValue:NaN atIndex:33];
        [event setValue:NaN atIndex:34];
        [event setValue:NaN atIndex:35];
    }
}

- (void)intonationPointTimeDidChange:(MMIntonationPoint *)intonationPoint;
{
    self.intonationPointsNeedSorting = YES;
    [self intonationPointDidChange:intonationPoint];
}

- (void)intonationPointDidChange:(MMIntonationPoint *)intonationPoint;
{
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:NSKeyValueChangeSetting], NSKeyValueChangeKindKey, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:EventListDidChangeIntonationPoints object:self userInfo:userInfo];
}

#pragma mark - Other

#pragma mark - Archiving - XML

- (BOOL)writeXMLToFile:(NSString *)filename comment:(NSString *)comment;
{
    NSMutableString *resultString = [[NSMutableString alloc] init];
    [resultString appendString:@"<?xml version='1.0' encoding='utf-8'?>\n"];
    //[resultString appendString:@"<!DOCTYPE root PUBLIC \"\" \"monet-v1.dtd\">\n"];
    if (comment != nil)
        [resultString appendFormat:@"<!-- %@ -->\n", comment];
    [resultString appendString:@"<intonation-contour version='1'>\n"];

    [resultString indentToLevel:1];
    [resultString appendFormat:@"<utterance>%@</utterance>\n", GSXMLCharacterData(_phoneString)];

    [[self intonationPoints] appendXMLToString:resultString elementName:@"intonation-points" level:1]; // Make sure they are sorted.

    [resultString appendString:@"</intonation-contour>\n"];

    BOOL result = [[resultString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:filename atomically:YES];

    return result;
}

- (BOOL)loadIntonationContourFromXMLFile:(NSString *)filename;
{
    NSURL *fileURL = [NSURL fileURLWithPath:filename];
    NSError *xmlError;
    NSXMLDocument *xmlDocument = [[NSXMLDocument alloc] initWithContentsOfURL:fileURL options:0 error:&xmlError];
    if (xmlDocument == nil) {
        NSLog(@"%s, error loading xml doc: %@", __PRETTY_FUNCTION__, xmlError);
        // TODO: (2014-08-09) Set error.
        return NO;
    }

    if (![@"intonation-contour" isEqualToString:[[xmlDocument rootElement] name]]) {
        NSLog(@"Error: Not an intonation contour.");
        return NO;
    }

    NSString *str = [[[[xmlDocument rootElement] elementsForName:@"utterance"] firstObject] stringValue];
    [self loadStoredPhoneString:str];

    NSXMLElement *element = [[[xmlDocument rootElement] elementsForName:@"intonation-points"] firstObject];
    for (NSXMLElement *childElement in [element elementsForName:@"intonation-point"]) {
        MMIntonationPoint *intonationPoint = [[MMIntonationPoint alloc] initWithXMLElement:childElement error:NULL];
        if (intonationPoint != nil)
            [self addIntonationPoint:intonationPoint];
    }

    return YES;
}

- (void)loadStoredPhoneString:(NSString *)str;
{
    [self parsePhoneString:str];
    [self applyRhythm];
    [self applyRules];
}

@end

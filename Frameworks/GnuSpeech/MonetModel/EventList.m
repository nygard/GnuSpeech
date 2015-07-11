//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "EventList.h"

#import <Tube/Tube.h>
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
#import "MMIntonationParameters.h"
#import "MModel.h"
#import "MMParameter.h"
#import "MMPoint.h"
#import "MMPosture.h"
#import "MMPostureRewriter.h"
#import "MMRule.h"
#import "MMAppliedRule.h"
#import "MMSlopeRatio.h"
#import "MMTarget.h"
#import "MMTransition.h"
#import "MMToneGroup.h"
#import "MMPhone.h"
#import "MMSynthesisParameters.h"
#import "TRMSynthesizer.h"
#import "MMFoot.h"

#import "STLogger.h"

NSString *EventListDidChangeIntonationPoints = @"EventListDidChangeIntonationPoints";
NSString *EventListDidGenerateIntonationPoints = @"EventListDidGenerateIntonationPoints";

NSString *EventListNotification_DidGenerateOutput = @"EventListNotification_DidGenerateOutput";

@interface EventList ()
@property (assign) BOOL intonationPointsNeedSorting;
@property (nonatomic, assign) NSInteger zeroRef;

@property (readonly) NSMutableArray *toneGroups;
@property (readonly) NSMutableArray *feet;
@property (readonly) NSMutableArray *phones;
@property (readonly) NSMutableArray *mutableEvents;

/// This is stored when -parsePhoneString: is called, so that it can be saved with the intonation contour.
@property (strong) NSString *phoneString;

@property (assign) NSUInteger duration;
@property (assign) NSUInteger timeQuantization;

@property (assign) double multiplier;

@end

#pragma mark -

@implementation EventList
{
    MModel *_model; // Property is nonatomic, so not synthesized.

    NSInteger _zeroRef;
    NSInteger _zeroIndex; // Event index derived from zeroRef.

    NSUInteger _duration; // Move... somewhere else.
    NSUInteger _timeQuantization; // in msecs.  By default it generates parameters every 4 msec

    double _multiplier; // Move... somewhere else.

    NSMutableArray *_intonationPoints; // Sorted by absolute time
    BOOL _intonationPointsNeedSorting;

    // The only place this is used is in -generateOutput.  The only reason for keeping this here is so that the memory doesn't get reset each time.
    MMDriftGenerator *_driftGenerator;
}

- (id)init;
{
    if ((self = [super init])) {
        _model = nil;
        _phoneString = nil;

        _zeroRef   = 0;
        _zeroIndex = 0;
        _duration  = 0;
        _timeQuantization = 4;

        _multiplier = 1.0;

        _intonation = [[MMIntonation alloc] init];

        _phones        = [[NSMutableArray alloc] init];
        _feet          = [[NSMutableArray alloc] init];
        _toneGroups    = [[NSMutableArray alloc] init];
        _appliedRules  = [[NSMutableArray alloc] init];
        _mutableEvents = [[NSMutableArray alloc] init];

        _intonationPoints = [[NSMutableArray alloc] init];
        _intonationPointsNeedSorting = NO;

        _driftGenerator = [[MMDriftGenerator alloc] init];
        [_driftGenerator configureWithDeviation:1 sampleRate:(1000 / _timeQuantization) lowpassCutoff:1000];
    }
        
    return self;
}

#pragma mark -

- (void)setModel:(MModel *)newModel;
{
    if (newModel != _model) {
        // TODO (2004-08-19): Maybe it's better just to allocate a new one?  Or create it just before synthesis?
        [self resetWithIntonation:self.intonation]; // So that we don't have stuff left over from the previous model, which can cause a crash.

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
    
    [_mutableEvents enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(Event *event, NSUInteger index, BOOL *stop){
        if (event.time < newValue) {
            _zeroIndex = index;
            *stop = YES;
        }
    }];
}

#pragma mark -

- (void)resetWithIntonation:(MMIntonation *)intonation phoneString:(NSString *)phoneString;
{
    [self resetWithIntonation:intonation];

    [self parsePhoneString:phoneString]; // This creates the tone groups, feet.
    [self applyRhythm];
    [self applyRules]; // This applies the rules, adding events to the EventList.
    [self generateIntonationPoints];
}

- (void)resetWithIntonation:(MMIntonation *)intonation;
{
    // _model remains the same

    _phoneString = nil;

    _zeroRef = 0;
    _zeroIndex = 0;
    _duration = 0;
    _timeQuantization = 4;

    _multiplier = 1.0;

    // _intonation is unchanged

    [self.phones        removeAllObjects];
    [self.feet          removeAllObjects];
    [self.toneGroups    removeAllObjects];
    [self.appliedRules  removeAllObjects];
    [self.mutableEvents removeAllObjects];

    [self removeAllIntonationPoints];

    // _delegate remains unchanged
    // _driftGenerator remains unchanged

    self.intonation = intonation;
}

- (void)setFullTimeScale;
{
    _zeroRef = 0;
    _zeroIndex = 0;
    _duration = [[_mutableEvents lastObject] time] + 100;
}

#pragma mark - Rules

- (void)getRuleIndex:(NSUInteger *)ruleIndexPtr offsetTime:(double *)offsetTimePtr forAbsoluteTime:(double)absoluteTime;
{
    NSUInteger count = [self.appliedRules count];
    for (NSUInteger index = 0; index < count; index++) {
        MMAppliedRule *appliedRule = self.appliedRules[index];
        MMPhone *phone = self.phones[appliedRule.firstPhone];
        double onset = phone.onset;
        if (absoluteTime >= onset && absoluteTime < onset + appliedRule.duration) {
            if (ruleIndexPtr != NULL)  *ruleIndexPtr  = index;
            if (offsetTimePtr != NULL) *offsetTimePtr = absoluteTime - appliedRule.beat;
            return;
        }
    }

    if (ruleIndexPtr != NULL)  *ruleIndexPtr = -1;
    if (offsetTimePtr != NULL) *offsetTimePtr = 0.0;
}

#pragma mark - Feet

- (void)endCurrentFoot;
{
    if ([self.feet count] > 0) {
        MMFoot *foot = [self.feet lastObject];
        foot.endPhoneIndex = [self.phones count] - 1;
    }
}

- (void)newFoot;
{
    [self endCurrentFoot];

    MMFoot *foot = [[MMFoot alloc] init];
    foot.startPhoneIndex = [self.phones count]; // TODO (2004-08-18): And you better add that posture!
    foot.endPhoneIndex = -1;
    foot.tempo = 1.0;
    [self.feet addObject:foot];
}

- (void)setCurrentFootTempo:(double)tempo;
{
    if ([self.feet count] == 0) {
        NSLog(@"%s, footCount == 0", __PRETTY_FUNCTION__);
        return;
    }

    MMFoot *foot = [self.feet lastObject];
    foot.tempo = tempo;
}

#pragma mark - Postures

- (MMPosture *)getPhoneAtIndex:(NSUInteger)phoneIndex;
{
    if (phoneIndex >= [self.phones count])
        return nil;

    MMPhone *phone = self.phones[phoneIndex];
    return phone.posture;
}

- (void)newPhoneWithObject:(MMPosture *)object;
{
    MMPhone *phone = [[MMPhone alloc] initWithPosture:object];
    [self.phones addObject:phone];
}

- (void)replaceCurrentPhoneWith:(MMPosture *)object;
{
    if ([self.phones count] == 0) {
        NSLog(@"%s, postureCount == 0", __PRETTY_FUNCTION__);
        return;
    }

    MMPhone *lastPhone = [self.phones lastObject];

    NSLog(@"Replacing %@ with %@", [lastPhone.posture name], object.name);
    lastPhone.posture = object;
}

- (void)setCurrentPhoneTempo:(double)tempo;
{
    if ([self.phones count] == 0) {
        NSLog(@"%s, postureCount == 0", __PRETTY_FUNCTION__);
        return;
    }

    MMPhone *lastPhone = [self.phones lastObject];
    lastPhone.tempo = tempo;
}

- (void)setCurrentPhoneRuleTempo:(float)tempo;
{
    if ([self.phones count] == 0) {
        NSLog(@"%s, postureCount == 0", __PRETTY_FUNCTION__);
        return;
    }

    MMPhone *lastPhone = [self.phones lastObject];
    lastPhone.ruleTempo = tempo;
}

- (void)setCurrentPhoneSyllable;
{
    if ([self.phones count] == 0) {
        NSLog(@"%s, postureCount == 0", __PRETTY_FUNCTION__);
        return;
    }

    MMPhone *lastPhone = [self.phones lastObject];
    lastPhone.syllable = 1;
}

- (NSUInteger)ruleIndexForPostureAtIndex:(NSUInteger)postureIndex;
{
    NSUInteger count = [self.appliedRules count];
    for (NSUInteger index = 0; index < count; index++) {
        MMAppliedRule *appliedRule = self.appliedRules[index];
        if ((postureIndex >= appliedRule.firstPhone) && (postureIndex <= appliedRule.lastPhone))
            return index;
    }

    return 0;
}

#pragma mark - Events

- (NSArray *)events;
{
    return [_mutableEvents copy];
}

/// Get the event at time "time".  Create and insert it into "events" array, if necessary.
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
    if ([_mutableEvents count] == 0) {
        newEvent = [[Event alloc] initWithTime:tempTime];
        [_mutableEvents addObject:newEvent];
        return newEvent;
    }

    // Otherwise we need to search through the events to find the correct place to insert it.
    NSInteger i;
    for (i = [_mutableEvents count] - 1; i >= _zeroIndex; i--) {
        // If there is an Event at exactly this time, we can use that event.
        if ([_mutableEvents[i] time] == tempTime)
            return _mutableEvents[i];

        // Otherwise we'll need to create an Event at that time and insert it in the proper place.
        if ([_mutableEvents[i] time] < tempTime) {
            newEvent = [[Event alloc] initWithTime:tempTime];
            [_mutableEvents insertObject:newEvent atIndex:i+1];
            return newEvent;
        }
    }

    // In this case the event should come at the end of the list.
    newEvent = [[Event alloc] initWithTime:tempTime];
    [_mutableEvents insertObject:newEvent atIndex:i+1];

    return newEvent;
}

/// Return the interpolated value at the given time, or an exact value if it lies on an event.
- (double)valueAtTimeOffset:(double)time forEvent:(NSInteger)number;
{
    //NSLog(@"%s, time: %f, event number: %ld", __PRETTY_FUNCTION__, time, number);
    if (time < 0)
        return NAN; // From math.h

    // Not the most efficient, creating an array, but easiest to understand.

    NSMutableArray *a1 = [[NSMutableArray alloc] init];

    for (Event *event in self.events) {
        double value = [event getValueAtIndex:number];
        if (!isnan(value)) {
            [a1 addObject:event];
        }
    }
    // a1 now contains all Events that have a value for the even number we're interested in.
    Event *previous;
    for (Event *event in a1) {
        if (time > event.time) {
            previous = event;
        } else if (time == event.time) {
            return [event getValueAtIndex:number];
        } else {
            double value         = [event getValueAtIndex:number];
            double previousValue = [previous getValueAtIndex:number];
            double interpolated = previousValue + (value - previousValue) * (time - previous.time) / (event.time - previous.time);
            //NSLog(@"previous: %lu - %f, this: %lu - %f, interpolated: %lu - %f", previous.time, previousValue, event.time, value, (unsigned long)time, interpolated);
            return interpolated;
        }
    }

    return NAN; // From math.h
}

// Time relative to zeroRef
- (void)insertEvent:(NSInteger)number atTimeOffset:(double)time withValue:(double)value;
{
    Event *event = [self eventAtTimeOffset:time];
    if (number >= 0) {
        [event setValue:value atIndex:number];
    }
}

/// This represents the time exactly on a posture, not interpolated between them.
- (void)insertEventAtTimeOffset:(double)time posture:(MMPosture *)posture;
{
    Event *event = [self eventAtTimeOffset:time];
    event.isAtPosture = YES;
    event.posture = posture;
}

- (void)finalEvent:(NSUInteger)number withValue:(double)value posture:(MMPosture *)posture;
{
    Event *lastEvent = [_mutableEvents lastObject];
    [lastEvent setValue:value atIndex:number];
    lastEvent.isAtPosture = YES;
    lastEvent.posture = posture;
}

#pragma mark - Tone groups

// This is horribly ugly and is going to be full of bugs :(
// It would be easier if we just didn't allow the trailing // that produces an empty tone group.
- (void)endCurrentToneGroup;
{
    MMToneGroup *currentToneGroup = [self.toneGroups lastObject];
    if (currentToneGroup != nil) {
        if ([self.feet count] == 0) {
            [self.toneGroups removeLastObject]; // No feet in this tone group, so remove it.
        } else {
            MMFoot *foot = [self.feet lastObject];
            if (foot.startPhoneIndex >= [self.phones count]) {
                [self.feet removeObject:foot]; // No posture in the foot, so remove it.
                [self.toneGroups removeLastObject]; // And remove the tone group too
            } else {
                NSParameterAssert([self.feet count] > 0);
                currentToneGroup.endFootIndex = [self.feet count] - 1; // TODO (2004-08-18): What if footCount == 0
                [self endCurrentFoot];
            }
        }
    }
}

#pragma mark - Other

- (void)parsePhoneString:(NSString *)str;
{
    NSCharacterSet *whitespaceCharacterSet = [NSCharacterSet phoneStringWhitespaceCharacterSet];
    NSCharacterSet *defaultCharacterSet    = [NSCharacterSet phoneStringIdentifierCharacterSet];

    BOOL markedFoot   = NO;
    BOOL lastFoot     = NO;
    double ruleTempo  = 1.0;
    double phoneTempo = 1.0;
    BOOL wordMarker   = NO;

    self.phoneString = str;
    
    MMPostureRewriter *postureRewriter = [[MMPostureRewriter alloc] initWithModel:self.model];
    //[postureRewriter resetState];

    NSScanner *scanner = [[NSScanner alloc] initWithString:str];
    scanner.charactersToBeSkipped = nil;

    MMToneGroup *currentToneGroup = [self.toneGroups lastObject];

    while ([scanner isAtEnd] == NO) {
        [scanner scanCharactersFromSet:whitespaceCharacterSet intoString:NULL];
        if (scanner.isAtEnd)
            break;
        
        double tempDouble;

        if ([scanner scanString:@"/" intoString:NULL])
        {
            // Handle "/" escape sequences
            if ([scanner scanString:@"0" intoString:NULL])                    // Tone group 0. Statement
            {
                //NSLog(@"Tone group 0. Statement");
                currentToneGroup.type = MMToneGroupType_Statement;
            }
            else if ([scanner scanString:@"1" intoString:NULL])               // Tone group 1. Exclamation
            {
                //NSLog(@"Tone group 1. Exclamation");
                currentToneGroup.type = MMToneGroupType_Exclamation;
            }
            else if ([scanner scanString:@"2" intoString:NULL])               // Tone group 2. Question
            {
                //NSLog(@"Tone group 2. Question");
                currentToneGroup.type = MMToneGroupType_Question;
            }
            else if ([scanner scanString:@"3" intoString:NULL])               // Tone group 3. Continuation
            {
                //NSLog(@"Tone group 3. Continuation");
                currentToneGroup.type = MMToneGroupType_Continuation;
            }
            else if ([scanner scanString:@"4" intoString:NULL])               // Tone group 4. Semi-colon
            {
                //NSLog(@"Tone group 4. Semi-colon");
                currentToneGroup.type = MMToneGroupType_Semicolon;
            }
            else if ([scanner scanString:@" " intoString:NULL] || [scanner scanString:@"_" intoString:NULL])   // New foot
            {
                //NSLog(@"New foot");
                [self newFoot];
                if (lastFoot) {
                    MMFoot *foot = [self.feet lastObject];
                    foot.isLast = YES;
                }
                lastFoot   = NO;
                markedFoot = NO;
            }
            else if ([scanner scanString:@"*" intoString:NULL])               // New Marked foot
            {
                //NSLog(@"New Marked foot");
                [self newFoot];
                MMFoot *foot = [self.feet lastObject];
                foot.isTonic = YES;
                if (lastFoot) {
                    foot.isLast = YES;
                }

                lastFoot   = NO;
                markedFoot = YES;
            }
            else if ([scanner scanString:@"/" intoString:NULL])               // New Tone Group
            {
                //NSLog(@"New Tone Group");
                [self endCurrentToneGroup];

                {
                    [self newFoot];

                    MMToneGroup *toneGroup = [[MMToneGroup alloc] init];
                    NSParameterAssert([self.feet count] > 0);
                    toneGroup.startFootIndex = [self.feet count] - 1;
                    toneGroup.endFootIndex = -1;
                    [self.toneGroups addObject:toneGroup];
                    currentToneGroup = toneGroup;
                }
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
                lastFoot = YES;
            }
            else if ([scanner scanString:@"f" intoString:NULL])               // Foot tempo indicator
            {
                //NSLog(@"Foot tempo indicator - 'f'");
                [scanner scanCharactersFromSet:whitespaceCharacterSet intoString:NULL];
                double value;
                if ([scanner scanDouble:&value]) {
                    //NSLog(@"current foot tempo: %g", value);
                    [self setCurrentFootTempo:value];
                }
            }
            else if ([scanner scanString:@"r" intoString:NULL])               // Foot tempo indicator
            {
                //NSLog(@"Foot tempo indicator - 'r'");
                [scanner scanCharactersFromSet:whitespaceCharacterSet intoString:NULL];
                double value;
                if ([scanner scanDouble:&value]) {
                    //NSLog(@"ruleTemp = %g", value);
                    ruleTempo = value;
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
            phoneTempo = tempDouble;
        }
        else {
            NSString *buffer;
            if ([scanner scanCharactersFromSet:defaultCharacterSet intoString:&buffer]) {
                //NSLog(@"Scanned this: '%@'", buffer);
                if (markedFoot)
                    buffer = [buffer stringByAppendingString:@"'"];
                MMPosture *phone = [_model postureWithName:buffer];
                //NSLog(@"aPhone: %p (%@), eventList: %p", aPhone, [aPhone name], self); // Each has the same event list
                if (phone) {
                    [postureRewriter rewriteEventList:self withNextPosture:phone wordMarker:wordMarker];

                    [self newPhoneWithObject:phone];
                    [self setCurrentPhoneTempo:phoneTempo];
                    [self setCurrentPhoneRuleTempo:(float)ruleTempo];
                }
                phoneTempo = 1.0;
                ruleTempo  = 1.0;
                wordMarker = NO;
            } else {
                break;
            }
        }
    }

    [self endCurrentToneGroup];
}

// Adjust the tempos of each of the feet.  They start out at 1.0.
// Calculate Rhythm including regression.
- (void)applyRhythm;
{
    for (NSUInteger i = 0; i < [self.feet count]; i++) {
        MMFoot *foot = self.feet[i];
        double footTempo;

        // 2015-07-09: I think "rus" stands for Rhythm Units.
        NSUInteger rus = foot.endPhoneIndex - foot.startPhoneIndex + 1;

        /* Apply rhythm model */
        if (foot.isTonic) {
            double tempo = 117.7 - (19.36 * (double)rus);
            foot.tempo -= tempo / 180.0;
            //NSLog(@"Rus = %d tempTempo = %f", rus, tempo);
            footTempo = self.intonation.tempo * foot.tempo;
        } else {
            double tempo = 18.5 - (2.08 * (double)rus);
            foot.tempo -= tempo / 140.0;
            //NSLog(@"Rus = %d tempTempo = %f", rus, tempTempo);
            footTempo = self.intonation.tempo * foot.tempo;
        }

        // Adjust the posture tempos for postures in this foot, limiting it to a minimum of 0.2 and maximum of 2.0.
        //NSLog(@"Foot Tempo = %f", footTempo);
        for (NSUInteger j = foot.startPhoneIndex; j < foot.endPhoneIndex + 1; j++) {
            MMPhone *phone = self.phones[j];
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

    if ([self.phones count] > 0) {
        // Apply rules
        for (NSUInteger index = 0; index < [self.phones count] - 1; ) { // TODO: (2015-07-09) And if there are no phones?
            NSMutableArray *tempPhones       = [[NSMutableArray alloc] init];
            NSMutableArray *tempCategoryList = [[NSMutableArray alloc] init];

            // Rules can match up to four phones.  Should be minimum of two phones.  (Hence [self.phones count]-1 above.)
            for (NSUInteger rulePhoneIndex = 0; rulePhoneIndex < 4; rulePhoneIndex++) {
                NSUInteger actualIndex = index + rulePhoneIndex;
                if (actualIndex < [self.phones count]) {
                    MMPhone *phone = self.phones[actualIndex];
                    [tempPhones addObject:phone];
                    [tempCategoryList addObject:phone.posture.categories];
                }
            }

            NSInteger ruleIndex;
            MMRule *matchedRule = [_model findRuleMatchingCategories:tempCategoryList ruleIndex:&ruleIndex];
            MMAppliedRule *appliedRule = [[MMAppliedRule alloc] init];
            appliedRule.number = ruleIndex + 1;
            [self.appliedRules addObject:appliedRule];

            //NSLog(@"----------------------------------------------------------------------");
            //NSLog(@"Applying rule %d", ruleIndex + 1);
            [self _applyRule:matchedRule values:appliedRule withPhones:tempPhones phoneIndex:index];

            NSMutableArray *a1 = [[NSMutableArray alloc] init];
            for (NSUInteger index = appliedRule.firstPhone; index <= appliedRule.lastPhone; index++) {
                [a1 addObject:[[self getPhoneAtIndex:index] name]];
            }
            appliedRule.matchedPhonesDescription = [a1 componentsJoinedByString:@" > "];

            index += [matchedRule expressionCount] - 1;
        }

        // 2015-07-09: There are a couple places where I'm not sure of the correct posture.  So, for now, just set all the postures after the rules have been applied.
        {
            NSUInteger postureIndex = 0;
            for (Event *event in self.events) {
                if (event.isAtPosture) {
                    if (postureIndex < [self.phones count]) {
                        MMPhone *phone = self.phones[postureIndex];
                        event.posture = phone.posture;
                        postureIndex++;
                    } else {
                        break;
                    }
                }
            }
        }
    }

    [self printDataStructures:@"Applied rules"];

    //NSLog(@"%s, EventList count: %d", _cmd, [events count]);
}

// Use a 0.0 offset time for the first intonation point in each tone group, -40.0 for the rest.
// Seems based on the first part of Monet.realtime applyIntonation.
- (void)generateIntonationPoints;
{
    double offsetTime = 0.0;

    _zeroRef = 0;
    _zeroIndex = 0;
    _duration = [[_mutableEvents lastObject] time] + 100;

    [self removeAllIntonationPoints];
//    [self addIntonationPoint:-20.0 offsetTime:0.0 slope:0.0 ruleIndex:0];

    MMIntonationParameters *intonationParameters;

    for (MMToneGroup *toneGroup in self.toneGroups) {
        NSUInteger firstFootIndex = toneGroup.startFootIndex;
        NSUInteger endFootIndex   = toneGroup.endFootIndex;

        MMFoot *firstFoot = self.feet[firstFootIndex];
        MMFoot *endFoot   = self.feet[endFootIndex];

        MMPhone *startPhone = self.phones[firstFoot.startPhoneIndex];
        MMPhone *endPhone   = self.phones[endFoot.endPhoneIndex];

        double startTime = startPhone.onset;
        double endTime   = endPhone.onset;

        // Missing stuff here.
        {
            toneGroup.intonationParameters = [self.intonation intonationParametersForToneGroup:toneGroup];
            intonationParameters = toneGroup.intonationParameters;
        }

        // TODO: (2015-07-07) Pretty sure this should be intonationParameters.pretonicPitchRange instead.
//        double pretonicDelta = (intonationParameters.notionalPitch) / (endTime - startTime); // TODO: This doesn't look right to me...
        double pretonicDelta = (intonationParameters.pretonicPitchRange) / (endTime - startTime);
        //NSLog(@"Pretonic Delta = %f time = %f", pretonicDelta, (endTime - startTime));

        /* Set up intonation boundary variables */
        for (NSUInteger j = firstFootIndex; j <= endFootIndex; j++) {
            MMFoot *foot = self.feet[j];
            NSUInteger phoneIndex = foot.startPhoneIndex;
            while ([((MMPhone *)self.phones[phoneIndex]).posture isMemberOfCategoryNamed:@"vocoid"] == NO) { // TODO (2004-08-16): Hardcoded category
                phoneIndex++;
                //NSLog(@"Checking phone %@ for vocoid", [phones[phoneIndex].phone name]);
                if (phoneIndex > foot.endPhoneIndex) {
                    phoneIndex = foot.startPhoneIndex;
                    break;
                }
            }

            if (!foot.isTonic) { // Pretonic
                NSUInteger ruleIndex = [self ruleIndexForPostureAtIndex:phoneIndex];

                double randomSemitone;
                double randomSlope;

                if (self.intonation.shouldRandomizeIntonation) {
                    // randomSemitone is in range of +/- 1/2 of pretonicRange
                    // Monet was param[2], Monet.realtime was param[3].  Which should it be?
                    randomSemitone = ((double)random() / RAND_MAX) * (double)intonationParameters.pretonicPerturbationRange - intonationParameters.pretonicPerturbationRange / 2.0;

                    // Slopes from 0.01 to 0.025
                    randomSlope = ((double)random() / RAND_MAX) * 0.015 + 0.01;
                } else {
                    randomSemitone = 0;
                    randomSlope = 0.02;
                }


                MMIntonationPoint *newIntonationPoint = [[MMIntonationPoint alloc] init];
                // TODO (2004-08-19): But this will generate extra change notifications.  Try setting the event list for the intonation point in -addIntonationPoint:.
                MMPhone *phone = self.phones[phoneIndex];
                newIntonationPoint.semitone   = ((phone.onset-startTime) * pretonicDelta) + intonationParameters.notionalPitch + randomSemitone;
                newIntonationPoint.offsetTime = offsetTime;
                newIntonationPoint.slope      = randomSlope;
                newIntonationPoint.ruleIndex  = ruleIndex;
                [self addIntonationPoint:newIntonationPoint];

//                NSLog(@"Calculated Delta = %f  time = %f", ((phones[phoneIndex].onset-startTime)*pretonicDelta),
//                       (phones[phoneIndex].onset-startTime));
            } else { // Tonic
                double randomSemitone;
                double randomSlope = (toneGroup.type = MMToneGroupType_Continuation) ? 0.01 : 0.02;

                NSUInteger ruleIndex = [self ruleIndexForPostureAtIndex:phoneIndex];
                if (self.intonation.shouldRandomizeIntonation) {
                    randomSemitone  = ((double)random() / RAND_MAX) * (double)intonationParameters.tonicPerturbationRange - intonationParameters.tonicPerturbationRange / 2.0;
                    randomSlope    += ((double)random() / RAND_MAX) * 0.03;
                } else {
                    randomSemitone = 0;
                    randomSlope += 0.03;
                }

                MMIntonationPoint *newIntonationPoint = [[MMIntonationPoint alloc] init];
                newIntonationPoint.semitone   = intonationParameters.pretonicPitchRange + intonationParameters.notionalPitch + randomSemitone;
                newIntonationPoint.offsetTime = offsetTime;
                newIntonationPoint.slope      = randomSlope;
                newIntonationPoint.ruleIndex  = ruleIndex;
                [self addIntonationPoint:newIntonationPoint];

                phoneIndex = foot.endPhoneIndex;
                ruleIndex = [self ruleIndexForPostureAtIndex:phoneIndex];

                newIntonationPoint = [[MMIntonationPoint alloc] init];
                newIntonationPoint.semitone   = intonationParameters.pretonicPitchRange + intonationParameters.notionalPitch + intonationParameters.tonicPitchRange;
                newIntonationPoint.offsetTime = 0.0;
                newIntonationPoint.slope      = 0.0;
                newIntonationPoint.ruleIndex  = ruleIndex;
                [self addIntonationPoint:newIntonationPoint];
            }

            offsetTime = -40.0;
        }
    }
#if 0
    // 2015-07-09: Adding this intonation point causes the synthesizer to crash.  Somehow the glottalPitch is becoming NaN.
    MMIntonationPoint *newIntonationPoint = [[MMIntonationPoint alloc] init];
    newIntonationPoint.semitone   = intonationParameters.pretonicPitchRange + intonationParameters.notionalPitch + intonationParameters.tonicPitchRange;
    newIntonationPoint.offsetTime = 0.0;
    newIntonationPoint.slope      = 0.0;
    newIntonationPoint.ruleIndex  = _currentRule - 1;
    [self addIntonationPoint:newIntonationPoint];
#endif

    //[self printDataStructures:@"After applyIntonation generateEvents"];

    // One final notification after all the changes are complete is more convenient.
    [[NSNotificationCenter defaultCenter] postNotificationName:EventListDidGenerateIntonationPoints object:self userInfo:nil];
}

- (void)generateOutputInTimeRange:(NSRange)timeRange forSynthesizer:(TRMSynthesizer *)synthesizer saveParametersToFilename:(NSString *)filename;
{
    STLogger *parameterLogger = [[STLogger alloc] initWithOutputToPath:filename error:NULL];
    [self.model.synthesisParameters logToLogger:parameterLogger];

    [self generateOutputInTimeRange:timeRange forSynthesizer:synthesizer parameterLogger:parameterLogger];
}

- (void)generateOutputForSynthesizer:(TRMSynthesizer *)synthesizer;
{
    [self generateOutputInTimeRange:NSMakeRange(0, NSUIntegerMax) forSynthesizer:synthesizer];
}

- (void)generateOutputInTimeRange:(NSRange)timeRange forSynthesizer:(TRMSynthesizer *)synthesizer;
{
    [self generateOutputInTimeRange:timeRange forSynthesizer:synthesizer parameterLogger:nil];
}

- (void)generateOutputInTimeRange:(NSRange)timeRange forSynthesizer:(TRMSynthesizer *)synthesizer parameterLogger:(STLogger *)parameterLogger;
{
    //NSLog(@"%s, self: %@", _cmd, self);

    NSParameterAssert(_model != nil);
    
    if ([_mutableEvents count] == 0)
        return;

    if (timeRange.length == 0) {
        timeRange = NSMakeRange(0, NSUIntegerMax);
    }

    NSLog(@"%s, timeRange: %@", __PRETTY_FUNCTION__, NSStringFromRange(timeRange));
    NSUInteger startTime_ms = timeRange.location;
    NSUInteger endTime_ms   = NSMaxRange(timeRange);
    NSLog(@"start time (ms) - end time (ms): %lu - %lu", startTime_ms, endTime_ms);

    if (self.intonation.shouldUseDrift) {
        NSLog(@"%s, drift deviation: %f, cutoff: %f", __PRETTY_FUNCTION__, self.intonation.driftDeviation, self.intonation.driftCutoff);
        [self.driftGenerator configureWithDeviation:self.intonation.driftDeviation sampleRate:(1000 / _timeQuantization) lowpassCutoff:self.intonation.driftCutoff];
        //[self.driftGenerator setupWithDeviation:0.5 sampleRate:250 lowpassCutoff:0.5];
    }

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
        while ( isnan( temp = [_mutableEvents[j] getValueAtIndex:i]) )
            j++;

        currentValues[i] = [_mutableEvents[0] getValueAtIndex:i];
        currentDeltas[i] = ((temp - currentValues[i]) / (double) ([_mutableEvents[j] time])) * millisecondsPerInterval;
    }

    // Not sure what the next 16+4 values are
    for (NSUInteger i = 16; i < 36; i++)
        currentValues[i] = currentDeltas[i] = 0.0;

    if (self.intonation.shouldUseSmoothIntonation) {
        // Find the first value for "32", and use that as the current value[32], no delta
        NSUInteger j = 0;
        while ( isnan(temp = [_mutableEvents[j] getValueAtIndex:32]) ) {
            j++;
            if (j >= [_mutableEvents count])
                break;
        }

        currentValues[32] = [_mutableEvents[j] getValueAtIndex:32];
        currentDeltas[32] = 0.0;
        //NSLog(@"Smooth intonation: %f %f j = %d", currentValues[32], currentDeltas[32], j);
    } else {
        // Find the first value for "32" (skipping the very first value).  Use the very first entry as the current value, and calculate delta from the other one
        NSUInteger j = 1;
        while ( isnan(temp = [_mutableEvents[j] getValueAtIndex:32]) ) {
            j++;
            if (j >= [_mutableEvents count])
                break;
        }

        currentValues[32] = [_mutableEvents[0] getValueAtIndex:32];
        if (j < [_mutableEvents count])
            currentDeltas[32] = ((temp - currentValues[32]) / (double) ([_mutableEvents[j] time])) * millisecondsPerInterval;
        else
            currentDeltas[32] = 0;

        currentValues[32] = -20.0;
    }

//    NSLog(@"Starting Values:");
//    for (i = 0; i < 32; i++)
//        NSLog(@"%d;  cv: %f  cd: %f", i, currentValues[i], currentDeltas[i]);

    NSUInteger i = 1;
    currentTime_ms = 0;
    NSUInteger nextTime = [_mutableEvents[1] time];
    float table[16];

    while (i < [_mutableEvents count]) {
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

        table[0] += self.model.synthesisParameters.pitch;

        if (currentTime_ms >= startTime_ms && currentTime_ms <= endTime_ms) {
            TRMParameters *outputValues = [[TRMParameters alloc] init];
            outputValues.glottalPitch             = table[0];
            outputValues.glottalVolume            = table[1];
            outputValues.aspirationVolume         = table[2];
            outputValues.fricationVolume          = table[3];
            outputValues.fricationPosition        = table[4];
            outputValues.fricationCenterFrequency = table[5];
            outputValues.fricationBandwidth       = table[6];
            outputValues.radius[0]                = table[7];
            outputValues.radius[1]                = table[8];
            outputValues.radius[2]                = table[9];
            outputValues.radius[3]                = table[10];
            outputValues.radius[4]                = table[11];
            outputValues.radius[5]                = table[12];
            outputValues.radius[6]                = table[13];
            outputValues.radius[7]                = table[14];
            outputValues.velum                    = table[15];

            [synthesizer addParameters:outputValues];
            [parameterLogger log:@"%@", outputValues.valuesString];
        }

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
            if (i == [_mutableEvents count])
                break;

            nextTime = [_mutableEvents[i] time];
            for (NSUInteger j = 0; j < 33; j++) {
                if (!isnan([_mutableEvents[i-1] getValueAtIndex:j])) {
                    NSUInteger k = i;
                    while ( isnan(temp = [_mutableEvents[k] getValueAtIndex:j]) ) {
                        if (k >= [_mutableEvents count] - 1) {
                            currentDeltas[j] = 0.0;
                            break;
                        }
                        k++;
                    }

                    if (!isnan(temp)) {
                        currentDeltas[j] = (temp - currentValues[j]) /
                            (double) ([_mutableEvents[k] time] - currentTime_ms) * millisecondsPerInterval;
                    }
                }
            }
            if (self.intonation.shouldUseSmoothIntonation) {
                if (!isnan([_mutableEvents[i-1] getValueAtIndex:33])) {
                    currentValues[32] = [_mutableEvents[i-1] getValueAtIndex:32];
                    currentDeltas[32] = 0.0;
                    currentDeltas[33] = [_mutableEvents[i-1] getValueAtIndex:33];
                    currentDeltas[34] = [_mutableEvents[i-1] getValueAtIndex:34];
                    currentDeltas[35] = [_mutableEvents[i-1] getValueAtIndex:35];
                }
            }
        }
    }

    // Use a notification so that multiple objects can be notified.  Also, this happens at a different time to the current delegate method.
    [[NSNotificationCenter defaultCenter] postNotificationName:EventListNotification_DidGenerateOutput object:self userInfo:nil];

    // TODO (2004-03-25): There used to be some silence padding here.
}

// 1. Calculate the rule symbols (Rule Duration, Beat, Mark 1, Mark 2, Mark 3), given tempos and phones.
// 2.
// TODO: (2014-08-09) How is phoneIndex used?
- (void)_applyRule:(MMRule *)rule values:(MMAppliedRule *)ruleValues withPhones:(NSArray *)somePhones phoneIndex:(NSUInteger)phoneIndex;
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
    MMPhone *phone = self.phones[phoneIndex];
    self.multiplier = 1.0 / (double)(phone.ruleTempo);
    //NSLog(@"multiplier after: %f", multiplier);

    NSUInteger type = [rule expressionCount];
    [self setDuration:(int)(ruleSymbols.ruleDuration * self.multiplier)];

    ruleValues.firstPhone = phoneIndex;
    ruleValues.lastPhone  = phoneIndex + (type - 1);
    ruleValues.beat       = (ruleSymbols.beat * self.multiplier) + (double)_zeroRef;
    ruleValues.duration   = ruleSymbols.ruleDuration * self.multiplier;

    // This creates events (if necessary) at the posture times, and sets the "flag" on them to indicate this is for a posture.
    switch (type) {
            // Note: Tetraphone case should execute all of the below, Triphone case the last two.
        case MMPhoneType_Tetraphone:
        {
            MMPhone *phonePlus3 = self.phones[phoneIndex+3];
            MMPhone *phonePlus2 = self.phones[phoneIndex+2];
            MMPhone *phonePlus1 = self.phones[phoneIndex+1];

            phonePlus3.onset = (double)_zeroRef + ruleSymbols.beat;
            [self insertEventAtTimeOffset:ruleSymbols.mark2 posture:phonePlus2.posture];

            phonePlus2.onset = (double)_zeroRef + ruleSymbols.beat;
            [self insertEventAtTimeOffset:ruleSymbols.mark1 posture:phonePlus1.posture];

            phonePlus1.onset = (double)_zeroRef + ruleSymbols.beat;
            [self insertEventAtTimeOffset:0.0 posture:phone.posture];
            break;
        }
        case MMPhoneType_Triphone:
        {
            MMPhone *phonePlus2 = self.phones[phoneIndex+2];
            MMPhone *phonePlus1 = self.phones[phoneIndex+1];

            phonePlus2.onset = (double)_zeroRef + ruleSymbols.beat;
            [self insertEventAtTimeOffset:ruleSymbols.mark1 posture:phonePlus1.posture];

            phonePlus1.onset = (double)_zeroRef + ruleSymbols.beat;
            [self insertEventAtTimeOffset:0.0 posture:phone.posture];
            break;
        }
        case MMPhoneType_Diphone:
        {
            MMPhone *phonePlus1 = self.phones[phoneIndex+1];
            phonePlus1.onset = (double)_zeroRef + ruleSymbols.beat;
            [self insertEventAtTimeOffset:0.0 posture:phone.posture];
            break;
        }
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
            targets[index] = [(MMTarget *)phone.posture.parameterTargets[transitionIndex] value];
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

            MMTransition *transition = parameterTransitions[transitionIndex];
            double maxValue = 0.0;

            /* Apply lists to parameter */
            for (MMPoint *currentPoint in transition.points) {
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
                                                                 baseline:targets[currentType-2] delta:currentDelta parameter:_model.parameters[transitionIndex]
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
        MMParameter *parameter = _model.parameters[parameterIndex];
        if (transition != nil) {
            for (MMPoint *currentPoint in transition.points) {
                double tempTime;
                /* calculate time of event */
                if (currentPoint.timeEquation == nil)
                    tempTime = currentPoint.freeTime;
                else {
                    MMEquation *equation = currentPoint.timeEquation;
                    tempTime = [equation evaluateWithPhonesInArray:somePhones ruleSymbols:ruleSymbols andCacheWithTag:cache];
                }

                /* Calculate value of event */
                //value = (([currentPoint value]/100.0) * (max[parameterIndex] - min[parameterIndex])) + min[parameterIndex];
                double value = ((currentPoint.value / 100.0) * (parameter.maximumValue - parameter.minimumValue));
                //maxValue = value;

                /* insert event into event list */
                [self insertEvent:parameterIndex+16 atTimeOffset:tempTime withValue:value];
            }
        }
    }

    [self setZeroRef:(int)(ruleSymbols.ruleDuration * self.multiplier) + _zeroRef];
    [self insertEventAtTimeOffset:0.0 posture:nil]; // TODO: (2015-07-09) What posture is it?
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: postureCount: %lu, footCount: %lu, toneGroupCount: %lu, ruleValues count: %lu, + a bunch of other stuff, super: %@",
                     NSStringFromClass([self class]), self, [self.phones count], [self.feet count], [self.toneGroups count], [self.appliedRules count], [super description]];
}

- (void)printDataStructures:(NSString *)comment;
{
    __block NSUInteger ruleIndex = 0;
    
    STLogger *logger = [[STLogger alloc] init];

    [logger log:@"----------------------------------------------------------------------"];

    //NSLog(@"toneGroupCount: %d", toneGroupCount);
    [self.toneGroups enumerateObjectsUsingBlock:^(MMToneGroup *toneGroup, NSUInteger toneGroupIndex, BOOL *stop1){
        [logger log:@"toneGroup[%lu], type: %@", toneGroupIndex, MMToneGroupTypeName(toneGroup.type)];

        //NSLog(@"tg (%d -- %d)", toneGroups[toneGroupIndex].startFoot, toneGroups[toneGroupIndex].endFoot);
        for (NSUInteger footIndex = toneGroup.startFootIndex; footIndex <= toneGroup.endFootIndex; footIndex++) {
            MMFoot *foot = self.feet[footIndex];
            [logger log:@"  foot[%lu]  tempo: %.3f, isTonic? %d, last? %d  (%ld -- %ld)", footIndex, foot.tempo,
             foot.isTonic, foot.isLast, foot.startPhoneIndex, foot.endPhoneIndex];

            //NSLog(@"Foot (%d -- %d)", feet[footIndex].start, feet[footIndex].end);
            for (NSUInteger postureIndex = foot.startPhoneIndex; postureIndex <= foot.endPhoneIndex; postureIndex++) {
                MMPhone *phone = self.phones[postureIndex];
                MMAppliedRule *appliedRule = (ruleIndex < [self.appliedRules count]) ? self.appliedRules[ruleIndex] : nil;
                if (appliedRule != nil && appliedRule.firstPhone == postureIndex) {
                    [logger log:@"    posture[%2lu]  tempo: %.3f, syllable: %lu, onset: %7.2f, ruleTempo: %.3f, %@ # Rule %2lu, duration: %7.2f, beat: %7.2f",
                     postureIndex, phone.tempo, phone.syllable, phone.onset,
                     phone.ruleTempo, [[phone.posture name] leftJustifiedStringPaddedToLength:18],
                     appliedRule.number, appliedRule.duration, appliedRule.beat];
                    ruleIndex++;
                } else {
                    [logger log:@"    posture[%2lu]  tempo: %.3f, syllable: %lu, onset: %7.2f, ruleTempo: %.3f, %@",
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
    intonationPoint.eventList = self;
    self.intonationPointsNeedSorting = YES;

    NSDictionary *userInfo = @{
                               NSKeyValueChangeKindKey : @(NSKeyValueChangeInsertion),
                               };
    [[NSNotificationCenter defaultCenter] postNotificationName:EventListDidChangeIntonationPoints object:self userInfo:userInfo];
}

- (void)removeIntonationPoint:(MMIntonationPoint *)intonationPoint;
{
    intonationPoint.eventList = nil;
    [_intonationPoints removeObject:intonationPoint];

    NSDictionary *userInfo = @{
                               NSKeyValueChangeKindKey : @(NSKeyValueChangeRemoval),
                               };
    [[NSNotificationCenter defaultCenter] postNotificationName:EventListDidChangeIntonationPoints object:self userInfo:userInfo];
}

- (void)removeIntonationPointsFromArray:(NSArray *)array;
{
    for (MMIntonationPoint *intonationPoint in array) {
        intonationPoint.eventList = nil;
        [_intonationPoints removeObject:intonationPoint];
    }

    NSDictionary *userInfo = @{
                               NSKeyValueChangeKindKey : @(NSKeyValueChangeRemoval),
                               };
    [[NSNotificationCenter defaultCenter] postNotificationName:EventListDidChangeIntonationPoints object:self userInfo:userInfo];
}

- (void)removeAllIntonationPoints;
{
    for (MMIntonationPoint *intonationPoint in _intonationPoints) {
        intonationPoint.eventList = nil;
    }
    [_intonationPoints removeAllObjects];
    self.intonationPointsNeedSorting = NO;
    [self clearIntonationEvents];

    NSDictionary *userInfo = @{
                               NSKeyValueChangeKindKey : @(NSKeyValueChangeRemoval),
                               };
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
// This is derived from -[IntonationView applyIntonation] from old source.
- (void)_applyFlatIntonation;
{
    NSLog(@" > %s", __PRETTY_FUNCTION__);

    [self setFullTimeScale];
    [self insertEvent:32 atTimeOffset:0.0 withValue:-20.0];

    NSUInteger count = [self.intonationPoints count]; // This makes sure they get sorted
    NSLog(@"Applying intonation, %lu points", count);

    for (MMIntonationPoint *intonationPoint in self.intonationPoints) { // Use property notation to make sure the points get sorted.
        NSLog(@"Added Event at Time: %f withValue: %f", intonationPoint.absoluteTime, intonationPoint.semitone);
        [self insertEvent:32 atTimeOffset:intonationPoint.absoluteTime withValue:intonationPoint.semitone];
        [self insertEvent:33 atTimeOffset:intonationPoint.absoluteTime withValue:0.0];
        [self insertEvent:34 atTimeOffset:intonationPoint.absoluteTime withValue:0.0];
        [self insertEvent:35 atTimeOffset:intonationPoint.absoluteTime withValue:0.0];
    }

    [self finalEvent:32 withValue:-20.0 posture:nil]; // TODO: (2015-07-09) What posture?

    NSLog(@"<  %s", __PRETTY_FUNCTION__);
}

// This was derived from -[IntonationView applyIntonationSmooth] from old source.
// Was same as Monet.realtime, except for that first intonation point.
- (void)_applySmoothIntonation;
{
    //NSLog(@" > %s", _cmd);

    [self setFullTimeScale];

    if ([_intonationPoints count] == 0)
        return;

    NSUInteger count = [self.intonationPoints count]; // Again, make sure it gets sorted since we just added a point.

    //[self insertEvent:32 atTimeOffset:0.0 withValue:-20.0];
    for (NSUInteger index = 0; index < count - 1; index++) {
        MMIntonationPoint *point1 = _intonationPoints[index];
        MMIntonationPoint *point2 = _intonationPoints[index + 1];

        double x1 = point1.absoluteTime / 4.0;
        double y1 = point1.semitone + 20.0;
        double m1 = point1.slope;

        double x2 = point2.absoluteTime / 4.0;
        double y2 = point2.semitone + 20.0;
        double m2 = point2.slope;

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

        [self insertEvent:32 atTimeOffset:point1.absoluteTime withValue:point1.semitone];

        double yTemp = (3.0 * a * x1_2) + (2.0 * b * x1) + c;
        //NSLog(@"time: %.2f", [point1 absoluteTime]);
        //NSLog(@"index: %d, inserting event 33: %7.3f", index, yTemp);
        [self insertEvent:33 atTimeOffset:point1.absoluteTime withValue:yTemp];

        yTemp = (6.0 * a * x1) + (2.0 * b);
        //NSLog(@"index: %d, inserting event 34: %7.3f", index, yTemp);
        [self insertEvent:34 atTimeOffset:point1.absoluteTime withValue:yTemp];

        yTemp = 6.0 * a;
        //NSLog(@"index: %d, inserting event 35: %7.3f", index, yTemp);
        [self insertEvent:35 atTimeOffset:point1.absoluteTime withValue:yTemp];
    }

    //NSLog(@"<  %s", _cmd);
}

// So that we can reapply the current intonation to the events.
- (void)clearIntonationEvents;
{
    for (Event *event in _mutableEvents) {
        [event setValue:NAN atIndex:32];
        [event setValue:NAN atIndex:33];
        [event setValue:NAN atIndex:34];
        [event setValue:NAN atIndex:35];
    }
}

#pragma mark - MMIntonationPointChanges

- (void)intonationPointTimeDidChange:(MMIntonationPoint *)intonationPoint;
{
    self.intonationPointsNeedSorting = YES;
    [self intonationPointDidChange:intonationPoint];
}

#pragma mark -

- (void)intonationPointDidChange:(MMIntonationPoint *)intonationPoint;
{
    NSDictionary *userInfo = @{
                               NSKeyValueChangeKindKey : @(NSKeyValueChangeSetting),
                               };
    [[NSNotificationCenter defaultCenter] postNotificationName:EventListDidChangeIntonationPoints object:self userInfo:userInfo];
}

#pragma mark - Other

#pragma mark - Archiving - XML

- (BOOL)writeIntonationContourToXMLFile:(NSString *)filename comment:(NSString *)comment;
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

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
#import "MModel.h"
#import "MMParameter.h"
#import "MMPoint.h"
#import "MMPosture.h"
#import "MMPostureRewriter.h"
#import "MMRule.h"
#import "MMSlopeRatio.h"
#import "MMTarget.h"
#import "MMTransition.h"
#import "MXMLParser.h"
#import "MXMLArrayDelegate.h"
#import "MXMLPCDataDelegate.h"
#import "MMIntonationParameters.h"

#import "TRMSynthesizer.h" // For addParameters:

NSString *NSStringFromToneGroupType(NSUInteger toneGroupType)
{
    switch (toneGroupType) {
        case STATEMENT:    return @"Statement";
        case EXCLAMATION:  return @"Exclamation";
        case QUESTION:     return @"Question";
        case CONTINUATION: return @"Continuation";
        case SEMICOLON:    return @"Semicolon";
    }

    return nil;
}

NSString *EventListDidChangeIntonationPoints = @"EventListDidChangeIntonationPoints";

@interface EventList ()
@property (assign) BOOL intonationPointsNeedSorting;
@end

#pragma mark -

@implementation EventList
{
    MModel *model;
    
    MMPostureRewriter *postureRewriter;
    
    NSString *phoneString;
    
    NSInteger zeroRef;
    NSInteger zeroIndex; // Event index derived from zeroRef.
    
    NSUInteger duration; // Move... somewhere else.
    NSUInteger timeQuantization; // in msecs.  By default it generates parameters every 4 msec
    
    BOOL m_shouldStoreParameters; // YES -> -generateOutput writes to /tmp/Monet.parameters
    BOOL m_shouldUseMacroIntonation;
    BOOL m_shouldUseMicroIntonation;
    BOOL m_shouldUseDrift;
    BOOL m_shouldUseSmoothIntonation;
    BOOL m_intonationPointsNeedSorting;
    
    double m_radiusMultiply; // Affects hard coded parameters, in this case r1 and r2.
    double m_pitchMean;
    double m_globalTempo;
    double m_multiplier; // Move... somewhere else.
    MMIntonationParameters *m_intonationParameters;
    
    /* NOTE phones and phoneTempo are separate for Optimization reasons */
    NSUInteger postureCount;
    struct _phone phones[MAXPHONES];
    double phoneTempo[MAXPHONES];
    
    NSUInteger footCount;
    struct _foot feet[MAXFEET];
    
    NSUInteger toneGroupCount;
    struct _toneGroup toneGroups[MAXTONEGROUPS];
    
    NSUInteger currentRule;
    struct _rule rules[MAXRULES];
    
    double min[16]; // Min of each parameter value
    double max[16]; // Max of each parameter value
    
    NSMutableArray *events;
    NSMutableArray *intonationPoints; // Sorted by absolute time
    
    id delegate;
    
    // Hack for inflexible XML parsing.  I have plan to change how I parse XML.
    NSUInteger parseState;
    
    MMDriftGenerator *m_driftGenerator;
}

- (id)init;
{
    if ((self = [super init])) {
        model = nil;
        postureRewriter = [[MMPostureRewriter alloc] initWithModel:nil];
        phoneString = nil;
        
        events = [[NSMutableArray alloc] init];
        intonationPoints = [[NSMutableArray alloc] init];
        m_intonationPointsNeedSorting = NO;
        
        m_intonationParameters = [[MMIntonationParameters alloc] init];
        
        m_driftGenerator = [[MMDriftGenerator alloc] init];
        [m_driftGenerator configureWithDeviation:1 sampleRate:500 lowpassCutoff:1000];
        
        [self setUp];
        
        m_radiusMultiply = 1.0;
    }
        
    return self;
}

- (void)dealloc;
{
    [model release];
    [postureRewriter release];
    [phoneString release];

    [events release];
    [intonationPoints release];
    [delegate release];

    [super dealloc];
}

#pragma mark -

- (MModel *)model;
{
    return model;
}

- (void)setModel:(MModel *)newModel;
{
    if (newModel != model) {
        // TODO (2004-08-19): Maybe it's better just to allocate a new one?  Or create it just before synthesis?
        [self setUp]; // So that we don't have stuff left over from the previous model, which can cause a crash.

        [model release];
        model = [newModel retain];

        [postureRewriter setModel:model];
    }
}

@synthesize delegate;

@synthesize phoneString;

- (NSInteger)zeroRef;
{
    return zeroRef;
}

- (void)setZeroRef:(NSInteger)newValue;
{
    zeroRef = newValue;
    zeroIndex = 0;

    if ([events count] > 0) {
        for (NSInteger index = [events count] - 1; index >= 0; index--) {
            //NSLog(@"index = %d", index);
            if ([[events objectAtIndex:index] time] < newValue) {
                zeroIndex = index;
                return;
            }
        }
    }
}

@synthesize duration, timeQuantization;
@synthesize shouldStoreParameters = m_shouldStoreParameters;
@synthesize shouldUseMacroIntonation = m_shouldUseMacroIntonation;
@synthesize shouldUseMicroIntonation = m_shouldUseMicroIntonation;
@synthesize shouldUseDrift = m_shouldUseDrift;
@synthesize shouldUseSmoothIntonation = m_shouldUseSmoothIntonation;
@synthesize intonationPointsNeedSorting = m_intonationPointsNeedSorting;
@synthesize radiusMultiply = m_radiusMultiply;
@synthesize pitchMean = m_pitchMean;
@synthesize globalTempo = m_globalTempo;
@synthesize multiplier = m_multiplier;
@synthesize intonationParameters = m_intonationParameters;

//
//
//

- (void)setUp;
{
    //NSLog(@"<%@>[%p]  > %s", NSStringFromClass([self class]), self, _cmd);

    [events removeAllObjects];
    [self removeAllIntonationPoints];

    zeroRef = 0;
    zeroIndex = 0;
    duration = 0;
    timeQuantization = 4;

    m_globalTempo = 1.0;
    m_multiplier = 1.0;
    self.shouldUseMacroIntonation = NO;
    self.shouldUseMicroIntonation = NO;
    self.shouldUseDrift = NO;

    m_intonationParameters.notionalPitch = 0;
    m_intonationParameters.pretonicRange = 0;
    m_intonationParameters.pretonicLift = -2;
    m_intonationParameters.tonicRange = -8;
    m_intonationParameters.tonicMovement = -6;

    self.shouldUseSmoothIntonation = NO;

    postureCount = 0;
    bzero(phones, MAXPHONES * sizeof(struct _phone));
    // TODO (2004-08-09): What about phoneTempo[]?

    footCount = 0;
    bzero(feet, MAXFEET * sizeof(struct _foot));

    toneGroupCount = 0;
    bzero(toneGroups, MAXTONEGROUPS * sizeof(struct _toneGroup));

    currentRule = 0;
    bzero(rules, MAXRULES * sizeof(struct _rule));

    phoneTempo[0] = 1.0;
    feet[0].tempo = 1.0;

    //NSLog(@"<%@>[%p] <  %s", NSStringFromClass([self class]), self, _cmd);
}

- (void)setFullTimeScale;
{
    zeroRef = 0;
    zeroIndex = 0;
    duration = [[events lastObject] time] + 100;
}

//
// Rules
//

- (struct _rule *)getRuleAtIndex:(NSUInteger)ruleIndex;
{
    if (ruleIndex > currentRule)
        return NULL;

    return &rules[ruleIndex];
}

- (NSString *)ruleDescriptionAtIndex:(NSUInteger)ruleIndex;
{
    NSMutableString *str;
    struct _rule *rule;
    NSUInteger index;

    rule = [self getRuleAtIndex:ruleIndex];
    str = [NSMutableString string];

    for (index = rule->firstPhone; index <= rule->lastPhone; index++) {
        [str appendString:[[self getPhoneAtIndex:index] name]];
        if (index == rule->lastPhone)
            break;
        [str appendString:@" > "];
    }

    return str;
}

- (double)getBeatAtIndex:(NSUInteger)ruleIndex;
{
    if (ruleIndex > currentRule)
        return 0.0;

    return rules[ruleIndex].beat;
}

- (NSUInteger)ruleCount;
{
    return currentRule;
}

- (void)getRuleIndex:(NSUInteger *)ruleIndexPtr offsetTime:(double *)offsetTimePtr forAbsoluteTime:(double)absoluteTime;
{
    NSUInteger index;
    double onset;

    for (index = 0; index <= currentRule; index++) {
        onset = phones[rules[index].firstPhone].onset;
        if (absoluteTime >= onset && absoluteTime < onset + rules[index].duration) {
            if (ruleIndexPtr != NULL)
                *ruleIndexPtr = index;
            if (offsetTimePtr != NULL)
                *offsetTimePtr = absoluteTime - rules[index].beat;
            return;
        }
    }

    if (ruleIndexPtr != NULL)
        *ruleIndexPtr = -1;
    if (offsetTimePtr != NULL)
        *offsetTimePtr = 0.0;
}

#pragma mark - Tone groups

// This is horribly ugly and is going to be full of bugs :(
// It would be easier if we just didn't allow the trailing // that produces an empty tone group.
- (void)endCurrentToneGroup;
{
    if (toneGroupCount > 0) {
        if (footCount == 0) {
            toneGroupCount--; // No feet in this tone group, so remove it.
        } else if (feet[footCount-1].start >= postureCount) {
            footCount--; // No posture in the foot, so remove it.
            toneGroupCount--; // And remove the toen group too
        } else {
            toneGroups[toneGroupCount - 1].endFoot = footCount - 1; // TODO (2004-08-18): What if footCount == 0
            [self endCurrentFoot];
        }
    }
}

- (void)newToneGroup;
{
    [self endCurrentToneGroup];
    [self newFoot];

    toneGroups[toneGroupCount].startFoot = footCount - 1;
    toneGroups[toneGroupCount].endFoot = -1;
    toneGroupCount++;
}

- (void)setCurrentToneGroupType:(NSUInteger)type;
{
    if (toneGroupCount == 0) {
        NSLog(@"%s, not tone groups.", __PRETTY_FUNCTION__);
        return;
    }

    toneGroups[toneGroupCount - 1].type = type;
}

#pragma mark - Feet

- (void)endCurrentFoot;
{
    if (footCount > 0)
        feet[footCount - 1].end = postureCount - 1;
}

- (void)newFoot;
{
    [self endCurrentFoot];
    feet[footCount].start = postureCount; // TODO (2004-08-18): And you better add that posture!
    feet[footCount].end = -1;
    feet[footCount].tempo = 1.0;
    footCount++;
}

- (void)setCurrentFootMarked;
{
    if (footCount == 0) {
        NSLog(@"%s, footCount == 0", __PRETTY_FUNCTION__);
        return;
    }

    feet[footCount - 1].marked = 1;
}

- (void)setCurrentFootLast;
{
    if (footCount == 0) {
        NSLog(@"%s, footCount == 0", __PRETTY_FUNCTION__);
        return;
    }

    feet[footCount - 1].last = 1;
}

- (void)setCurrentFootTempo:(double)tempo;
{
    if (footCount == 0) {
        NSLog(@"%s, footCount == 0", __PRETTY_FUNCTION__);
        return;
    }

    feet[footCount - 1].tempo = tempo;
}

#pragma mark - Postures

- (MMPosture *)getPhoneAtIndex:(NSUInteger)phoneIndex;
{
    if (phoneIndex >= postureCount)
        return nil;

    return phones[phoneIndex].phone;
}

- (void)newPhoneWithObject:(MMPosture *)anObject;
{
    phoneTempo[postureCount] = 1.0;
    phones[postureCount].ruleTempo = 1.0;
    phones[postureCount].phone = anObject;
    postureCount++;
}

- (void)replaceCurrentPhoneWith:(MMPosture *)anObject;
{
    if (postureCount == 0) {
        NSLog(@"%s, postureCount == 0", __PRETTY_FUNCTION__);
        return;
    }

    NSLog(@"Replacing %@ with %@", [phones[postureCount - 1].phone name], [anObject name]);
    phones[postureCount - 1].phone = anObject;
}

- (void)setCurrentPhoneTempo:(double)tempo;
{
    if (postureCount == 0) {
        NSLog(@"%s, postureCount == 0", __PRETTY_FUNCTION__);
        return;
    }

    phoneTempo[postureCount - 1] = tempo;
}

- (void)setCurrentPhoneRuleTempo:(float)tempo;
{
    if (postureCount == 0) {
        NSLog(@"%s, postureCount == 0", __PRETTY_FUNCTION__);
        return;
    }

    phones[postureCount - 1].ruleTempo = tempo;
}

- (void)setCurrentPhoneSyllable;
{
    if (postureCount == 0) {
        NSLog(@"%s, postureCount == 0", __PRETTY_FUNCTION__);
        return;
    }

    phones[postureCount - 1].syllable = 1;
}

- (NSUInteger)ruleIndexForPostureAtIndex:(NSUInteger)postureIndex;
{
    for (NSUInteger index = 0; index < currentRule; index++) {
        if ((postureIndex >= rules[index].firstPhone) && (postureIndex <= rules[index].lastPhone))
            return index;
    }

    return 0;
}

#pragma mark - Events

- (NSArray *)events;
{
    return events;
}

// Get the event a time "time", creating it if necessary and insserting into "events" array.
// Time relative to zeroRef
- (Event *)eventAtTimeOffset:(double)time;
{
    Event *newEvent = nil;
    NSInteger i, tempTime;

    time = time * self.multiplier;
    if (time < 0.0)
        return nil;
    if (time > (double)(duration + timeQuantization))
        return nil;

    tempTime = zeroRef + (int)time;
    tempTime = tempTime - (tempTime % timeQuantization);

    // If there are no events yet, we can just add it.
    if ([events count] == 0) {
        newEvent = [[[Event alloc] init] autorelease];
        newEvent.time = tempTime;
        [events addObject:newEvent];
        return newEvent;
    }

    // Otherwise we need to search through the events to find the correct place to insert it.
    for (i = [events count] - 1; i >= zeroIndex; i--) {
        // If there is an Event at exactly this time, we can use that event.
        if ([[events objectAtIndex:i] time] == tempTime)
            return [events objectAtIndex:i];

        // Otherwise we'll need to create an Event at that time and insert it in the proper place.
        if ([[events objectAtIndex:i] time] < tempTime) {
            newEvent = [[[Event alloc] init] autorelease];
            newEvent.time = tempTime;
            [events insertObject:newEvent atIndex:i+1];
            return newEvent;
        }
    }

    // In this case the event should come at the end of the list.
    newEvent = [[[Event alloc] init] autorelease];
    newEvent.time = tempTime;
    [events insertObject:newEvent atIndex:i+1];

    return newEvent;
}

// Time relative to zeroRef
- (Event *)insertEvent:(NSInteger)number atTimeOffset:(double)time withValue:(double)value;
{
    Event *event;

    event = [self eventAtTimeOffset:time];
    if (number >= 0) {
        if ((number >= 7) && (number <= 8))
            [event setValue:value*self.radiusMultiply atIndex:number];
        else
            [event setValue:value atIndex:number];
    }

    return event;
}

- (void)finalEvent:(NSUInteger)number withValue:(double)value;
{
    Event *lastEvent;

    lastEvent = [events lastObject];
    [lastEvent setValue:value atIndex:number];
    [lastEvent setFlag:YES];
}

#pragma mark - Other

// EventList API used:
//  - setCurrentToneGroupType:
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
    MMPosture *aPhone;
    NSUInteger lastFoot = 0, markedFoot = 0;
    double footTempo = 1.0;
    double ruleTempo = 1.0;
    double aPhoneTempo = 1.0;
    double aDouble;
    NSScanner *scanner;
    NSCharacterSet *whitespaceCharacterSet = [NSCharacterSet phoneStringWhitespaceCharacterSet];
    NSCharacterSet *defaultCharacterSet = [NSCharacterSet phoneStringIdentifierCharacterSet];
    NSString *buffer;
    BOOL wordMarker = NO;

    self.phoneString = str;
    [postureRewriter resetState];

    scanner = [[[NSScanner alloc] initWithString:str] autorelease];
    [scanner setCharactersToBeSkipped:nil];

    while ([scanner isAtEnd] == NO) {
        [scanner scanCharactersFromSet:whitespaceCharacterSet intoString:NULL];
        if ([scanner isAtEnd] == YES)
            break;

        if ([scanner scanString:@"/" intoString:NULL] == YES) {
            // Handle "/" escape sequences
            if ([scanner scanString:@"0" intoString:NULL] == YES) {
                // Tone group 0. Statement
                //NSLog(@"Tone group 0. Statement");
                [self setCurrentToneGroupType:STATEMENT];
            } else if ([scanner scanString:@"1" intoString:NULL] == YES) {
                // Tone group 1. Exclamation
                //NSLog(@"Tone group 1. Exclamation");
                [self setCurrentToneGroupType:EXCLAMATION];
            } else if ([scanner scanString:@"2" intoString:NULL] == YES) {
                // Tone group 2. Question
                //NSLog(@"Tone group 2. Question");
                [self setCurrentToneGroupType:QUESTION];
            } else if ([scanner scanString:@"3" intoString:NULL] == YES) {
                // Tone group 3. Continuation
                //NSLog(@"Tone group 3. Continuation");
                [self setCurrentToneGroupType:CONTINUATION];
            } else if ([scanner scanString:@"4" intoString:NULL] == YES) {
                // Tone group 4. Semi-colon
                //NSLog(@"Tone group 4. Semi-colon");
                [self setCurrentToneGroupType:SEMICOLON];
            } else if ([scanner scanString:@" " intoString:NULL] == YES || [scanner scanString:@"_" intoString:NULL] == YES) {
                // New foot
                //NSLog(@"New foot");
                [self newFoot];
                if (lastFoot)
                    [self setCurrentFootLast];
                footTempo = 1.0;
                lastFoot = 0;
                markedFoot = 0;
            } else if ([scanner scanString:@"*" intoString:NULL] == YES) {
                // New Marked foot
                //NSLog(@"New Marked foot");
                [self newFoot];
                [self setCurrentFootMarked];
                if (lastFoot)
                    [self setCurrentFootLast];

                footTempo = 1.0;
                lastFoot = 0;
                markedFoot = 1;
            } else if ([scanner scanString:@"/" intoString:NULL] == YES) {
                // New Tone Group
                //NSLog(@"New Tone Group");
                [self newToneGroup];
            } else if ([scanner scanString:@"c" intoString:NULL] == YES) {
                // New Chunk
                //NSLog(@"New Chunk -- not sure that this is working.");
            } else if ([scanner scanString:@"w" intoString:NULL] == YES) {
                // Word Marker
                wordMarker = YES;
            } else if ([scanner scanString:@"l" intoString:NULL] == YES) {
                // Last Foot in tone group marker
                //NSLog(@"Last Foot in tone group");
                lastFoot = 1;
            } else if ([scanner scanString:@"f" intoString:NULL] == YES) {
                // Foot tempo indicator
                //NSLog(@"Foot tempo indicator - 'f'");
                [scanner scanCharactersFromSet:whitespaceCharacterSet intoString:NULL];
                if ([scanner scanDouble:&aDouble] == YES) {
                    //NSLog(@"current foot tempo: %g", aDouble);
                    [self setCurrentFootTempo:aDouble];
                }
            } else if ([scanner scanString:@"r" intoString:NULL] == YES) {
                // Foot tempo indicator
                //NSLog(@"Foot tempo indicator - 'r'");
                [scanner scanCharactersFromSet:whitespaceCharacterSet intoString:NULL];
                if ([scanner scanDouble:&aDouble] == YES) {
                    //NSLog(@"ruleTemp = %g", aDouble);
                    ruleTempo = aDouble;
                }
            } else {
                // Skip character
                [scanner scanCharacter:NULL];
            }
        } else if ([scanner scanString:@"." intoString:NULL] == YES) {
            // Syllable Marker
            //NSLog(@"Syllable Marker");
            [self setCurrentPhoneSyllable];
        } else if ([scanner scanDouble:&aDouble] == YES) {
            // TODO (2004-03-05): The original scanned digits and '.', and then used atof.
            //NSLog(@"aPhoneTempo = %g", aDouble);
            aPhoneTempo = aDouble;
        } else {
            if ([scanner scanCharactersFromSet:defaultCharacterSet intoString:&buffer] == YES) {
                //NSLog(@"Scanned this: '%@'", buffer);
                if (markedFoot)
                    buffer = [buffer stringByAppendingString:@"'"];
                aPhone = [model postureWithName:buffer];
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
    NSUInteger i, j;

    for (i = 0; i < footCount; i++) {
        int rus;
        double footTempo;

        rus = feet[i].end - feet[i].start + 1;

        /* Apply rhythm model */
        if (feet[i].marked) {
            double tempo;

            tempo = 117.7 - (19.36 * (double)rus);
            feet[i].tempo -= tempo / 180.0;
            //NSLog(@"Rus = %d tempTempo = %f", rus, tempo);
            footTempo = self.globalTempo * feet[i].tempo;
        } else {
            double tempo;

            tempo = 18.5 - (2.08 * (double)rus);
            feet[i].tempo -= tempo / 140.0;
            //NSLog(@"Rus = %d tempTempo = %f", rus, tempTempo);
            footTempo = self.globalTempo * feet[i].tempo;
        }

        // Adjust the posture tempos for postures in this foot, limiting it to a minimum of 0.2 and maximum of 2.0.
        //NSLog(@"Foot Tempo = %f", footTempo);
        for (j = feet[i].start; j < feet[i].end + 1; j++) {
            phoneTempo[j] *= footTempo;
            if (phoneTempo[j] < 0.2)
                phoneTempo[j] = 0.2;
            else if (phoneTempo[j] > 2.0)
                phoneTempo[j] = 2.0;

            //NSLog(@"PhoneTempo[%d] = %f, teed[%d].tempo = %f", j, phoneTempo[j], i, feet[i].tempo);
        }
    }

    //[self printDataStructures:@"Applied rhythm"];
}

- (void)applyRules;
{
    //[self printDataStructures:@"Start of generateEvents"];
    NSParameterAssert(model != nil);

    // Record min/max values for each of the parameters
    {
        NSMutableArray *parameters = [model parameters];
        NSUInteger count, index;
        MMParameter *aParameter = nil;

        //NSLog(@"parameters: %@", parameters);
        count = [parameters count];
        for (index = 0; index < count && index < 16; index++) {
            aParameter = [parameters objectAtIndex:index];

            min[index] = [aParameter minimumValue];
            max[index] = [aParameter maximumValue];
            //NSLog(@"Min: %9.3f Max: %9.3f", min[index], max[index]);
        }
    }

    {
        NSMutableArray *tempPostures, *tempCategoryList;
        NSUInteger index, j;

        tempPostures = [[NSMutableArray alloc] init];
        tempCategoryList = [[NSMutableArray alloc] init];

        // Apply rules
        for (index = 0; index < postureCount - 1; ) {
            NSInteger ruleIndex;
            MMRule *matchedRule;

            [tempPostures removeAllObjects];
            [tempCategoryList removeAllObjects];

            for (j = 0; j < 4; j++) {
                if (phones[j+index].phone != nil) {
                    [tempPostures addObject:phones[j+index].phone];
                    [tempCategoryList addObject:[phones[j+index].phone categories]];
                }
            }

            matchedRule = [model findRuleMatchingCategories:tempCategoryList ruleIndex:&ruleIndex];
            rules[currentRule].number = ruleIndex + 1;

            //NSLog(@"----------------------------------------------------------------------");
            //NSLog(@"Applying rule %d", ruleIndex + 1);
            [self _applyRule:matchedRule withPostures:tempPostures andTempos:&phoneTempo[index] phoneIndex:index];

            index += [matchedRule numberExpressions] - 1;
        }

        [tempPostures release];
        [tempCategoryList release];
    }


//    if (currentPhone)
//        [self generateIntonationPoints];

    [[events lastObject] setFlag:YES];

    [self printDataStructures:@"Applied rules"];

    //NSLog(@"%s, EventList count: %d", _cmd, [events count]);
}

// Use a 0.0 offset time for the first intonation point in each tone group, -40.0 for the rest.
- (void)generateIntonationPoints;
{
    NSUInteger firstFoot, endFoot;
    NSUInteger ruleIndex, phoneIndex;
    NSUInteger i, j;
    double startTime, endTime, pretonicDelta, offsetTime = 0.0;
    double randomSemitone, randomSlope;

    zeroRef = 0;
    zeroIndex = 0;
    duration = [[events lastObject] time] + 100;

    [self removeAllIntonationPoints];
//    [self addIntonationPoint:-20.0 offsetTime:0.0 slope:0.0 ruleIndex:0];

    for (i = 0; i < toneGroupCount; i++) {
        firstFoot = toneGroups[i].startFoot;
        endFoot = toneGroups[i].endFoot;

        startTime  = phones[feet[firstFoot].start].onset;
        endTime  = phones[feet[endFoot].end].onset;

        pretonicDelta = (m_intonationParameters.pretonicRange) / (endTime - startTime);
        //NSLog(@"Pretonic Delta = %f time = %f", pretonicDelta, (endTime - startTime));

        /* Set up intonation boundary variables */
        for (j = firstFoot; j <= endFoot; j++) {
            MMIntonationPoint *newIntonationPoint;

            phoneIndex = feet[j].start;
            while ([phones[phoneIndex].phone isMemberOfCategoryNamed:@"vocoid"] == NO) { // TODO (2004-08-16): Hardcoded category
                phoneIndex++;
                //NSLog(@"Checking phone %@ for vocoid", [phones[phoneIndex].phone name]);
                if (phoneIndex > feet[j].end) {
                    phoneIndex = feet[j].start;
                    break;
                }
            }

            if (!feet[j].marked) {
                ruleIndex = [self ruleIndexForPostureAtIndex:phoneIndex];

                // randomSemitone is in range of +/- 1/2 of pretonicLift
                randomSemitone = ((double)random() / (double)0x7fffffff) * (double)m_intonationParameters.pretonicLift - m_intonationParameters.pretonicLift / 2.0;
                // Slopes from 0.02 to 0.035
                randomSlope = ((double)random() / (double)0x7fffffff) * 0.015 + 0.02;

                newIntonationPoint = [[MMIntonationPoint alloc] init];
                // TODO (2004-08-19): But this will generate extra change notifications.  Try setting the event list for the intonation point in -addIntonationPoint:.
                [newIntonationPoint setSemitone:((phones[phoneIndex].onset-startTime) * pretonicDelta) + m_intonationParameters.notionalPitch + randomSemitone];
                [newIntonationPoint setOffsetTime:offsetTime];
                [newIntonationPoint setSlope:randomSlope];
                [newIntonationPoint setRuleIndex:ruleIndex];
                [self addIntonationPoint:newIntonationPoint];
                [newIntonationPoint release];

//                NSLog(@"Calculated Delta = %f  time = %f", ((phones[phoneIndex].onset-startTime)*pretonicDelta),
//                       (phones[phoneIndex].onset-startTime));
            } else { /* Tonic */
                ruleIndex = [self ruleIndexForPostureAtIndex:phoneIndex];

                // Slopes from 0.02 to 0.05
                randomSlope = ((double)random() / (double)0x7fffffff) * 0.03 + 0.02;

                newIntonationPoint = [[MMIntonationPoint alloc] init];
                [newIntonationPoint setSemitone:m_intonationParameters.pretonicRange + m_intonationParameters.notionalPitch];
                [newIntonationPoint setOffsetTime:offsetTime];
                [newIntonationPoint setSlope:randomSlope];
                [newIntonationPoint setRuleIndex:ruleIndex];
                [self addIntonationPoint:newIntonationPoint];
                [newIntonationPoint release];

                phoneIndex = feet[j].end;
                ruleIndex = [self ruleIndexForPostureAtIndex:phoneIndex];

                newIntonationPoint = [[MMIntonationPoint alloc] init];
                [newIntonationPoint setSemitone:m_intonationParameters.pretonicRange + m_intonationParameters.notionalPitch + m_intonationParameters.tonicRange];
                [newIntonationPoint setOffsetTime:0.0];
                [newIntonationPoint setSlope:0.0];
                [newIntonationPoint setRuleIndex:ruleIndex];
                [self addIntonationPoint:newIntonationPoint];
                [newIntonationPoint release];
            }

            offsetTime = -40.0;
        }
    }

    //[self printDataStructures:@"After applyIntonation generateEvents"];
}

- (void)generateOutput;
{
    NSUInteger i, j, k;
    NSUInteger currentTime, nextTime;
    double currentValues[36];
    double currentDeltas[36];
    double temp;
    float table[16];
    FILE *fp;

    //NSLog(@"%s, self: %@", _cmd, self);

    if ([events count] == 0)
        return;

    if (self.shouldStoreParameters == YES) {
        fp = fopen("/tmp/Monet.parameters", "a+");
    } else
        fp = NULL;

    currentTime = 0;
    for (i = 0; i < 16; i++) {
        j = 1;
        while ( ( temp = [[events objectAtIndex:j] getValueAtIndex:i]) == NaN)
            j++;

        currentValues[i] = [[events objectAtIndex:0] getValueAtIndex:i];
        currentDeltas[i] = ((temp - currentValues[i]) / (double) ([[events objectAtIndex:j] time])) * 4.0;
    }

    for (i = 16; i < 36; i++)
        currentValues[i] = currentDeltas[i] = 0.0;

    if (self.shouldUseSmoothIntonation) {
        j = 0;
        while ( (temp = [[events objectAtIndex:j] getValueAtIndex:32]) == NaN) {
            j++;
            if (j >= [events count])
                break;
        }

        currentValues[32] = [[events objectAtIndex:j] getValueAtIndex:32];
        currentDeltas[32] = 0.0;
        //NSLog(@"Smooth intonation: %f %f j = %d", currentValues[32], currentDeltas[32], j);
    } else {
        j = 1;
        while ( (temp = [[events objectAtIndex:j] getValueAtIndex:32]) == NaN) {
            j++;
            if (j >= [events count])
                break;
        }

        currentValues[32] = [[events objectAtIndex:0] getValueAtIndex:32];
        if (j < [events count])
            currentDeltas[32] = ((temp - currentValues[32]) / (double) ([[events objectAtIndex:j] time])) * 4.0;
        else
            currentDeltas[32] = 0;
    }

//    NSLog(@"Starting Values:");
//    for (i = 0; i < 32; i++)
//        NSLog(@"%d;  cv: %f  cd: %f", i, currentValues[i], currentDeltas[i]);

    i = 1;
    currentTime = 0;
    nextTime = [[events objectAtIndex:1] time];
    while (i < [events count]) {
        for (j = 0; j < 16; j++) {
            table[j] = (float)currentValues[j] + (float)currentValues[j+16];
        }
        if (!self.shouldUseMicroIntonation)
            table[0] = 0.0;
        if (self.shouldUseDrift)
            table[0] += self.driftGenerator.generateDrift;
        if (self.shouldUseMacroIntonation) {
            //NSLog(@"sumi, table[0]: %f, currentValues[32]: %f", table[0], currentValues[32]);
            table[0] += currentValues[32];
        }

        table[0] += self.pitchMean;

        if (fp)
            fprintf(fp, "%.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f\n",
                    table[0], table[1], table[2], table[3],
                    table[4], table[5], table[6], table[7],
                    table[8], table[9], table[10], table[11],
                    table[12], table[13], table[14], table[15]);

        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(addParameters:)])
            [self.delegate addParameters:table];

        for (j = 0 ; j < 32; j++) {
            if (currentDeltas[j])
                currentValues[j] += currentDeltas[j];
        }
        if (self.shouldUseSmoothIntonation) {
            currentDeltas[34] += currentDeltas[35];
            currentDeltas[33] += currentDeltas[34];
            currentValues[32] += currentDeltas[33];
        } else {
            if (currentDeltas[32])
                currentValues[32] += currentDeltas[32];
        }
        currentTime += 4;

        if (currentTime >= nextTime) {
            i++;
            if (i == [events count])
                break;

            nextTime = [[events objectAtIndex:i] time];
            for (j = 0; j < 33; j++) {
                if ([[events objectAtIndex:i-1] getValueAtIndex:j] != NaN) {
                    k = i;
                    while ((temp = [[events objectAtIndex:k] getValueAtIndex:j]) == NaN) {
                        if (k >= [events count] - 1) {
                            currentDeltas[j] = 0.0;
                            break;
                        }
                        k++;
                    }

                    if (temp != NaN) {
                        currentDeltas[j] = (temp - currentValues[j]) /
                            (double) ([[events objectAtIndex:k] time] - currentTime) * 4.0;
                    }
                }
            }
            if (self.shouldUseSmoothIntonation) {
                if ([[events objectAtIndex:i-1] getValueAtIndex:33] != NaN) {
                    currentDeltas[32] = 0.0;
                    currentDeltas[33] = [[events objectAtIndex:i-1] getValueAtIndex:33];
                    currentDeltas[34] = [[events objectAtIndex:i-1] getValueAtIndex:34];
                    currentDeltas[35] = [[events objectAtIndex:i-1] getValueAtIndex:35];
                }
            }
        }
    }

    // TODO (2004-03-25): There used to be some silence padding here.

    if (fp)
        fclose(fp);

    [self writeXMLToFile:@"/tmp/contour.xml" comment:nil];
}

// 1. Calculate the rule symbols (Rule Duration, Beat, Mark 1, Mark 2, Mark 3), given tempos and phones.
// 2.
- (void)_applyRule:(MMRule *)rule withPostures:(NSArray *)somePostures andTempos:(double *)tempos phoneIndex:(NSUInteger)phoneIndex;
{
    NSUInteger transitionIndex, parameterIndex;
    NSUInteger type;
    BOOL shouldCalculate;
    NSUInteger currentType;
    double currentDelta, value, maxValue;
    double tempTime, targets[4];
    MMFRuleSymbols ruleSymbols;
    MMTransition *transition;
    MMPoint *currentPoint;
    NSArray *parameterTransitions;
    NSArray *points;
    NSUInteger cache = [model nextCacheTag];

    bzero(&ruleSymbols, sizeof(MMFRuleSymbols));
    [rule evaluateSymbolEquations:&ruleSymbols tempos:tempos postures:somePostures withCache:cache];
#if 0
    NSLog(@"Rule symbols, duration: %.2f, beat: %.2f, mark1: %.2f, mark2: %.2f, mark3: %.2f",
          ruleSymbols.ruleDuration, ruleSymbols.beat, ruleSymbols.mark1, ruleSymbols.mark2, ruleSymbols.mark3);
#endif
    // TODO (2004-08-14): Is this supposed to change the multiplier?  I suppose so, since setMultiplier: is never used.
    //NSLog(@"multiplier before: %f", multiplier);
    self.multiplier = 1.0 / (double)(phones[phoneIndex].ruleTempo);
    //NSLog(@"multiplier after: %f", multiplier);

    type = [rule numberExpressions];
    [self setDuration:(int)(ruleSymbols.ruleDuration * self.multiplier)];

    rules[currentRule].firstPhone = phoneIndex;
    rules[currentRule].lastPhone = phoneIndex + (type - 1);
    rules[currentRule].beat = (ruleSymbols.beat * self.multiplier) + (double)zeroRef;
    rules[currentRule++].duration = ruleSymbols.ruleDuration * self.multiplier;

    // This creates events (if necessary) at the posture times, and sets the "flag" on them to indicate this is for a posture.
    switch (type) {
        /* Note: Case 4 should execute all of the below, case 3 the last two */
      case MMPhoneType_Tetraphone:
          phones[phoneIndex+3].onset = (double)zeroRef + ruleSymbols.beat;
          [[self insertEvent:-1 atTimeOffset:ruleSymbols.mark2 withValue:0.0] setFlag:YES];
      case MMPhoneType_Triphone:
          phones[phoneIndex+2].onset = (double)zeroRef + ruleSymbols.beat;
          [[self insertEvent:-1 atTimeOffset:ruleSymbols.mark1 withValue:0.0] setFlag:YES];
      case MMPhoneType_Diphone:
          phones[phoneIndex+1].onset = (double)zeroRef + ruleSymbols.beat;
          [[self insertEvent:-1 atTimeOffset:0.0 withValue:0.0] setFlag:YES];
          break;
    }

    parameterTransitions = [rule parameterTransitions];

    /* Loop through the parameters */
    for (transitionIndex = 0; transitionIndex < [parameterTransitions count]; transitionIndex++) {
        NSUInteger count, index;

        /* Get actual parameter target values */
        count = [somePostures count];
        for (index = 0; index < 4 && index < count; index++)
            targets[index] = [(MMTarget *)[[[somePostures objectAtIndex:index] parameterTargets] objectAtIndex:transitionIndex] value];
        for (; index < 4; index++)
            targets[index] = 0.0;

        //NSLog(@"Targets %f %f %f %f", targets[0], targets[1], targets[2], targets[3]);

        // Optimization: Don't calculate if no changes occur.
        shouldCalculate = YES;
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
            NSUInteger pointIndex, pointCount;

            currentType = MMPhoneType_Diphone;
            currentDelta = targets[1] - targets[0];

            transition = [parameterTransitions objectAtIndex:transitionIndex];
            maxValue = 0.0;
            points = [transition points];
            pointCount = [points count];

            /* Apply lists to parameter */
            for (pointIndex = 0; pointIndex < pointCount; pointIndex++) {
                currentPoint = [points objectAtIndex:pointIndex];

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
                maxValue = [currentPoint calculatePoints:&ruleSymbols tempos:tempos postures:somePostures
                                         andCacheWith:cache baseline:targets[currentType-2] delta:currentDelta
                                         min:min[transitionIndex] max:max[transitionIndex] toEventList:self atIndex:transitionIndex];
            }
        } else {
            // TODO (2004-08-15): This doesn't look right -- the time shouldn't be 0.
            [self insertEvent:transitionIndex atTimeOffset:0.0 withValue:targets[0]];
        }
    }

    /* Special Event Profiles */
    // TODO (2004-08-15): Does this support slope ratios?
    for (parameterIndex = 0; parameterIndex < 16; parameterIndex++) {
        transition = [rule getSpecialProfile:parameterIndex];
        if (transition != nil) {
            NSUInteger pointIndex, pointCount;

            points = [transition points];
            pointCount = [points count];

            for (pointIndex = 0; pointIndex < pointCount; pointIndex++) {
                currentPoint = [points objectAtIndex:pointIndex];

                /* calculate time of event */
                if ([currentPoint timeEquation] == nil)
                    tempTime = [currentPoint freeTime];
                else
                    tempTime = [[currentPoint timeEquation] evaluate:&ruleSymbols tempos:tempos postures:somePostures andCacheWith:cache];

                /* Calculate value of event */
                //value = (([currentPoint value]/100.0) * (max[parameterIndex] - min[parameterIndex])) + min[parameterIndex];
                value = (([currentPoint value] / 100.0) * (max[parameterIndex] - min[parameterIndex]));
                //maxValue = value;

                /* insert event into event list */
                [self insertEvent:parameterIndex+16 atTimeOffset:tempTime withValue:value];
            }
        }
    }

    [self setZeroRef:(int)(ruleSymbols.ruleDuration * self.multiplier) + zeroRef];
    [[self insertEvent:-1 atTimeOffset:0.0 withValue:0.0] setFlag:YES];
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: postureCount: %lu, footCount: %lu, toneGroupCount: %lu, currentRule: %lu, + a bunch of other stuff, super: %@",
                     NSStringFromClass([self class]), self, postureCount, footCount, toneGroupCount, currentRule, [super description]];
}

- (void)printDataStructures:(NSString *)comment;
{
    NSUInteger toneGroupIndex, footIndex, postureIndex;
    NSUInteger ruleIndex = 0;

    NSLog(@"----------------------------------------------------------------------");
    NSLog(@" > %s (%@)", __PRETTY_FUNCTION__, comment);

    //NSLog(@"toneGroupCount: %d", toneGroupCount);
    for (toneGroupIndex = 0; toneGroupIndex < toneGroupCount; toneGroupIndex++) {
        NSLog(@"Tone Group %lu, type: %@", toneGroupIndex, NSStringFromToneGroupType(toneGroups[toneGroupIndex].type));

        //NSLog(@"tg (%d -- %d)", toneGroups[toneGroupIndex].startFoot, toneGroups[toneGroupIndex].endFoot);
        for (footIndex = toneGroups[toneGroupIndex].startFoot; footIndex <= toneGroups[toneGroupIndex].endFoot; footIndex++) {
            NSLog(@"  Foot %lu  tempo: %.3f, marked: %lu, last: %lu, onset1: %.3f, onset2: %.3f", footIndex, feet[footIndex].tempo,
                  feet[footIndex].marked, feet[footIndex].last, feet[footIndex].onset1, feet[footIndex].onset2);

            //NSLog(@"Foot (%d -- %d)", feet[footIndex].start, feet[footIndex].end);
            for (postureIndex = feet[footIndex].start; postureIndex <= feet[footIndex].end; postureIndex++) {
                if (rules[ruleIndex].firstPhone == postureIndex) {
                    NSLog(@"    Posture %2lu  tempo: %.3f, syllable: %lu, onset: %7.2f, ruleTempo: %.3f, %@ # Rule %2lu, duration: %7.2f, beat: %7.2f",
                          postureIndex, phoneTempo[postureIndex], phones[postureIndex].syllable, phones[postureIndex].onset,
                          phones[postureIndex].ruleTempo, [[phones[postureIndex].phone name] leftJustifiedStringPaddedToLength:18],
                          rules[ruleIndex].number, rules[ruleIndex].duration, rules[ruleIndex].beat);
                    ruleIndex++;
                } else {
                    NSLog(@"    Posture %2lu  tempo: %.3f, syllable: %lu, onset: %7.2f, ruleTempo: %.3f, %@",
                          postureIndex, phoneTempo[postureIndex], phones[postureIndex].syllable, phones[postureIndex].onset,
                          phones[postureIndex].ruleTempo, [phones[postureIndex].phone name]);
                }
            }
        }
    }

    NSLog(@"<  %s", __PRETTY_FUNCTION__);
}

#pragma mark - Intonation points

- (NSArray *)intonationPoints;
{
    if (self.intonationPointsNeedSorting) {
        [intonationPoints sortUsingSelector:@selector(compareByAscendingAbsoluteTime:)];
        self.intonationPointsNeedSorting = NO;
    }

    return intonationPoints;
}

- (void)addIntonationPoint:(MMIntonationPoint *)newIntonationPoint;
{
    NSDictionary *userInfo = nil;

    [intonationPoints addObject:newIntonationPoint];
    [newIntonationPoint setEventList:self];
    self.intonationPointsNeedSorting = YES;
    userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:NSKeyValueChangeInsertion], NSKeyValueChangeKindKey, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:EventListDidChangeIntonationPoints object:self userInfo:userInfo];
    [userInfo release];
}

- (void)removeIntonationPoint:(MMIntonationPoint *)anIntonationPoint;
{
    [anIntonationPoint setEventList:nil];
    [intonationPoints removeObject:anIntonationPoint];
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:NSKeyValueChangeRemoval], NSKeyValueChangeKindKey, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:EventListDidChangeIntonationPoints object:self userInfo:userInfo];
    [userInfo release];
}

- (void)removeIntonationPointsFromArray:(NSArray *)someIntonationPoints;
{
    NSUInteger count, index;
    MMIntonationPoint *anIntonationPoint;

    count = [someIntonationPoints count];
    for (index = 0; index < count; index++) {
        anIntonationPoint = [someIntonationPoints objectAtIndex:index];
        [anIntonationPoint setEventList:nil];
        [intonationPoints removeObject:anIntonationPoint];
    }
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:NSKeyValueChangeRemoval], NSKeyValueChangeKindKey, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:EventListDidChangeIntonationPoints object:self userInfo:userInfo];
    [userInfo release];
}

- (void)removeAllIntonationPoints;
{
    NSDictionary *userInfo = nil;

    [intonationPoints makeObjectsPerformSelector:@selector(setEventList:) withObject:nil];
    [intonationPoints removeAllObjects];
    userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:NSKeyValueChangeRemoval], NSKeyValueChangeKindKey, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:EventListDidChangeIntonationPoints object:self userInfo:nil];
    [userInfo release];
}

#pragma mark - Intonation

- (void)applyIntonation;
{
    if (self.shouldUseSmoothIntonation)
        [self _applySmoothIntonation];
    else
        [self _applyFlatIntonation];
}

// This just add values for the semitone (event 32) for each of the intonation points, clearing the slope, 3rd, and 4th derivatives.
// Values with a semitone of -20 are added at the start and end (but their slopes, etc., aren't reset to 0.).
- (void)_applyFlatIntonation;
{
    NSUInteger count, index;
    MMIntonationPoint *anIntonationPoint;

    NSLog(@" > %s", __PRETTY_FUNCTION__);

    [self setFullTimeScale];
    [self insertEvent:32 atTimeOffset:0.0 withValue:-20.0];

    count = [[self intonationPoints] count]; // This makes sure they get sorted
    NSLog(@"Applying intonation, %lu points", count);

    for (index = 0; index < count; index++) {
        anIntonationPoint = [intonationPoints objectAtIndex:index];
        NSLog(@"Added Event at Time: %f withValue: %f", [anIntonationPoint absoluteTime], [anIntonationPoint semitone]);
        [self insertEvent:32 atTimeOffset:[anIntonationPoint absoluteTime] withValue:[anIntonationPoint semitone]];
        [self insertEvent:33 atTimeOffset:[anIntonationPoint absoluteTime] withValue:0.0];
        [self insertEvent:34 atTimeOffset:[anIntonationPoint absoluteTime] withValue:0.0];
        [self insertEvent:35 atTimeOffset:[anIntonationPoint absoluteTime] withValue:0.0];
    }

    [self finalEvent:32 withValue:-20.0];

    NSLog(@"<  %s", __PRETTY_FUNCTION__);
}

- (void)_applySmoothIntonation;
{
    NSUInteger count, index;
    MMIntonationPoint *point1, *point2;
    MMIntonationPoint *firstIntonationPoint;
    double a, b, c, d;
    double x1, y1, m1, x12, x13;
    double x2, y2, m2, x22, x23;
    double denominator;
    double yTemp;

    //NSLog(@" > %s", _cmd);

    [self setFullTimeScale];

    if ([intonationPoints count] == 0)
        return;

    firstIntonationPoint = [[MMIntonationPoint alloc] init];
    [firstIntonationPoint setSemitone:[[[self intonationPoints] objectAtIndex:0] semitone]]; // Make sure it's sorted
    [firstIntonationPoint setSlope:0.0];
    [firstIntonationPoint setRuleIndex:0];
    [firstIntonationPoint setOffsetTime:0];
    [self addIntonationPoint:firstIntonationPoint];

    count = [[self intonationPoints] count]; // Again, make sure it gets sorted since we just added a point.

    //[self insertEvent:32 atTimeOffset:0.0 withValue:-20.0];
    for (index = 0; index < count - 1; index++) {
        point1 = [intonationPoints objectAtIndex:index];
        point2 = [intonationPoints objectAtIndex:index + 1];

        x1 = [point1 absoluteTime] / 4.0;
        y1 = [point1 semitone] + 20.0;
        m1 = [point1 slope];

        x2 = [point2 absoluteTime] / 4.0;
        y2 = [point2 semitone] + 20.0;
        m2 = [point2 slope];

        x12 = x1*x1;
        x13 = x12*x1;

        x22 = x2*x2;
        x23 = x22*x2;

        denominator = (x2 - x1);
        denominator = denominator * denominator * denominator;

        d = ( -(y2*x13) + 3*y2*x12*x2 + m2*x13*x2 + m1*x12*x22 - m2*x12*x22 - 3*x1*y1*x22 - m1*x1*x23 + y1*x23) / denominator;
        c = ( -(m2*x13) - 6*y2*x1*x2 - 2*m1*x12*x2 - m2*x12*x2 + 6*x1*y1*x2 + m1*x1*x22 + 2*m2*x1*x22 + m1*x23) / denominator;
        b = ( 3*y2*x1 + m1*x12 + 2*m2*x12 - 3*x1*y1 + 3*x2*y2 + m1*x1*x2 - m2*x1*x2 - 3*y1*x2 - 2*m1*x22 - m2*x22) / denominator;
        a = ( -2*y2 - m1*x1 - m2*x1 + 2*y1 + m1*x2 + m2*x2) / denominator;

        [self insertEvent:32 atTimeOffset:[point1 absoluteTime] withValue:[point1 semitone]];

        yTemp = (3.0 * a * x12) + (2.0 * b * x1) + c;
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
    [firstIntonationPoint release];

    //NSLog(@"<  %s", _cmd);
}

// So that we can reapply the current intonation to the events.
- (void)clearIntonationEvents;
{
    [self clearEventNumber:32];
    [self clearEventNumber:33];
    [self clearEventNumber:34];
    [self clearEventNumber:35];
    [self removeEmptyEvents];
}

- (void)clearEventNumber:(NSUInteger)number;
{
    for (Event *event in events) {
        [event setValue:NaN atIndex:number];
    }
}

- (void)removeEmptyEvents;
{
    // TODO (2004-08-17): not yet implemented.
}

- (void)intonationPointTimeDidChange:(MMIntonationPoint *)anIntonationPoint;
{
    self.intonationPointsNeedSorting = YES;
    [self intonationPointDidChange:anIntonationPoint];
}

- (void)intonationPointDidChange:(MMIntonationPoint *)anIntonationPoint;
{
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:NSKeyValueChangeSetting], NSKeyValueChangeKindKey, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:EventListDidChangeIntonationPoints object:self userInfo:userInfo];
    [userInfo release];
}

#pragma mark - Other

#pragma mark - Archiving - XML

- (BOOL)writeXMLToFile:(NSString *)aFilename comment:(NSString *)aComment;
{
    NSMutableString *resultString = [[NSMutableString alloc] init];
    [resultString appendString:@"<?xml version='1.0' encoding='utf-8'?>\n"];
    //[resultString appendString:@"<!DOCTYPE root PUBLIC \"\" \"monet-v1.dtd\">\n"];
    if (aComment != nil)
        [resultString appendFormat:@"<!-- %@ -->\n", aComment];
    [resultString appendString:@"<intonation-contour version='1'>\n"];

    [resultString indentToLevel:1];
    [resultString appendFormat:@"<utterance>%@</utterance>\n", GSXMLCharacterData(phoneString)];

    [[self intonationPoints] appendXMLToString:resultString elementName:@"intonation-points" level:1]; // Make sure they are sorted.

    [resultString appendString:@"</intonation-contour>\n"];

    BOOL result = [[resultString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:aFilename atomically:YES];

    [resultString release];

    return result;
}

#define PARSE_STATE_INITIAL 0
#define PARSE_STATE_ROOT 1

- (BOOL)loadIntonationContourFromXMLFile:(NSString *)filename;
{
    parseState = PARSE_STATE_INITIAL;

    if (filename == nil)
        return NO;
    
    NSURL *fileURL = [NSURL fileURLWithPath:filename];
    MXMLParser *parser = [[MXMLParser alloc] initWithContentsOfURL:fileURL];
    [(MXMLParser *)parser setContext:self];
    [parser pushDelegate:self];
    [parser setShouldResolveExternalEntities:NO];
    BOOL result = [parser parse];
    if (result == NO) {
        NSLog(@"Error: Failed to load file %@, (%@)", filename, [[parser parserError] localizedDescription]);
        //NSRunAlertPanel(@"Error", @"Failed to load file %@, (%@)", @"OK", nil, nil, filename, [[parser parserError] localizedDescription]);
    }
    [parser release];

    return result;
}

- (void)loadStoredPhoneString:(NSString *)aPhoneString;
{
    [self parsePhoneString:aPhoneString];
    [self applyRhythm];
    [self applyRules];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    if (parseState == PARSE_STATE_INITIAL) {
        if ([elementName isEqualToString:@"intonation-contour"]) {
            parseState = PARSE_STATE_ROOT;
        }
    } else if (parseState == PARSE_STATE_ROOT) {
        if ([elementName isEqualToString:@"utterance"]) {
            MXMLPCDataDelegate *newDelegate;

            newDelegate = [[MXMLPCDataDelegate alloc] initWithElementName:elementName delegate:self setSelector:@selector(loadStoredPhoneString:)];
            [(MXMLParser *)parser pushDelegate:newDelegate];
            [newDelegate release];
        } else if([elementName isEqualToString:@"intonation-points"]) {
            MXMLArrayDelegate *newDelegate;

            // TODO (2004-08-21): Perhaps not the most efficient, since a notification will go out each time an intonation point is added.  But good enough for now.
            newDelegate = [[MXMLArrayDelegate alloc] initWithChildElementName:@"intonation-point" class:[MMIntonationPoint class] delegate:self addObjectSelector:@selector(addIntonationPoint:)];
            [(MXMLParser *)parser pushDelegate:newDelegate];
            [newDelegate release];
        } else {
            NSLog(@"starting unknown element: '%@'", elementName);
            [(MXMLParser *)parser skipTree];
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    parseState = PARSE_STATE_INITIAL;
}

#pragma mark -

@synthesize driftGenerator = m_driftGenerator;

@end

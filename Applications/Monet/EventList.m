#import "EventList.h"

#import <Foundation/Foundation.h>
#import "NSString-Extensions.h"
#import "driftGenerator.h"
#import "CategoryList.h"
#import "Event.h"
#import "IntonationPoint.h"
#import "MMEquation.h"
#import "MMFRuleSymbols.h"
#import "MModel.h"
#import "MMParameter.h"
#import "MMPoint.h"
#import "MMPosture.h"
#import "MMRule.h"
#import "MMTransition.h"
#import "MMSlopeRatio.h"
#import "MMTarget.h"
#import "PhoneList.h"

#import "TRMSynthesizer.h" // For addParameters:

NSString *NSStringFromToneGroupType(int toneGroupType)
{
    switch (toneGroupType) {
      case STATEMENT: return @"Statement";
      case EXCLAMATION: return @"Exclamation";
      case QUESTION: return @"Question";
      case CONTINUATION: return @"Continuation";
      case SEMICOLON: return @"Semicolon";
    }

    return nil;
}

@implementation EventList

- (id)init;
{
    if ([super init] == nil)
        return nil;

    events = [[NSMutableArray alloc] init];
    intonationPoints = [[NSMutableArray alloc] init];

    [self setUp];

    setDriftGenerator(1.0, 500.0, 1000.0);
    radiusMultiply = 1.0;

    return self;
}

- (void)dealloc;
{
    [events release];
    [intonationPoints release];
    [delegate release];

    [super dealloc];
}

- (id)delegate;
{
    return delegate;
}

- (void)setDelegate:(id)newDelegate;
{
    if (newDelegate == delegate)
        return;

    [delegate release];
    delegate = [newDelegate retain];
}

- (void)setUp;
{
    NSLog(@"<%@>[%p]  > %s", NSStringFromClass([self class]), self, _cmd);

    [events removeAllObjects];

    zeroRef = 0;
    zeroIndex = 0;
    duration = 0;
    timeQuantization = 4;

    globalTempo = 1.0;
    multiplier = 1.0;
    shouldUseMacroIntonation = NO;
    shouldUseMicroIntonation = NO;
    shouldUseDrift = NO;

    intonationParameters.notionalPitch = 0;
    intonationParameters.pretonicRange = 0;
    intonationParameters.pretonicLift = -2;
    intonationParameters.tonicRange = -8;
    intonationParameters.tonicMovement = -6;

    shouldUseSmoothIntonation = NO;

    currentPhone = 0;
    bzero(phones, MAXPHONES * sizeof(struct _phone));
    // TODO (2004-08-09): What about phoneTempo[]?

    currentFoot = 0;
    bzero(feet, MAXFEET * sizeof(struct _foot));

    currentToneGroup = 0;
    bzero(toneGroups, MAXTONEGROUPS * sizeof(struct _toneGroup));

    currentRule = 0;
    bzero(rules, MAXRULES * sizeof(struct _rule));

    phoneTempo[0] = 1.0;
    feet[0].tempo = 1.0;

    NSLog(@"<%@>[%p] <  %s", NSStringFromClass([self class]), self, _cmd);
}

- (int)zeroRef;
{
    return zeroRef;
}

- (void)setZeroRef:(int)newValue;
{
    int index;

    zeroRef = newValue;
    zeroIndex = 0;

    if ([events count] == 0)
        return;

    for (index = [events count] - 1; index >= 0; index--) {
        //NSLog(@"index = %d", index);
        if ([[events objectAtIndex:index] time] < newValue) {
            zeroIndex = index;
            return;
        }
    }
}

- (int)duration;
{
    return duration;
}

- (void)setDuration:(int)newValue;
{
    NSLog(@"duration: %d", duration);
    duration = newValue;
}

- (double)radiusMultiply;
{
    return radiusMultiply;
}

- (void)setRadiusMultiply:(double)newValue;
{
    radiusMultiply = newValue;
}

- (void)setFullTimeScale;
{
    zeroRef = 0;
    zeroIndex = 0;
    duration = [[events lastObject] time] + 100;
}

- (int)timeQuantization;
{
    return timeQuantization;
}

- (void)setTimeQuantization:(int)newValue;
{
    timeQuantization = newValue;
}

- (BOOL)shouldStoreParameters;
{
    return shouldStoreParameters;
}

- (void)setShouldStoreParameters:(BOOL)newFlag;
{
    shouldStoreParameters = newFlag;
}

- (double)pitchMean;
{
    return pitchMean;
}

- (void)setPitchMean:(double)newMean;
{
    pitchMean = newMean;
}

- (double)globalTempo;
{
    return globalTempo;
}

- (void)setGlobalTempo:(double)newTempo;
{
    globalTempo = newTempo;
}

- (double)multiplier;
{
    return multiplier;
}

- (void)setMultiplier:(double)newValue;
{
    multiplier = newValue;
}

- (BOOL)shouldUseMacroIntonation;
{
    return shouldUseMacroIntonation;
}

- (void)setShouldUseMacroIntonation:(BOOL)newFlag;
{
    shouldUseMacroIntonation = newFlag;
}

- (BOOL)shouldUseMicroIntonation;
{
    return shouldUseMicroIntonation;
}

- (void)setShouldUseMicroIntonation:(BOOL)newFlag;
{
    shouldUseMicroIntonation = newFlag;
}

- (BOOL)shouldUseDrift;
{
    return shouldUseDrift;
}

- (void)setShouldUseDrift:(BOOL)newFlag;
{
    shouldUseDrift = newFlag;
}

- (BOOL)shouldUseSmoothIntonation;
{
    return shouldUseSmoothIntonation;
}

- (void)setShouldUseSmoothIntonation:(BOOL)newValue;
{
    shouldUseSmoothIntonation = newValue;
}

- (struct _intonationParameters)intonationParameters;
{
    return intonationParameters;
}

- (void)setIntonationParameters:(struct _intonationParameters)newIntonationParameters;
{
    intonationParameters = newIntonationParameters;
}

- (MMPosture *)getPhoneAtIndex:(int)phoneIndex;
{
    if (phoneIndex > currentPhone)
        return nil;

    return phones[phoneIndex].phone;
}

- (struct _rule *)getRuleAtIndex:(int)ruleIndex;
{
    if (ruleIndex > currentRule)
        return NULL;

    return &rules[ruleIndex];
}

- (NSString *)ruleDescriptionAtIndex:(int)ruleIndex;
{
    NSMutableString *str;
    struct _rule *rule;
    int index;

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

- (double)getBeatAtIndex:(int)ruleIndex;
{
    if (ruleIndex > currentRule)
        return 0.0;

    return rules[ruleIndex].beat;
}

- (int)numberOfRules;
{
    return currentRule;
}

//
// Tone groups
//

- (void)newToneGroup;
{
    if (currentFoot == 0)
        return;

    toneGroups[currentToneGroup++].endFoot = currentFoot;
    [self newFoot];

    toneGroups[currentToneGroup].startFoot = currentFoot;
    toneGroups[currentToneGroup].endFoot = -1;
}

- (void)setCurrentToneGroupType:(int)type;
{
    toneGroups[currentToneGroup].type = type;
}

//
// Feet
//

- (void)newFoot;
{
    if (currentPhone == 0)
        return;

    feet[currentFoot++].end = currentPhone;
    [self newPhone];

    feet[currentFoot].start = currentPhone;
    feet[currentFoot].end = -1;
    feet[currentFoot].tempo = 1.0;
}

- (void)setCurrentFootMarked;
{
    feet[currentFoot].marked = 1;
}

- (void)setCurrentFootLast;
{
    feet[currentFoot].last = 1;
}

- (void)setCurrentFootTempo:(double)tempo;
{
    feet[currentFoot].tempo = tempo;
}

- (void)newPhone;
{
    if (phones[currentPhone].phone)
        currentPhone++;
    phoneTempo[currentPhone] = 1.0;
}

- (void)newPhoneWithObject:(MMPosture *)anObject;
{
    if (phones[currentPhone].phone)
        currentPhone++;
    phoneTempo[currentPhone] = 1.0;
    phones[currentPhone].ruleTempo = 1.0;
    phones[currentPhone].phone = anObject;
}

- (void)replaceCurrentPhoneWith:(MMPosture *)anObject;
{
    if (phones[currentPhone].phone)
        phones[currentPhone].phone = anObject;
    else
        phones[currentPhone-1].phone = anObject;
    NSLog(@"Replacing %@ with %@", [phones[currentPhone].phone name], [anObject name]);
}

- (void)setCurrentPhoneTempo:(double)tempo;
{
    phoneTempo[currentPhone] = tempo;
}

- (void)setCurrentPhoneRuleTempo:(float)tempo;
{
    phones[currentPhone].ruleTempo = tempo;
}

- (void)setCurrentPhoneSyllable;
{
    phones[currentPhone].syllable = 1;
}

- (NSArray *)events;
{
    return events;
}

// Get the event a time "time", creating it if necessary and insserting into "events" array.
- (Event *)eventAtTime:(double)time;
{
    Event *newEvent = nil;
    int i, tempTime;

    time = time * multiplier;
    if (time < 0.0)
        return nil;
    if (time > (double)(duration + timeQuantization))
        return nil;

    tempTime = zeroRef + (int)time;
    tempTime = tempTime - (tempTime % timeQuantization);

    // If there are no events yet, we can just add it.
    if ([events count] == 0) {
        newEvent = [[[Event alloc] initWithTime:tempTime] autorelease];
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
            newEvent = [[[Event alloc] initWithTime:tempTime] autorelease];
            [events insertObject:newEvent atIndex:i+1];
            return newEvent;
        }
    }

    // In this case the event should come at the end of the list.
    newEvent = [[[Event alloc] initWithTime:tempTime] autorelease];
    [events insertObject:newEvent atIndex:i+1];

    return newEvent;
}

- (Event *)insertEvent:(int)number atTime:(double)time withValue:(double)value;
{
    Event *event;

    event = [self eventAtTime:time];
    if (number >= 0) {
        if ((number >= 7) && (number <= 8))
            [event setValue:value*radiusMultiply ofIndex:number];
        else
            [event setValue:value ofIndex:number];
    }

    return event;
}

- (void)finalEvent:(int)number withValue:(double)value;
{
    Event *lastEvent;

    lastEvent = [events lastObject];
    [lastEvent setValue:value ofIndex:number];
    [lastEvent setFlag:YES];
}

- (void)generateOutput;
{
    int i, j, k;
    int currentTime, nextTime;
    double currentValues[36];
    double currentDeltas[36];
    double temp;
    float table[16];
    FILE *fp;

    //NSLog(@"%s, self: %@", _cmd, self);

    if ([events count] == 0)
        return;

    if (shouldStoreParameters == YES) {
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

    if (shouldUseSmoothIntonation) {
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
        if (!shouldUseMicroIntonation)
            table[0] = 0.0;
        if (shouldUseDrift)
            table[0] += drift();
        if (shouldUseMacroIntonation) {
            //NSLog(@"sumi, table[0]: %f, currentValues[32]: %f", table[0], currentValues[32]);
            table[0] += currentValues[32];
        }

        table[0] += pitchMean;

        if (fp)
            fprintf(fp, "%.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f\n",
                    table[0], table[1], table[2], table[3],
                    table[4], table[5], table[6], table[7],
                    table[8], table[9], table[10], table[11],
                    table[12], table[13], table[14], table[15]);

        if (delegate != nil && [delegate respondsToSelector:@selector(addParameters:)] == YES)
            [delegate addParameters:table];

        for (j = 0 ; j < 32; j++) {
            if (currentDeltas[j])
                currentValues[j] += currentDeltas[j];
        }
        if (shouldUseSmoothIntonation) {
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
            if (shouldUseSmoothIntonation) {
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
}

- (void)generateEventListWithModel:(MModel *)aModel;
{
    NSLog(@" > %s", _cmd);

    [self printDataStructures:@"Start of generateEventListWithModel:"];
    assert(aModel != nil);

    // Record min/max values for each of the parameters
    {
        NSMutableArray *parameters = [aModel parameters];
        int count, index;
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

    // Adjust the tempos of each of the feet.  They start out at 1.0.
    {
        int i, j;

        NSLog(@"currentFoot: %d", currentFoot);
        for (i = 0; i < currentFoot; i++) {
            int rus;
            double footTempo;

            rus = feet[i].end - feet[i].start + 1;

            /* Apply rhythm model */
            if (feet[i].marked) {
                double tempo;

                tempo = 117.7 - (19.36 * (double)rus);
                feet[i].tempo -= tempo / 180.0;
                //NSLog(@"Rus = %d tempTempo = %f", rus, tempo);
                footTempo = globalTempo * feet[i].tempo;
            } else {
                double tempo;

                tempo = 18.5 - (2.08 * (double)rus);
                feet[i].tempo -= tempo / 140.0;
                //NSLog(@"Rus = %d tempTempo = %f", rus, tempTempo);
                footTempo = globalTempo * feet[i].tempo;
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
        [self printDataStructures:@"Changed tempos"];
    }

    {
        NSMutableArray *tempPhoneList, *tempCategoryList;
        int index, j;

        tempPhoneList = [[NSMutableArray alloc] init];
        tempCategoryList = [[NSMutableArray alloc] init];

        // Apply rules
        for (index = 0; index < currentPhone - 1; ) {
            int ruleIndex;
            MMRule *matchedRule;

            [tempPhoneList removeAllObjects];
            [tempCategoryList removeAllObjects];

            for (j = 0; j < 4; j++) {
                if (phones[j+index].phone != nil) {
                    [tempPhoneList addObject:phones[j+index].phone];
                    [tempCategoryList addObject:[phones[j+index].phone categories]];
                }
            }

            matchedRule = [aModel findRuleMatchingCategories:tempCategoryList ruleIndex:&ruleIndex];
            rules[currentRule].number = ruleIndex + 1;

            NSLog(@"----------------------------------------------------------------------");
            NSLog(@"Applying rule %d", ruleIndex + 1);
            [self applyRule:matchedRule withPhones:tempPhoneList andTempos:&phoneTempo[index] phoneIndex:index model:aModel];

            index += [matchedRule numberExpressions] - 1;
        }

        [tempPhoneList release];
        [tempCategoryList release];
    }


//    if (currentPhone)
//        [self applyIntonation];

    [[events lastObject] setFlag:YES];

    [self printDataStructures:@"Applied rules"];

    NSLog(@"%s, EventList count: %d", _cmd, [events count]);

    NSLog(@"<  %s", _cmd);
}

// 1. Calculate the rule symbols (Rule Duration, Beat, Mark 1, Mark 2, Mark 3), given tempos and phones.
// 2.
- (void)applyRule:(MMRule *)rule withPhones:(NSArray *)phoneList andTempos:(double *)tempos phoneIndex:(int)phoneIndex model:(MModel *)aModel;
{
    int i, j, type;
    BOOL shouldCalculate;
    int currentType;
    double currentDelta, value, maxValue;
    double tempTime, targets[4];
    MMFRuleSymbols ruleSymbols;
    MMTransition *transition;
    MMPoint *currentPoint;
    NSArray *parameterTransitions;
    MonetList *points;
    int cache = [aModel nextCacheTag];

    bzero(&ruleSymbols, sizeof(MMFRuleSymbols));
    [rule evaluateSymbolEquations:&ruleSymbols tempos:tempos phones:phoneList withCache:cache];
    NSLog(@"Rule symbols, duration: %.2f, beat: %.2f, mark1: %.2f, mark2: %.2f, mark3: %.2f",
          ruleSymbols.ruleDuration, ruleSymbols.beat, ruleSymbols.mark1, ruleSymbols.mark2, ruleSymbols.mark3);

    // TODO (2004-08-14): Is this supposed to change the multiplier?  I suppose so, since setMultiplier: is never used.
    NSLog(@"multiplier before: %f", multiplier);
    multiplier = 1.0 / (double)(phones[phoneIndex].ruleTempo);
    NSLog(@"multiplier after: %f", multiplier);

    type = [rule numberExpressions];
    [self setDuration:(int)(ruleSymbols.ruleDuration * multiplier)];

    rules[currentRule].firstPhone = phoneIndex;
    rules[currentRule].lastPhone = phoneIndex + (type - 1);
    rules[currentRule].beat = (ruleSymbols.beat * multiplier) + (double)zeroRef;
    rules[currentRule++].duration = ruleSymbols.ruleDuration * multiplier;

    // This creates events (if necessary) at the posture times, and sets the "flag" on them to indicate this is for a posture.
    switch (type) {
        /* Note: Case 4 should execute all of the below, case 3 the last two */
      case MMPhoneTypeTetraphone:
          phones[phoneIndex+3].onset = (double)zeroRef + ruleSymbols.beat;
          [[self insertEvent:-1 atTime:ruleSymbols.mark2 withValue:0.0] setFlag:YES];
      case MMPhoneTypeTriphone:
          phones[phoneIndex+2].onset = (double)zeroRef + ruleSymbols.beat;
          [[self insertEvent:-1 atTime:ruleSymbols.mark1 withValue:0.0] setFlag:YES];
      case MMPhoneTypeDiphone:
          phones[phoneIndex+1].onset = (double)zeroRef + ruleSymbols.beat;
          [[self insertEvent:-1 atTime:0.0 withValue:0.0] setFlag:YES];
          break;
    }

    parameterTransitions = [rule parameterTransitions];

    /* Loop through the parameters */
    for (i = 0; i < [parameterTransitions count]; i++) {
        unsigned int postureCount;
        unsigned int targetIndex;

        /* Get actual parameter target values */
        postureCount = [phoneList count];
        for (targetIndex = 0; targetIndex < 4 && targetIndex < postureCount; targetIndex++)
            targets[targetIndex] = [(MMTarget *)[[[phoneList objectAtIndex:targetIndex] parameterTargets] objectAtIndex:i] value];
        for (; targetIndex < 4; targetIndex++)
            targets[targetIndex] = 0.0;

        //NSLog(@"Targets %f %f %f %f", targets[0], targets[1], targets[2], targets[3]);

        // Optimization: Don't calculate if no changes occur.
        shouldCalculate = YES;
        switch (type) {
          case MMPhoneTypeDiphone:
              if (targets[0] == targets[1])
                  shouldCalculate = NO;
              break;
          case MMPhoneTypeTriphone:
              if ((targets[0] == targets[1]) && (targets[0] == targets[2]))
                  shouldCalculate = NO;
              break;
          case MMPhoneTypeTetraphone:
              if ((targets[0] == targets[1]) && (targets[0] == targets[2]) && (targets[0] == targets[3]))
                  shouldCalculate = NO;
              break;
        }

        if (shouldCalculate) {
            currentType = MMPhoneTypeDiphone;
            currentDelta = targets[1] - targets[0];

            /* Get transition profile list */
            transition = (MMTransition *)[parameterTransitions objectAtIndex:i];
            points = [transition points];

            maxValue = 0.0;

            /* Apply lists to parameter */
            for (j = 0; j < [points count]; j++) {
                currentPoint = [points objectAtIndex:j];

                if ([currentPoint isKindOfClass:[MMSlopeRatio class]]) {
                    if ([(MMPoint *)[[(MMSlopeRatio *)currentPoint points] objectAtIndex:0] type] != currentType) {
                        currentType = [(MMPoint *)[[(MMSlopeRatio *)currentPoint points] objectAtIndex:0] type];
                        targets[currentType-2] = maxValue;
                        currentDelta = targets[currentType-1] - maxValue;
                    }
                } else {
                    if ([currentPoint type] != currentType) {
                        currentType = [currentPoint type];
                        targets[currentType-2] = maxValue;
                        currentDelta = targets[currentType-1] - maxValue;
                    }

                    /* insert event into event list */
                    //tempEvent = [self insertEvent:i atTime:tempTime withValue:value];
                }
                // TODO (2004-03-01): I don't see how this works...
                maxValue = [currentPoint calculatePoints:&ruleSymbols tempos:tempos phones:phoneList
                                         andCacheWith:cache baseline:targets[currentType-2] delta:currentDelta
                                         min:min[i] max:max[i] toEventList:self atIndex:(int)i];
            }
        } else {
            [self insertEvent:i atTime:0.0 withValue:targets[0]];
        }
    }

    /* Special Event Profiles */
    for (i = 0; i < 16; i++) {
        if ((transition = [rule getSpecialProfile:i])) {
            /* Get transition profile list */
            points = [transition points];

            for (j = 0; j < [points count]; j++) {
                currentPoint = [points objectAtIndex:j];

                /* calculate time of event */
                if ([currentPoint expression] == nil)
                    tempTime = [currentPoint freeTime];
                else
                    tempTime = [[currentPoint expression] evaluate:&ruleSymbols tempos:tempos phones:phoneList andCacheWith:cache];

                /* Calculate value of event */
                //value = (([currentPoint value]/100.0) * (max[i] - min[i])) + min[i];
                value = (([currentPoint value]/100.0) * (max[i] - min[i]));
                maxValue = value;

                /* insert event into event list */
                [self insertEvent:i+16 atTime:tempTime withValue:value];
            }
        }
    }

    [self setZeroRef:(int)(ruleSymbols.ruleDuration * multiplier) + zeroRef];
    [[self insertEvent:-1 atTime:0.0 withValue:0.0] setFlag:YES];
}

- (void)synthesizeToFile:(NSString *)filename;
{
    NSLog(@"Warning: No DSP for -synthesizeToFile:");
}

// Warning (building for 10.2 deployment) (2004-04-02): ruleIndex might be used uninitialized in this function
- (void)applyIntonation;
{
    int firstFoot, endFoot;
    int ruleIndex, phoneIndex;
    int i, j, k;
    double startTime, endTime, pretonicDelta, offsetTime = 0.0;
    double randomSemitone, randomSlope;

    zeroRef = 0;
    zeroIndex = 0;
    duration = [[events lastObject] time] + 100;

    [self clearIntonationPoints];
//    [self addPoint:-20.0 offsetTime:0.0 slope:0.0 ruleIndex:0];

    for (i = 0; i < currentToneGroup; i++) {
        firstFoot = toneGroups[i].startFoot;
        endFoot = toneGroups[i].endFoot;

        startTime  = phones[feet[firstFoot].start].onset;
        endTime  = phones[feet[endFoot].end].onset;

        pretonicDelta = (intonationParameters.pretonicRange) / (endTime - startTime);
        NSLog(@"Pretonic Delta = %f time = %f", pretonicDelta, (endTime - startTime));

        /* Set up intonation boundary variables */
        for (j = firstFoot; j <= endFoot; j++) {
            phoneIndex = feet[j].start;
            while ([phones[phoneIndex].phone isMemberOfCategoryNamed:@"vocoid"] == NO) {
                phoneIndex++;
                NSLog(@"Checking phone %@ for vocoid", [phones[phoneIndex].phone name]);
                if (phoneIndex > feet[j].end) {
                    phoneIndex = feet[j].start;
                    break;
                }
            }

            if (!feet[j].marked) {
                for (k = 0; k < currentRule; k++) {
                    if ((phoneIndex >= rules[k].firstPhone) && (phoneIndex <= rules[k].lastPhone)) {
                        ruleIndex = k;
                        break;
                    }
                }

                randomSemitone = ((double)random() / (double)0x7fffffff) * (double)intonationParameters.pretonicLift - intonationParameters.pretonicLift / 2.0;
                randomSlope = ((double)random() / (double)0x7fffffff) * 0.015 + 0.02;

                [self addPoint:((phones[phoneIndex].onset-startTime) * pretonicDelta) + intonationParameters.notionalPitch + randomSemitone
                      offsetTime:offsetTime slope:randomSlope ruleIndex:ruleIndex];

//                NSLog(@"Calculated Delta = %f  time = %f", ((phones[phoneIndex].onset-startTime)*pretonicDelta),
//                       (phones[phoneIndex].onset-startTime));
            } else { /* Tonic */
                for (k = 0; k < currentRule; k++) {
                    if ((phoneIndex >= rules[k].firstPhone) && (phoneIndex <= rules[k].lastPhone)) {
                        ruleIndex = k;
                        break;
                    }
                }

                randomSlope = ((double)random() / (double)0x7fffffff) * 0.03 + 0.02;

                [self addPoint:intonationParameters.pretonicRange + intonationParameters.notionalPitch
                      offsetTime:offsetTime slope:randomSlope ruleIndex:ruleIndex];

                phoneIndex = feet[j].end;
                for (k = ruleIndex; k < currentRule; k++) {
                    if ((phoneIndex >= rules[k].firstPhone) && (phoneIndex <= rules[k].lastPhone)) {
                        ruleIndex = k;
                        break;
                    }
                }

                [self addPoint:intonationParameters.pretonicRange + intonationParameters.notionalPitch + intonationParameters.tonicRange
                      offsetTime:0.0 slope:0.0 ruleIndex:ruleIndex];

            }

            offsetTime = -40.0;
        }
    }
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: currentPhone: %d, currentFoot: %d, currentToneGroup: %d, currentRule: %d, + a bunch of other stuff, super: %@",
                     NSStringFromClass([self class]), self, currentPhone, currentFoot, currentToneGroup, currentRule, [super description]];
}

- (void)printDataStructures:(NSString *)comment;
{
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@" > %s (%@)", _cmd, comment);
#if 0
    {
        int i;

        NSLog(@"Tone Groups %d", currentToneGroup);
        for (i = 0; i < currentToneGroup; i++) {
            NSLog(@"%d  start: %d, end: %d, type: %d", i, toneGroups[i].startFoot, toneGroups[i].endFoot, toneGroups[i].type);
        }

        NSLog(@"\n");
        NSLog(@"Feet %d", currentFoot);
        for (i = 0; i < currentFoot; i++) {
            NSLog(@"%d  tempo: %.3f, start: %2d, end: %2d, marked: %d, last: %d, onset1: %.3f, onset2: %.3f", i, feet[i].tempo,
                  feet[i].start, feet[i].end, feet[i].marked, feet[i].last, feet[i].onset1, feet[i].onset2);
        }

        NSLog(@"\n");
        NSLog(@"Phones %d", currentPhone);
        for (i = 0; i < currentPhone; i++) {
            NSLog(@"%3d  tempo: %.3f, syllable: %d, onset: %7.2f, ruleTempo: %.3f, %@",
                  i, phoneTempo[i], phones[i].syllable, phones[i].onset, phones[i].ruleTempo, [phones[i].phone symbol]);
        }

        NSLog(@"\n");
        NSLog(@"Rules %d", currentRule);
        for (i = 0; i < currentRule; i++) {
            NSLog(@"Number: %2d  start: %2d, end: %2d, duration %7.2f", rules[i].number, rules[i].firstPhone,
                  rules[i].lastPhone, rules[i].duration);
        }

        NSLog(@"\n\n");
    }
#endif
    {
        int toneGroupIndex, footIndex, postureIndex;
        int ruleIndex = 0;

        for (toneGroupIndex = 0; toneGroupIndex < currentToneGroup; toneGroupIndex++) {
            NSLog(@"Tone Group %d, type: %@", toneGroupIndex, NSStringFromToneGroupType(toneGroups[toneGroupIndex].type));

            for (footIndex = toneGroups[toneGroupIndex].startFoot; footIndex <= toneGroups[toneGroupIndex].endFoot; footIndex++) {
                NSLog(@"  Foot %d  tempo: %.3f, marked: %d, last: %d, onset1: %.3f, onset2: %.3f", footIndex, feet[footIndex].tempo,
                      feet[footIndex].marked, feet[footIndex].last, feet[footIndex].onset1, feet[footIndex].onset2);

                for (postureIndex = feet[footIndex].start; postureIndex <= feet[footIndex].end; postureIndex++) {
                    if (rules[ruleIndex].firstPhone == postureIndex) {
                        NSLog(@"    Posture %2d  tempo: %.3f, syllable: %d, onset: %7.2f, ruleTempo: %.3f, %@ # Rule %2d, duration: %7.2f, beat: %7.2f",
                              postureIndex, phoneTempo[postureIndex], phones[postureIndex].syllable, phones[postureIndex].onset,
                              phones[postureIndex].ruleTempo, [[phones[postureIndex].phone name] leftJustifiedStringPaddedToLength:18],
                              rules[ruleIndex].number, rules[ruleIndex].duration, rules[ruleIndex].beat);
                        ruleIndex++;
                    } else {
                        NSLog(@"    Posture %2d  tempo: %.3f, syllable: %d, onset: %7.2f, ruleTempo: %.3f, %@",
                              postureIndex, phoneTempo[postureIndex], phones[postureIndex].syllable, phones[postureIndex].onset,
                              phones[postureIndex].ruleTempo, [phones[postureIndex].phone name]);
                    }
                }
            }
        }
    }

    NSLog(@"<  %s", _cmd);
}

- (NSArray *)intonationPoints;
{
    return intonationPoints;
}

- (void)removeIntonationPoint:(IntonationPoint *)aPoint;
{
    [intonationPoints removeObject:aPoint];
}

//
// Moved from IntonationView
//

- (void)clearIntonationPoints;
{
    [intonationPoints removeAllObjects];
}

- (void)addIntonationPoint:(IntonationPoint *)iPoint;
{
    double time;
    int i;

    NSLog(@" > %s", _cmd);

//    NSLog(@"Point  Semitone: %f  timeOffset:%f slope:%f phoneIndex:%d", [iPoint semitone], [iPoint offsetTime],
//           [iPoint slope], [iPoint ruleIndex]);

    if ([iPoint ruleIndex] > [self numberOfRules]) {
        NSLog(@"%d > %d", [iPoint ruleIndex], [self numberOfRules]);
        NSLog(@"<  %s", _cmd);
        return;
    }

    [intonationPoints removeObject:iPoint];
    time = [iPoint absoluteTime];
    for (i = 0; i < [intonationPoints count]; i++) {
        if (time < [[intonationPoints objectAtIndex:i] absoluteTime]) {
            [intonationPoints insertObject:iPoint atIndex:i];
            return;
        }
    }

    [intonationPoints addObject:iPoint];

    NSLog(@"<  %s", _cmd);
}

- (void)addPoint:(double)semitone offsetTime:(double)offsetTime slope:(double)slope ruleIndex:(int)ruleIndex;
{
    IntonationPoint *newIntonationPoint;

    NSLog(@" > %s", _cmd);
    NSLog(@"semitone: %g, offsetTime: %g, slope: %g, ruleIndex: %d", semitone, offsetTime, slope, ruleIndex);

    newIntonationPoint = [[IntonationPoint alloc] initWithEventList:self];
    [newIntonationPoint setRuleIndex:ruleIndex];
    [newIntonationPoint setOffsetTime:offsetTime];
    [newIntonationPoint setSemitone:semitone];
    [newIntonationPoint setSlope:slope];
    [self addIntonationPoint:newIntonationPoint];
    [newIntonationPoint release];

    NSLog(@"<  %s", _cmd);
}

- (void)applyIntonation_fromIntonationView;
{
    int i;
    IntonationPoint *anIntonationPoint;

    NSLog(@" > %s", _cmd);

    [self setFullTimeScale];
    [self insertEvent:32 atTime:0.0 withValue:-20.0];
    NSLog(@"Applying intonation, %d points", [intonationPoints count]);

    for (i = 0; i < [intonationPoints count]; i++) {
        anIntonationPoint = [intonationPoints objectAtIndex:i];
        NSLog(@"Added Event at Time: %f withValue: %f", [anIntonationPoint absoluteTime], [anIntonationPoint semitone]);
        [self insertEvent:32 atTime:[anIntonationPoint absoluteTime] withValue:[anIntonationPoint semitone]];
        [self insertEvent:33 atTime:[anIntonationPoint absoluteTime] withValue:0.0];
        [self insertEvent:34 atTime:[anIntonationPoint absoluteTime] withValue:0.0];
        [self insertEvent:35 atTime:[anIntonationPoint absoluteTime] withValue:0.0];
    }

    [self finalEvent:32 withValue:-20.0];

    NSLog(@"<  %s", _cmd);
}

- (void)applySmoothIntonation;
{
    int j;
    IntonationPoint *point1, *point2;
    IntonationPoint *tempPoint;
    double a, b, c, d;
    double x1, y1, m1, x12, x13;
    double x2, y2, m2, x22, x23;
    double denominator;
    double yTemp;

    NSLog(@" > %s", _cmd);

    [self setFullTimeScale];
    tempPoint = [[IntonationPoint alloc] initWithEventList:self];
    if ([intonationPoints count] > 0)
        [tempPoint setSemitone:[[intonationPoints objectAtIndex:0] semitone]];
    [tempPoint setSlope:0.0];
    [tempPoint setRuleIndex:0];
    [tempPoint setOffsetTime:0];

    [intonationPoints insertObject:tempPoint atIndex:0];

    NSLog(@"[intonationPoints count]: %d", [intonationPoints count]);

    //[self insertEvent:32 atTime: 0.0 withValue: -20.0];
    for (j = 0; j < [intonationPoints count] - 1; j++) {
        point1 = [intonationPoints objectAtIndex:j];
        point2 = [intonationPoints objectAtIndex:j + 1];

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

        [self insertEvent:32 atTime:[point1 absoluteTime] withValue:[point1 semitone]];

        yTemp = (3.0*a*x12) + (2.0*b*x1) + c;
        NSLog(@"j: %d, event 33: %g", j, yTemp);
        [self insertEvent:33 atTime:[point1 absoluteTime] withValue:yTemp];

        yTemp = (6.0*a*x1) + (2.0*b);
        NSLog(@"j: %d, event 34: %g", j, yTemp);
        [self insertEvent:34 atTime:[point1 absoluteTime] withValue:yTemp];

        yTemp = (6.0*a);
        NSLog(@"j: %d, event 35: %g", j, yTemp);
        [self insertEvent:35 atTime:[point1 absoluteTime] withValue:yTemp];
    }

    [intonationPoints removeObjectAtIndex:0];

    NSLog(@"<  %s", _cmd);
}

@end

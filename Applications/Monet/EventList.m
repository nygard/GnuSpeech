#import "EventList.h"

#import <Foundation/Foundation.h>
#import "driftGenerator.h"
#import "CategoryList.h"
#import "Event.h"
#import "IntonationPoint.h"
#import "MMEquation.h"
#import "MModel.h"
#import "MMParameter.h"
#import "MMPoint.h"
#import "MMPosture.h"
#import "MMRule.h"
#import "MMTransition.h"
#import "MMSlopeRatio.h"
#import "MMTarget.h"
#import "PhoneList.h"
#import "ParameterList.h"
#import "RuleList.h"
#import "TargetList.h"

@implementation EventList

- (id)initWithCapacity:(unsigned int)numSlots;
{
    if ([super initWithCapacity:numSlots] == nil)
        return nil;

    cache = 10000000;
    intonationPoints = [[NSMutableArray alloc] init];

    [self setUp];

    setDriftGenerator(1.0, 500.0, 1000.0);
    radiusMultiply = 1.0;

    return self;
}

- (void)dealloc;
{
    [intonationPoints release];

    [super dealloc];
}

- (void)setUp;
{
    NSLog(@"<%@>[%p]  > %s", NSStringFromClass([self class]), self, _cmd);

    [self removeAllObjects];

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

    bzero(phones, MAXPHONES * sizeof(struct _phone));
    bzero(feet, MAXFEET * sizeof(struct _foot));
    bzero(toneGroups, MAXTONEGROUPS * sizeof(struct _toneGroup));

    bzero(rules, MAXRULES * sizeof(struct _rule));

    currentPhone = 0;
    currentFoot = 0;
    currentToneGroup = 0;

    currentRule = 0;

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

    if ([self count] == 0)
        return;

    for (index = [self count] - 1; index >= 0; index--) {
        //NSLog(@"index = %d", index);
        if ([[self objectAtIndex:index] time] < newValue) {
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
    duration = [[self lastObject] time] + 100;
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

- (BOOL)shouldUseSoftwareSynthesis;
{
    return shouldUseSoftwareSynthesis;
}

- (void)setShouldUseSoftwareSynthesis:(BOOL)newFlag;
{
    shouldUseSoftwareSynthesis = newFlag;
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
        [str appendString:[[self getPhoneAtIndex:index] symbol]];
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
    NSLog(@"Replacing %@ with %@", [phones[currentPhone].phone symbol], [anObject symbol]);
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

- (Event *)insertEvent:(int)number atTime:(double)time withValue:(double)value;
{
    Event *newEvent = nil;
    int i, tempTime;

    time = time * multiplier;
    if (time < 0.0)
        return nil;
    if (time > (double)(duration + timeQuantization))
        return nil;

    tempTime = zeroRef + (int) time;
    tempTime = (tempTime >> 2) << 2;
//    if ((tempTime % timeQuantization) != 0)
//        tempTime++;


    if ([self count] == 0) {
        newEvent = [[[Event alloc] init] autorelease];
        [newEvent setTime:tempTime];
        if (number >= 0) {
            if ((number >= 7) && (number <= 8))
                [newEvent setValue:value*radiusMultiply ofIndex:number];
            else
                [newEvent setValue:value ofIndex:number];
        }

        [self addObject:newEvent];
        return newEvent;
    }

    for (i = [self count] - 1; i >= zeroIndex; i--) {
        if ([[self objectAtIndex:i] time] == tempTime) {
            if (number >= 0) {
                if ((number >= 7) && (number <= 8))
                    [[self objectAtIndex:i] setValue:value*radiusMultiply ofIndex:number];
                else
                    [[self objectAtIndex:i] setValue:value ofIndex:number];
            }

            return [self objectAtIndex:i];
        }

        if ([[self objectAtIndex: i] time]< tempTime) {
            newEvent = [[[Event alloc] init] autorelease];
            [newEvent setTime:tempTime];
            if (number >= 0) {
                if ((number >= 7) && (number <= 8))
                    [newEvent setValue:value*radiusMultiply ofIndex:number];
                else
                    [newEvent setValue:value ofIndex:number];
            }

            [self insertObject:newEvent atIndex:i+1];
            return newEvent;
        }
    }


    newEvent = [[[Event alloc] init] autorelease];
    [newEvent setTime:tempTime];
    if (number >= 0) {
        if ((number >= 7) && (number <= 8))
            [newEvent setValue:value*radiusMultiply ofIndex:number];
        else
            [newEvent setValue:value ofIndex:number];
    }

    [self insertObject:newEvent atIndex:i+1];

    return newEvent;
}

- (void)finalEvent:(int)number withValue:(double)value;
{
    Event *lastEvent;

    lastEvent = [self lastObject];
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

    NSLog(@"%s, self: %@", _cmd, self);

    if ([self count] == 0)
        return;

    if (shouldStoreParameters == NO) {
        fp = fopen("/tmp/Monet.parameters", "w");
    } else if (shouldUseSoftwareSynthesis) {
        NSLog(@"%s, software synthesis enabled.", _cmd);
        fp = fopen("/tmp/Monet.parameters", "a+");
    } else
        fp = NULL;

    currentTime = 0;
    for (i = 0; i < 16; i++) {
        j = 1;
        while ( ( temp = [[self objectAtIndex:j] getValueAtIndex:i]) == NaN)
            j++;

        currentValues[i] = [[self objectAtIndex:0] getValueAtIndex:i];
        currentDeltas[i] = ((temp - currentValues[i]) / (double) ([[self objectAtIndex:j] time])) * 4.0;
    }

    for (i = 16; i < 36; i++)
        currentValues[i] = currentDeltas[i] = 0.0;

    if (shouldUseSmoothIntonation) {
        j = 0;
        while ( (temp = [[self objectAtIndex:j] getValueAtIndex:32]) == NaN) {
            j++;
            if (j >= [self count])
                break;
        }

        currentValues[32] = [[self objectAtIndex:j] getValueAtIndex:32];
        currentDeltas[32] = 0.0;
        //NSLog(@"Smooth intonation: %f %f j = %d", currentValues[32], currentDeltas[32], j);
    } else {
        j = 1;
        while ( (temp = [[self objectAtIndex:j] getValueAtIndex:32]) == NaN) {
            j++;
            if (j >= [self count])
                break;
        }

        currentValues[32] = [[self objectAtIndex:0] getValueAtIndex:32];
        if (j < [self count])
            currentDeltas[32] = ((temp - currentValues[32]) / (double) ([[self objectAtIndex:j] time])) * 4.0;
        else
            currentDeltas[32] = 0;
    }

//    NSLog(@"Starting Values:");
//    for (i = 0; i < 32; i++)
//        NSLog(@"%d;  cv: %f  cd: %f", i, currentValues[i], currentDeltas[i]);

    i = 1;
    currentTime = 0;
    nextTime = [[self objectAtIndex:1] time];
    while (i < [self count]) {
        for (j = 0; j < 16; j++) {
            table[j] = (float)currentValues[j] + (float)currentValues[j+16];
        }
        if (!shouldUseMicroIntonation)
            table[0] = 0.0;
        if (shouldUseDrift)
            table[0] += drift();
        if (shouldUseMacroIntonation)
            table[0] += currentValues[32];

        table[0] += pitchMean;

        if (fp)
            fprintf(fp, "%.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f\n",
                    table[0], table[1], table[2], table[3],
                    table[4], table[5], table[6], table[7],
                    table[8], table[9], table[10], table[11],
                    table[12], table[13], table[14], table[15]);

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
            if (i == [self count])
                break;

            nextTime = [[self objectAtIndex:i] time];
            for (j = 0; j < 33; j++) {
                if ([[self objectAtIndex:i-1] getValueAtIndex:j] != NaN) {
                    k = i;
                    while ((temp = [[self objectAtIndex:k] getValueAtIndex:j]) == NaN) {
                        if (k >= [self count] - 1) {
                            currentDeltas[j] = 0.0;
                            break;
                        }
                        k++;
                    }

                    if (temp != NaN) {
                        currentDeltas[j] = (temp - currentValues[j]) /
                            (double) ([[self objectAtIndex:k] time] - currentTime) * 4.0;
                    }
                }
            }
            if (shouldUseSmoothIntonation) {
                if ([[self objectAtIndex:i-1] getValueAtIndex:33] != NaN) {
                    currentDeltas[32] = 0.0;
                    currentDeltas[33] = [[self objectAtIndex:i-1] getValueAtIndex:33];
                    currentDeltas[34] = [[self objectAtIndex:i-1] getValueAtIndex:34];
                    currentDeltas[35] = [[self objectAtIndex:i-1] getValueAtIndex:35];
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
    MonetList *tempCategoryList;
    PhoneList *tempPhoneList;
    double tempoList[4];
    double footTempo, tempTempo;
    int index = 0;
    int i, j, rus;
    int ruleIndex;
    RuleList *ruleList = [aModel rules];
    MMRule *tempRule;
    ParameterList *mainParameterList = [aModel parameters];
    MMParameter *tempParameter = nil;

    assert(aModel != nil);
    //NSLog(@"mainParameterList: %@", mainParameterList);
    for (i = 0; i < 16; i++) {
        tempParameter = [mainParameterList objectAtIndex:i];

        min[i] = (double) [tempParameter minimumValue];
        max[i] = (double) [tempParameter maximumValue];
        //NSLog(@"Min: %f Max: %f", min[i], max[i]);
    }

    tempPhoneList = [[PhoneList alloc] initWithCapacity:4];
    tempCategoryList = [[MonetList alloc] initWithCapacity:4];
    bzero(tempoList, sizeof(double) * 4);

    NSLog(@"currentFoot: %d", currentFoot);
    for (i = 0; i < currentFoot; i++) {
        rus = feet[i].end - feet[i].start + 1;
        /* Apply rhythm model */
        if (feet[i].marked) {
            tempTempo = 117.7 - (19.36 * (double) rus);
            feet[i].tempo -= tempTempo/180.0;
            //NSLog(@"Rus = %d tempTempo = %f", rus, tempTempo);
            footTempo = globalTempo * feet[i].tempo;
        } else {
            tempTempo = 18.5 - (2.08 * (double) rus);
            feet[i].tempo -= tempTempo/140.0;
            //NSLog(@"Rus = %d tempTempo = %f", rus, tempTempo);
            footTempo = globalTempo * feet[i].tempo;
        }
        //NSLog(@"Foot Tempo = %f", footTempo);
        for (j = feet[i].start; j < feet[i].end + 1; j++) {
            phoneTempo[j] *= footTempo;
            if (phoneTempo[j] < 0.2)
                phoneTempo[j] = 0.2;
            else
                if (phoneTempo[j] > 2.0)
                    phoneTempo[j] = 2.0;

            //NSLog(@"PhoneTempo[%d] = %f, teed[%d].tempo = %f", j, phoneTempo[j], i, feet[i].tempo);
        }
    }

    while (index < currentPhone - 1) {
        [tempPhoneList removeAllObjects];
        [tempCategoryList removeAllObjects];
        i = index;

        for (j = 0; j < 4; j++) {
            [tempPhoneList addObject:phones[j+i].phone];
            [tempCategoryList addObject:[phones[j+i].phone categoryList]];
        }

        tempRule = [ruleList findRule:tempCategoryList index:&ruleIndex];
        rules[currentRule].number = ruleIndex + 1;

        [self applyRule:tempRule withPhones:tempPhoneList andTempos:&phoneTempo[i] phoneIndex:i+1];

        index += [tempRule numberExpressions] - 1;
    }

//    if (currentPhone)
//        [self applyIntonation];

    [[self lastObject] setFlag:YES];
    NSLog(@"%s, EventList count: %d", _cmd, [self count]);
}

- (void)applyRule:(MMRule *)rule withPhones:(PhoneList *)phoneList andTempos:(double *)tempos phoneIndex:(int)phoneIndex;
{
    int i, j, type, cont;
    int currentType;
    double currentDelta, value, maxValue;
    double ruleSymbols[5], tempTime, targets[4];
    MMTransition *protoTemplate;
    MMPoint *currentPoint;
    MonetList *tempTargets, *points;
    Event *tempEvent;

    bzero(ruleSymbols, sizeof(double)*5);
    [rule evaluateExpressionSymbols:ruleSymbols tempos:tempos phones:phoneList withCache:(int)++cache];

    multiplier = 1.0 / (double)(phones[phoneIndex-1].ruleTempo);

    type = [rule numberExpressions];
    [self setDuration:(int)(ruleSymbols[0]*multiplier)];

    rules[currentRule].firstPhone = phoneIndex - 1;
    rules[currentRule].lastPhone = phoneIndex - 2 + type;
    rules[currentRule].beat = (ruleSymbols[1]*multiplier) + (double)zeroRef;
    rules[currentRule++].duration = ruleSymbols[0] * multiplier;

    switch (type) {
        /* Note: Case 4 should execute all of the below, case 3 the last two */
      case 4:
          phones[phoneIndex+2].onset = (double)zeroRef + ruleSymbols[1];
          tempEvent = [self insertEvent:-1 atTime:ruleSymbols[3] withValue:0.0];
          [tempEvent setFlag:YES];
      case 3:
          phones[phoneIndex+1].onset = (double)zeroRef + ruleSymbols[1];
          tempEvent = [self insertEvent:-1 atTime:ruleSymbols[2] withValue:0.0];
          [tempEvent setFlag:YES];
      case 2:
          phones[phoneIndex].onset = (double)zeroRef + ruleSymbols[1];
          tempEvent = [self insertEvent:-1 atTime:0.0 withValue:0.0];
          [tempEvent setFlag:YES];
          break;
    }

    tempTargets = [rule parameterList];

    /* Loop through the parameters */
    for (i = 0; i < [tempTargets count]; i++) {
        /* Get actual parameter target values */
        targets[0] = [(MMTarget *)[[[phoneList objectAtIndex:0] parameterTargets] objectAtIndex:i] value];
        targets[1] = [(MMTarget *)[[[phoneList objectAtIndex:1] parameterTargets] objectAtIndex:i] value];
        targets[2] = [(MMTarget *)[[[phoneList objectAtIndex:2] parameterTargets] objectAtIndex:i] value];
        targets[3] = [(MMTarget *)[[[phoneList objectAtIndex:3] parameterTargets] objectAtIndex:i] value];

        //NSLog(@"Targets %f %f %f %f", targets[0], targets[1], targets[2], targets[3]);

        /* Optimization, Don't calculate if no changes occur */
        cont = 1;
        switch (type) {
          case MMPhoneTypeDiphone:
              if (targets[0] == targets[1])
                  cont = 0;
              break;
          case MMPhoneTypeTriphone:
              if ((targets[0] == targets[1]) && (targets[0] == targets[2]))
                  cont = 0;
              break;
          case MMPhoneTypeTetraphone:
              if ((targets[0] == targets[1]) && (targets[0] == targets[2]) && (targets[0] == targets[3]))
                  cont = 0;
              break;
        }

        if (cont) {
            currentType = MMPhoneTypeDiphone;
            currentDelta = targets[1] - targets[0];

            /* Get transition profile list */
            protoTemplate = (MMTransition *)[tempTargets objectAtIndex:i];
            points = [protoTemplate points];

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
                maxValue = [currentPoint calculatePoints:ruleSymbols tempos:tempos phones:phoneList
                                         andCacheWith:cache baseline:targets[currentType-2] delta:currentDelta
                                         min:min[i] max:max[i] toEventList:self atIndex:(int)i];
            }
        } else {
            tempEvent = [self insertEvent:i atTime:0.0 withValue:targets[0]];
            //[tempEvent setFlag:YES];
        }
    }

    /* Special Event Profiles */
    for (i = 0; i < 16; i++) {
        if ((protoTemplate = [rule getSpecialProfile:i])) {
            /* Get transition profile list */
            points = [protoTemplate points];

            for (j = 0; j < [points count]; j++) {
                currentPoint = [points objectAtIndex:j];

                /* calculate time of event */
                if ([currentPoint expression] == nil)
                    tempTime = [currentPoint freeTime];
                else
                    tempTime = [[currentPoint expression] evaluate:ruleSymbols tempos:tempos phones:phoneList andCacheWith:(int)cache];

                /* Calculate value of event */
                //value = (([currentPoint value]/100.0) * (max[i] - min[i])) + min[i];
                value = (([currentPoint value]/100.0) * (max[i] - min[i]));
                maxValue = value;

                /* insert event into event list */
                [self insertEvent:i+16 atTime:tempTime withValue:value];
            }
        }
    }

    [self setZeroRef:(int)(ruleSymbols[0]*multiplier) +  zeroRef];
    tempEvent = [self insertEvent:(-1) atTime:0.0 withValue:0.0];
    [tempEvent setFlag:YES];
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
    duration = [[self lastObject] time] + 100;

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
                NSLog(@"Checking phone %@ for vocoid", [phones[phoneIndex].phone symbol]);
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

- (void)printDataStructures;
{
    int i;

    NSLog(@"Tone Groups %d", currentToneGroup);
    for (i = 0; i < currentToneGroup; i++) {
        NSLog(@"%d  start: %d  end: %d  type: %d", i, toneGroups[i].startFoot, toneGroups[i].endFoot, toneGroups[i].type);
    }

    NSLog(@"\n");
    NSLog(@"Feet %d", currentFoot);
    for (i = 0; i < currentFoot; i++) {
        NSLog(@"%d  tempo: %f start: %d  end: %d  marked: %d last: %d onset1: %f onset2: %f", i, feet[i].tempo,
               feet[i].start, feet[i].end, feet[i].marked, feet[i].last, feet[i].onset1, feet[i].onset2);
    }

    NSLog(@"\n");
    NSLog(@"Phones %d", currentPhone);
    for (i = 0; i < currentPhone; i++) {
        NSLog(@"%d  \"%@\" tempo: %f syllable: %d onset: %f ruleTempo: %f",
               i, [phones[i].phone symbol], phoneTempo[i], phones[i].syllable, phones[i].onset, phones[i].ruleTempo);
    }

    NSLog(@"\n");
    NSLog(@"Rules %d", currentRule);
    for (i = 0; i < currentRule; i++) {
        NSLog(@"Number: %d  start: %d  end: %d  duration %f", rules[i].number, rules[i].firstPhone,
               rules[i].lastPhone, rules[i].duration);
    }
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
    NSLog(@"Applying intonation");

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

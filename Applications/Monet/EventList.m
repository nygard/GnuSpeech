#import "EventList.h"

#import <Foundation/Foundation.h>
#import "driftGenerator.h"
#import "CategoryList.h"
#import "Event.h"
#import "IntonationView.h"
#import "MyController.h"
#import "Parameter.h"
#import "ParameterList.h"
#import "Phone.h"
#import "Point.h"
#import "ProtoEquation.h"
#import "ProtoTemplate.h"
#import "Rule.h"
#import "RuleList.h"
#import "RuleManager.h"
#import "SlopeRatio.h"
#import "Target.h"
#import "TargetList.h"

#ifdef PORTING
#import "PhoneList.h"
#ifdef HAVE_DSP
#import "tube_module/synthesizer_module.h"
#endif
#endif

/*===========================================================================


===========================================================================*/

#define PAGES 16

static char *outputBuffer;
static int currentInputBuffer, currentOutputBuffer, currentConsumed;
static int bufferFree[PAGES];
static int currentIndex;

static void update_synth_ptr(void)
{

//	printf("BufferFree[%d] = %d\n", currentOutputBuffer, bufferFree[currentOutputBuffer]);
	if (!bufferFree[currentOutputBuffer])
	{
//		printf("\t\t\tSending out page %d\n", currentOutputBuffer);
#ifdef HAVE_DSP
		synth_read_ptr = outputBuffer+(currentOutputBuffer*NSPageSize());
#endif
		bufferFree[currentOutputBuffer] = 2;
		currentOutputBuffer = (currentOutputBuffer+1)%PAGES;
	}
}

static void page_consumed(void)
{
//	printf("\t\t\t\t\t\tConsumed Page %d\n", currentConsumed);
	bufferFree[currentConsumed] = 1;
	currentConsumed = (currentConsumed+1)%PAGES;
}



@implementation EventList

#define IDLE 0
#define RUNNING 1

- (id)initWithCapacity:(unsigned int)numSlots;
{
    if ([super initWithCapacity:numSlots] == nil)
        return nil;

    outputBuffer = NSAllocateMemoryPages(NSPageSize()*PAGES);
    if (outputBuffer == 0) {
        NSLog(@"UGH!  Cannot vm_allocate");
        return self;
    }

    cache = 10000000;
    [self setUp];

    setDriftGenerator(1.0, 500.0, 1000.0);
    radiusMultiply = 1.0;

    return self;
}

- (void)dealloc;
{
    NSDeallocateMemoryPages(outputBuffer, NSPageSize()*PAGES);
    [super dealloc];
}


- (void)setUp;
{
    int i;

    [self removeAllObjects];

    zeroRef = 0;
    zeroIndex = 0;
    duration = 0;
    timeQuantization = 4;
    globalTempo = 1.0;
    multiplier = 1.0;
    macroFlag = 0;
    microFlag = 0;
    driftFlag = 0;
    intonParms = NULL;
    smoothIntonation = 0;

    /* set up buffer */
    bzero(outputBuffer, NSPageSize()*PAGES);
    currentInputBuffer = currentOutputBuffer = currentConsumed = 0;
    currentIndex = 0;
    for (i = 0; i < PAGES; i++)
        bufferFree[i] = 1;

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
}

- (int)zeroRef;
{
    return zeroRef;
}

- (void)setZeroRef:(int)newValue;
{
    int i;
    zeroRef = newValue;
    zeroIndex = 0;

    if ([self count] == 0)
        return;

    for (i = [self count] - 1; i >= 0; i--)
    {
        //printf("i = %d\n", i);
        if ([[self objectAtIndex:i] time] < newValue) {
            zeroIndex = i;
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

- (int)parameterStore;
{
    return parameterStore;
}

- (void)setParameterStore:(int)newValue;
{
    parameterStore = newValue;
}

- (int)softwareSynthesis;
{
    return softwareSynthesis;
}

- (void)setSoftwareSynthesis:(int)newValue;
{
    softwareSynthesis = newValue;
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

- (int)macroIntonation;
{
    return macroFlag;
}

- (void)setMacroIntonation:(int)newValue
{
    macroFlag = newValue;
}

- (int)microIntonation;
{
    return microFlag;
}

- (void)setMicroIntonation:(int)newValue;
{
    microFlag = newValue;
}

- (int)drift;
{
    return driftFlag;
}

- (void)setDrift:(int)newValue;
{
    driftFlag = newValue;
}

- (int)smoothIntonation;
{
    return smoothIntonation;
}

- (void)setSmoothIntonation:(int)newValue;
{
    smoothIntonation = newValue;
}

- (float*)intonParms;
{
    return intonParms;
}

- (void)setIntonParms:(float *)newValue;
{
    intonParms = newValue;
}

- getPhoneAtIndex:(int)phoneIndex;
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

/* Tone groups */

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

/* Feet */

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

- (void)newPhoneWithObject:(id)anObject;
{
    if (phones[currentPhone].phone)
        currentPhone++;
    phoneTempo[currentPhone] = 1.0;
    phones[currentPhone].ruleTempo = 1.0;
    phones[currentPhone].phone = anObject;
}

- (void)replaceCurrentPhoneWith:(id)anObject;
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
    Event *tempEvent = nil;
    int i, tempTime;

    time = time * multiplier;
    if (time < 0.0)
        return nil;
    if (time > (double)(duration + timeQuantization))
        return nil;

    tempTime = zeroRef + (int) time;
    tempTime = (tempTime >> 2) << 2;
//	if ((tempTime%timeQuantization) !=0)
//		tempTime++;


    if ([self count] == 0) {
        tempEvent = [[Event alloc] init];
        [tempEvent setTime:tempTime];
        if (number >= 0) {
            if ((number >= 7) && (number <= 8))
                [tempEvent setValue:value*radiusMultiply ofIndex:number];
            else
                [tempEvent setValue:value ofIndex:number];
        }

        [self addObject:tempEvent];
        return tempEvent;
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
            tempEvent = [[Event alloc] init];
            [tempEvent setTime:tempTime];
            if (number >= 0) {
                if ((number >= 7) && (number <= 8))
                    [tempEvent setValue:value*radiusMultiply ofIndex:number];
                else
                    [tempEvent setValue:value ofIndex:number];
            }

            [self insertObject:tempEvent atIndex:i+1];
            return tempEvent;
        }
    }


    tempEvent = [[Event alloc] init];
    [tempEvent setTime:tempTime];
    if (number >= 0) {
        if ((number >= 7) && (number <= 8))
            [tempEvent setValue:value*radiusMultiply ofIndex:number];
        else
            [tempEvent setValue:value ofIndex:number];
    }

    [self insertObject:tempEvent atIndex:i+1];

    return tempEvent;
//	return nil;
}

- (void)finalEvent:(int)number withValue:(double)value;
{
    Event *tempEvent;

    tempEvent = [self lastObject];
    [tempEvent setValue:value ofIndex:number];
    [tempEvent setFlag:YES];
}

- (Event *)lastEvent;
{
    return [self lastObject];
}

- (void)generateOutput;
{
#ifdef HAVE_DSP
    int i, j, k;
    int synthStatus = IDLE;
    int currentTime, nextTime;
    int watermark = 0;
    double currentValues[36];
    double currentDeltas[36];
    double temp;
    float table[16];
    FILE *fp;
    float silencePage[16] = {0.0, 0.0, 0.0, 0.0, 5.5, 2500.0, 500.0, 0.8, 0.89, 0.99, 0.81, 0.76, 1.05, 1.23, 0.01, 0.0};
    DSPFix24 *silenceTable;

    if ([self count] == 0)
        return;
    if (parameterStore) {
        fp = fopen("/tmp/Monet.parameters", "w");
    } else if (softwareSynthesis) {
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

    if (smoothIntonation) {
        j = 0;
        while( ( temp = [[self objectAtIndex:j] getValueAtIndex:32]) == NaN) {
            j++;
            if (j >= [self count])
                break;
        }

        currentValues[32] = [[self objectAtIndex:j] getValueAtIndex:32];
        currentDeltas[32] = 0.0;
        //NSLog(@"Smooth intonation: %f %f j = %d", currentValues[32], currentDeltas[32], j);
    } else {
        j = 1;
        while( ( temp = [[self objectAtIndex:j] getValueAtIndex:32]) == NaN) {
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
        /* If buffer space is available, perform calculations */
        if (bufferFree[currentInputBuffer] == 1) {
            bzero(outputBuffer + (currentInputBuffer*NSPageSize()), 8192);
            while (currentIndex < 8192) {
                for (j = 0; j < 16; j++) {
                    table[j] = (float)currentValues[j] + (float)currentValues[j+16];
                }
                if (!microFlag)
                    table[0] = 0.0;
                if (driftFlag)
                    table[0] += drift();
                if (macroFlag)
                    table[0] += currentValues[32];

                table[0] += pitchMean;

                if (fp)
                    fprintf(fp, "%.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f\n",
                            table[0], table[1], table[2], table[3],
                            table[4], table[5], table[6], table[7],
                            table[8], table[9], table[10], table[11],
                            table[12], table[13], table[14], table[15]);

                convert_parameter_table(table, outputBuffer + (currentInputBuffer*NSPageSize()) + currentIndex);

                currentIndex += 128;

                for (j = 0 ; j < 32; j++) {
                    if (currentDeltas[j])
                        currentValues[j] += currentDeltas[j];
                }
                if (smoothIntonation) {
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
                            while (( temp = [[self objectAtIndex:k] getValueAtIndex:j]) == NaN) {
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
                    if (smoothIntonation) {
                        if ([[self objectAtIndex:i-1] getValueAtIndex:33] != NaN) {
                            currentDeltas[32] = 0.0;
                            currentDeltas[33] = [[self objectAtIndex:i-1] getValueAtIndex:33];
                            currentDeltas[34] = [[self objectAtIndex:i-1] getValueAtIndex:34];
                            currentDeltas[35] = [[self objectAtIndex:i-1] getValueAtIndex:35];
                        }
                    }
                }
                if (i >= [self count])
                    break;
            }

            if (i >= [self count])
                break;
            if (currentIndex >= 8192) {
                //NSLog(@"Calculated page %d.", currentInputBuffer);
                bufferFree[currentInputBuffer] = 0;
                currentIndex = 0;
                currentInputBuffer = (currentInputBuffer+1) % PAGES;
                watermark++;
                //NSLog(@" new page = %d", currentInputBuffer);
            }
        }
        if ((synthStatus == IDLE) && (watermark > 14))
            if(start_synthesizer() == ST_NO_ERROR)
                synthStatus = RUNNING;

        if (synthStatus == RUNNING)
            await_request_new_page(ST_NO, ST_NO, update_synth_ptr, page_consumed);
    }

    if (synthStatus == IDLE)
        if (start_synthesizer() == ST_NO_ERROR)
            synthStatus = RUNNING;

    if (currentIndex < 8192) {
        if (softwareSynthesis) {
            fclose(fp);
            fp = NULL;
        }
        if (fp)
            fprintf(fp, "Start of Padding\n");
        silenceTable = new_dsp_pad_table(silencePage);
        for(i = 0; i < 16; i++)
            currentValues[i] = (double)DSPFix24ToFloat(silenceTable[i]);
        while (currentIndex < 8192) {
            bcopy(silenceTable, outputBuffer + (currentInputBuffer*NSPageSize()) + currentIndex, 128);
            currentIndex += 128;
            if (fp)
                fprintf(fp, "Time: %d; %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f\n",
                        currentTime, currentValues[0], currentValues[1], currentValues[2], currentValues[3],
                        currentValues[4], currentValues[5], currentValues[6], currentValues[7],
                        currentValues[8], currentValues[9], currentValues[10], currentValues[11],
                        currentValues[12], currentValues[13], currentValues[14], currentValues[15]);
            currentTime += 4;
        }
        if (fp)
            fprintf(fp, "End of Padding\n");
        bufferFree[currentInputBuffer] = 0;
        free(silenceTable);
        //NSLog(@"Finished Silencing page %d", currentInputBuffer);
    } else {
        bufferFree[currentInputBuffer] = 0;
    }


    while (bufferFree[currentOutputBuffer] != 1) {
        if (bufferFree[(currentOutputBuffer+1)%PAGES])
            await_request_new_page(ST_YES, ST_YES, update_synth_ptr, page_consumed);
        else
            await_request_new_page(ST_NO, ST_NO, update_synth_ptr, page_consumed);
    }


    if (fp)
        fclose(fp);
#else
#warning No DSP for -generateOutput
#endif
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
        NSLog(@"%d  \"%s\" tempo: %f syllable: %d onset: %f ruleTempo: %f",
               i, [phones[i].phone symbol], phoneTempo[i], phones[i].syllable, phones[i].onset, phones[i].ruleTempo);
    }

    NSLog(@"\n");
    NSLog(@"Rules %d", currentRule);
    for (i = 0; i < currentRule; i++) {
        NSLog(@"Number: %d  start: %d  end: %d  duration %f", rules[i].number, rules[i].firstPhone,
               rules[i].lastPhone, rules[i].duration);
    }
}

- (void)generateEventList;
{
    MonetList *tempPhoneList, *tempCategoryList;
    double tempoList[4];
    double footTempo, tempTempo;
    int index = 0;
    int i, j, rus;
    int ruleIndex;
    RuleList *ruleList = [(RuleManager *)NXGetNamedObject(@"ruleManager", NSApp) ruleList];
    Rule *tempRule;
    ParameterList *mainParameterList = (ParameterList *) NXGetNamedObject(@"mainParameterList", NSApp);
    Parameter *tempParameter = nil;

    for (i = 0; i < 16; i++) {
        tempParameter = [mainParameterList objectAtIndex:i];

        min[i] = (double) [tempParameter minimumValue];
        max[i] = (double) [tempParameter maximumValue];
        //NSLog(@"Min: %f Max: %f", min[i], max[i]);
    }

    tempPhoneList = [[MonetList alloc] initWithCapacity:4];
    tempCategoryList = [[MonetList alloc] initWithCapacity:4];
    bzero(tempoList, sizeof(double) * 4);

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

        rules[currentRule].number = ruleIndex+1;

        [self applyRule:tempRule withPhones:tempPhoneList andTempos:&phoneTempo[i] phoneIndex:i+1];

        index += [tempRule numberExpressions] - 1;
    }

//    if (currentPhone)
//        [self applyIntonation];

    [[self lastObject] setFlag:YES];
}

- (void)applyRule:rule withPhones:phoneList andTempos:(double *)tempos phoneIndex:(int)phoneIndex;
{
    int i, j, type, cont;
    int currentType;
    double currentDelta, value, maxValue;
    double ruleSymbols[5], tempTime, targets[4];
    ProtoTemplate *protoTemplate;
    GSMPoint *currentPoint;
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
    rules[currentRule++].duration = ruleSymbols[0]*multiplier;

    switch(type) {
        /* Note: Case 4 should execute all of the below, case 3 the last two */
      case 4:
          phones[phoneIndex+2].onset = (double)zeroRef + ruleSymbols[1];
          tempEvent = [self insertEvent:(-1) atTime:ruleSymbols[3] withValue:0.0];
          [tempEvent setFlag:YES];
      case 3:
          phones[phoneIndex+1].onset = (double)zeroRef + ruleSymbols[1];
          tempEvent = [self insertEvent:(-1) atTime:ruleSymbols[2] withValue:0.0];
          [tempEvent setFlag:YES];
      case 2:
          phones[phoneIndex].onset = (double)zeroRef + ruleSymbols[1];
          tempEvent = [self insertEvent:(-1) atTime:0.0 withValue:0.0];
          [tempEvent setFlag:YES];
          break;
    }

    tempTargets = [rule parameterList];

    /* Loop through the parameters */
    for (i = 0; i < [tempTargets count]; i++) {
        /* Get actual parameter target values */
        targets[0] = [(Target *)[[[phoneList objectAtIndex:0] parameterList] objectAtIndex:i] value];
        targets[1] = [(Target *)[[[phoneList objectAtIndex:1] parameterList] objectAtIndex:i] value];
        targets[2] = [(Target *)[[[phoneList objectAtIndex:2] parameterList] objectAtIndex:i] value];
        targets[3] = [(Target *)[[[phoneList objectAtIndex:3] parameterList] objectAtIndex:i] value];

        //NSLog(@"Targets %f %f %f %f", targets[0], targets[1], targets[2], targets[3]);

        /* Optimization, Don't calculate if no changes occur */
        cont = 1;
        switch (type) {
          case DIPHONE:
              if (targets[0] == targets[1])
                  cont = 0;
              break;
          case TRIPHONE:
              if ((targets[0] == targets[1]) && (targets[0] == targets[2]))
                  cont = 0;
              break;
          case TETRAPHONE:
              if ((targets[0] == targets[1]) && (targets[0] == targets[2]) && (targets[0] == targets[3]))
                  cont = 0;
              break;
        }

        if (cont) {
            currentType = DIPHONE;
            currentDelta = targets[1] - targets[0];

            /* Get transition profile list */
            protoTemplate = (ProtoTemplate *)[tempTargets objectAtIndex:i];
            points = [protoTemplate points];

            maxValue = 0.0;

            /* Apply lists to parameter */
            for (j = 0; j < [points count]; j++) {
                currentPoint = [points objectAtIndex:j];

                if ([currentPoint isKindOfClass:[SlopeRatio class]]) {
                    if ([(GSMPoint *)[[(SlopeRatio *)currentPoint points] objectAtIndex:0] type] != currentType) {
                        currentType = [(GSMPoint *)[[(SlopeRatio *)currentPoint points] objectAtIndex:0] type];
                        targets[currentType-2] = maxValue;
                        currentDelta = targets[currentType-1] - (maxValue);
                    }
                } else {
                    if ([currentPoint type] != currentType) {
                        currentType = [currentPoint type];
                        targets[currentType-2] = maxValue;
                        currentDelta = targets[currentType-1] - (maxValue);
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
#ifdef HAVE_DSP
    set_synthesizer_output(filename, getuid(), getgid(), 1);
#else
#warning No DSP for -synthesizeToFile:
#endif
}

- (void)applyIntonation;
{
    id tempView = [NXGetNamedObject(@"intonationView", NSApp) documentView];
    id mainCategoryList = NXGetNamedObject(@"mainCategoryList", NSApp);
    id vocoidCategory;
    int firstFoot, endFoot;
    int ruleIndex, phoneIndex;
    int i, j, k;
    float tempIntonParms[5] = {0.0, 0.0, -2.0, -8.0, -6.0};
    double startTime, endTime, pretonicDelta, offsetTime = 0.0;
    double randomSemitone, randomSlope;

    zeroRef = 0;
    zeroIndex = 0;
    duration = [[self lastObject] time] + 100;

    vocoidCategory = [mainCategoryList findSymbol:@"vocoid"];

    [tempView clearIntonationPoints];
//    [tempView addPoint: -20.0 offsetTime:0.0 slope: 0.0 ruleIndex: 0 eventList: self];

    if (!intonParms)
        intonParms = tempIntonParms;

//    NSLog(@"intonation parameters");
//    for (i = 0; i< 5; i++)
//        NSLog(@"%d: %f", i, intonParms[i]);

    for (i = 0; i < currentToneGroup; i++) {
        firstFoot = toneGroups[i].startFoot;
        endFoot = toneGroups[i].endFoot;

        startTime  = phones[feet[firstFoot].start].onset;
        endTime  = phones[feet[endFoot].end].onset;

        pretonicDelta = (intonParms[1]) / (endTime - startTime);
        NSLog(@"Pretonic Delta = %f time = %f", pretonicDelta, (endTime - startTime));

        /* Set up intonation boundary variables */
        for (j = firstFoot; j <= endFoot; j++) {
            phoneIndex = feet[j].start;
            while ([[phones[phoneIndex].phone categoryList] indexOfObject:vocoidCategory] == NSNotFound) {
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

                randomSemitone = ((double)random() / (double)0x7fffffff) * (double)intonParms[2] - intonParms[2] / 2.0;
                randomSlope = ((double)random() / (double)0x7fffffff) * 0.015 + 0.02;

                [tempView addPoint:((phones[phoneIndex].onset-startTime) * pretonicDelta) + intonParms[0] + randomSemitone
                          offsetTime:offsetTime slope:randomSlope ruleIndex:ruleIndex eventList:self];

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

                [tempView addPoint:intonParms[1] + intonParms[0]
                          offsetTime:offsetTime slope:randomSlope ruleIndex:ruleIndex eventList:self];

                phoneIndex = feet[j].end;
                for (k = ruleIndex; k < currentRule; k++) {
                    if ((phoneIndex >= rules[k].firstPhone) && (phoneIndex <= rules[k].lastPhone)) {
                        ruleIndex = k;
                        break;
                    }
                }

                [tempView addPoint:intonParms[1] + intonParms[0] +intonParms[3]
                          offsetTime:0.0 slope:0.0 ruleIndex:ruleIndex eventList:self];

            }

            offsetTime = -40.0;
        }
    }
}

@end




/*			printf("%.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f\n",
				currentValues[0], currentValues[1], currentValues[7], currentValues[8],
				currentValues[9], currentValues[10], currentValues[11], currentValues[12],
				currentValues[13], currentValues[14], currentValues[15], currentValues[2],
				currentValues[3], currentValues[4], currentValues[5], currentValues[6]);*/

#import "StringParser.h"

#include <sys/time.h>
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "AppController.h"
#import "DefaultMgr.h"
#import "EventList.h"
#import "EventListView.h"
#import "IntonationView.h"
#import "MMPosture.h"
#import "PhoneList.h"
#include "driftGenerator.h"

#ifdef HAVE_DSP
#import "tube_module/synthesizer_module.h"
#endif

int parse_string(EventList *eventList, NSString *str);

@implementation StringParser

+ (NSCharacterSet *)gsStringParserWhitespaceCharacterSet;
{
    static NSCharacterSet *characterSet = nil;

    if (characterSet == nil) {
        NSMutableCharacterSet *aSet;

        aSet = [[NSCharacterSet whitespaceCharacterSet] mutableCopy];
        [aSet addCharactersInString:@"_"];
        characterSet = [aSet copy];

        [aSet release];
    }

    return characterSet;
}

+ (NSCharacterSet *)gsStringParserDefaultCharacterSet;
{
    static NSCharacterSet *characterSet = nil;

    if (characterSet == nil) {
        NSMutableCharacterSet *aSet;

        aSet = [[NSCharacterSet letterCharacterSet] mutableCopy];
        [aSet addCharactersInString:@"^'#"];
        characterSet = [aSet copy];

        [aSet release];
    }

    return characterSet;
}

- (id)init;
{
    if ([super init] == nil)
        return nil;

    eventList = [[EventList alloc] initWithCapacity:1000];
    NXNameObject(@"mainEventList", eventList, NSApp);

    return self;
}

- (void)dealloc;
{
    [eventList release];

    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
    DefaultMgr *defaultManager;

    NSLog(@"<%@>[%p]  > %s", NSStringFromClass([self class]), self, _cmd);

    defaultManager = NXGetNamedObject(@"defaultManager", NSApp);

    [masterVolume setDoubleValue:[defaultManager masterVolume]];
    [length setDoubleValue:[defaultManager vocalTractLength]];
    [temperature setDoubleValue:[defaultManager temperature]];
    [balance setDoubleValue:[defaultManager balance]];
    [breathiness setDoubleValue:[defaultManager breathiness]];
    [lossFactor setDoubleValue:[defaultManager lossFactor]];

    [n1 setDoubleValue:[defaultManager n1]];
    [n2 setDoubleValue:[defaultManager n2]];
    [n3 setDoubleValue:[defaultManager n3]];
    [n4 setDoubleValue:[defaultManager n4]];
    [n5 setDoubleValue:[defaultManager n5]];

    [tp setDoubleValue:[defaultManager tp]];
    [tnMin setDoubleValue:[defaultManager tnMin]];
    [tnMax setDoubleValue:[defaultManager tnMax]];

    [throatCutoff setDoubleValue:[defaultManager throatCuttoff]];
    [throatVolume setDoubleValue:[defaultManager throatVolume]];
    [apScale setDoubleValue:[defaultManager apertureScaling]];
    [mouthCoef setDoubleValue:[defaultManager mouthCoef]];
    [noseCoef setDoubleValue:[defaultManager noseCoef]];
    [mixOffset setDoubleValue:[defaultManager mixOffset]];

    if ([@"ON" isEqualToString:[defaultManager noiseModulation]])
        [modulation selectCellAtRow:0 column:1];
    else
        [modulation selectCellAtRow:0 column:0];

    if ([@"PULSE" isEqualToString:[defaultManager glottalPulseShape]])
        [waveform selectCellAtRow:0 column:0];
    else
        [waveform selectCellAtRow:0 column:1];

    phoneList = NXGetNamedObject(@"mainPhoneList", NSApp);

    NSLog(@"<%@>[%p] <  %s", NSStringFromClass([self class]), self, _cmd);
}

- (void)saveDefaults:(id)sender;
{
    DefaultMgr *defaultManager;

    defaultManager = NXGetNamedObject(@"defaultManager", NSApp);

    [defaultManager setMasterVolume:[masterVolume doubleValue]];
    [defaultManager setVocalTractLength:[length doubleValue]];
    [defaultManager setTemperature:[temperature doubleValue]];
    [defaultManager setBalance:[balance doubleValue]];
    [defaultManager setBreathiness:[breathiness doubleValue]];
    [defaultManager setLossFactor:[lossFactor doubleValue]];
    [defaultManager setn1:[n1 doubleValue]];
    [defaultManager setn2:[n2 doubleValue]];
    [defaultManager setn3:[n3 doubleValue]];
    [defaultManager setn4:[n4 doubleValue]];
    [defaultManager setn5:[n5 doubleValue]];
    [defaultManager setTp:[tp doubleValue]];
    [defaultManager setTnMin:[tnMin doubleValue]];
    [defaultManager setTnMax:[tnMax doubleValue]];
    [defaultManager setThroatCuttoff:[throatCutoff doubleValue]];
    [defaultManager setThroatVolume:[throatVolume doubleValue]];
    [defaultManager setApertureScaling:[apScale doubleValue]];
    [defaultManager setMouthCoef:[mouthCoef doubleValue]];
    [defaultManager setNoseCoef:[noseCoef doubleValue]];
    [defaultManager setMixOffset:[mixOffset doubleValue]];

    if ([modulation selectedColumn])
        [defaultManager setNoiseModulation:@"ON"];
    else
        [defaultManager setNoiseModulation:@"OFF"];

    if ([waveform selectedColumn])
        [defaultManager setGlottalPulseShape:@"SINE"];
    else
        [defaultManager setGlottalPulseShape:@"PULSE"];

//    [modulation
//    [waveform

    [defaultManager updateDefaults];
}

- (void)parseStringButton:(id)sender;
{
    struct timeval tp1, tp2;
    struct timezone tzp;
    int i;
    float intonationParameters[5];
    float sRate;
    //float silencePage[16] = {0.0, 0.0, 0.0, 0.0, 5.5, 2500.0, 500.0, 0.8, 0.89, 0.99, 0.81, 0.76, 1.05, 1.23, 0.01, 0.0};

    NSLog(@"%.2f %.2f %.2f %.2f %.2f \n%.2f %.2f %.2f %.2f %.2f\n%.2f %.2f %.2f %.2f %.2f\n%.2f %.2f %.2f %.2f %.2f",
           [masterVolume floatValue], [balance floatValue], [tp floatValue], [tnMin floatValue],
           [tnMax floatValue], [breathiness floatValue], [length floatValue], [temperature floatValue],
           [lossFactor floatValue], [apScale floatValue], [mouthCoef floatValue], [noseCoef floatValue],
           [n1 floatValue], [n2 floatValue], [n3 floatValue], [n4 floatValue], [n5 floatValue],
           [throatCutoff floatValue], [throatVolume floatValue], [mixOffset floatValue]);

    if ([samplingRate selectedColumn])
        sRate = 44100.0;
    else
        sRate = 22050.0;

#ifdef HAVE_DSP
    set_utterance_rate_parameters(sRate, 250.0, [masterVolume floatValue],
                                  [stereoMono selectedColumn]+1, [balance floatValue],
                                  [waveform selectedColumn], [tp floatValue], [tnMin floatValue],
                                  [tnMax floatValue], [breathiness floatValue],
                                  [length floatValue], [temperature floatValue],
                                  [lossFactor floatValue], [apScale floatValue],
                                  [mouthCoef floatValue], [noseCoef floatValue],
                                  [n1 floatValue], [n2 floatValue], [n3 floatValue],
                                  [n4 floatValue], [n5 floatValue],
                                  [throatCutoff floatValue], [throatVolume floatValue],
                                  [modulation selectedColumn], [mixOffset floatValue], [pitchMean doubleValue],
                                  silencePage);
#endif


    //[self parseString:[stringTextField stringValue]];

    gettimeofday(&tp1, &tzp);

    [eventList setUp];
    [eventList setPitchMean:[pitchMean doubleValue]];
    [eventList setGlobalTempo:[tempoField doubleValue]];
    [eventList setParameterStore:[parametersStore state]];

    [eventList setMacroIntonation:[[intonationMatrix cellAtRow:0 column:0] state]];
    [eventList setMicroIntonation:[[intonationMatrix cellAtRow:1 column:0] state]];
    [eventList setDrift:[[intonationMatrix cellAtRow:2 column:0] state]];
    setDriftGenerator([driftDeviationField floatValue], 500, [driftCutoffField floatValue]);

    [eventList setRadiusMultiply:[radiusMultiplyField doubleValue]];

    //[eventList setIntonation:[intonationFlag state]];
    for (i = 0; i < 5; i++)
        intonationParameters[i] = [[intonParmsField cellAtIndex:i] floatValue];
    [eventList setIntonParms:intonationParameters];

    parse_string(eventList, [stringTextField stringValue]);

    [eventList generateEventList];
    if ([smoothIntonationSwitch state])
        [[intonationView documentView] applyIntonationSmooth];
    else
        [[intonationView documentView] applyIntonation];

    [eventList setSmoothIntonation:[smoothIntonationSwitch state]];

    gettimeofday(&tp2, &tzp);
    NSLog(@"%ld", (tp2.tv_sec*1000000 + tp2.tv_usec) - (tp1.tv_sec*1000000 + tp1.tv_usec));

    NSLog(@"\n***\n");
    [eventList printDataStructures];
#if 0
    for (i = 0; i < [eventList count]; i++) {
        printf("Time: %d  | ", [[eventList objectAt:i] time]);
        for (j = 0 ; j < 16; j++) {
            printf("%.3f ", [[eventList objectAt:i] getValueAtIndex:j]);
        }
        printf("\n");
    }
#endif

    if ([sender tag]) {
        NSLog(@"this case, trying to synthesize to file.");
        if ([[filenameField stringValue] length])
            [eventList synthesizeToFile:[filenameField stringValue]];
        else
            NSBeep();
    } else
        [eventList synthesizeToFile:nil];

    [eventList generateOutput];

    [eventListView setEventList:eventList];

    [[intonationView documentView] setEventList:eventList];

    [stringTextField selectText:self];
}

- (void)synthesizeWithSoftware:(id)sender;
{
    FILE *fp;
    float sRate;
    //char commandLine[256];

    NSLog(@" > %s", _cmd);
    //NSLog(@"eventList: %@", eventList);
    //[[NSApp delegate] generateXML:@"before software synthesis"];

    if ([samplingRate selectedColumn])
        sRate = 44100.0;
    else
        sRate = 22050.0;

    fp = fopen("/tmp/Monet.parameters", "w");
    fprintf(fp,"0\n%f\n250\n%f\n%d\n%f\n%d\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%d\n%f\n",
            sRate, [masterVolume floatValue],
            [stereoMono selectedColumn]+1, [balance floatValue],
            [waveform selectedColumn], [tp floatValue], [tnMin floatValue],
            [tnMax floatValue], [breathiness floatValue],
            [length floatValue], [temperature floatValue],
            [lossFactor floatValue], [apScale floatValue],
            [mouthCoef floatValue], [noseCoef floatValue],
            [n1 floatValue], [n2 floatValue], [n3 floatValue],
            [n4 floatValue], [n5 floatValue],
            [throatCutoff floatValue], [throatVolume floatValue],
            [modulation selectedColumn], [mixOffset floatValue]);

    fclose(fp);
    [eventList setParameterStore:0];
    [eventList setSoftwareSynthesis:1];

    [eventList setUp];
    [eventList setPitchMean:[pitchMean doubleValue]];
    [eventList setGlobalTempo:[tempoField doubleValue]];
    [eventList setParameterStore:[parametersStore state]];

    [eventList setMacroIntonation:[[intonationMatrix cellAtRow:0 column:0] state]];
    [eventList setMicroIntonation:[[intonationMatrix cellAtRow:1 column:0] state]];
    [eventList setDrift:[[intonationMatrix cellAtRow:2 column:0] state]];
    setDriftGenerator([driftDeviationField floatValue], 500, [driftCutoffField floatValue]);

    [eventList setRadiusMultiply:[radiusMultiplyField doubleValue]];

    NSLog(@"eventList before: %@", eventList);
    parse_string(eventList, [stringTextField stringValue]);
    NSLog(@"eventList after: %@", eventList);

    [eventList generateEventList];
    [[intonationView documentView] applyIntonation];

    [eventList generateOutput];

    [eventListView setEventList:eventList];
    [eventListView display]; // TODO (2004-03-17): It's not updating otherwise

    [[intonationView documentView] setEventList:eventList];

    [stringTextField selectText:self];

#if 0
    sprintf(commandLine,"/bin/tube /tmp/Monet.parameters %s\n", [[filenameField stringValue] cString]);
    system(commandLine);
    sprintf(commandLine,"sndplay %s\n", [[filenameField stringValue] cString]);
    system(commandLine);
#endif

    NSLog(@"<  %s", _cmd);
}

- (void)setUpDataStructures;
{
    [eventList setUp];

    parse_string(eventList, [stringTextField stringValue]);

    [eventList generateEventList];

    [eventListView setEventList:eventList];

    [[intonationView documentView] setEventList:eventList];

    [stringTextField selectText:self];
}

- (void)automaticIntonation:(id)sender;
{
    float intonationParameters[5];
    int i;

    for (i = 0; i < 5; i++)
        intonationParameters[i] = [[intonParmsField cellAtIndex:i] floatValue];

    [eventList setIntonParms:intonationParameters];

    [eventList applyIntonation];
    [intonationView display];

    NSLog(@"contour:\n%@", [[intonationView documentView] contourString]);
}

@end

int parse_string(EventList *eventList, NSString *str)
{
    MMPosture *aPhone;
    //int chunk = 0;
    int lastFoot = 0, markedFoot = 0;
    double footTempo = 1.0;
    double ruleTempo = 1.0;
    double phoneTempo = 1.0;
    double aDouble;
    PhoneList *mainPhoneList;
    NSScanner *scanner;
    NSCharacterSet *whitespaceCharacterSet = [StringParser gsStringParserWhitespaceCharacterSet];
    NSCharacterSet *defaultCharacterSet = [StringParser gsStringParserDefaultCharacterSet]; // I know, it's not a great name.
    NSString *buffer;

    mainPhoneList = NXGetNamedObject(@"mainPhoneList", NSApp);
    NSLog(@"mainPhoneList: %p", mainPhoneList);

    aPhone = [mainPhoneList findPhone:@"^"];
    [eventList newPhoneWithObject:aPhone];

    scanner = [[[NSScanner alloc] initWithString:str] autorelease];
    [scanner setCharactersToBeSkipped:nil];

    while ([scanner isAtEnd] == NO) {
        [scanner scanCharactersFromSet:whitespaceCharacterSet intoString:NULL];
        if ([scanner isAtEnd] == YES)
            break;

        if ([scanner scanString:@"/" intoString:NULL] == YES) {
            /* Handle "/" escape sequences */
            if ([scanner scanString:@"0" intoString:NULL] == YES) {
                /* Tone group 0. Statement */
                NSLog(@"Tone group 0. Statement");
                [eventList setCurrentToneGroupType:STATEMENT];
            } else if ([scanner scanString:@"1" intoString:NULL] == YES) {
                /* Tone group 1. Exclaimation */
                NSLog(@"Tone group 1. Exclaimation");
                [eventList setCurrentToneGroupType:EXCLAIMATION];
            } else if ([scanner scanString:@"2" intoString:NULL] == YES) {
                /* Tone group 2. Question */
                NSLog(@"Tone group 2. Question");
                [eventList setCurrentToneGroupType:QUESTION];
            } else if ([scanner scanString:@"3" intoString:NULL] == YES) {
                /* Tone group 3. Continuation */
                NSLog(@"Tone group 3. Continuation");
                [eventList setCurrentToneGroupType:CONTINUATION];
            } else if ([scanner scanString:@"4" intoString:NULL] == YES) {
                /* Tone group 4. Semi-colon */
                NSLog(@"Tone group 4. Semi-colon");
                [eventList setCurrentToneGroupType:SEMICOLON];
            } else if ([scanner scanString:@" " intoString:NULL] == YES || [scanner scanString:@"_" intoString:NULL] == YES) {
                /* New foot */
                NSLog(@"New foot");
                [eventList newFoot];
                if (lastFoot)
                    [eventList setCurrentFootLast];
                footTempo = 1.0;
                lastFoot = 0;
                markedFoot = 0;
            } else if ([scanner scanString:@"*" intoString:NULL] == YES) {
                /* New Marked foot */
                NSLog(@"New Marked foot");
                [eventList newFoot];
                [eventList setCurrentFootMarked];
                if (lastFoot)
                    [eventList setCurrentFootLast];

                footTempo = 1.0;
                lastFoot = 0;
                markedFoot = 1;
            } else if ([scanner scanString:@"/" intoString:NULL] == YES) {
                /* New Tone Group */
                NSLog(@"New Tone Group");
                [eventList newToneGroup];
            } else if ([scanner scanString:@"c" intoString:NULL] == YES) {
                /* New Chunk */
                NSLog(@"New Chunk -- not sure that this is working.");
#ifdef PORTING
                if (chunk) {
                    //aPhone = [mainPhoneList findPhone:"#"];
                    //[eventList newPhoneWithObject:aPhone];
                    //aPhone = [mainPhoneList findPhone:"^"];
                    //[eventList newPhoneWithObject:aPhone];
                    index--;
                    return index;
                } else {
                    chunk++;
                    index++;
                }
#endif
            } else if ([scanner scanString:@"l" intoString:NULL] == YES) {
                /* Last Foot in tone group marker */
                NSLog(@"Last Foot in tone group");
                lastFoot = 1;
            } else if ([scanner scanString:@"f" intoString:NULL] == YES) {
                /* Foot tempo indicator */
                NSLog(@"Foot tempo indicator - 'f'");
                [scanner scanCharactersFromSet:whitespaceCharacterSet intoString:NULL];
                if ([scanner scanDouble:&aDouble] == YES) {
                    NSLog(@"current foot tempo: %g", aDouble);
                    [eventList setCurrentFootTempo:aDouble];
                }
            } else if ([scanner scanString:@"r" intoString:NULL] == YES) {
                /* Foot tempo indicator */
                NSLog(@"Foot tempo indicator - 'r'");
                [scanner scanCharactersFromSet:whitespaceCharacterSet intoString:NULL];
                if ([scanner scanDouble:&aDouble] == YES) {
                    NSLog(@"ruleTemp = %g", aDouble);
                    ruleTempo = aDouble;
                }
            }
        } else if ([scanner scanString:@"." intoString:NULL] == YES) {
            /* Syllable Marker */
            NSLog(@"Syllable Marker");
            [eventList setCurrentPhoneSyllable];
        } else if ([scanner scanDouble:&aDouble] == YES) {
            // TODO (2004-03-05): The original scanned digits and '.', and then used atof.
            NSLog(@"phoneTempo = %g", aDouble);
            phoneTempo = aDouble;
        } else {
            if ([scanner scanCharactersFromSet:defaultCharacterSet intoString:&buffer] == YES) {
                NSLog(@"Scanned this: '%@'", buffer);
                if (markedFoot)
                    buffer = [buffer stringByAppendingString:@"'"];
                aPhone = [mainPhoneList findPhone:buffer];
                NSLog(@"aPhone: %p, eventList: %p", aPhone, eventList);
                if (aPhone) {
                    [eventList newPhoneWithObject:aPhone];
                    [eventList setCurrentPhoneTempo:phoneTempo];
                    [eventList setCurrentPhoneRuleTempo:(float)ruleTempo];
                }
                phoneTempo = 1.0;
                ruleTempo = 1.0;
            } else {
                break;
            }
        }
    }

    NSLog(@"Done parse_string().");
    return [scanner scanLocation];
}

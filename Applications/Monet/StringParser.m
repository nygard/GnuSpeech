#import "StringParser.h"

#include <sys/time.h>
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "AppController.h"
#import "DefaultMgr.h"
#import "EventList.h"
#import "EventListView.h"
#import "IntonationView.h"
#import "Phone.h"
#import "PhoneList.h"
#include "driftGenerator.h"

#ifdef HAVE_DSP
#import "tube_module/synthesizer_module.h"
#endif

@implementation StringParser

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
    float silencePage[16] = {0.0, 0.0, 0.0, 0.0, 5.5, 2500.0, 500.0, 0.8, 0.89, 0.99, 0.81, 0.76, 1.05, 1.23, 0.01, 0.0};

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
    char commandLine[256];

    NSLog(@" > %s", _cmd);

    if ([samplingRate selectedColumn])
        sRate = 44100.0;
    else
        sRate = 22050.0;

    fp = fopen("/tmp/Monet.parameters", "w");
    fprintf(fp,"%f\n250\n%f\n%d\n%f\n%d\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%d\n%f\n",
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

    parse_string(eventList, [stringTextField stringValue]);

    [eventList generateEventList];
    [[intonationView documentView] applyIntonation];

    [eventList generateOutput];

    [eventListView setEventList:eventList];

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
}

@end

int parse_string(id eventList, char *string)
{
    Phone *tempPhone;
    int length, dummy;
    int index = 0, bufferIndex = 0;
    int chunk = 0;
    char buffer[128];
    int lastFoot = 0, markedFoot = 0;
    double footTempo = 1.0;
    double ruleTempo = 1.0;
    double phoneTempo = 1.0;
    PhoneList *mainPhoneList;

    mainPhoneList = NXGetNamedObject(@"mainPhoneList", NSApp);

    length = strlen(string);
    tempPhone = [mainPhoneList binarySearchPhone:@"^" index:&dummy];
    [eventList newPhoneWithObject:tempPhone];
    while (index < length) {
        while ((isspace(string[index]) || (string[index] == '_')) && (index<length))
            index++;

        if (index>length)
            break;

        bzero(buffer, 128);
        bufferIndex = 0;

        switch (string[index]) {
          case '/': /* Handle "/" escape sequences */
              index++;
              switch (string[index]) {
                case '0': /* Tone group 0. Statement */
                    index++;
                    [eventList setCurrentToneGroupType:STATEMENT];
                    break;
                case '1': /* Tone group 1. Exclaimation */
                    index++;
                    [eventList setCurrentToneGroupType:EXCLAIMATION];
                    break;
                case '2': /* Tone group 2. Question */
                    index++;
                    [eventList setCurrentToneGroupType:QUESTION];
                    break;
                case '3': /* Tone group 3. Continuation */
                    index++;
                    [eventList setCurrentToneGroupType:CONTINUATION];
                    break;
                case '4': /* Tone group 4. Semi-colon */
                    index++;
                    [eventList setCurrentToneGroupType:SEMICOLON];
                    break;
                case ' ':
                case '_': /* New foot */
                    [eventList newFoot];
                    if (lastFoot)
                        [eventList setCurrentFootLast];
                    footTempo = 1.0;
                    lastFoot = 0;
                    markedFoot = 0;
                    index++;
                    break;
                case '*': /* New Marked foot */
                    [eventList newFoot];
                    [eventList setCurrentFootMarked];
                    if (lastFoot)
                        [eventList setCurrentFootLast];

                    footTempo = 1.0;
                    lastFoot = 0;
                    markedFoot = 1;
                    index++;
                    break;
                case '/': /* New Tone Group */
                    index++;
                    [eventList newToneGroup];
                    break;
                case 'c': /* New Chunk */
                    if (chunk) {
                        //tempPhone = [mainPhoneList binarySearchPhone:"#" index:&dummy];
                        //[eventList newPhoneWithObject:tempPhone];
                        //tempPhone = [mainPhoneList binarySearchPhone:"^" index:&dummy];
                        //[eventList newPhoneWithObject:tempPhone];
                        index--;
                        return (index);
                    } else {
                        chunk++;
                        index++;
                    }
                    break;
                case 'l': /* Last Foot in tone group marker */
                    index++;
                    lastFoot = 1;
                    break;
                case 'f': /* Foot tempo indicator */
                    index++;
                    while ((isspace(string[index]) || (string[index] == '_')) && (index < length))
                        index++;
                    if (index > length)
                        break;
                    while (isdigit(string[index]) || (string[index] == '.')) {
                        buffer[bufferIndex++] = string[index++];
                    }
                    footTempo = atof(buffer);
                    [eventList setCurrentFootTempo:footTempo];
                    break;
                case 'r': /* Foot tempo indicator */
                    index++;
                    while ((isspace(string[index]) || (string[index] == '_')) && (index < length))
                        index++;
                    if (index > length)
                        break;
                    while (isdigit(string[index]) || (string[index] == '.')) {
                        buffer[bufferIndex++] = string[index++];
                    }
                    ruleTempo = atof(buffer);
                    break;
                default:
                    index++;
                    break;
              }
              break;
          case '.': /* Syllable Marker */
              [eventList setCurrentPhoneSyllable];
              index++;
              break;

          case '0':
          case '1':
          case '2':
          case '3':
          case '4':
          case '5':
          case '6':
          case '7':
          case '8':
          case '9':
              while (isdigit(string[index]) || (string[index] == '.')) {
                  buffer[bufferIndex++] = string[index++];
              }
              phoneTempo = atof(buffer);
              break;

          default:
              if (isalpha(string[index]) || (string[index] == '^') || (string[index] == '\'') || (string[index] == '#') ) {
                  while ( (isalpha(string[index]) || (string[index] == '^') || (string[index] == '\'') || (string[index] == '#')) && (index < length))
                      buffer[bufferIndex++] = string[index++];
                  if (markedFoot)
                      strcat(buffer,"'");
                  tempPhone = [mainPhoneList binarySearchPhone:buffer index:&dummy];
                  if (tempPhone) {
                      [eventList newPhoneWithObject:tempPhone];
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

    return index;
}

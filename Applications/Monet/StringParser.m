#import "StringParser.h"

#include <sys/time.h>
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "NSScanner-Extensions.h"

#import "AppController.h"
#import "EventList.h"
#import "EventListView.h"
#import "IntonationView.h"
#import "MMPosture.h"
#import "MMSynthesisParameters.h"
#import "PhoneList.h"
#include "driftGenerator.h"

#ifdef HAVE_DSP
#import "tube_module/synthesizer_module.h"
#endif

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

    synthesisParameters = [[MMSynthesisParameters alloc] init];

    return self;
}

- (void)dealloc;
{
    [eventList release];
    [synthesisParameters release];

    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
    NSLog(@"<%@>[%p]  > %s", NSStringFromClass([self class]), self, _cmd);

    phoneList = NXGetNamedObject(@"mainPhoneList", NSApp);

    NSLog(@"<%@>[%p] <  %s", NSStringFromClass([self class]), self, _cmd);
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
          [synthesisParameters masterVolume], [synthesisParameters balance], [synthesisParameters tp], [synthesisParameters tnMin],
          [synthesisParameters tnMax], [synthesisParameters breathiness], [synthesisParameters vocalTractLength], [synthesisParameters temperature],
          [synthesisParameters lossFactor], [synthesisParameters apertureScaling], [synthesisParameters mouthCoef], [synthesisParameters noseCoef],
          [synthesisParameters n1], [synthesisParameters n2], [synthesisParameters n3], [synthesisParameters n4], [synthesisParameters n5],
          [synthesisParameters throatCutoff], [synthesisParameters throatVolume], [synthesisParameters mixOffset]);

    if ([synthesisParameters samplingRate] == MMSamplingRate44100)
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
    [eventList setPitchMean:[synthesisParameters pitch]];
    [eventList setGlobalTempo:[tempoField doubleValue]];
    [eventList setShouldStoreParameters:[parametersStore state]];

    [eventList setShouldUseMacroIntonation:[[intonationMatrix cellAtRow:0 column:0] state]];
    [eventList setShouldUseMicroIntonation:[[intonationMatrix cellAtRow:1 column:0] state]];
    [eventList setShouldUseDrift:[[intonationMatrix cellAtRow:2 column:0] state]];
    setDriftGenerator([driftDeviationField floatValue], 500, [driftCutoffField floatValue]);

    [eventList setRadiusMultiply:[radiusMultiplyField doubleValue]];

    //[eventList setIntonation:[intonationFlag state]];
    for (i = 0; i < 5; i++)
        intonationParameters[i] = [[intonParmsField cellAtIndex:i] floatValue];
    [eventList setIntonParms:intonationParameters];

    [self parsePhoneString:[stringTextField stringValue]];

    [eventList generateEventList];
    if ([smoothIntonationSwitch state])
        [[intonationView documentView] applySmoothIntonation];
    else
        [[intonationView documentView] applyIntonation];

    [eventList setShouldUseSmoothIntonation:[smoothIntonationSwitch state]];

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

    if ([synthesisParameters samplingRate] == MMSamplingRate44100)
        sRate = 44100.0;
    else
        sRate = 22050.0;

    fp = fopen("/tmp/Monet.parameters", "w");
#if 1
    fprintf(fp, "%d\t\t; %s\n", 0, "output file format (0 = AU, 1 = AIFF, 2 = WAVE)");
    fprintf(fp, "%f\t; %s\n", sRate, "output sample rate (22050.0, 44100.0)");
    fprintf(fp, "%d\t\t; %s\n", 250, "input control rate (1 - 1000 Hz)");
    fprintf(fp, "%f\t; %s\n", [synthesisParameters masterVolume], "master volume (0 - 60 dB)");
    fprintf(fp, "%d\t\t; %s\n", [synthesisParameters outputChannels] + 1, "number of sound output channels (1 or 2)");
    fprintf(fp, "%f\t; %s\n", [synthesisParameters balance], "stereo balance (-1 to +1)");
    fprintf(fp, "%d\t\t; %s\n", [synthesisParameters glottalPulseShape], "glottal source waveform type (0 = pulse, 1 = sine)");
    fprintf(fp, "%f\t; %s\n", [synthesisParameters tp], "glottal pulse rise time (5 - 50 % of GP period)");
    fprintf(fp, "%f\t; %s\n", [synthesisParameters tnMin], "glottal pulse fall time minimum (5 - 50 % of GP period)");
    fprintf(fp, "%f\t; %s\n", [synthesisParameters tnMax], "glottal pulse fall time maximum (5 - 50 % of GP period)");
    fprintf(fp, "%f\t; %s\n", [synthesisParameters breathiness], "glottal source breathiness (0 - 10 % of GS amplitude)");
    fprintf(fp, "%f\t; %s\n", [synthesisParameters vocalTractLength], "nominal tube length (10 - 20 cm)");
    fprintf(fp, "%f\t; %s\n", [synthesisParameters temperature], "tube temperature (25 - 40 degrees celsius)");
    fprintf(fp, "%f\t; %s\n", [synthesisParameters lossFactor], "junction loss factor (0 - 5 % of unity gain)");
    fprintf(fp, "%f\t; %s\n", [synthesisParameters apertureScaling], "aperture scaling radius (3.05 - 12 cm)");
    fprintf(fp, "%f\t; %s\n", [synthesisParameters mouthCoef], "mouth aperture coefficient (0 - 0.99)");
    fprintf(fp, "%f\t; %s\n", [synthesisParameters noseCoef], "nose aperture coefficient (0 - 0.99)");
    fprintf(fp, "%f\t; %s\n", [synthesisParameters n1], "radius of nose section 1 (0 - 3 cm)");
    fprintf(fp, "%f\t; %s\n", [synthesisParameters n2], "radius of nose section 2 (0 - 3 cm)");
    fprintf(fp, "%f\t; %s\n", [synthesisParameters n3], "radius of nose section 3 (0 - 3 cm)");
    fprintf(fp, "%f\t; %s\n", [synthesisParameters n4], "radius of nose section 4 (0 - 3 cm)");
    fprintf(fp, "%f\t; %s\n", [synthesisParameters n5], "radius of nose section 5 (0 - 3 cm)");
    fprintf(fp, "%f\t; %s\n", [synthesisParameters throatCutoff], "throat lowpass frequency cutoff (50 - nyquist Hz)");
    fprintf(fp, "%f\t; %s\n", [synthesisParameters throatVolume], "throat volume (0 - 48 dB)");
    fprintf(fp, "%d\t\t; %s\n", [synthesisParameters shouldUseNoiseModulation], "pulse modulation of noise (0 = off, 1 = on)");
    fprintf(fp, "%f\t; %s\n", [synthesisParameters mixOffset], "noise crossmix offset (30 - 60 db)");
#else
    fprintf(fp,"0\n%f\n250\n%f\n%d\n%f\n%d\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%f\n%d\n%f\n",
            sRate, [synthesisParameters masterVolume],
            [synthesisParameters outputChannels] + 1, [synthesisParameters balance],
            [synthesisParameters glottalPulseShape], [synthesisParameters tp], [synthesisParameters tnMin],
            [synthesisParameters tnMax], [synthesisParameters breathiness],
            [synthesisParameters vocalTractLength], [synthesisParameters temperature],
            [synthesisParameters lossFactor], [synthesisParameters apertureScaling],
            [synthesisParameters mouthCoef], [synthesisParameters noseCoef],
            [synthesisParameters n1], [synthesisParameters n2], [synthesisParameters n3],
            [synthesisParameters n4], [synthesisParameters n5],
            [synthesisParameters throatCutoff], [synthesisParameters throatVolume],
            [synthesisParameters shouldUseNoiseModulation], [synthesisParameters mixOffset]);
#endif

    fclose(fp);

    [eventList setUp];
    [eventList setPitchMean:[synthesisParameters pitch]];
    [eventList setGlobalTempo:[tempoField doubleValue]];
    [eventList setShouldStoreParameters:[parametersStore state]];
    [eventList setShouldUseSoftwareSynthesis:YES];

    [eventList setShouldUseMacroIntonation:[[intonationMatrix cellAtRow:0 column:0] state]];
    [eventList setShouldUseMicroIntonation:[[intonationMatrix cellAtRow:1 column:0] state]];
    [eventList setShouldUseDrift:[[intonationMatrix cellAtRow:2 column:0] state]];
    setDriftGenerator([driftDeviationField floatValue], 500, [driftCutoffField floatValue]);

    [eventList setRadiusMultiply:[radiusMultiplyField doubleValue]];

    // TODO (2004-03-25): Should we set up the intonation parameters, like the hardware synthesis did?

    //NSLog(@"eventList before: %@", eventList);
    [self parsePhoneString:[stringTextField stringValue]];
    //NSLog(@"eventList after: %@", eventList);

    [eventList generateEventList];

    // TODO (2004-03-25): What about checking for smooth intonation, like the hardware synthesis did?
    [[intonationView documentView] applyIntonation];

    [eventList printDataStructures];
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

    [self parsePhoneString:[stringTextField stringValue]];

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

- (void)parsePhoneString:(NSString *)str;
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

    NSLog(@" > %s", _cmd);

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
            } else {
                // Skip character
                [scanner scanCharacter:NULL];
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

    NSLog(@"<  %s", _cmd);
}

@end

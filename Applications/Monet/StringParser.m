
#import "StringParser.h"
#import "DefaultMgr.h"
#import <stdio.h>
#import <string.h>
#import <stdlib.h>
#import "Parameter.h"
#import "ProtoTemplate.h"
#import "ProtoEquation.h"
#import "Point.h"
#import "PhoneList.h"
#import "EventListView.h"
#import "IntonationView.h"
#import <sys/time.h>
#import <AppKit/NSApplication.h>
#ifdef HAVE_DSP
#import "tube_module/synthesizer_module.h"
#endif

#import "driftGenerator.h"

@implementation StringParser

- init
{
	eventList = [[EventList alloc] initWithCapacity: 1000];
	NXNameObject("mainEventList", eventList, NSApp);

	return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    id defaultManager;

	defaultManager = NXGetNamedObject("defaultManager", NSApp);

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

	if (!strcmp("ON", [defaultManager noiseModulation]))
	{
		[modulation selectCellAtRow:0 column:1];
	}
	else
	{
		[modulation selectCellAtRow:0 column:0];
	}

	if (!strcmp("PULSE", [defaultManager glottalPulseShape]))
	{
		[waveform selectCellAtRow:0 column:0];
	}
	else
	{
		[waveform selectCellAtRow:0 column:1];
	}
}

- (void)saveDefaults:sender
{
id defaultManager;

	defaultManager = NXGetNamedObject("defaultManager", NSApp);

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
	[defaultManager setn5:[n5  doubleValue]];
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
	{
		[defaultManager setNoiseModulation:"ON"];
	}
	else
	{
		[defaultManager setNoiseModulation:"OFF"];
	}

	if ([waveform selectedColumn])
	{
		[defaultManager setGlottalPulseShape:"SINE"];
	}
	else
	{
		[defaultManager setGlottalPulseShape:"PULSE"];
	}

//	[modulation
//	[waveform

	[defaultManager updateDefaults]; 
}

- (void)parseStringButton:sender
{
struct timeval tp1, tp2;
struct timezone tzp;
int i;
float intonationParameters[5];
float sRate;
float silencePage[16] = {0.0, 0.0, 0.0, 0.0, 5.5, 2500.0, 500.0, 0.8, 0.89, 0.99, 0.81, 0.76, 1.05, 1.23, 0.01, 0.0};

	printf("%.2f %.2f %.2f %.2f %.2f \n%.2f %.2f %.2f %.2f %.2f\n%.2f %.2f %.2f %.2f %.2f\n%.2f %.2f %.2f %.2f %.2f \n", 
		[masterVolume floatValue], [balance floatValue], [tp floatValue], [tnMin floatValue],
		[tnMax floatValue], [breathiness floatValue],[length floatValue], [temperature floatValue],
		[lossFactor floatValue], [apScale floatValue],	[mouthCoef floatValue], [noseCoef floatValue],
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


//	[self parseString: [stringTextField stringValue]];

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

//	[eventList setIntonation: [intonationFlag state]];
	for(i = 0;i<5;i++)
		intonationParameters[i] = [[intonParmsField cellAtIndex:i] floatValue];
	[eventList setIntonParms:intonationParameters];

	parse_string(eventList, [[stringTextField stringValue] cString]);

	[eventList generateEventList];
	if ([smoothIntonationSwitch state])
		[[intonationView documentView] applyIntonationSmooth];
	else
		[[intonationView documentView] applyIntonation];

	[eventList setSmoothIntonation:[smoothIntonationSwitch state]];

	gettimeofday(&tp2, &tzp);
	printf("%ld\n", (tp2.tv_sec*1000000 + tp2.tv_usec) - (tp1.tv_sec*1000000 + tp1.tv_usec));

	printf("\n***\n");
	[eventList printDataStructures];
/*	for(i = 0; i< [eventList count]; i++)
	{
		printf("Time: %d  | ", [[eventList objectAt: i] time]);
		for (j = 0 ; j<16; j++)
		{
			printf("%.3f ", [[eventList objectAt: i] getValueAtIndex:j]);
		}
		printf("\n");
	}*/

	if ([sender tag])
	{
		if ([[filenameField stringValue] length])
			[eventList synthesizeToFile:[[filenameField stringValue] cString]];
		else
			NSBeep();
	}
	else
		[eventList synthesizeToFile:NULL];

	[eventList generateOutput];

	[eventListView setEventList:eventList];

	[[intonationView documentView] setEventList:eventList];

	[stringTextField selectText:self]; 
}

- (void)synthesizeWithSoftware:sender
{
FILE *fp;
float sRate;
char commandLine[256];

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

	parse_string(eventList, [[stringTextField stringValue] cString]);

	[eventList generateEventList];
	[[intonationView documentView] applyIntonation];

	[eventList generateOutput];

	[eventListView setEventList:eventList];

	[[intonationView documentView] setEventList:eventList];

	[stringTextField selectText:self];

	sprintf(commandLine,"/bin/tube /tmp/Monet.parameters %s\n", [[filenameField stringValue] cString]);
	system(commandLine);
	sprintf(commandLine,"sndplay %s\n", [[filenameField stringValue] cString]);
	system(commandLine); 
}

- (void)setUpDataStructures
{
	[eventList setUp];

	parse_string(eventList, [[stringTextField stringValue] cString]);

	[eventList generateEventList];

	[eventListView setEventList:eventList];

	[[intonationView documentView] setEventList:eventList];

	[stringTextField selectText:self]; 
}

- (void)automaticIntonation:sender
{
float intonationParameters[5];
int i;

	for(i = 0;i<5;i++)
		intonationParameters[i] = [[intonParmsField cellAtIndex:i] floatValue];

	[eventList setIntonParms:intonationParameters];

	[eventList applyIntonation];
	[intonationView display]; 
}

@end

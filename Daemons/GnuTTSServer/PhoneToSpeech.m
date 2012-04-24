//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "PhoneToSpeech.h"

// Location of the diphones XML file that allows speech to happen.
#define GNUSPEECH_SERVER_DIPHONES_XML_PATH	@"/Library/GnuSpeech/Diphones.mxml"

// These defines were taken from Monet's MSynthesisController.m
#define MDK_ShouldUseSmoothIntonation @"ShouldUseSmoothIntonation"
#define MDK_ShouldUseMacroIntonation @"ShouldUseMacroIntonation"
#define MDK_ShouldUseMicroIntonation @"ShouldUseMicroIntonation"
#define MDK_ShouldUseDrift @"ShouldUseDrift"

@implementation PhoneToSpeech
{
	MModel *model;
    EventList *eventList;	
	TRMSynthesizer *synthesizer;
}

- (id)init;
{
	if ((self = [super init])) {
        eventList = [[EventList alloc] init];
        synthesizer = [[TRMSynthesizer alloc] init];
	
        // Now get the model from the diphones XML file.
        MDocument *document = [[MDocument alloc] init];
        BOOL result = [document loadFromXMLFile:GNUSPEECH_SERVER_DIPHONES_XML_PATH];
        if (result == YES)
            [self setModel:[document model]];
        [document release];
    }
	
	return self;
}

- (void)dealloc;
{
    [model release];
    [eventList release];
    [synthesizer release];
	
	[super dealloc];
}

- (void)speakPhoneString:(NSString *)phoneString;
{
	[self synthesize:phoneString];
}

- (MModel *)model;
{
    return model;
}

- (void)setModel:(MModel *)newModel;
{
    if (newModel == model)
        return;
	
    [model release];
    model = [newModel retain];	
    [eventList setModel:model];
}

- (void)synthesize:(NSString *)phoneString;
{
    [self prepareForSynthesis];
	
    [eventList parsePhoneString:phoneString];  // this creates the tone groups, feet, etc.
    [eventList applyRhythm];
    [eventList applyRules];  // this applies the rules, adding events to the EventList
    [eventList generateIntonationPoints];
	
    [self continueSynthesis];
}

- (void)prepareForSynthesis;
{
    // NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
		
    [eventList setUp];
	
    [eventList setPitchMean:[[[self model] synthesisParameters] pitch]];
    [eventList setGlobalTempo:1.0];  // hard-coded defaults taken from Monet
    [eventList setShouldStoreParameters:NO];
	
    //[eventList setShouldUseMacroIntonation:[defaults boolForKey:MDK_ShouldUseMacroIntonation]];
    //[eventList setShouldUseMicroIntonation:[defaults boolForKey:MDK_ShouldUseMicroIntonation]];
    //[eventList setShouldUseDrift:[defaults boolForKey:MDK_ShouldUseDrift]];
	[eventList setShouldUseMacroIntonation:YES];
	[eventList setShouldUseMicroIntonation:YES];
	[eventList setShouldUseDrift:YES];		
	[eventList.driftGenerator configureWithDeviation:1.0 sampleRate:500 lowpassCutoff:4.0];  // hard-coded defaults taken from Monet
    [eventList setRadiusMultiply:1.0];  // hard-coded defaults taken from Monet
	
    [self _takeIntonationParametersFromUI];
}

- (void)_takeIntonationParametersFromUI;
{
	// These are the Monet defaults we've just hard-coded (for now).
    eventList.intonationParameters.notionalPitch = -1.0;
    eventList.intonationParameters.pretonicRange = 2.0;
    eventList.intonationParameters.pretonicLift  = -2.0;
    eventList.intonationParameters.tonicRange    = -10.0;
    eventList.intonationParameters.tonicMovement = -6.0;
}

- (void)continueSynthesis;
{
    // NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];	
    // [eventList setShouldUseSmoothIntonation:[defaults boolForKey:MDK_ShouldUseSmoothIntonation]];
	[eventList setShouldUseSmoothIntonation:YES];
	
    [eventList applyIntonation];
		
    [synthesizer setupSynthesisParameters:[[self model] synthesisParameters]]; // TODO (2004-08-22): This may overwrite the file type...
    [synthesizer removeAllParameters];
	
    [eventList setDelegate:synthesizer];
    [eventList generateOutput];
    [eventList setDelegate:nil];
	
    [synthesizer synthesize];		
}

@end

//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "PhoneToSpeech.h"

#import <GnuSpeech/GnuSpeech.h>

// Location of the diphones XML file that allows speech to happen.
#define GNUSPEECH_SERVER_DIPHONES_XML_PATH	@"/Library/GnuSpeech/Diphones.mxml"

// These defines were taken from Monet's MSynthesisController.m
#define MDK_ShouldUseSmoothIntonation @"ShouldUseSmoothIntonation"
#define MDK_ShouldUseMacroIntonation  @"ShouldUseMacroIntonation"
#define MDK_ShouldUseMicroIntonation  @"ShouldUseMicroIntonation"
#define MDK_ShouldUseDrift            @"ShouldUseDrift"

@interface PhoneToSpeech () <EventListDelegate>

@property (nonatomic, strong) MModel *model;
@property (readonly) EventList *eventList;
@property (readonly) TRMSynthesizer *synthesizer;

- (void)synthesize:(NSString *)phoneString;
- (void)prepareForSynthesis;
- (void)continueSynthesis;
@end

@implementation PhoneToSpeech
{
	MModel *m_model;
    EventList *m_eventList;
	TRMSynthesizer *m_synthesizer;
}

- (id)init;
{
	if ((self = [super init])) {
        m_eventList = [[EventList alloc] init];
        m_synthesizer = [[TRMSynthesizer alloc] init];
	
        // Now get the model from the diphones XML file.
        MDocument *document = [[[MDocument alloc] init] autorelease];
        BOOL result = [document loadFromXMLFile:GNUSPEECH_SERVER_DIPHONES_XML_PATH];
        if (result)
            self.model = document.model;
    }
	
	return self;
}

- (void)dealloc;
{
    [m_model release];
    [m_eventList release];
    [m_synthesizer release];
	
	[super dealloc];
}

#pragma mark -

- (MModel *)model;
{
    return m_model;
}

- (void)setModel:(MModel *)newModel;
{
    if (newModel != m_model) {
        [m_model release];
        m_model = [newModel retain];
        [self.eventList setModel:m_model];
    }
}

@synthesize synthesizer = m_synthesizer;
@synthesize eventList = m_eventList;

#pragma mark -

- (void)synthesize:(NSString *)phoneString;
{
    [self prepareForSynthesis];
	
    [self.eventList parsePhoneString:phoneString];  // this creates the tone groups, feet, etc.
    [self.eventList applyRhythm];
    [self.eventList applyRules];                    // this applies the rules, adding events to the EventList
    [self.eventList generateIntonationPoints];
	
    [self continueSynthesis];
}

- (void)prepareForSynthesis;
{
    [self.eventList setUp];
	
    self.eventList.pitchMean = [[[self model] synthesisParameters] pitch];
    self.eventList.globalTempo = 1.0;  // hard-coded defaults taken from Monet
	
	self.eventList.shouldUseMacroIntonation = YES;
	self.eventList.shouldUseMicroIntonation = YES;
	self.eventList.shouldUseDrift = YES;
	[self.eventList.driftGenerator configureWithDeviation:1.0 sampleRate:500 lowpassCutoff:4.0];  // hard-coded defaults taken from Monet
    self.eventList.radiusMultiply = 1.0;  // hard-coded defaults taken from Monet
	
	// These are the Monet defaults we've just hard-coded (for now).
    self.eventList.intonationParameters.notionalPitch = -1.0;
    self.eventList.intonationParameters.pretonicRange = 2.0;
    self.eventList.intonationParameters.pretonicLift  = -2.0;
    self.eventList.intonationParameters.tonicRange    = -10.0;
    self.eventList.intonationParameters.tonicMovement = -6.0;
}

- (void)continueSynthesis;
{
    // NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];	
    // [eventList setShouldUseSmoothIntonation:[defaults boolForKey:MDK_ShouldUseSmoothIntonation]];
	[self.eventList setShouldUseSmoothIntonation:YES];
	
    [self.eventList applyIntonation];
		
    [self.synthesizer setupSynthesisParameters:[[self model] synthesisParameters]]; // TODO (2004-08-22): This may overwrite the file type...
    [self.synthesizer removeAllParameters];
	
    self.eventList.delegate = self;
    [self.eventList generateOutput];
    self.eventList.delegate = nil;
	
    [self.synthesizer synthesize];
}

#pragma mark - EventListDelegate

- (void)eventListWillGenerateOutput:(EventList *)eventList;
{
}

- (void)eventList:(EventList *)eventList generatedOutputValues:(float *)valPtr valueCount:(NSUInteger)count;
{
    [self.synthesizer addParameters:valPtr];
}

- (void)eventListDidGenerateOutput:(EventList *)eventList;
{
}

#pragma mark - Public API

- (void)speakPhoneString:(NSString *)phoneString;
{
	[self synthesize:phoneString];
}

@end

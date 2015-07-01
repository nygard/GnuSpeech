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

@interface PhoneToSpeech ()

@property (nonatomic, strong) MModel *model;
@property (readonly) EventList *eventList;
@property (readonly) TRMSynthesizer *synthesizer;

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
        MDocument *document = [[MDocument alloc] initWithXMLFile:GNUSPEECH_SERVER_DIPHONES_XML_PATH error:NULL];
        if (document != nil) {
            self.model = [document.model autorelease];
        }
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
    MMIntonation *intonation = [[MMIntonation alloc] init];
    [self.eventList resetWithIntonation:intonation phoneString:phoneString];

    [self continueSynthesis];
}


- (void)continueSynthesis;
{
    // NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];	
    // [eventList setShouldUseSmoothIntonation:[defaults boolForKey:MDK_ShouldUseSmoothIntonation]];

    [self.eventList applyIntonation];
		
    [self.synthesizer setupSynthesisParameters:self.model.synthesisParameters]; // TODO (2004-08-22): This may overwrite the file type...
    [self.synthesizer removeAllParameters];
	
    [self.eventList generateOutputForSynthesizer:self.synthesizer];
	
    [self.synthesizer synthesize];
}

#pragma mark - Public API

- (void)speakPhoneString:(NSString *)phoneString;
{
	[self synthesize:phoneString];
}

@end

//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

#import <GnuSpeech/GnuSpeech.h>  // for struct _intonationParameters

@interface PhoneToSpeech : NSObject
{
	MModel *model;
    EventList *eventList;	
	TRMSynthesizer *synthesizer;
	struct _intonationParameters intonationParameters;
}

- (id)init;
- (void)dealloc;

- (void)speakPhoneString:(NSString *)phoneString;

- (MModel *)model;
- (void)setModel:(MModel *)newModel;

- (void)synthesize:(NSString *)phoneString;
- (void)prepareForSynthesis;
- (void)continueSynthesis;

- (void)_takeIntonationParametersFromUI;


@end

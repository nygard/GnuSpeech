//
//  PhoneToSpeech.h
//  GnuTTSServer
//
//  Created by Dalmazio on 05/01/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GnuSpeech/GnuSpeech.h>  // for struct _intonationParameters

@interface PhoneToSpeech : NSObject {
	MModel * model;
    EventList * eventList;	
	TRMSynthesizer * synthesizer;
	struct _intonationParameters intonationParameters;
}

- (id) init;
- (void) dealloc;

- (void) speakPhoneString:(NSString *)phoneString;

- (MModel *) model;
- (void) setModel:(MModel *)newModel;

- (void) synthesize:(NSString *)phoneString;
- (void) prepareForSynthesis;
- (void) continueSynthesis;

- (void) _takeIntonationParametersFromUI;


@end

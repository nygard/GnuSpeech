////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
//  
//  Contributors: Dalmazio Brisinda
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
////////////////////////////////////////////////////////////////////////////////
//
//  PhoneToSpeech.h
//  GnuTTSServer
//
//  Created by Dalmazio on 05/01/09.
//
//  Version: 0.1.1
//
////////////////////////////////////////////////////////////////////////////////

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

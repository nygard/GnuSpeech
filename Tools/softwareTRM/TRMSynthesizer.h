//
// $Id$
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>
//#import <CoreAudio/AudioHardware.h>
#import <AudioUnit/AudioUnit.h>
#import "structs.h"

@class MMSynthesisParameters;

extern int verbose;

@interface TRMSynthesizer : NSObject
{
    TRMData *inputData;
    NSMutableData *soundData;

    AudioUnit outputUnit;

    int bufferLength;
    int bufferIndex;
}

- (id)init;
- (void)dealloc;

- (void)setupSynthesisParameters:(MMSynthesisParameters *)synthesisParameters;
- (void)addParameters:(float *)values;
- (void)removeAllParameters;

- (void)synthesize;
- (void)convertSamplesIntoData:(TRMSampleRateConverter *)sampleRateConverter;
- (void)startPlaying;
- (void)stopPlaying;

- (void)setupSoundDevice;
- (BOOL)fillBuffer:(short *)buffer count:(int)count;

@end

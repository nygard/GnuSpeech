//
// $Id$
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>
#import <CoreAudio/AudioHardware.h>
#import "structs.h"

@class MMSynthesisParameters;

extern int verbose;

@interface TRMSynthesizer : NSObject
{
    TRMData *inputData;
    NSMutableData *soundData;

    UInt32 _bufferSize;
    AudioDeviceID _device;
    AudioStreamBasicDescription _format;

    BOOL _deviceReady;
    BOOL _isPlaying;

    int bufferLength;
    int bufferIndex;
}

- (id)init;
- (void)dealloc;

//- (TRMInputParameters *)inputParameters;
- (void)setupSynthesisParameters:(MMSynthesisParameters *)synthesisParameters;
- (void)addParameters:(float *)values;
- (void)removeAllParameters;

- (void)synthesize;
- (void)convertSamplesIntoData;
- (void)startPlaying;
- (void)stopPlaying;

- (void)setupSoundDevice;
- (BOOL)fillBuffer:(float *)buffer count:(int)count;

@end

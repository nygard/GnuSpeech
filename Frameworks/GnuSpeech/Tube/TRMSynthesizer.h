//
// $Id: TRMSynthesizer.h,v 1.2 2008-10-20 04:39:02 dbrisinda Exp $
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>
#import <Foundation/NSData.h>

#ifndef GNUSTEP
//#import <CoreAudio/AudioHardware.h>
#import <AudioUnit/AudioUnit.h>
#endif

#include <Tube/TubeModel.h>

@class MMSynthesisParameters;

@interface TRMSynthesizer : NSObject
{
    TRMData *inputData;
    NSMutableData *soundData;

#ifndef GNUSTEP
    AudioUnit outputUnit;
#endif

    int bufferLength;
    int bufferIndex;

    BOOL shouldSaveToSoundFile;
    NSString *filename;
}

- (id)init;
- (void)dealloc;

- (void)setupSynthesisParameters:(MMSynthesisParameters *)synthesisParameters;
- (void)removeAllParameters;
- (void)addParameters:(float *)values;

- (BOOL)shouldSaveToSoundFile;
- (void)setShouldSaveToSoundFile:(BOOL)newFlag;

- (NSString *)filename;
- (void)setFilename:(NSString *)newFilename;

- (int)fileType;
- (void)setFileType:(int)newFileType;

- (void)synthesize;
- (void)convertSamplesIntoData:(TRMSampleRateConverter *)sampleRateConverter;
- (void)startPlaying;

#ifndef GNUSTEP
- (void)stopPlaying;

- (void)setupSoundDevice;
- (void)fillBuffer:(AudioBuffer *)ioData;
#endif

- (void)writeAiffDataHeader:(NSMutableData *)data channels:(int)numberChannels samples:(int)numberSamples rate:(float)outputRate;

@end

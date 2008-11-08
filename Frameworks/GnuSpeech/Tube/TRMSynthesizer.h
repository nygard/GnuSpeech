//
// $Id: TRMSynthesizer.h,v 1.4 2008-11-08 07:45:34 dbrisinda Exp $
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>
#import <Foundation/NSData.h>
#import <Tube/TubeModel.h>

#ifndef GNUSTEP

#import <AudioUnit/AudioUnit.h>

#endif

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

- (void)stopPlaying;
- (void)setupSoundDevice;

#ifndef GNUSTEP
- (void)fillBuffer:(AudioBuffer *)ioData;
#endif

@end

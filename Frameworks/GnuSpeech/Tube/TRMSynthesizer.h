////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
//  
//  Contributors: Steve Nygard
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
//  TRMSynthesizer.h
//  GnuSpeech
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.9.1
//
////////////////////////////////////////////////////////////////////////////////

#import <Foundation/NSObject.h>
#import <Foundation/NSData.h>
#import <Tube/TubeModel.h>

@class AVAudioPlayer;
@class MMSynthesisParameters;

@interface TRMSynthesizer : NSObject
{
    TRMDataList *inputData;

    BOOL shouldSaveToSoundFile;
    NSString *filename;
    AVAudioPlayer *m_audioPlayer;
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
- (NSData *)generateWAVDataWithSampleRateConverter:(TRMSampleRateConverter *)sampleRateConverter;

- (AVAudioPlayer *)audioPlayer;
- (void)setAudioPlayer:(AVAudioPlayer *)audioPlayer;

- (void)startPlaying:(TRMTubeModel *)tube;

- (void)stopPlaying;

@end

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
//  MMPostureRewriter.h
//  GnuSpeech
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.9.1
//
////////////////////////////////////////////////////////////////////////////////

#import <Foundation/NSObject.h>

@class EventList, MModel, MMPosture;

@interface MMPostureRewriter : NSObject
{
    MModel *model;

    NSString *categoryNames[15];
    MMPosture *returnPostures[7];

    int currentState;
    MMPosture *lastPosture;
}

- (id)initWithModel:(MModel *)aModel;
- (void)dealloc;

- (void)_setupCategoryNames;
- (void)_setup;

- (MModel *)model;
- (void)setModel:(MModel *)newModel;

- (MMPosture *)lastPosture;
- (void)setLastPosture:(MMPosture *)newPosture;

- (void)resetState;
- (void)rewriteEventList:(EventList *)eventList withNextPosture:(MMPosture *)nextPosture wordMarker:(BOOL)followsWordMarker;

@end

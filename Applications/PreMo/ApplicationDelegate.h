////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
//  
//  Contributors: Steve Nygard, Dalmazio Brisinda
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
//  ApplicationDelegate.h
//  PreMo
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.9.1
//
////////////////////////////////////////////////////////////////////////////////

#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h>

@class NSNotification;
@class GSPronunciationDictionary;
@class NSTextView;
@class NSButton;
@class NSTextField;
@class MMTextToPhone;

@interface ApplicationDelegate : NSObject
{
    IBOutlet NSTextView *inputTextView;
    IBOutlet NSButton *copyPhoneStringCheckBox;
    IBOutlet NSTextView *outputTextView;

    IBOutlet NSTextField *dictionaryVersionTextField;
    IBOutlet NSTextField *wordTextField;
    IBOutlet NSTextField *pronunciationTextField;

    GSPronunciationDictionary *dictionary;
	MMTextToPhone *textToPhone;
}

+ (void)initialize;

- (id)init;
- (void)dealloc;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;

- (IBAction)parseText:(id)sender;
- (IBAction)lookupPronunication:(id)sender;

@end

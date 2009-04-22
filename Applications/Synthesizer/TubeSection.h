////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
//  
//  Contributors: David Hill
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
//  TubeSection.h
//  Synthesizer
//
//  Created by David Hill on 12/19/05.
//
//  Version: 0.7.3
//
////////////////////////////////////////////////////////////////////////////////

#import <Cocoa/Cocoa.h>
#import "Controller.h"

#define MAX_SECT_DIAM 4.0
#define MIN_SECT_DIAM 0.1


@interface TubeSection : NSView {
	
	IBOutlet NSTextField *radius;
	IBOutlet NSTextField *diameter;
	IBOutlet NSTextField *area;

	// I probably need a notification in here so I can get the observer
	// to use the newSlider method to get the slider value and id + ID
	//IBOutlet Controller *myController;
	NSRect slide;
	NSPoint temp;
	BOOL status; // State = 0 for setting value; state = 1 for field change input
	@public float slideHeight;

	
}


- (void)mouseDragged:(NSEvent *)event;
- (void)controlTextDidEndEditing:(NSNotification *) aNotification;
- (void)setValue:(float)value;
- (float)getValue;
- (void)setSection:(double)value:(int)tag:(BOOL)state;
- (void)sectionChanged:(float)value;




@end

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
//  VelumSlider.h
//  Synthesizer
//
//  Created by David Hill in 2006.
//
//  Version: 0.7.4
//
////////////////////////////////////////////////////////////////////////////////

#import <Cocoa/Cocoa.h>
#import "Controller.h"

#define VMAX_SECT_DIAM 3
#define VMIN_SECT_DIAM 0

@interface VelumSlider : NSView
{
	IBOutlet NSTextField *radius;
	IBOutlet NSTextField *diameter;
	IBOutlet NSTextField *area;
	NSRect slide;
	NSPoint temp;
	@public float slideWidth;
	
}

- (void)mouseDragged:(NSEvent *)event;
- (void)setSection:(float)value:(int)tag;
- (void)sectionChanged:(float)value;
- (void)setValue:(float)value;

@end

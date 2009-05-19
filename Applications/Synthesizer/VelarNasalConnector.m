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
//  VelarNasalConnector.m
//  Synthesizer
//
//  Created by David Hill in 2006.
//
//  Version: 0.7.4
//
////////////////////////////////////////////////////////////////////////////////

#import "VelarNasalConnector.h"

@implementation VelarNasalConnector

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		// Add initialization code here
	}
	return self;
}

- (void)drawRect:(NSRect)rect
{
	NSBezierPath *line = [NSBezierPath bezierPath];
	NSRect bounds = [self bounds];
	[[[NSColor lightGrayColor] colorWithAlphaComponent:0.0] set];
	[NSBezierPath fillRect:bounds];
	[[NSColor blackColor] set];
	// Draw connector round edge of view
	NSPoint start = NSMakePoint(bounds.origin.x, bounds.origin.y);
	NSPoint middle = NSMakePoint(bounds.origin.x, bounds.size.height);
	NSPoint end = NSMakePoint(bounds.size.width, bounds.size.height);
	[line setLineWidth:5];
	[line moveToPoint:start];
	[line lineToPoint:middle];
	[line lineToPoint:end];
	[line stroke];
	
}

@end

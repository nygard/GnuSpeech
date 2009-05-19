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
//  FricativeArrow.m
//  Synthesizer
//
//  Created by David Hill in 2006.
//
//  Version: 0.7.4
//
////////////////////////////////////////////////////////////////////////////////

#import "FricativeArrow.h"


// Width of the down arrow indicating fricationPosition
#define TOP_ARROW 15
// Position of the oral tube to velum connection
#define VELUM_CENTER 74
// Number of steps from lips (1) to glottis (11) is 7
#define POS_UNITS 8
// Fudge factor for value of fricationPosition
// Both this & previous may need changing when mating to the actual synthesiser
#define CORR 1.014903 // **** 



@implementation FricativeArrow

NSRect fricationView;
BOOL begin;

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		// Add initialization code here
		NSLog(@"success");
	}
	return self;
}

- (void)awakeFromNib
{
	begin=YES;
}

- (void)drawRect:(NSRect)rect

{
	NSBezierPath *line = [NSBezierPath bezierPath];
	downArrow = [NSBezierPath bezierPath];
	NSRect bounds = [self bounds];
	fricationView = bounds;
	if (begin == YES) {
		fricationPosition = (fricationView.origin.x + fricationView.size.width - TOP_ARROW/2);
		//NSLog(@"fricationPosition is %f", fricationPosition);
		scale = (fricationView.size.width - TOP_ARROW)/(POS_UNITS - 1);
	}
	begin = NO;
	[[[NSColor lightGrayColor] colorWithAlphaComponent:0.0] set];
	[NSBezierPath fillRect:bounds];
	[[NSColor blackColor] set];
	// Set the line connection oral tube to velum center
	NSPoint start = NSMakePoint(bounds.origin.x + VELUM_CENTER, bounds.origin.y);
	NSPoint end = NSMakePoint(bounds.origin.x + VELUM_CENTER, bounds.origin.y + bounds.size.height);
	[line setLineWidth:2.5];
	[line moveToPoint:start];
	[line lineToPoint:end];
	[line stroke];
	// Set the arrow tip of down arrow for fricationPosition
	[downArrow moveToPoint:NSMakePoint(fricationPosition,
			fricationView.origin.y)];
	// Set the arrow top left corner
	[downArrow lineToPoint:NSMakePoint((fricationPosition - TOP_ARROW/2),
			(fricationView.origin.y + fricationView.size.height/2))];
	// Set the arrow top right corner
	[downArrow lineToPoint:NSMakePoint((fricationPosition + TOP_ARROW/2),
			(fricationView.origin.y + fricationView.size.height/2))];
	[downArrow closePath];
	[downArrow setLineWidth:2.0];
	[downArrow setLineCapStyle:NSButtLineCapStyle];
	//[downArrow setLineJointStyle:NSRoundLineJointStyle];
	[downArrow stroke];
	[downArrow fill];
		
}

- (void)setFricationPosition:(float)aValue
{
	//NSLog(@"aValue scale are %f %f", aValue, scale);
	fricationPosition = (aValue * scale + TOP_ARROW/2 + CORR);
	//NSLog(@"fricationPosition is %f", fricationPosition);
	[self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)event
{
	//fricationView.origin = [self convertPoint:temp toView:nil];
	NSPoint mouseloc = [self convertPoint:[event locationInWindow] fromView:nil];
	fricationPosition = mouseloc.x;
	//NSLog(@"mouseloc.x is %f", mouseloc.x);
	if (fricationPosition > (fricationView.origin.x + fricationView.size.width - TOP_ARROW/2)) {
		fricationPosition = (fricationView.size.width - TOP_ARROW/2);
	}
	else {
		if (fricationPosition < fricationView.origin.x + TOP_ARROW/2) {
			fricationPosition = TOP_ARROW/2;
			}
		}
	
	fricationValue = ((float)POS_UNITS -1.0 - (fricationPosition - (float)TOP_ARROW/2)/scale + CORR);
	[self setFricationPosition:(8.0 - fricationValue)];
	
	//NSLog(@"fricValue is %f", fricationValue);

	
	NSNotificationCenter *nc;
	nc = [NSNotificationCenter defaultCenter];
	//NSLog(@" Sending notification re slider from FricativeArrow");
	[nc postNotificationName:@"FricArrowMoved" object:self];
	
	[self setNeedsDisplay:YES];
	
}

- (float)floatValue
{
	return (POS_UNITS - fricationValue);
}



@end

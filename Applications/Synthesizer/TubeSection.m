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
//  TubeSection.m
//  Synthesizer
//
//  Created by David Hill on 12/19/05.
//
//  Version: 0.7.4
//
////////////////////////////////////////////////////////////////////////////////

#import "TubeSection.h"
// #import "ResonantSystem.h" **** 

@implementation TubeSection

@class Event, NSTextField, Controller;

NSRect slide, section;
int maxSectionDiam = 147; // This depends on the size in the IB window
float  rad, diam, lumen, sectionParameter;
extern float PI;

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		// Add initialization code here
		
	}
	return self;
}

- (void)drawRect:(NSRect)rect
{
	NSRect bounds = [self bounds];
	section = bounds;
	section.size.height = maxSectionDiam;
	section.origin.y = bounds.origin.y + (bounds.size.height - section.size.height)/2;
	slide = section;
	[[[NSColor greenColor] colorWithAlphaComponent:0.2] set];
	[NSBezierPath fillRect:section];
	slide.size.height = slideHeight;
	//NSLog(@"Slide height is %f", slideHeight);
	slide.origin.y = bounds.origin.y + (bounds.size.height - slideHeight)/2;
	[[NSColor greenColor] set];
	[NSBezierPath fillRect:slide];

}

- (void)awakeFromNib
{
	
	[radius setFloatingPointFormat:(BOOL)NO left:(unsigned)2 right:(unsigned)2];
	[diameter setFloatingPointFormat:(BOOL)NO left:(unsigned)2 right:(unsigned)2];
	[area setFloatingPointFormat:(BOOL)NO left:(unsigned)2 right:(unsigned)2];

	
	rad = 0.25;
	diam = rad * 2;
	lumen = rad * rad * PI;
	[radius setFloatValue:rad];
	[diameter setFloatValue:diam];
	[area setFloatValue:lumen];
	slideHeight = diam * maxSectionDiam/MAX_REAL_DIAMETER;
	[self setNeedsDisplay:YES];
	
	
}

- (void)mouseDragged:(NSEvent *)event
{
	//slide.origin = [self convertPoint:temp toView:nil];
	NSPoint mouseloc = [self convertPoint:[event locationInWindow] fromView:nil];
	if (mouseloc.y > (section.origin.y + section.size.height/2)) {
	slideHeight = (mouseloc.y - (section.origin.y + section.size.height/2))*2;
	}
	else {
			slideHeight =  ((section.origin.y - 1 + section.size.height/2) - mouseloc.y)*2;
		}
	// Keep slide height within range
	if (slideHeight > section.size.height)
		slideHeight = section.size.height;
	if (slideHeight < 0)
		slideHeight = 0;
	diam = (slideHeight * MAX_SECT_DIAM)/section.size.height;
	if (diam < MIN_SECT_DIAM) diam = MIN_SECT_DIAM;
	rad = diam/2;
	lumen = rad * rad * 3.1415297;
	[radius setFloatValue:rad];
	[diameter setFloatValue:diam];
	[area setFloatValue:lumen];
	[self setNeedsDisplay:YES];
	[self sectionChanged:rad];
}


- (void)controlTextDidEndEditing:(NSNotification *) aNotification
{
	int tag;
	tag = [[aNotification object] tag];
	NSLog(@" Tag value is %d", tag);
	sectionParameter = [[aNotification object] floatValue];
	[self setSection:(double)sectionParameter:(int)tag:(BOOL) 1]; // Let setSection know that this is an interface driven change

}

- (void)setSection:(double)value:(int)identifier:(BOOL)state
{
	int sectionId, fieldId, tag;
	tag = (int)identifier;
	fieldId = (tag % 10);
	sectionId = (tag - fieldId)/10;
	NSLog(@"In setSection, value, section and field are %f %d %d", value, sectionId, fieldId);

	if ( fieldId == 0 && sectionParameter>=MIN_SECT_DIAM/2 && sectionParameter<=MAX_SECT_DIAM/2) {
		rad = sectionParameter;
	diam = rad * 2;
	lumen = (rad * rad * PI);
	}
	else {
		
		if (fieldId == 1 && sectionParameter>=MIN_SECT_DIAM && sectionParameter<=MAX_SECT_DIAM) {
			diam = sectionParameter;
			rad = diam/2;
			lumen = (rad * rad * PI);		
		}
		else {
			
			if (fieldId == 2 && sectionParameter>=MIN_SECT_DIAM/2 * MIN_SECT_DIAM/2 * PI && sectionParameter<=MAX_SECT_DIAM/2 * MAX_SECT_DIAM/2 * PI) {
				rad = sqrt(sectionParameter/PI);
				diam = rad * 2;
				lumen = sectionParameter;
				NSLog(@"Area is %f", sectionParameter);
			}
		}
	}
	
	[radius setFloatValue:rad];
	[diameter setFloatValue:diam];
	[area setFloatValue:lumen];
	slideHeight = diam * maxSectionDiam/MAX_REAL_DIAMETER;
	NSLog(@"setSection slideHeight is %f", slideHeight);
	[self setNeedsDisplay:YES];
	if (state != 0)
	[self sectionChanged:rad];
	
}

- (void)sectionChanged:(float)value
{

NSNotificationCenter *nc;
NSMutableDictionary *ident;
NSNumber *identifier, *sectionRadius;
nc = [NSNotificationCenter defaultCenter];
//NSLog(@"Sending Notification slider changed");
int temp2 = [diameter tag];
identifier = [NSNumber numberWithInt:((temp2 - temp2 % 10)/10)];
sectionRadius = [NSNumber numberWithFloat:value];
//NSLog(@"identifier is %@", identifier);
ident = [NSMutableDictionary dictionaryWithCapacity:1];
[ident setObject:identifier forKey:@"sliderId"];
[ident setObject:sectionRadius forKey:@"radius"];
[nc postNotificationName:@"SliderMoved" object:self userInfo:ident];

}

- (float)getValue;
{
	return diam;
}

- (void)setValue:(float)value
{
	//NSLog(@" Set slider value %f", value);
	rad = value;
	diam = 2 * value;
	lumen = rad * rad * PI;
	[radius setFloatValue:rad];
	[diameter setFloatValue:diam];
	[area setFloatValue:lumen];
	slideHeight = diam * maxSectionDiam/MAX_REAL_DIAMETER;
	[self setNeedsDisplay:YES];
}

- (BOOL)sendAction
{
	return YES;
}


@end

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
//  VelumSlider.m
//  Synthesizer
//
//  Created by David Hill in 2006.
//
//  Version: 0.7.3
//
////////////////////////////////////////////////////////////////////////////////

#import "VelumSlider.h"

@implementation VelumSlider

@class Event, NSTextField;

NSRect slide, section;
float rad, diam, lumen, foo;
extern float PI;

int maxVelumDiam = 50;


- (id)initWithFrame:(NSRect)frameRect;
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		// Add initialization code here
		
	}
	return self;
}

- (void)drawRect:(NSRect)rect;
{
	NSRect bounds = [self bounds];
	section = bounds;
	section.size.width = maxVelumDiam;
	section.origin.x = bounds.origin.x + (bounds.size.width - section.size.width)/2;
	slide = section;
	[[[NSColor greenColor] colorWithAlphaComponent:0.2] set];
	[NSBezierPath fillRect:section];
	slide.size.width = slideWidth;
	slide.origin.x = bounds.origin.x + (bounds.size.width - slideWidth)/2;
	[[NSColor greenColor] set];
	[NSBezierPath fillRect:slide];
	
}

- (void)awakeFromNib;
{
	rad = 0.0;
	diam = 0;
	lumen = 0;
	[radius setFloatValue:rad];
	[diameter setFloatValue:diam];
	[area setFloatValue:lumen];
	slideWidth = diam * maxVelumDiam;
	[self setNeedsDisplay:YES];
	[radius setFloatingPointFormat:(BOOL)NO left:(unsigned)2 right:(unsigned)2];
	[diameter setFloatingPointFormat:(BOOL)NO left:(unsigned)2 right:(unsigned)2];
	[area setFloatingPointFormat:(BOOL)NO left:(unsigned)2 right:(unsigned)2];
	
	
}

- (void)mouseDragged:(NSEvent *)event;
{
	slide.origin = [self convertPoint:temp toView:nil];
	NSPoint mouseloc = [self convertPoint:[event locationInWindow] fromView:nil];
	if (mouseloc.x > (section.origin.x + section.size.width/2)) {
		slideWidth = (mouseloc.x - (section.origin.x + section.size.width/2))*2;
	}
	else {
		slideWidth =  ((section.origin.x - 1 + section.size.width/2) - mouseloc.x)*2;
	}
	// Keep slide width within range
	if (slideWidth > section.size.width)
		slideWidth = section.size.width;
	if (slideWidth < 0)
		slideWidth = 0;
	diam = (slideWidth * VMAX_SECT_DIAM)/section.size.width;
	rad = diam/2;
	lumen = rad * rad * 3.1415297;
	[radius setFloatValue:rad];
	[diameter setFloatValue:diam];
	[area setFloatValue:lumen];
	[self setNeedsDisplay:YES];
	[self sectionChanged:rad];
	
}

- (void)controlTextDidEndEditing:(NSNotification *)aNotification;
{
	int tag = [[aNotification object] tag];
	NSLog(@" Tag value is %d", tag);
	foo = [[aNotification object] floatValue];
	[self setSection:(float)foo:tag];
}

- (void)setSection:(float)value:(int)identifier;
{
	int sectionId, fieldId, tag;
	tag = (int)identifier;
	fieldId = (tag % 10);
	sectionId = (tag - fieldId)/10;
	NSLog(@" Section and field are %d %d", sectionId, fieldId);
	
	if ( fieldId == 0 && foo>=VMIN_SECT_DIAM/2 && foo<=VMAX_SECT_DIAM/2) {
		rad = foo;
		diam = rad * 2;
		lumen = (rad * rad * PI);
	}
	else {
		
		if (fieldId == 1 && foo>=VMIN_SECT_DIAM && foo<=VMAX_SECT_DIAM) {
			diam = foo;
			rad = diam/2;
			lumen = (rad * rad * PI);		
		}
		else {
			
			if (fieldId == 2 && foo>=VMIN_SECT_DIAM/2 * VMIN_SECT_DIAM/2 * PI && foo<=VMAX_SECT_DIAM/2 * VMAX_SECT_DIAM/2 * PI) {
				rad = sqrt(foo/PI);
				diam = rad * 2;
				lumen = foo;
			}
		}
	}
	
	[radius setFloatValue:rad];
	[diameter setFloatValue:diam];
	[area setFloatValue:lumen];
	slideWidth= diam * maxVelumDiam;
	[self setNeedsDisplay:YES];
	[self sectionChanged:rad];
	
}

- (void)sectionChanged:(float)value;
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

- (void)setValue:(float)value;
{
	//NSLog(@" Set slider value %f", value);
	rad = value;
	diam = 2 * value;
	lumen = rad * rad * PI;
	[radius setFloatValue:rad];
	[diameter setFloatValue:diam];
	[area setFloatValue:lumen];
	slideWidth = diam * maxVelumDiam/MAX_REAL_DIAMETER;
	[self setNeedsDisplay:YES];
}


@end

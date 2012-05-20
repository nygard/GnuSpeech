//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "TubeSection.h"
// #import "ResonantSystem.h" **** 

@implementation TubeSection

@class Event, NSTextField, Controller;

NSRect slide, section;
int maxSectionDiam = 147; // This depends on the size in the IB window
float  rad, diam, lumen, sectionParameter;

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
    // TODO (2012-05-19): Set up number formatters
    //[radius setFloatingPointFormat:(BOOL)NO left:(unsigned)2 right:(unsigned)2];
	//[diameter setFloatingPointFormat:(BOOL)NO left:(unsigned)2 right:(unsigned)2];
	//[area setFloatingPointFormat:(BOOL)NO left:(unsigned)2 right:(unsigned)2];

	
	rad = 0.25;
	diam = rad * 2;
	lumen = rad * rad * M_PI;
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
	lumen = (rad * rad * M_PI);
	}
	else {
		
		if (fieldId == 1 && sectionParameter>=MIN_SECT_DIAM && sectionParameter<=MAX_SECT_DIAM) {
			diam = sectionParameter;
			rad = diam/2;
			lumen = (rad * rad * M_PI);		
		}
		else {
			
			if (fieldId == 2 && sectionParameter>=MIN_SECT_DIAM/2 * MIN_SECT_DIAM/2 * M_PI && sectionParameter<=MAX_SECT_DIAM/2 * MAX_SECT_DIAM/2 * M_PI) {
				rad = sqrt(sectionParameter/M_PI);
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
	lumen = rad * rad * M_PI;
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

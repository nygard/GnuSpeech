//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "VelumSlider.h"

#import "Controller.h"

#define VMAX_SECT_DIAM 3
#define VMIN_SECT_DIAM 0

@class Event, NSTextField;

NSRect slide, section;
float rad, diam, lumen, foo;

int maxVelumDiam = 50;


@implementation VelumSlider
{
	IBOutlet NSTextField *radius;
	IBOutlet NSTextField *diameter;
	IBOutlet NSTextField *area;
	NSRect slide;
	NSPoint temp;
    float slideWidth;
}

- (id)initWithFrame:(NSRect)frameRect;
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
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
    // TODO (2012-05-19): Set up number formatters
	//[radius setFloatingPointFormat:(BOOL)NO left:(unsigned)2 right:(unsigned)2];
	//[diameter setFloatingPointFormat:(BOOL)NO left:(unsigned)2 right:(unsigned)2];
	//[area setFloatingPointFormat:(BOOL)NO left:(unsigned)2 right:(unsigned)2];
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

- (void)setSection:(float)value :(int)identifier;
{
	int sectionId, fieldId, tag;
	tag = (int)identifier;
	fieldId = (tag % 10);
	sectionId = (tag - fieldId)/10;
	NSLog(@" Section and field are %d %d", sectionId, fieldId);
	
	if ( fieldId == 0 && foo>=VMIN_SECT_DIAM/2 && foo<=VMAX_SECT_DIAM/2) {
		rad = foo;
		diam = rad * 2;
		lumen = (rad * rad * M_PI);
	} else {
		if (fieldId == 1 && foo>=VMIN_SECT_DIAM && foo<=VMAX_SECT_DIAM) {
			diam = foo;
			rad = diam/2;
			lumen = (rad * rad * M_PI);		
		} else {
			if (fieldId == 2 && foo>=VMIN_SECT_DIAM/2 * VMIN_SECT_DIAM/2 * M_PI && foo<=VMAX_SECT_DIAM/2 * VMAX_SECT_DIAM/2 * M_PI) {
				rad = sqrt(foo/M_PI);
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
	//NSLog(@"Sending Notification slider changed");
	int temp2 = [diameter tag];
	NSNumber *identifier = [NSNumber numberWithInt:((temp2 - temp2 % 10)/10)];
	NSNumber *sectionRadius = [NSNumber numberWithFloat:value];
	//NSLog(@"identifier is %@", identifier);

	NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
	[userInfo setObject:identifier    forKey:@"sliderId"];
	[userInfo setObject:sectionRadius forKey:@"radius"];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SliderMoved" object:self userInfo:userInfo];
}

- (void)setValue:(float)value;
{
	//NSLog(@" Set slider value %f", value);
	rad = value;
	diam = 2 * value;
	lumen = rad * rad * M_PI;
	[radius setFloatValue:rad];
	[diameter setFloatValue:diam];
	[area setFloatValue:lumen];
	slideWidth = diam * maxVelumDiam / MAX_REAL_DIAMETER;
	[self setNeedsDisplay:YES];
}


@end

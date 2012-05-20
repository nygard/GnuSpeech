//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

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

//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "Crossmix.h"
#import "ChartView.h"
#import "tube.h"
#import "conversion.h"

@implementation Crossmix

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		[self setAxesWithScale:CMX_SCALE_DIVS xScaleOrigin:CMX_SCALE_ORIGIN xScaleSteps:CMX_SCALE_STEPS
				xLabelInterval:CMX_LABEL_INTERVAL yScaleDivs:CMY_SCALE_DIVS yScaleOrigin:CMY_SCALE_ORIGIN
				   yScaleSteps:CMY_SCALE_STEPS yLabelInterval:CMY_LABEL_INTERVAL];
        
        NSNotificationCenter *nc;
        nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(mixOffsetChanged:) // Ditto for the apScale coef display
                   name:@"mixOffsetChanged"
                 object:nil];
        NSLog(@"Added Crossmix as observer for mixOffsetChanged");
	}

    
    
	return self;
}

/******************************************************************************
 *
 *	function:	pulsedGain
 *
 *	purpose:	Returns the gain of the pulsed noise, for a given
 *                       volume (in dB) and crossmix offset (in dB).
 *
 *       arguments:      volume, crossmixOffset
 *
 *	internal
 *	functions:	amplitude
 *
 *	library
 *	functions:	none
 *
 ******************************************************************************/

float pulsedGain(float volume, float crossmixOffset)
{
    //NSLog(@"volume is %f, crossmixOffset is %f", volume, crossmixOffset);
    float gain = amplitude((double)volume) / amplitude((double)crossmixOffset);
    gain = (gain > 1.0) ? 1.0 : gain;
    return (gain);
}

    
- (void)drawGraph;

{
    bounds = [self bounds];
    [self lockFocus];

    /*  CALCULATE NUMBER OF GRAPHING POINTS, COORDINATES, & OPERATORS  */
    width = bounds.size.width  - LEFT_MARGIN - RIGHT_MARGIN;
    float mixOffset = (*((double *) getMixOffset()));
    numberPoints = mixOffset * width/VOLUME_MAX; //(*((int *) getMixOffset())) * width/VOLUME_MAX;
    height = bounds.size.height - TOP_MARGIN - BOTTOM_MARGIN;
    float maxY = (1.0 - pulsedGain(VOLUME_MIN, 54));
    NSPoint graphOrigin = [self graphOrigin];
    NSLog(@"Graph origin is %f, %f", graphOrigin.x, graphOrigin.y);
    //NSLog(@"height is %f, width is %f", height, numberPoints);

    //numberOps = numberPoints + 1;
    //numberCoords = numberOps * 2;
    

    NSBezierPath *bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
    
    
//  CALCULATE PURE NOISE PATH
    NSPoint currentPoint;
    [bezierPath moveToPoint:graphOrigin];
    NSLog(@"mixOffset is %f", *((double *) getMixOffset()));
    

    for (NSUInteger index = 0; index <= numberPoints; index++) //- LEFT_MARGIN - RIGHT_MARGIN); index++)
    {
        currentPoint.x = graphOrigin.x + index; // * numberPoints/numberPoints);
        currentPoint.y = graphOrigin.y + height * ((1.0 - pulsedGain(CMY_VOLUME_MAX * (float) index/height, mixOffset))/maxY); // *((int *) getMixOffset())));
        if (index ==0) [bezierPath moveToPoint:currentPoint];
        else [bezierPath lineToPoint:currentPoint];
    }

    [bezierPath stroke];
    
    
    //  CALCULATE PULSED NOISE PATH
    //NSPoint currentPoint;
    [bezierPath moveToPoint:graphOrigin];
    
    
    for (NSUInteger index = 0; index <= numberPoints; index++) //- LEFT_MARGIN - RIGHT_MARGIN); index++)
    {
        currentPoint.x = graphOrigin.x + index; // * numberPoints/numberPoints);
        currentPoint.y = graphOrigin.y + height * ((pulsedGain(CMY_VOLUME_MAX * (float) index/height, mixOffset))/maxY); // *((int *) getMixOffset())));
        if (index ==0) [bezierPath moveToPoint:currentPoint];
        else [bezierPath lineToPoint:currentPoint];
    }
    
    [bezierPath stroke];
    
    [self unlockFocus];

        //return self;
}

- (void)mixOffsetChanged:(NSNotification *)note;
{
    
	NSLog(@"mixOffset change notification received and being acted on");
    
    [self lockFocus];

    
    [self drawRect:bounds];
    //[self drawGraph];
    [self unlockFocus];
    
}



@end

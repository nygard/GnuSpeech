//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "Bandpass.h"
#import "ChartView.h"
#import "tube.h"
#import "conversion.h"

static float gain(float omega, float alpha, float beta, float gamma);

@implementation Bandpass

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		//[self setAxesWithScale:SCALE_DIVS xScaleOrigin:SCALE_ORIGIN xScaleSteps:SCALE_STEPS
				//xLabelInterval:LABEL_INTERVAL yScaleDivs:SCALE_DIVS yScaleOrigin:SCALE_ORIGIN
				   //yScaleSteps:SCALE_STEPS yLabelInterval:LABEL_INTERVAL];
        
        NSNotificationCenter *nc;
        nc = [NSNotificationCenter defaultCenter];
                     [nc addObserver:self selector:@selector(fricParamChanged:) // Ditto for the apScale coef display
                   name:@"fricParamChanged"
                 object:nil];
        NSLog(@"Added Bandpass as observer for fricParamChanged");
	}

    
    
	return self;
}

/******************************************************************************
 *
 *	function:	gain
 *
 *	purpose:	Returns the gain of the bandpass filter (a value from
 *                       0.0 to 1.0) according to the filter coefficients
 *                       alpha, beta, and gamma, at the frequency omega (which
 *                       varies from 0 to Pi).
 *
 *       arguments:      omega - value from 0 to Pi (Nyquist)
 *                       alpha, beta, gamma - filter coefficients
 *
 *	internal
 *	functions:	none
 *
 *	library
 *	functions:	cos, sin, sqrt
 *
 ******************************************************************************/

float gain(float omega, float alpha, float beta, float gamma)
{
    float a, b, c, d;
    float omega2, alpha2, beta2, gamma2, cosOmega2, sinOmega2;
    
    omega2 = 2.0 * omega;
    alpha2 = 2.0 * alpha;
    beta2 = 2.0 * beta;
    gamma2 = 2.0 * gamma;
    cosOmega2 = cos(omega2);
    sinOmega2 = sin(omega2);
    
    a = alpha2 - alpha2 * cosOmega2;
    b = alpha2 * sinOmega2;
    c = 1.0 - gamma2 * cos(omega) + beta2 * cosOmega2;
    d = gamma2 * sin(omega) - beta2 * sinOmega2;
    
    return( sqrt((a * a) + (b * b)) / sqrt((c * c) + (d * d)) );
}
    
- (void)drawGraph;

{
    float alpha, beta, gamma, theta, thetaDelta, pi2divSampleRate;
    float tanThetaDeltaDiv2, nyquist;
    int nyquistPoint;
    double bandwidth = *((double *) getFricBW());
    NSLog(@"Frication bandwidth is %f", bandwidth);
    double centerFrequency = *((double *) getFricCF());
    NSLog(@"Frication centre frequency is %f", centerFrequency);
    
    bounds = [self bounds];
    [self lockFocus];

    /*  CALCULATE NUMBER OF GRAPHING POINTS, COORDINATES, & OPERATORS  */
    width = bounds.size.width  - LEFT_MARGIN - RIGHT_MARGIN;
    //numberPoints =  //mixOffset * width/VOLUME_MAX; //(*((int *) getMixOffset())) * width/VOLUME_MAX;
    height = bounds.size.height - TOP_MARGIN - BOTTOM_MARGIN;
    //float maxY = (1.0 - pulsedGain(VOLUME_MIN, 54));
    NSPoint graphOrigin = [self graphOrigin];
    NSLog(@"Frication graph origin is %f, %f", graphOrigin.x, graphOrigin.y);
    //NSLog(@"height is %f, width is %f", height, numberPoints);


    NSBezierPath *bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];
    
    /*  CALCULATE FILTER COEFFICIENTS  */
    pi2divSampleRate = PI2 / sampleRate; // i.e. 0.0003142 @ 20,000
    NSLog(@"Sample rate is %d", sampleRate);
    thetaDelta = (float)bandwidth * pi2divSampleRate; // i.e. 0.3142 @ 1000
    theta = (float)centerFrequency * pi2divSampleRate; // i.e. 1.8850 @ 6,000
    tanThetaDeltaDiv2 = tan(thetaDelta/2.0); // i.e. 0.0027
    beta = 0.5 * (1.0 - tanThetaDeltaDiv2) / (1.0 + tanThetaDeltaDiv2); // 0.5 * 0.9973 / 1.0027 = 0.4973
    gamma = (0.5 + beta) * cos(theta); // 0.9973 * 0.9995 = 0.9968
    alpha = (0.5 - beta) / 2.0; // 0.00135
    
    /*  CALCULATE FREQUENCY AND NYQUIST SCALES  */
    frequencyScale = NYQUIST_MAX / width; //(float)numberPoints;
    nyquistScale = frequencyScale * PI;
    
    /*  CALCULATE NYQUIST AND NYQUIST GRAPHING POINT  */
    nyquist = sampleRate / 2.0;
    nyquistPoint = (int)(nyquist / frequencyScale);
    
    
//  CALCULATE FRICATIVE PASS BAND SHAPE AND PLOT
    NSPoint currentPoint;
    [bezierPath moveToPoint:graphOrigin];
    NSLog(@"fricCF is %f", *((double *) getFricCF()));
    NSLog(@"fricBW is %f", *((double *) getFricBW()));


    for (NSUInteger index = 0; index <= nyquistPoint; index++) //- LEFT_MARGIN - RIGHT_MARGIN); index++)
    {
        currentPoint.x = graphOrigin.x + index; // * numberPoints/numberPoints);
        
        currentPoint.y = graphOrigin.y + (height *  gain((float)index *nyquistScale/nyquist, alpha, beta, gamma)); // * nyquistScale)/nyquist
        
        if (index == 0) [bezierPath moveToPoint:currentPoint];
        else [bezierPath lineToPoint:currentPoint];
    }

    [bezierPath stroke];
    [bezierPath release];
    [self unlockFocus];
    
    

}

- (void)fricParamChanged:(NSNotification *)note;
{
    
	NSLog(@"fricCF change notification received and being acted on");
    
    [self lockFocus];

    

    [self drawRect:bounds];
    
    
    [self unlockFocus];
}



@end

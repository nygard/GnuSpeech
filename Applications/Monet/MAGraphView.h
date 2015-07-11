//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Cocoa/Cocoa.h>

@class MMDisplayParameter, EventList;
@protocol MAGraphViewDelegate;

@interface MAGraphView : NSView
@property (nonatomic, strong) MMDisplayParameter *displayParameter;
@property (nonatomic, strong) EventList *eventList;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGFloat selectedXPosition;
@property (nonatomic, assign) NSRange selectedRange;
@property (weak) id <MAGraphViewDelegate> delegate;
@end

@protocol MAGraphViewDelegate
- (void)graphView:(MAGraphView *)graphView didSelectXPosition:(CGFloat)xPosition;
- (void)graphView:(MAGraphView *)graphView didSelectRange:(NSRange)range;
- (void)graphView:(MAGraphView *)graphView trackingTime:(NSNumber *)time value:(NSNumber *)value;
@end


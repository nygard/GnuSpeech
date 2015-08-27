//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Cocoa/Cocoa.h>

@class EventList, MMIntonationPoint;
@class MAIntonationScaleView;

@protocol MAIntonationViewNotification
- (void)intonationViewSelectionDidChange:(NSNotification *)notification;
@end

extern NSString *MAIntonationViewSelectionDidChangeNotification;

@interface MAIntonationView : NSView

- (void)setScaleView:(MAIntonationScaleView *)newScaleView;

- (void)setEventList:(EventList *)newEventList;

@property (nonatomic, assign) CGFloat scale;

- (BOOL)shouldDrawSelection;
- (void)setShouldDrawSelection:(BOOL)newFlag;

- (BOOL)shouldDrawSmoothPoints;
- (void)setShouldDrawSmoothPoints:(BOOL)newFlag;

@property (weak) id delegate;

// Actions
- (IBAction)selectAll:(id)sender;
- (IBAction)delete:(id)sender;

- (MMIntonationPoint *)selectedIntonationPoint;
- (void)selectIntonationPoint:(MMIntonationPoint *)intonationPoint;

@end

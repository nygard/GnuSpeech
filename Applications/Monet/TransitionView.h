//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Cocoa/Cocoa.h>
#import <GnuSpeech/GnuSpeech.h> // For MMFRuleSymbols

@class MonetList, MModel, MMPoint, MMSlope, MMTransition;
@class TransitionView;

@protocol TransitionViewNotifications
- (void)transitionViewSelectionDidChange:(NSNotification *)aNotification;
@end

@protocol TransitionViewDelegate
- (BOOL)transitionView:(TransitionView *)aTransitionView shouldAddPoint:(MMPoint *)aPoint;
@end

extern NSString *TransitionViewSelectionDidChangeNotification;

// TODO (2004-03-22): Make this an NSControl subclass.
@interface TransitionView : NSControl <NSTextDelegate>

- (id)initWithFrame:(NSRect)frameRect;

@property (readonly) NSFont *timesFont;
@property (nonatomic, assign) NSInteger zeroIndex;
@property (nonatomic, assign) NSInteger sectionAmount;
@property (readonly) NSMutableArray *samplePostures;
@property (readonly) NSMutableArray *displayPoints;
@property (readonly) NSMutableArray *displaySlopes;
@property (readonly) NSMutableArray *selectedPoints;
@property (nonatomic, readonly) MMFRuleSymbols *parameters;

@property (nonatomic, retain) MModel *model;

- (void)_updateFromModel;
- (void)updateTransitionType;

@property (nonatomic, assign) double ruleDuration;
@property (nonatomic, assign) double beatLocation;
@property (nonatomic, assign) double mark1;
@property (nonatomic, assign) double mark2;
@property (nonatomic, assign) double mark3;

- (IBAction)takeRuleDurationFrom:(id)sender;
- (IBAction)takeBeatLocationFrom:(id)sender;
- (IBAction)takeMark1From:(id)sender;
- (IBAction)takeMark2From:(id)sender;
- (IBAction)takeMark3From:(id)sender;

@property (assign) BOOL shouldDrawSelection;
@property (assign) BOOL shouldDrawSlopes;

@property (assign) id delegate;

// Drawing
- (void)drawRect:(NSRect)rect;

- (void)clearView;
- (void)drawGrid;
- (void)drawEquations;
- (void)drawPhones;
- (void)drawTransition;
- (void)updateDisplayPoints;
- (void)highlightSelectedPoints;

// Event handling
- (BOOL)acceptsFirstResponder;
- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent;
- (void)mouseDown:(NSEvent *)mouseEvent;
- (void)mouseDragged:(NSEvent *)mouseEvent;
- (void)mouseUp:(NSEvent *)mouseEvent;
- (void)keyDown:(NSEvent *)keyEvent;

// View geometry
- (CGFloat)sectionHeight;
- (NSPoint)graphOrigin;
- (CGFloat)timeScale;
- (NSRect)rectFormedByPoint:(NSPoint)point1 andPoint:(NSPoint)point2;
- (CGFloat)slopeMarkerYPosition;
- (NSRect)slopeMarkerRect;

// Slopes
- (void)drawSlopes;
- (void)_setEditingSlope:(MMSlope *)newSlope;
- (void)editSlope:(MMSlope *)aSlope startTime:(CGFloat)startTime endTime:(CGFloat)endTime;
- (MMSlope *)getSlopeMarkerAtPoint:(NSPoint)aPoint startTime:(CGFloat *)startTime endTime:(CGFloat *)endTime;

// NSTextView delegate method, used for editing slopes
- (void)textDidEndEditing:(NSNotification *)notification;

// Selection
- (MMPoint *)selectedPoint;
- (void)selectGraphPointsBetweenPoint:(NSPoint)point1 andPoint:(NSPoint)point2;
- (void)_selectionDidChange;

// Actions
- (IBAction)deleteBackward:(id)sender;
- (IBAction)groupInSlopeRatio:(id)sender;

// Publicly used API
- (MMTransition *)transition;
- (void)setTransition:(MMTransition *)newTransition;

@end
